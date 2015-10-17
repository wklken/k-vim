" vim600: set foldmethod=marker:
"
" CVS extension for VCSCommand.
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
" Command documentation {{{2
"
" The following commands only apply to files under CVS source control.
"
" CVSEdit          Performs "cvs edit" on the current file.
"
" CVSEditors       Performs "cvs editors" on the current file.
"
" CVSUnedit        Performs "cvs unedit" on the current file.
"
" CVSWatch         Takes an argument which must be one of [on|off|add|remove].
"                  Performs "cvs watch" with the given argument on the current
"                  file.
"
" CVSWatchers      Performs "cvs watchers" on the current file.
"
" CVSWatchAdd      Alias for "CVSWatch add"
"
" CVSWatchOn       Alias for "CVSWatch on"
"
" CVSWatchOff      Alias for "CVSWatch off"
"
" CVSWatchRemove   Alias for "CVSWatch remove"
"
" Mapping documentation: {{{2
"
" By default, a mapping is defined for each command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
" nnoremap ,ce <Plug>CVSEdit
"
" The default mappings are as follow:
"
"   <Leader>ce CVSEdit
"   <Leader>cE CVSEditors
"   <Leader>ct CVSUnedit
"   <Leader>cwv CVSWatchers
"   <Leader>cwa CVSWatchAdd
"   <Leader>cwn CVSWatchOn
"   <Leader>cwf CVSWatchOff
"   <Leader>cwr CVSWatchRemove
"
" Options documentation: {{{2
"
" VCSCommandCVSExec
"   This variable specifies the CVS executable.  If not set, it defaults to
"   'cvs' executed from the user's executable path.
"
" VCSCommandCVSDiffOpt
"   This variable, if set, determines the options passed to the cvs diff
"   command.  If not set, it defaults to 'u'.

" Section: Plugin header {{{1

if exists('VCSCommandDisableAll')
	finish
endif

if v:version < 700
	echohl WarningMsg|echomsg 'VCSCommand requires at least VIM 7.0'|echohl None
	finish
endif

runtime plugin/vcscommand.vim

if !executable(VCSCommandGetOption('VCSCommandCVSExec', 'cvs'))
	" CVS is not installed
	finish
endif

let s:save_cpo=&cpo
set cpo&vim

" Section: Variable initialization {{{1

let s:cvsFunctions = {}

" Section: Utility functions {{{1

" Function: s:Executable() {{{2
" Returns the executable used to invoke cvs suitable for use in a shell
" command.
function! s:Executable()
	return shellescape(VCSCommandGetOption('VCSCommandCVSExec', 'cvs'))
endfunction

" Function: s:DoCommand(cmd, cmdName, statusText, options) {{{2
" Wrapper to VCSCommandDoCommand to add the name of the CVS executable to the
" command argument.
function! s:DoCommand(cmd, cmdName, statusText, options)
	if VCSCommandGetVCSType(expand('%')) == 'CVS'
		let fullCmd = s:Executable() . ' ' . a:cmd
		let ret = VCSCommandDoCommand(fullCmd, a:cmdName, a:statusText, a:options)

		if ret > 0
			if getline(line('$')) =~ '^cvs \w\+: closing down connection'
				$d
				1
			endif

		endif

		return ret
	else
		throw 'CVS VCSCommand plugin called on non-CVS item.'
	endif
endfunction

" Function: s:GetRevision() {{{2
" Function for retrieving the current buffer's revision number.
" Returns: Revision number or an empty string if an error occurs.

function! s:GetRevision()
	if !exists('b:VCSCommandBufferInfo')
		let b:VCSCommandBufferInfo =  s:cvsFunctions.GetBufferInfo()
	endif

	if len(b:VCSCommandBufferInfo) > 0
		return b:VCSCommandBufferInfo[0]
	else
		return ''
	endif
endfunction

" Section: VCS function implementations {{{1

" Function: s:cvsFunctions.Identify(buffer) {{{2
function! s:cvsFunctions.Identify(buffer)
	let fileName = resolve(bufname(a:buffer))
	if isdirectory(fileName)
		let directoryName = fileName
	else
		let directoryName = fnamemodify(fileName, ':h')
	endif
	if strlen(directoryName) > 0
		let CVSRoot = directoryName . '/CVS/Root'
	else
		let CVSRoot = 'CVS/Root'
	endif
	if filereadable(CVSRoot)
		return 1
	else
		return 0
	endif
endfunction

" Function: s:cvsFunctions.Add(argList) {{{2
function! s:cvsFunctions.Add(argList)
	return s:DoCommand(join(['add'] + a:argList, ' '), 'add', join(a:argList, ' '), {})
endfunction

" Function: s:cvsFunctions.Annotate(argList) {{{2
function! s:cvsFunctions.Annotate(argList)
	if len(a:argList) == 0
		if &filetype == 'CVSannotate'
			" This is a CVSAnnotate buffer.  Perform annotation of the version
			" indicated by the current line.
			let caption = matchstr(getline('.'),'\v^[0-9.]+')

			if VCSCommandGetOption('VCSCommandCVSAnnotateParent', 0) != 0
				if caption != '1.1'
					let revmaj = matchstr(caption,'\v[0-9.]+\ze\.[0-9]+')
					let revmin = matchstr(caption,'\v[0-9.]+\.\zs[0-9]+') - 1
					if revmin == 0
						" Jump to ancestor branch
						let caption = matchstr(revmaj,'\v[0-9.]+\ze\.[0-9]+')
					else
						let caption = revmaj . "." .  revmin
					endif
				endif
			endif

			let options = ['-r' . caption]
		else
			" CVS defaults to pulling HEAD, regardless of current branch.
			" Therefore, always pass desired revision.
			let caption = ''
			let options = ['-r' .  s:GetRevision()]
		endif
	elseif len(a:argList) == 1 && a:argList[0] !~ '^-'
		let caption = a:argList[0]
		let options = ['-r' . caption]
	else
		let caption = join(a:argList)
		let options = a:argList
	endif

	let resultBuffer = s:DoCommand(join(['-q', 'annotate'] + options), 'annotate', caption, {})
	if resultBuffer > 0
		" Remove header lines from standard error
		silent v/^\d\+\%(\.\d\+\)\+/d
	endif
	return resultBuffer
endfunction

" Function: s:cvsFunctions.Commit(argList) {{{2
function! s:cvsFunctions.Commit(argList)
	let resultBuffer = s:DoCommand('commit -F "' . a:argList[0] . '"', 'commit', '', {})
	if resultBuffer == 0
		echomsg 'No commit needed.'
	endif
	return resultBuffer
endfunction

" Function: s:cvsFunctions.Delete() {{{2
" By default, use the -f option to remove the file first.  If options are
" passed in, use those instead.
function! s:cvsFunctions.Delete(argList)
	let options = ['-f']
	let caption = ''
	if len(a:argList) > 0
		let options = a:argList
		let caption = join(a:argList, ' ')
	endif
	return s:DoCommand(join(['remove'] + options, ' '), 'delete', caption, {})
endfunction

" Function: s:cvsFunctions.Diff(argList) {{{2
function! s:cvsFunctions.Diff(argList)
	if len(a:argList) == 0
		let revOptions = []
		let caption = ''
	elseif len(a:argList) <= 2 && match(a:argList, '^-') == -1
		let revOptions = ['-r' . join(a:argList, ' -r')]
		let caption = '(' . a:argList[0] . ' : ' . get(a:argList, 1, 'current') . ')'
	else
		" Pass-through
		let caption = join(a:argList, ' ')
		let revOptions = a:argList
	endif

	let cvsDiffOpt = VCSCommandGetOption('VCSCommandCVSDiffOpt', 'u')
	if cvsDiffOpt == ''
		let diffOptions = []
	else
		let diffOptions = ['-' . cvsDiffOpt]
	endif

	return s:DoCommand(join(['diff'] + diffOptions + revOptions), 'diff', caption, {'allowNonZeroExit': 1})
endfunction

" Function: s:cvsFunctions.GetBufferInfo() {{{2
" Provides version control details for the current file.  Current version
" number and current repository version number are required to be returned by
" the vcscommand plugin.  This CVS extension adds branch name to the return
" list as well.
" Returns: List of results:  [revision, repository, branch]

function! s:cvsFunctions.GetBufferInfo()
	let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
	let fileName = bufname(originalBuffer)
	if isdirectory(fileName)
		let tag = ''
		if filereadable(fileName . '/CVS/Tag')
			let tagFile = readfile(fileName . '/CVS/Tag')
			if len(tagFile) == 1
				let tag = substitute(tagFile[0], '^T', '', '')
			endif
		endif
		return [tag]
	endif
	let realFileName = fnamemodify(resolve(fileName), ':t')
	if !filereadable(fileName)
		return ['Unknown']
	endif
	let oldCwd = VCSCommandChangeToCurrentFileDir(fileName)
	try
		let statusText=s:VCSCommandUtility.system(s:Executable() . ' status -- "' . realFileName . '"')
		if(v:shell_error)
			return []
		endif
		let revision=substitute(statusText, '^\_.*Working revision:\s*\(\d\+\%(\.\d\+\)\+\|New file!\)\_.*$', '\1', '')

		" We can still be in a CVS-controlled directory without this being a CVS
		" file
		if match(revision, '^New file!$') >= 0
			let revision='New'
		elseif match(revision, '^\d\+\.\d\+\%(\.\d\+\.\d\+\)*$') <0
			return ['Unknown']
		endif

		let branch=substitute(statusText, '^\_.*Sticky Tag:\s\+\(\d\+\%(\.\d\+\)\+\|\a[A-Za-z0-9-_]*\|(none)\).*$', '\1', '')
		let repository=substitute(statusText, '^\_.*Repository revision:\s*\(\d\+\%(\.\d\+\)\+\|New file!\|No revision control file\)\_.*$', '\1', '')
		let repository=substitute(repository, '^New file!\|No revision control file$', 'New', '')
		return [revision, repository, branch]
	finally
		call VCSCommandChdir(oldCwd)
	endtry
endfunction

" Function: s:cvsFunctions.Log() {{{2
function! s:cvsFunctions.Log(argList)
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

	return s:DoCommand(join(['log'] + options), 'log', caption, {})
endfunction

" Function: s:cvsFunctions.Revert(argList) {{{2
function! s:cvsFunctions.Revert(argList)
	return s:DoCommand('update -C', 'revert', '', {})
endfunction

" Function: s:cvsFunctions.Review(argList) {{{2
function! s:cvsFunctions.Review(argList)
	if len(a:argList) == 0
		let versiontag = '(current)'
		let versionOption = ''
	else
		let versiontag = a:argList[0]
		let versionOption = ' -r ' . versiontag . ' '
	endif

	return s:DoCommand('-q update -p' . versionOption, 'review', versiontag, {})
endfunction

" Function: s:cvsFunctions.Status(argList) {{{2
function! s:cvsFunctions.Status(argList)
	return s:DoCommand(join(['status'] + a:argList, ' '), 'status', join(a:argList, ' '), {})
endfunction

" Function: s:cvsFunctions.Update(argList) {{{2
function! s:cvsFunctions.Update(argList)
	return s:DoCommand('update', 'update', '', {})
endfunction

" Section: CVS-specific functions {{{1

" Function: s:CVSEdit() {{{2
function! s:CVSEdit()
	return s:DoCommand('edit', 'cvsedit', '', {})
endfunction

" Function: s:CVSEditors() {{{2
function! s:CVSEditors()
	return s:DoCommand('editors', 'cvseditors', '', {})
endfunction

" Function: s:CVSUnedit() {{{2
function! s:CVSUnedit()
	return s:DoCommand('unedit', 'cvsunedit', '', {})
endfunction

" Function: s:CVSWatch(onoff) {{{2
function! s:CVSWatch(onoff)
	if a:onoff !~ '^\c\%(on\|off\|add\|remove\)$'
		echoerr 'Argument to CVSWatch must be one of [on|off|add|remove]'
		return -1
	end
	return s:DoCommand('watch ' . tolower(a:onoff), 'cvswatch', '', {})
endfunction

" Function: s:CVSWatchers() {{{2
function! s:CVSWatchers()
	return s:DoCommand('watchers', 'cvswatchers', '', {})
endfunction

" Annotate setting {{{2
let s:cvsFunctions.AnnotateSplitRegex = '): '

" Section: Command definitions {{{1
" Section: Primary commands {{{2
com! CVSEdit call s:CVSEdit()
com! CVSEditors call s:CVSEditors()
com! CVSUnedit call s:CVSUnedit()
com! -nargs=1 CVSWatch call s:CVSWatch(<f-args>)
com! CVSWatchAdd call s:CVSWatch('add')
com! CVSWatchOn call s:CVSWatch('on')
com! CVSWatchOff call s:CVSWatch('off')
com! CVSWatchRemove call s:CVSWatch('remove')
com! CVSWatchers call s:CVSWatchers()

" Section: Plugin command mappings {{{1

let s:cvsExtensionMappings = {}
let mappingInfo = [
			\['CVSEdit', 'CVSEdit', 'e'],
			\['CVSEditors', 'CVSEditors', 'E'],
			\['CVSUnedit', 'CVSUnedit', 't'],
			\['CVSWatchers', 'CVSWatchers', 'wv'],
			\['CVSWatchAdd', 'CVSWatch add', 'wa'],
			\['CVSWatchOff', 'CVSWatch off', 'wf'],
			\['CVSWatchOn', 'CVSWatch on', 'wn'],
			\['CVSWatchRemove', 'CVSWatch remove', 'wr']
			\]

for [pluginName, commandText, shortCut] in mappingInfo
	execute 'nnoremap <silent> <Plug>' . pluginName . ' :' . commandText . '<CR>'
	if !hasmapto('<Plug>' . pluginName)
		let s:cvsExtensionMappings[shortCut] = commandText
	endif
endfor

" Section: Plugin Registration {{{1
let s:VCSCommandUtility = VCSCommandRegisterModule('CVS', expand('<sfile>'), s:cvsFunctions, s:cvsExtensionMappings)

" Section: Menu items {{{1
for [s:shortcut, s:command] in [
			\['CVS.&Edit', '<Plug>CVSEdit'],
			\['CVS.Ed&itors', '<Plug>CVSEditors'],
			\['CVS.Unedi&t', '<Plug>CVSUnedit'],
			\['CVS.&Watchers', '<Plug>CVSWatchers'],
			\['CVS.WatchAdd', '<Plug>CVSWatchAdd'],
			\['CVS.WatchOn', '<Plug>CVSWatchOn'],
			\['CVS.WatchOff', '<Plug>CVSWatchOff'],
			\['CVS.WatchRemove', '<Plug>CVSWatchRemove']
			\]
	call s:VCSCommandUtility.addMenuItem(s:shortcut, s:command)
endfor
unlet s:shortcut s:command

let &cpo = s:save_cpo
