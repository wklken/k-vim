" vim600: set foldmethod=marker:
"
" Mercurial extension for VCSCommand.
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
" VCSCommandHGExec
"   This variable specifies the mercurial executable.  If not set, it defaults
"   to 'hg' executed from the user's executable path.
"
" VCSCommandHGDiffExt
"   This variable, if set, sets the external diff program used by Subversion.
"
" VCSCommandHGDiffOpt
"   This variable, if set, determines the options passed to the hg diff
"   command (such as 'u', 'w', or 'b').

" Section: Plugin header {{{1

if exists('VCSCommandDisableAll')
	finish
endif

if v:version < 700
	echohl WarningMsg|echomsg 'VCSCommand requires at least VIM 7.0'|echohl None
	finish
endif

runtime plugin/vcscommand.vim

if !executable(VCSCommandGetOption('VCSCommandHGExec', 'hg'))
	" HG is not installed
	finish
endif

let s:save_cpo=&cpo
set cpo&vim

" Section: Variable initialization {{{1

let s:hgFunctions = {}

" Section: Utility functions {{{1

" Function: s:Executable() {{{2
" Returns the executable used to invoke hg suitable for use in a shell
" command.
function! s:Executable()
	return shellescape(VCSCommandGetOption('VCSCommandHGExec', 'hg'))
endfunction

" Function: s:DoCommand(cmd, cmdName, statusText, options) {{{2
" Wrapper to VCSCommandDoCommand to add the name of the HG executable to the
" command argument.
function! s:DoCommand(cmd, cmdName, statusText, options)
	if VCSCommandGetVCSType(expand('%')) == 'HG'
		let fullCmd = s:Executable() . ' ' . a:cmd
		return VCSCommandDoCommand(fullCmd, a:cmdName, a:statusText, a:options)
	else
		throw 'HG VCSCommand plugin called on non-HG item.'
	endif
endfunction

" Section: VCS function implementations {{{1

" Function: s:hgFunctions.Identify(buffer) {{{2
function! s:hgFunctions.Identify(buffer)
	let oldCwd = VCSCommandChangeToCurrentFileDir(resolve(bufname(a:buffer)))
	try
		call s:VCSCommandUtility.system(s:Executable() . ' root')
		if(v:shell_error)
			return 0
		else
			return g:VCSCOMMAND_IDENTIFY_INEXACT
		endif
	finally
		call VCSCommandChdir(oldCwd)
	endtry
endfunction

" Function: s:hgFunctions.Add() {{{2
function! s:hgFunctions.Add(argList)
	return s:DoCommand(join(['add -v'] + a:argList, ' '), 'add', join(a:argList, ' '), {})
endfunction

" Function: s:hgFunctions.Annotate(argList) {{{2
function! s:hgFunctions.Annotate(argList)
	if len(a:argList) == 0
		if &filetype == 'HGannotate'
			" Perform annotation of the version indicated by the current line.
			let caption = matchstr(getline('.'),'\v^\s+\zs\d+')
			let options = ' -r' . caption
		else
			let caption = ''
			let options = ' -un'
		endif
	elseif len(a:argList) == 1 && a:argList[0] !~ '^-'
		let caption = a:argList[0]
		let options = ' -un -r' . caption
	else
		let caption = join(a:argList, ' ')
		let options = ' ' . caption
	endif

	return s:DoCommand('blame' . options, 'annotate', caption, {})
endfunction

" Function: s:hgFunctions.Commit(argList) {{{2
function! s:hgFunctions.Commit(argList)
	try
		return s:DoCommand('commit -v -l "' . a:argList[0] . '"', 'commit', '', {})
	catch /Version control command failed.*nothing changed/
		echomsg 'No commit needed.'
	endtry
endfunction

" Function: s:hgFunctions.Delete() {{{2
function! s:hgFunctions.Delete(argList)
	return s:DoCommand(join(['remove'] + a:argList, ' '), 'remove', join(a:argList, ' '), {})
endfunction

" Function: s:hgFunctions.Diff(argList) {{{2
function! s:hgFunctions.Diff(argList)
	if len(a:argList) == 0
		let revOptions = []
		let caption = ''
	elseif len(a:argList) <= 2 && match(a:argList, '^-') == -1
		let revOptions = ['-r' . join(a:argList, ':')]
		let caption = '(' . a:argList[0] . ' : ' . get(a:argList, 1, 'current') . ')'
	else
		" Pass-through
		let caption = join(a:argList, ' ')
		let revOptions = a:argList
	endif

	let hgDiffExt = VCSCommandGetOption('VCSCommandHGDiffExt', '')
	if hgDiffExt == ''
		let diffExt = []
	else
		let diffExt = ['--diff-cmd ' . hgDiffExt]
	endif

	let hgDiffOpt = VCSCommandGetOption('VCSCommandHGDiffOpt', '')
	if hgDiffOpt == ''
		let diffOptions = []
	else
		let diffOptions = ['-x -' . hgDiffOpt]
	endif

	return s:DoCommand(join(['diff'] + diffExt + diffOptions + revOptions), 'diff', caption, {})
endfunction

" Function: s:hgFunctions.Info(argList) {{{2
function! s:hgFunctions.Info(argList)
	return s:DoCommand(join(['log --limit 1'] + a:argList, ' '), 'log', join(a:argList, ' '), {})
endfunction

" Function: s:hgFunctions.GetBufferInfo() {{{2
" Provides version control details for the current file.  Current version
" number and current repository version number are required to be returned by
" the vcscommand plugin.
" Returns: List of results:  [revision, repository, branch]

function! s:hgFunctions.GetBufferInfo()
	let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
	let fileName = bufname(originalBuffer)
	let statusText = s:VCSCommandUtility.system(s:Executable() . ' status -- "' . fileName . '"')
	if(v:shell_error)
		return []
	endif

	" File not under HG control.
	if statusText =~ '^?'
		return ['Unknown']
	endif

	let parentsText = s:VCSCommandUtility.system(s:Executable() . ' parents -- "' . fileName . '"')
	let revision = matchlist(parentsText, '^changeset:\s\+\(\S\+\)\n')[1]

	let logText = s:VCSCommandUtility.system(s:Executable() . ' log -- "' . fileName . '"')
	let repository = matchlist(logText, '^changeset:\s\+\(\S\+\)\n')[1]

	if revision == ''
		" Error
		return ['Unknown']
	elseif statusText =~ '^A'
		return ['New', 'New']
	else
		return [revision, repository]
	endif
endfunction

" Function: s:hgFunctions.Log(argList) {{{2
function! s:hgFunctions.Log(argList)
	if len(a:argList) == 0
		let options = []
		let caption = ''
	elseif len(a:argList) <= 2 && match(a:argList, '^-') == -1
		let options = ['-r' . join(a:argList, ':')]
		let caption = options[0]
	else
		" Pass-through
		let options = a:argList
		let caption = join(a:argList, ' ')
	endif

	let resultBuffer = s:DoCommand(join(['log', '-v'] + options), 'log', caption, {})
	return resultBuffer
endfunction

" Function: s:hgFunctions.Revert(argList) {{{2
function! s:hgFunctions.Revert(argList)
	return s:DoCommand('revert', 'revert', '', {})
endfunction

" Function: s:hgFunctions.Review(argList) {{{2
function! s:hgFunctions.Review(argList)
	if len(a:argList) == 0
		let versiontag = '(current)'
		let versionOption = ''
	else
		let versiontag = a:argList[0]
		let versionOption = ' -r ' . versiontag . ' '
	endif

	return s:DoCommand('cat' . versionOption, 'review', versiontag, {})
endfunction

" Function: s:hgFunctions.Status(argList) {{{2
function! s:hgFunctions.Status(argList)
	let options = ['-A', '-v']
	if len(a:argList) != 0
		let options = a:argList
	endif
	return s:DoCommand(join(['status'] + options, ' '), 'status', join(options, ' '), {})
endfunction

" Function: s:hgFunctions.Update(argList) {{{2
function! s:hgFunctions.Update(argList)
	return s:DoCommand('update', 'update', '', {})
endfunction

" Annotate setting {{{2
let s:hgFunctions.AnnotateSplitRegex = '\d\+: '

" Section: Plugin Registration {{{1
let s:VCSCommandUtility = VCSCommandRegisterModule('HG', expand('<sfile>'), s:hgFunctions, [])

let &cpo = s:save_cpo
