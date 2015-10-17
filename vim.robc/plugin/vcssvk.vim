" vim600: set foldmethod=marker:
"
" SVK extension for VCSCommand.
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
" VCSCommandSVKExec
"   This variable specifies the SVK executable.  If not set, it defaults to
"   'svk' executed from the user's executable path.

" Section: Plugin header {{{1

if exists('VCSCommandDisableAll')
	finish
endif

if v:version < 700
	echohl WarningMsg|echomsg 'VCSCommand requires at least VIM 7.0'|echohl None
	finish
endif

runtime plugin/vcscommand.vim

if !executable(VCSCommandGetOption('VCSCommandSVKExec', 'svk'))
	" SVK is not installed
	finish
endif

let s:save_cpo=&cpo
set cpo&vim

" Section: Variable initialization {{{1

let s:svkFunctions = {}

" Section: Utility functions {{{1

" Function: s:Executable() {{{2
" Returns the executable used to invoke SVK suitable for use in a shell
" command.
function! s:Executable()
	return shellescape(VCSCommandGetOption('VCSCommandSVKExec', 'svk'))
endfunction

" Function: s:DoCommand(cmd, cmdName, statusText, options) {{{2
" Wrapper to VCSCommandDoCommand to add the name of the SVK executable to the
" command argument.
function! s:DoCommand(cmd, cmdName, statusText, options)
	if VCSCommandGetVCSType(expand('%')) == 'SVK'
		let fullCmd = s:Executable() . ' ' . a:cmd
		return VCSCommandDoCommand(fullCmd, a:cmdName, a:statusText, a:options)
	else
		throw 'SVK VCSCommand plugin called on non-SVK item.'
	endif
endfunction

" Section: VCS function implementations {{{1

" Function: s:svkFunctions.Identify(buffer) {{{2
function! s:svkFunctions.Identify(buffer)
	let fileName = resolve(bufname(a:buffer))
	if isdirectory(fileName)
		let directoryName = fileName
	else
		let directoryName = fnamemodify(fileName, ':p:h')
	endif
	let statusText = s:VCSCommandUtility.system(s:Executable() . ' info -- "' . directoryName . '"', "no")
	if(v:shell_error)
		return 0
	else
		return 1
	endif
endfunction

" Function: s:svkFunctions.Add() {{{2
function! s:svkFunctions.Add(argList)
	return s:DoCommand(join(['add'] + a:argList, ' '), 'add', join(a:argList, ' '), {})
endfunction

" Function: s:svkFunctions.Annotate(argList) {{{2
function! s:svkFunctions.Annotate(argList)
	if len(a:argList) == 0
		if &filetype == 'SVKannotate'
			" Perform annotation of the version indicated by the current line.
			let caption = matchstr(getline('.'),'\v^\s+\zs\d+')
			let options = ' -r' . caption
		else
			let caption = ''
			let options = ''
		endif
	elseif len(a:argList) == 1 && a:argList[0] !~ '^-'
		let caption = a:argList[0]
		let options = ' -r' . caption
	else
		let caption = join(a:argList, ' ')
		let options = ' ' . caption
	endif

	let resultBuffer = s:DoCommand('blame' . options, 'annotate', caption, {})
	if resultBuffer > 0
		normal 1G2dd
	endif
	return resultBuffer
endfunction

" Function: s:svkFunctions.Commit(argList) {{{2
function! s:svkFunctions.Commit(argList)
	let resultBuffer = s:DoCommand('commit -F "' . a:argList[0] . '"', 'commit', '', {})
	if resultBuffer == 0
		echomsg 'No commit needed.'
	endif
endfunction

" Function: s:svkFunctions.Delete() {{{2
function! s:svkFunctions.Delete(argList)
	return s:DoCommand(join(['delete'] + a:argList, ' '), 'delete', join(a:argList, ' '), {})
endfunction

" Function: s:svkFunctions.Diff(argList) {{{2
function! s:svkFunctions.Diff(argList)
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

	return s:DoCommand(join(['diff'] + revOptions), 'diff', caption, {})
endfunction

" Function: s:svkFunctions.GetBufferInfo() {{{2
" Provides version control details for the current file.  Current version
" number and current repository version number are required to be returned by
" the vcscommand plugin.
" Returns: List of results:  [revision, repository]

function! s:svkFunctions.GetBufferInfo()
	let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
	let fileName = resolve(bufname(originalBuffer))
	let statusText = s:VCSCommandUtility.system(s:Executable() . ' status -v -- "' . fileName . '"')
	if(v:shell_error)
		return []
	endif

	" File not under SVK control.
	if statusText =~ '^?'
		return ['Unknown']
	endif

	let [flags, revision, repository] = matchlist(statusText, '^\(.\{3}\)\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\S\+\)\s')[1:3]
	if revision == ''
		" Error
		return ['Unknown']
	elseif flags =~ '^A'
		return ['New', 'New']
	else
		return [revision, repository]
	endif
endfunction

" Function: s:svkFunctions.Info(argList) {{{2
function! s:svkFunctions.Info(argList)
	return s:DoCommand(join(['info'] + a:argList, ' '), 'info', join(a:argList, ' '), {})
endfunction

" Function: s:svkFunctions.Lock(argList) {{{2
function! s:svkFunctions.Lock(argList)
	return s:DoCommand(join(['lock'] + a:argList, ' '), 'lock', join(a:argList, ' '), {})
endfunction

" Function: s:svkFunctions.Log() {{{2
function! s:svkFunctions.Log(argList)
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

" Function: s:svkFunctions.Revert(argList) {{{2
function! s:svkFunctions.Revert(argList)
	return s:DoCommand('revert', 'revert', '', {})
endfunction

" Function: s:svkFunctions.Review(argList) {{{2
function! s:svkFunctions.Review(argList)
	if len(a:argList) == 0
		let versiontag = '(current)'
		let versionOption = ''
	else
		let versiontag = a:argList[0]
		let versionOption = ' -r ' . versiontag . ' '
	endif

	return s:DoCommand('cat' . versionOption, 'review', versiontag, {})
endfunction

" Function: s:svkFunctions.Status(argList) {{{2
function! s:svkFunctions.Status(argList)
	let options = ['-v']
	if len(a:argList) != 0
		let options = a:argList
	endif
	return s:DoCommand(join(['status'] + options, ' '), 'status', join(options, ' '), {})
endfunction

" Function: s:svkFunctions.Unlock(argList) {{{2
function! s:svkFunctions.Unlock(argList)
	return s:DoCommand(join(['unlock'] + a:argList, ' '), 'unlock', join(a:argList, ' '), {})
endfunction
" Function: s:svkFunctions.Update(argList) {{{2
function! s:svkFunctions.Update(argList)
	return s:DoCommand('update', 'update', '', {})
endfunction

" Section: Plugin Registration {{{1
let s:VCSCommandUtility = VCSCommandRegisterModule('SVK', expand('<sfile>'), s:svkFunctions, [])

let &cpo = s:save_cpo
