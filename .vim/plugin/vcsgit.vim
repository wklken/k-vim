" vim600: set foldmethod=marker:
"
" git extension for VCSCommand.
"
" Maintainer:    Bob Hiestand <bob.hiestand@gmail.com>
" License:
" Copyright (c) Bob Hiestand
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.
"
" Section: Documentation {{{1
"
" Options documentation: {{{2
"
" VCSCommandGitExec
"   This variable specifies the git executable.  If not set, it defaults to
"   'git' executed from the user's executable path.
"
" VCSCommandGitDiffOpt
"   This variable, if set, determines the default options passed to the
"   VCSDiff command.  If any options (starting with '-') are passed to the
"   command, this variable is not used.

" Section: Plugin header {{{1

if exists('VCSCommandDisableAll')
	finish
endif

if v:version < 700
	echohl WarningMsg|echomsg 'VCSCommand requires at least VIM 7.0'|echohl None
	finish
endif

runtime plugin/vcscommand.vim

if !executable(VCSCommandGetOption('VCSCommandGitExec', 'git'))
	" git is not installed
	finish
endif

let s:save_cpo=&cpo
set cpo&vim

" Section: Variable initialization {{{1

let s:gitFunctions = {}

" Section: Utility functions {{{1

" Function: s:Executable() {{{2
" Returns the executable used to invoke git suitable for use in a shell
" command.
function! s:Executable()
	return shellescape(VCSCommandGetOption('VCSCommandGitExec', 'git'))
endfunction

" Function: s:DoCommand(cmd, cmdName, statusText, options) {{{2
" Wrapper to VCSCommandDoCommand to add the name of the git executable to the
" command argument.
function! s:DoCommand(cmd, cmdName, statusText, options)
	if VCSCommandGetVCSType(expand('%')) == 'git'
		let fullCmd = s:Executable() . ' ' . a:cmd
		return VCSCommandDoCommand(fullCmd, a:cmdName, a:statusText, a:options)
	else
		throw 'git VCSCommand plugin called on non-git item.'
	endif
endfunction

" Section: VCS function implementations {{{1

" Function: s:gitFunctions.Identify(buffer) {{{2
" This function only returns an inexact match due to the detection method used
" by git, which simply traverses the directory structure upward.
function! s:gitFunctions.Identify(buffer)
	let oldCwd = VCSCommandChangeToCurrentFileDir(resolve(bufname(a:buffer)))
	try
		call s:VCSCommandUtility.system(s:Executable() . ' rev-parse --is-inside-work-tree')
		if(v:shell_error)
			return 0
		else
			return g:VCSCOMMAND_IDENTIFY_INEXACT
		endif
	finally
		call VCSCommandChdir(oldCwd)
	endtry
endfunction

" Function: s:gitFunctions.Add(argList) {{{2
function! s:gitFunctions.Add(argList)
	return s:DoCommand(join(['add'] + ['-v'] + a:argList, ' '), 'add', join(a:argList, ' '), {})
endfunction

" Function: s:gitFunctions.Annotate(argList) {{{2
function! s:gitFunctions.Annotate(argList)
	if len(a:argList) == 0
		if &filetype == 'gitannotate'
			" Perform annotation of the version indicated by the current line.
			let options = matchstr(getline('.'),'^\x\+')
		else
			let options = ''
		endif
	elseif len(a:argList) == 1 && a:argList[0] !~ '^-'
		let options = a:argList[0]
	else
		let options = join(a:argList, ' ')
	endif

	return s:DoCommand('blame ' . options, 'annotate', options, {})
endfunction

" Function: s:gitFunctions.Commit(argList) {{{2
function! s:gitFunctions.Commit(argList)
	try
		return s:DoCommand('commit -F "' . a:argList[0] . '"', 'commit', '', {})
	catch /\m^Version control command failed.*nothing\%( added\)\? to commit/
		echomsg 'No commit needed.'
	endtry
endfunction

" Function: s:gitFunctions.Delete() {{{2
" All options are passed through.
function! s:gitFunctions.Delete(argList)
	let options = a:argList
	let caption = join(a:argList, ' ')
	return s:DoCommand(join(['rm'] + options, ' '), 'delete', caption, {})
endfunction

" Function: s:gitFunctions.Diff(argList) {{{2
" Pass-through call to git-diff.  If no options (starting with '-') are found,
" then the options in the 'VCSCommandGitDiffOpt' variable are added.
function! s:gitFunctions.Diff(argList)
	let gitDiffOpt = VCSCommandGetOption('VCSCommandGitDiffOpt', '')
	if gitDiffOpt == ''
		let diffOptions = []
	else
		let diffOptions = [gitDiffOpt]
		for arg in a:argList
			if arg =~ '^-'
				let diffOptions = []
				break
			endif
		endfor
	endif

	return s:DoCommand(join(['diff'] + diffOptions + a:argList), 'diff', join(a:argList), {})
endfunction

" Function: s:gitFunctions.GetBufferInfo() {{{2
" Provides version control details for the current file.  Current version
" number and current repository version number are required to be returned by
" the vcscommand plugin.  This CVS extension adds branch name to the return
" list as well.
" Returns: List of results:  [revision, repository, branch]

function! s:gitFunctions.GetBufferInfo()
	let oldCwd = VCSCommandChangeToCurrentFileDir(resolve(bufname('%')))
	try
		let branch = substitute(s:VCSCommandUtility.system(s:Executable() . ' symbolic-ref -q HEAD'), '\n$', '', '')
		if v:shell_error
			let branch = 'DETACHED'
		else
			let branch = substitute(branch, '^refs/heads/', '', '')
		endif

		let info = [branch]

		for method in split(VCSCommandGetOption('VCSCommandGitDescribeArgList', (',tags,all,always')), ',', 1)
			if method != ''
				let method = ' --' . method
			endif
			let tag = substitute(s:VCSCommandUtility.system(s:Executable() . ' describe' . method), '\n$', '', '')
			if !v:shell_error
				call add(info, tag)
				break
			endif
		endfor

		return info
	finally
		call VCSCommandChdir(oldCwd)
	endtry
endfunction

" Function: s:gitFunctions.Log() {{{2
function! s:gitFunctions.Log(argList)
	return s:DoCommand(join(['log'] + a:argList), 'log', join(a:argList, ' '), {})
endfunction

" Function: s:gitFunctions.Revert(argList) {{{2
function! s:gitFunctions.Revert(argList)
	return s:DoCommand('checkout', 'revert', '', {})
endfunction

" Function: s:gitFunctions.Review(argList) {{{2
function! s:gitFunctions.Review(argList)
	if len(a:argList) == 0
		let revision = 'HEAD'
	else
		let revision = a:argList[0]
	endif

	let oldCwd = VCSCommandChangeToCurrentFileDir(resolve(bufname(VCSCommandGetOriginalBuffer('%'))))
	try
		let prefix = s:VCSCommandUtility.system(s:Executable() . ' rev-parse --show-prefix')
	finally
		call VCSCommandChdir(oldCwd)
	endtry

	let prefix = substitute(prefix, '\n$', '', '')
	let blob = '"' . revision . ':' . prefix . '<VCSCOMMANDFILE>"'
	return s:DoCommand('show ' . blob, 'review', revision, {})
endfunction

" Function: s:gitFunctions.Status(argList) {{{2
function! s:gitFunctions.Status(argList)
	return s:DoCommand(join(['status'] + a:argList), 'status', join(a:argList), {'allowNonZeroExit': 1})
endfunction

" Function: s:gitFunctions.Update(argList) {{{2
function! s:gitFunctions.Update(argList)
	throw "This command is not implemented for git because file-by-file update doesn't make much sense in that context.  If you have an idea for what it should do, please let me know."
endfunction

" Annotate setting {{{2
let s:gitFunctions.AnnotateSplitRegex = ') '

" Section: Plugin Registration {{{1
let s:VCSCommandUtility = VCSCommandRegisterModule('git', expand('<sfile>'), s:gitFunctions, [])

let &cpo = s:save_cpo
