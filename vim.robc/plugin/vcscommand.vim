" vim600: set foldmethod=marker:
"
" Vim plugin to assist in working with files under control of various Version
" Control Systems, such as CVS, SVN, SVK, and git.
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
" Provides functions to invoke various source control commands on the current
" file (either the current buffer, or, in the case of an directory buffer, the
" directory and all subdirectories associated with the current buffer).  The
" output of the commands is captured in a new scratch window.
"
" This plugin needs additional extension plugins, each specific to a source
" control system, to function.  Several options include the name of the
" version control system in the option name.  Such options use the placeholder
" text '{VCSType}', which would be replaced in actual usage with 'CVS' or
" 'SVN', for instance.
"
" Command documentation {{{2
"
" VCSAdd           Adds the current file to source control.
"
" VCSAnnotate[!]   Displays the current file with each line annotated with the
"                  version in which it was most recently changed.  If an
"                  argument is given, the argument is used as a revision
"                  number to display.  If not given an argument, it uses the
"                  most recent version of the file on the current branch.
"                  Additionally, if the current buffer is a VCSAnnotate buffer
"                  already, the version number on the current line is used.
"
"                  If '!' is used, the view of the annotated buffer is split
"                  so that the annotation is in a separate window from the
"                  content, and each is highlighted separately.
"
" VCSBlame         Alias for 'VCSAnnotate'.
"
" VCSCommit[!]     Commits changes to the current file to source control.
"
"                  If called with arguments, the arguments are the log message.
"
"                  If '!' is used, an empty log message is committed.
"
"                  If called with no arguments, this is a two-step command.
"                  The first step opens a buffer to accept a log message.
"                  When that buffer is written, it is automatically closed and
"                  the file is committed using the information from that log
"                  message.  The commit can be abandoned if the log message
"                  buffer is deleted or wiped before being written.
"
" VCSDelete        Deletes the current file and removes it from source control.
"
" VCSDiff          With no arguments, this displays the differences between
"                  the current file and its parent version under source
"                  control in a new scratch buffer.
"
"                  With one argument, the diff is performed on the
"                  current file against the specified revision.
"
"                  With two arguments, the diff is performed between the
"                  specified revisions of the current file.
"
"                  This command uses the 'VCSCommand{VCSType}DiffOpt' variable
"                  to specify diff options.  If that variable does not exist,
"                  a plugin-specific default is used.  If you wish to have no
"                  options, then set it to the empty string.
"
" VCSGotoOriginal  Jumps to the source buffer if the current buffer is a VCS
"                  scratch buffer.  If VCSGotoOriginal[!] is used, remove all
"                  VCS scratch buffers associated with the original file.
"
" VCSInfo          Displays extended information about the current file in a
"                  new scratch buffer.
"
" VCSLock          Locks the current file in order to prevent other users from
"                  concurrently modifying it.  The exact semantics of this
"                  command depend on the underlying VCS.
"
" VCSLog           Displays the version history of the current file in a new
"                  scratch buffer.
"
" VCSRemove        Alias for 'VCSDelete'.
"
" VCSRevert        Replaces the modified version of the current file with the
"                  most recent version from the repository.
"
" VCSReview        Displays a particular version of the current file in a new
"                  scratch buffer.  If no argument is given, the most recent
"                  version of the file on the current branch is retrieved.
"
" VCSStatus        Displays versioning information about the current file in a
"                  new scratch buffer.
"
" VCSUnlock        Unlocks the current file in order to allow other users from
"                  concurrently modifying it.  The exact semantics of this
"                  command depend on the underlying VCS.
"
" VCSUpdate        Updates the current file with any relevant changes from the
"                  repository.
"
" VCSVimDiff       Uses vimdiff to display differences between versions of the
"                  current file.
"
"                  If no revision is specified, the most recent version of the
"                  file on the current branch is used.  With one argument,
"                  that argument is used as the revision as above.  With two
"                  arguments, the differences between the two revisions is
"                  displayed using vimdiff.
"
"                  With either zero or one argument, the original buffer is
"                  used to perform the vimdiff.  When the scratch buffer is
"                  closed, the original buffer will be returned to normal
"                  mode.
"
"                  Once vimdiff mode is started using the above methods,
"                  additional vimdiff buffers may be added by passing a single
"                  version argument to the command.  There may be up to 4
"                  vimdiff buffers total.
"
"                  Using the 2-argument form of the command resets the vimdiff
"                  to only those 2 versions.  Additionally, invoking the
"                  command on a different file will close the previous vimdiff
"                  buffers.
"
" Mapping documentation: {{{2
"
" By default, a mapping is defined for each command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
" nmap ,ca <Plug>VCSAdd
"
" The default mappings are as follow:
"
"   <Leader>ca VCSAdd
"   <Leader>cn VCSAnnotate
"   <Leader>cN VCSAnnotate!
"   <Leader>cc VCSCommit
"   <Leader>cD VCSDelete
"   <Leader>cd VCSDiff
"   <Leader>cg VCSGotoOriginal
"   <Leader>cG VCSGotoOriginal!
"   <Leader>ci VCSInfo
"   <Leader>cl VCSLog
"   <Leader>cL VCSLock
"   <Leader>cr VCSReview
"   <Leader>cs VCSStatus
"   <Leader>cu VCSUpdate
"   <Leader>cU VCSUnlock
"   <Leader>cv VCSVimDiff
"
" Options documentation: {{{2
"
" Several variables are checked by the script to determine behavior as follow:
"
" VCSCommandCommitOnWrite
"   This variable, if set to a non-zero value, causes the pending commit to
"   take place immediately as soon as the log message buffer is written.  If
"   set to zero, only the VCSCommit mapping will cause the pending commit to
"   occur.  If not set, it defaults to 1.
"
" VCSCommandDeleteOnHide
"   This variable, if set to a non-zero value, causes the temporary VCS result
"   buffers to automatically delete themselves when hidden.
"
" VCSCommand{VCSType}DiffOpt
"   This variable, if set, determines the options passed to the diff command
"   of the underlying VCS.  Each VCS plugin defines a default value.
"
" VCSCommandDiffSplit
"   This variable overrides the VCSCommandSplit variable, but only for buffers
"   created with VCSVimDiff.
"
" VCSCommandDisableAll
"   This variable, if set, prevents the plugin or any extensions from loading
"   at all.  This is useful when a single runtime distribution is used on
"   multiple systems with varying versions.
"
" VCSCommandDisableMappings
"   This variable, if set to a non-zero value, prevents the default command
"   mappings from being set.
"
" VCSCommandDisableExtensionMappings
"   This variable, if set to a non-zero value, prevents the default command
"   mappings from being set for commands specific to an individual VCS.
"
" VCSCommandDisableMenu
"   This variable, if set to a non-zero value, prevents the default command
"   menu from being set.
"
" VCSCommandEdit
"   This variable controls whether to split the current window to display a
"   scratch buffer ('split'), or to display it in the current buffer ('edit').
"   If not set, it defaults to 'split'.
"
" VCSCommandEnableBufferSetup
"   This variable, if set to a non-zero value, activates VCS buffer management
"   mode.  This mode means that the buffer variable 'VCSRevision' is set if
"   the file is VCS-controlled.  This is useful for displaying version
"   information in the status bar.  Additional options may be set by
"   individual VCS plugins.
"
" VCSCommandMappings
"   This variable, if set, overrides the default mappings used for shortcuts.
"   It should be a List of 2-element Lists, each containing a shortcut and
"   function name pair.
"
" VCSCommandMapPrefix
"   This variable, if set, overrides the default mapping prefix ('<Leader>c').
"   This allows customization of the mapping space used by the vcscommand
"   shortcuts.
"
" VCSCommandMenuPriority
"   This variable, if set, overrides the default menu priority '' (empty)
"
" VCSCommandMenuRoot
"   This variable, if set, overrides the default menu root 'Plugin.VCS'
"
" VCSCommandResultBufferNameExtension
"   This variable, if set to a non-blank value, is appended to the name of the
"   VCS command output buffers.  For example, '.vcs'.  Using this option may
"   help avoid problems caused by autocommands dependent on file extension.
"
" VCSCommandResultBufferNameFunction
"   This variable, if set, specifies a custom function for naming VCS command
"   output buffers.  This function will be passed the following arguments:
"
"   command - name of the VCS command being executed (such as 'Log' or
"   'Diff').
"
"   originalBuffer - buffer number of the source file.
"
"   vcsType - type of VCS controlling this file (such as 'CVS' or 'SVN').
"
"   statusText - extra text associated with the VCS action (such as version
"   numbers).
"
" VCSCommandSplit
"   This variable controls the orientation of the various window splits that
"   may occur (such as with VCSVimDiff, when using a VCS command on a VCS
"   command buffer, or when the 'VCSCommandEdit' variable is set to 'split'.
"   If set to 'horizontal', the resulting windows will be on stacked on top of
"   one another.  If set to 'vertical', the resulting windows will be
"   side-by-side.  If not set, it defaults to 'horizontal' for all but
"   VCSVimDiff windows.
"
" VCSCommandVCSTypeOverride
"   This variable allows the VCS type detection to be overridden on a
"   path-by-path basis.  The value of this variable is expected to be a List
"   of Lists.  Each high-level List item is a List containing two elements.
"   The first element is a regular expression that will be matched against the
"   full file name of a given buffer.  If it matches, the second element will
"   be used as the VCS type.
"
" Event documentation {{{2
"   For additional customization, VCSCommand.vim uses User event autocommand
"   hooks.  Each event is in the VCSCommand group, and different patterns
"   match the various hooks.
"
"   For instance, the following could be added to the vimrc to provide a 'q'
"   mapping to quit a VCS scratch buffer:
"
"   augroup VCSCommand
"     au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr>
"   augroup END
"
"   The following hooks are available:
"
"   VCSBufferCreated           This event is fired just after a VCS command
"                              output buffer is created.  It is executed
"                              within the context of the new buffer.
"
"   VCSBufferSetup             This event is fired just after VCS buffer setup
"                              occurs, if enabled.
"
"   VCSPluginInit              This event is fired when the VCSCommand plugin
"                              first loads.
"
"   VCSPluginFinish            This event is fired just after the VCSCommand
"                              plugin loads.
"
"   VCSVimDiffFinish           This event is fired just after the VCSVimDiff
"                              command executes to allow customization of,
"                              for instance, window placement and focus.
"
" Section: Plugin header {{{1

" loaded_VCSCommand is set to 1 when the initialization begins, and 2 when it
" completes.  This allows various actions to only be taken by functions after
" system initialization.

if exists('VCSCommandDisableAll')
	finish
endif

if exists('loaded_VCSCommand')
	finish
endif
let loaded_VCSCommand = 1

if v:version < 700
	echohl WarningMsg|echomsg 'VCSCommand requires at least VIM 7.0'|echohl None
	finish
endif

let s:save_cpo=&cpo
set cpo&vim

" Section: Event group setup {{{1

augroup VCSCommand
augroup END

augroup VCSCommandCommit
augroup END

" Section: Plugin initialization {{{1
silent do VCSCommand User VCSPluginInit

" Section: Constants declaration {{{1

let g:VCSCOMMAND_IDENTIFY_EXACT = 1
let g:VCSCOMMAND_IDENTIFY_INEXACT = -1

" Section: Script variable initialization {{{1

" Hidden functions for use by extensions
let s:VCSCommandUtility = {}

" plugin-specific information:  {vcs -> [script, {command -> function}, {key -> mapping}]}
let s:plugins = {}

" temporary values of overridden configuration variables
let s:optionOverrides = {}

" state flag used to vary behavior of certain automated actions
let s:isEditFileRunning = 0

" Section: Utility functions {{{1

" Function: s:ReportError(mapping) {{{2
" Displays the given error in a consistent faction.  This is intended to be
" invoked from a catch statement.

function! s:ReportError(error)
	echohl WarningMsg|echomsg 'VCSCommand:  ' . a:error|echohl None
endfunction

" Function: s:VCSCommandUtility.system(...) {{{2
" Replacement for system() function.  This version protects the quoting in the
" command line on Windows systems.

function! s:VCSCommandUtility.system(...)
	if (has("win32") || has("win64")) && &sxq !~ '"'
		let save_sxq = &sxq
		set sxq=\"
	endif
	try
		return call('system', a:000)
	finally
		if exists("save_sxq")
			let &sxq = save_sxq
		endif
	endtry
endfunction

" Function: s:VCSCommandUtility.addMenuItem(shortcut, command) {{{2
" Adds the given menu item.

function! s:VCSCommandUtility.addMenuItem(shortcut, command)
	if s:menuEnabled
	    exe 'amenu <silent> '.s:menuPriority.' '.s:menuRoot.'.'.a:shortcut.' '.a:command
	endif
endfunction

" Function: s:ClearMenu() {{{2
" Removes all VCSCommand menu items
function! s:ClearMenu()
	if s:menuEnabled
		execute 'aunmenu' s:menuRoot
	endif
endfunction

" Function: s:CreateMapping(shortcut, expansion, display) {{{2
" Creates the given mapping by prepending the contents of
" 'VCSCommandMapPrefix' (by default '<Leader>c') to the given shortcut and
" mapping it to the given plugin function.  If a mapping exists for the
" specified shortcut + prefix, emit an error but continue.  If a mapping
" exists for the specified function, do nothing.

function! s:CreateMapping(shortcut, expansion, display)
	let lhs = VCSCommandGetOption('VCSCommandMapPrefix', '<Leader>c') . a:shortcut
	if !hasmapto(a:expansion)
		try
			execute 'nmap <silent> <unique>' lhs a:expansion
		catch /^Vim(.*):E227:/
			if(&verbose != 0)
				echohl WarningMsg|echomsg 'VCSCommand:  mapping ''' . lhs . ''' already exists, refusing to overwrite.  The mapping for ' . a:display . ' will not be available.'|echohl None
			endif
		endtry
	endif
endfunction

" Function: s:ExecuteExtensionMapping(mapping) {{{2
" Invokes the appropriate extension mapping depending on the type of the
" current buffer.

function! s:ExecuteExtensionMapping(mapping)
	let buffer = bufnr('%')
	let vcsType = VCSCommandGetVCSType(buffer)
	if !has_key(s:plugins, vcsType)
		throw 'Unknown VCS type:  ' . vcsType
	endif
	if !has_key(s:plugins[vcsType][2], a:mapping)
		throw 'This extended mapping is not defined for ' . vcsType
	endif
	silent execute 'normal' ':' .  s:plugins[vcsType][2][a:mapping] . "\<CR>"
endfunction

" Function: s:ExecuteVCSCommand(command, argList) {{{2
" Calls the indicated plugin-specific VCS command on the current buffer.
" Returns: buffer number of resulting output scratch buffer, or -1 if an error
" occurs.

function! s:ExecuteVCSCommand(command, argList)
	try
		let buffer = bufnr('%')

		let vcsType = VCSCommandGetVCSType(buffer)
		if !has_key(s:plugins, vcsType)
			throw 'Unknown VCS type:  ' . vcsType
		endif

		let originalBuffer = VCSCommandGetOriginalBuffer(buffer)
		let bufferName = bufname(originalBuffer)

		" It is already known that the directory is under VCS control.  No further
		" checks are needed.  Otherwise, perform some basic sanity checks to avoid
		" VCS-specific error messages from confusing things.
		if !isdirectory(bufferName)
			if !filereadable(bufferName)
				throw 'No such file ' . bufferName
			endif
		endif

		let functionMap = s:plugins[vcsType][1]
		if !has_key(functionMap, a:command)
			throw 'Command ''' . a:command . ''' not implemented for ' . vcsType
		endif
		return functionMap[a:command](a:argList)
	catch
		call s:ReportError(v:exception)
		return -1
	endtry
endfunction

" Function: s:GenerateResultBufferName(command, originalBuffer, vcsType, statusText) {{{2
" Default method of generating the name for VCS result buffers.  This can be
" overridden with the VCSResultBufferNameFunction variable.

function! s:GenerateResultBufferName(command, originalBuffer, vcsType, statusText)
	let fileName = bufname(a:originalBuffer)
	let bufferName = a:vcsType . ' ' . a:command
	if strlen(a:statusText) > 0
		let bufferName .= ' ' . a:statusText
	endif
	let bufferName .= ' ' . fileName
	let counter = 0
	let versionedBufferName = bufferName
	while bufexists(versionedBufferName)
		let counter += 1
		let versionedBufferName = bufferName . ' (' . counter . ')'
	endwhile
	return versionedBufferName
endfunction

" Function: s:GenerateResultBufferNameWithExtension(command, originalBuffer, vcsType, statusText) {{{2
" Method of generating the name for VCS result buffers that uses the original
" file name with the VCS type and command appended as extensions.

function! s:GenerateResultBufferNameWithExtension(command, originalBuffer, vcsType, statusText)
	let fileName = bufname(a:originalBuffer)
	let bufferName = a:vcsType . ' ' . a:command
	if strlen(a:statusText) > 0
		let bufferName .= ' ' . a:statusText
	endif
	let bufferName .= ' ' . fileName . VCSCommandGetOption('VCSCommandResultBufferNameExtension', '.vcs')
	let counter = 0
	let versionedBufferName = bufferName
	while bufexists(versionedBufferName)
		let counter += 1
		let versionedBufferName = '(' . counter . ') ' . bufferName
	endwhile
	return versionedBufferName
endfunction

" Function: s:EditFile(command, originalBuffer, statusText) {{{2
" Creates a new buffer of the given name and associates it with the given
" original buffer.

function! s:EditFile(command, originalBuffer, statusText)
	let vcsType = getbufvar(a:originalBuffer, 'VCSCommandVCSType')

	" Protect against useless buffer set-up
	let s:isEditFileRunning += 1
	try
		let editCommand = VCSCommandGetOption('VCSCommandEdit', 'split')
		if editCommand == 'split'
			if VCSCommandGetOption('VCSCommandSplit', 'horizontal') == 'horizontal'
				rightbelow split
			else
				vert rightbelow split
			endif
		endif

		enew

		call s:SetupScratchBuffer(a:command, vcsType, a:originalBuffer, a:statusText)

	finally
		let s:isEditFileRunning -= 1
	endtry
endfunction

" Function: s:SetupScratchBuffer(command, vcsType, originalBuffer, statusText) {{{2
" Creates convenience buffer variables and the name of a vcscommand result
" buffer.

function! s:SetupScratchBuffer(command, vcsType, originalBuffer, statusText)
	let nameExtension = VCSCommandGetOption('VCSCommandResultBufferNameExtension', '')
	if nameExtension == ''
		let nameFunction = VCSCommandGetOption('VCSCommandResultBufferNameFunction', 's:GenerateResultBufferName')
	else
		let nameFunction = VCSCommandGetOption('VCSCommandResultBufferNameFunction', 's:GenerateResultBufferNameWithExtension')
	endif

	let name = call(nameFunction, [a:command, a:originalBuffer, a:vcsType, a:statusText])

	let b:VCSCommandCommand = a:command
	let b:VCSCommandOriginalBuffer = a:originalBuffer
	let b:VCSCommandSourceFile = bufname(a:originalBuffer)
	let b:VCSCommandVCSType = a:vcsType
	if a:statusText != ''
		let b:VCSCommandStatusText = a:statusText
	endif

	setlocal buftype=nofile
	setlocal noswapfile
	let &filetype = tolower(a:vcsType . a:command)

	if VCSCommandGetOption('VCSCommandDeleteOnHide', 0)
		setlocal bufhidden=delete
	endif
	silent noautocmd file `=name`
endfunction

" Function: s:SetupBuffer() {{{2
" Attempts to set the b:VCSCommandBufferInfo variable

function! s:SetupBuffer()
	if (exists('b:VCSCommandBufferSetup') && b:VCSCommandBufferSetup)
		" This buffer is already set up.
		return
	endif

	if !isdirectory(@%) && (strlen(&buftype) > 0 || !filereadable(@%))
		" No special status for special buffers other than directory buffers.
		return
	endif

	if !VCSCommandGetOption('VCSCommandEnableBufferSetup', 0) || s:isEditFileRunning > 0
		unlet! b:VCSCommandBufferSetup
		return
	endif

	try
		let vcsType = VCSCommandGetVCSType(bufnr('%'))
		let b:VCSCommandBufferInfo = s:plugins[vcsType][1].GetBufferInfo()
		silent do VCSCommand User VCSBufferSetup
	catch /No suitable plugin/
		" This is not a VCS-controlled file.
		let b:VCSCommandBufferInfo = []
	endtry

	let b:VCSCommandBufferSetup = 1
endfunction

" Function: s:MarkOrigBufferForSetup(buffer) {{{2
" Resets the buffer setup state of the original buffer for a given VCS scratch
" buffer.
" Returns:  The VCS buffer number in a passthrough mode.

function! s:MarkOrigBufferForSetup(buffer)
	checktime
	if a:buffer > 0
		let origBuffer = VCSCommandGetOriginalBuffer(a:buffer)
		" This should never not work, but I'm paranoid
		if origBuffer != a:buffer
			call setbufvar(origBuffer, 'VCSCommandBufferSetup', 0)
		endif
	endif
	return a:buffer
endfunction

" Function: s:OverrideOption(option, [value]) {{{2
" Provides a temporary override for the given VCS option.  If no value is
" passed, the override is disabled.

function! s:OverrideOption(option, ...)
	if a:0 == 0
		call remove(s:optionOverrides[a:option], -1)
	else
		if !has_key(s:optionOverrides, a:option)
			let s:optionOverrides[a:option] = []
		endif
		call add(s:optionOverrides[a:option], a:1)
	endif
endfunction

" Function: s:WipeoutCommandBuffers() {{{2
" Clears all current VCS output buffers of the specified type for a given source.

function! s:WipeoutCommandBuffers(originalBuffer, VCSCommand)
	let buffer = 1
	while buffer <= bufnr('$')
		if getbufvar(buffer, 'VCSCommandOriginalBuffer') == a:originalBuffer
			if getbufvar(buffer, 'VCSCommandCommand') == a:VCSCommand
				execute 'bw' buffer
			endif
		endif
		let buffer = buffer + 1
	endwhile
endfunction

" Function: s:VimDiffRestore(vimDiffBuff) {{{2
" Checks whether the given buffer is one whose deletion should trigger
" restoration of an original buffer after it was diffed.  If so, it executes
" the appropriate setting command stored with that original buffer.

function! s:VimDiffRestore(vimDiffBuff)
	let s:isEditFileRunning += 1
	try
		if exists('t:vcsCommandVimDiffSourceBuffer')
			if a:vimDiffBuff == t:vcsCommandVimDiffSourceBuffer
				" Original file is being removed.
				unlet! t:vcsCommandVimDiffSourceBuffer
				unlet! t:vcsCommandVimDiffRestoreCmd
				unlet! t:vcsCommandVimDiffScratchList
			else
				let index = index(t:vcsCommandVimDiffScratchList, a:vimDiffBuff)
				if index >= 0
					call remove(t:vcsCommandVimDiffScratchList, index)
					if len(t:vcsCommandVimDiffScratchList) == 0
						if exists('t:vcsCommandVimDiffRestoreCmd')
							" All scratch buffers are gone, reset the original.
							" Only restore if the source buffer is still in Diff mode

							let sourceWinNR = bufwinnr(t:vcsCommandVimDiffSourceBuffer)
							if sourceWinNR != -1
								" The buffer is visible in at least one window
								let currentWinNR = winnr()
								while winbufnr(sourceWinNR) != -1
									if winbufnr(sourceWinNR) == t:vcsCommandVimDiffSourceBuffer
										execute sourceWinNR . 'wincmd w'
										if getwinvar(0, '&diff')
											execute t:vcsCommandVimDiffRestoreCmd
										endif
									endif
									let sourceWinNR = sourceWinNR + 1
								endwhile
								execute currentWinNR . 'wincmd w'
							else
								" The buffer is hidden.  It must be visible in order to set the
								" diff option.
								let currentBufNR = bufnr('')
								execute 'hide buffer' t:vcsCommandVimDiffSourceBuffer
								if getwinvar(0, '&diff')
									execute t:vcsCommandVimDiffRestoreCmd
								endif
								execute 'hide buffer' currentBufNR
							endif

							unlet t:vcsCommandVimDiffRestoreCmd
						endif
						" All buffers are gone.
						unlet t:vcsCommandVimDiffSourceBuffer
						unlet t:vcsCommandVimDiffScratchList
					endif
				endif
			endif
		endif
	finally
		let s:isEditFileRunning -= 1
	endtry
endfunction

" Section: Generic VCS command functions {{{1

" Function: s:VCSAnnotate(...) {{{2
function! s:VCSAnnotate(bang, ...)
	try
		let line = line('.')
		let currentBuffer = bufnr('%')
		let originalBuffer = VCSCommandGetOriginalBuffer(currentBuffer)

		let annotateBuffer = s:ExecuteVCSCommand('Annotate', a:000)
		if annotateBuffer == -1
			return -1
		endif
		if a:bang == '!' && VCSCommandGetOption('VCSCommandDisableSplitAnnotate', 0) == 0
			let vcsType = VCSCommandGetVCSType(annotateBuffer)
			let functionMap = s:plugins[vcsType][1]
			let splitRegex = ''
			if has_key(s:plugins[vcsType][1], 'AnnotateSplitRegex')
				let splitRegex = s:plugins[vcsType][1]['AnnotateSplitRegex']
			endif
			let splitRegex = VCSCommandGetOption('VCSCommand' . vcsType . 'AnnotateSplitRegex', splitRegex)
			if splitRegex == ''
				return annotateBuffer
			endif
			let originalFileType = getbufvar(originalBuffer, '&ft')
			let annotateFileType = getbufvar(annotateBuffer, '&ft')
			execute "normal 0zR\<c-v>G/" . splitRegex . "/e\<cr>d"
			call setbufvar('%', '&filetype', getbufvar(originalBuffer, '&filetype'))
			set scrollbind
			leftabove vert new
			normal 0P
			execute "normal" . col('$') . "\<c-w>|"
			call s:SetupScratchBuffer('annotate', vcsType, originalBuffer, 'header')
			wincmd l
		endif

		if currentBuffer == originalBuffer
			" Starting from the original source buffer, so the
			" current line is relevant.
			if a:0 == 0
				" No argument list means that we're annotating
				" the current version, so jumping to the same
				" line is the expected action.
				execute "normal" line . 'G'
				if has('folding')
					" The execution of the buffer created autocommand
					" re-folds the buffer.  Display the current line
					" unfolded.
					normal zv
				endif
			endif
		endif

		return annotateBuffer
	catch
		call s:ReportError(v:exception)
		return -1
	endtry
endfunction

" Function: s:VCSCommit() {{{2
function! s:VCSCommit(bang, message)
	try
		let vcsType = VCSCommandGetVCSType(bufnr('%'))
		if !has_key(s:plugins, vcsType)
			throw 'Unknown VCS type:  ' . vcsType
		endif

		let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))

		" Handle the commit message being specified.  If a message is supplied, it
		" is used; if bang is supplied, an empty message is used; otherwise, the
		" user is provided a buffer from which to edit the commit message.

		if strlen(a:message) > 0 || a:bang == '!'
			return s:VCSFinishCommit([a:message], originalBuffer)
		endif

		call s:EditFile('commitlog', originalBuffer, '')
		setlocal ft=vcscommit

		" Create a commit mapping.

		nnoremap <silent> <buffer> <Plug>VCSCommit :call <SID>VCSFinishCommitWithBuffer()<CR>

		silent 0put ='VCS: ----------------------------------------------------------------------'
		silent put ='VCS: Please enter log message.  Lines beginning with ''VCS:'' are removed automatically.'
		silent put ='VCS: To finish the commit, Type <leader>cc (or your own <Plug>VCSCommit mapping)'

		if VCSCommandGetOption('VCSCommandCommitOnWrite', 1) == 1
			setlocal buftype=acwrite
			au VCSCommandCommit BufWriteCmd <buffer> call s:VCSFinishCommitWithBuffer()
			silent put ='VCS: or write this buffer'
		endif

		silent put ='VCS: ----------------------------------------------------------------------'
		$
		setlocal nomodified
		silent do VCSCommand User VCSBufferCreated
	catch
		call s:ReportError(v:exception)
		return -1
	endtry
endfunction

" Function: s:VCSFinishCommitWithBuffer() {{{2
" Wrapper for s:VCSFinishCommit which is called only from a commit log buffer
" which removes all lines starting with 'VCS:'.

function! s:VCSFinishCommitWithBuffer()
	setlocal nomodified
	let currentBuffer = bufnr('%')
	let logMessageList = getbufline('%', 1, '$')
	call filter(logMessageList, 'v:val !~ ''^\s*VCS:''')
	let resultBuffer = s:VCSFinishCommit(logMessageList, b:VCSCommandOriginalBuffer)
	if resultBuffer >= 0
		execute 'bw' currentBuffer
	endif
	return resultBuffer
endfunction

" Function: s:VCSFinishCommit(logMessageList, originalBuffer) {{{2
function! s:VCSFinishCommit(logMessageList, originalBuffer)
	let messageFileName = tempname()
	call writefile(a:logMessageList, messageFileName)
	try
		let resultBuffer = s:ExecuteVCSCommand('Commit', [messageFileName])
		if resultBuffer < 0
			return resultBuffer
		endif
		return s:MarkOrigBufferForSetup(resultBuffer)
	finally
		call delete(messageFileName)
	endtry
endfunction

" Function: s:VCSGotoOriginal(bang) {{{2
function! s:VCSGotoOriginal(bang)
	let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
	if originalBuffer > 0
		let origWinNR = bufwinnr(originalBuffer)
		if origWinNR == -1
			execute 'buffer' originalBuffer
		else
			execute origWinNR . 'wincmd w'
		endif
		if a:bang == '!'
			let buffnr = 1
			let buffmaxnr = bufnr('$')
			while buffnr <= buffmaxnr
				if getbufvar(buffnr, 'VCSCommandOriginalBuffer') == originalBuffer
					execute 'bw' buffnr
				endif
				let buffnr = buffnr + 1
			endwhile
		endif
	endif
endfunction

function! s:VCSDiff(...)  "{{{2
	let resultBuffer = s:ExecuteVCSCommand('Diff', a:000)
	if resultBuffer > 0
		let &filetype = 'diff'
	elseif resultBuffer == 0
		echomsg 'No differences found'
	endif
	return resultBuffer
endfunction

function! s:VCSReview(...)  "{{{2
	let resultBuffer = s:ExecuteVCSCommand('Review', a:000)
	if resultBuffer > 0
		let &filetype = getbufvar(b:VCSCommandOriginalBuffer, '&filetype')
	endif
	return resultBuffer
endfunction

" Function: s:VCSVimDiff(...) {{{2
function! s:VCSVimDiff(...)
	try
		let vcsType = VCSCommandGetVCSType(bufnr('%'))
		if !has_key(s:plugins, vcsType)
			throw 'Unknown VCS type:  ' . vcsType
		endif
		let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
		let s:isEditFileRunning = s:isEditFileRunning + 1
		try
			" If there's already a VimDiff'ed window, restore it.
			" There may only be one VCSVimDiff original window at a time.

			if exists('t:vcsCommandVimDiffSourceBuffer') && t:vcsCommandVimDiffSourceBuffer != originalBuffer
				" Clear the existing vimdiff setup by removing the result buffers.
				call s:WipeoutCommandBuffers(t:vcsCommandVimDiffSourceBuffer, 'vimdiff')
			endif

			let orientation = &diffopt =~ 'horizontal' ? 'horizontal' : 'vertical'
			let orientation = VCSCommandGetOption('VCSCommandSplit', orientation)
			let orientation = VCSCommandGetOption('VCSCommandDiffSplit', orientation)

			" Split and diff
			if(a:0 == 2)
				" Reset the vimdiff system, as 2 explicit versions were provided.
				if exists('t:vcsCommandVimDiffSourceBuffer')
					call s:WipeoutCommandBuffers(t:vcsCommandVimDiffSourceBuffer, 'vimdiff')
				endif
				let resultBuffer = s:VCSReview(a:1)
				if resultBuffer < 0
					echomsg 'Can''t open revision ' . a:1
					return resultBuffer
				endif
				let b:VCSCommandCommand = 'vimdiff'
				diffthis
				let t:vcsCommandVimDiffScratchList = [resultBuffer]
				" If no split method is defined, cheat, and set it to vertical.
				try
					call s:OverrideOption('VCSCommandSplit', orientation)
					let resultBuffer = s:VCSReview(a:2)
				finally
					call s:OverrideOption('VCSCommandSplit')
				endtry
				if resultBuffer < 0
					echomsg 'Can''t open revision ' . a:1
					return resultBuffer
				endif
				let b:VCSCommandCommand = 'vimdiff'
				diffthis
				let t:vcsCommandVimDiffScratchList += [resultBuffer]
			else
				" Add new buffer
				call s:OverrideOption('VCSCommandEdit', 'split')
				try
					" Force splitting behavior, otherwise why use vimdiff?
					call s:OverrideOption('VCSCommandSplit', orientation)
					try
						if(a:0 == 0)
							let resultBuffer = s:VCSReview()
						else
							let resultBuffer = s:VCSReview(a:1)
						endif
					finally
						call s:OverrideOption('VCSCommandSplit')
					endtry
				finally
					call s:OverrideOption('VCSCommandEdit')
				endtry
				if resultBuffer < 0
					echomsg 'Can''t open current revision'
					return resultBuffer
				endif
				let b:VCSCommandCommand = 'vimdiff'
				diffthis

				if !exists('t:vcsCommandVimDiffSourceBuffer')
					" New instance of vimdiff.
					let t:vcsCommandVimDiffScratchList = [resultBuffer]

					" This could have been invoked on a VCS result buffer, not the
					" original buffer.
					wincmd W
					execute 'buffer' originalBuffer
					" Store info for later original buffer restore
					let t:vcsCommandVimDiffRestoreCmd =
								\    'call setbufvar('.originalBuffer.', ''&diff'', '.getbufvar(originalBuffer, '&diff').')'
								\ . '|call setbufvar('.originalBuffer.', ''&foldcolumn'', '.getbufvar(originalBuffer, '&foldcolumn').')'
								\ . '|call setbufvar('.originalBuffer.', ''&foldenable'', '.getbufvar(originalBuffer, '&foldenable').')'
								\ . '|call setbufvar('.originalBuffer.', ''&foldmethod'', '''.getbufvar(originalBuffer, '&foldmethod').''')'
								\ . '|call setbufvar('.originalBuffer.', ''&foldlevel'', '''.getbufvar(originalBuffer, '&foldlevel').''')'
								\ . '|call setbufvar('.originalBuffer.', ''&scrollbind'', '.getbufvar(originalBuffer, '&scrollbind').')'
								\ . '|call setbufvar('.originalBuffer.', ''&wrap'', '.getbufvar(originalBuffer, '&wrap').')'
								\ . '|if &foldmethod==''manual''|execute ''normal zE''|endif'
					diffthis
					wincmd w
				else
					" Adding a window to an existing vimdiff
					let t:vcsCommandVimDiffScratchList += [resultBuffer]
				endif
			endif

			let t:vcsCommandVimDiffSourceBuffer = originalBuffer

			" Avoid executing the modeline in the current buffer after the autocommand.

			let currentBuffer = bufnr('%')
			let saveModeline = getbufvar(currentBuffer, '&modeline')
			try
				call setbufvar(currentBuffer, '&modeline', 0)
				silent do VCSCommand User VCSVimDiffFinish
			finally
				call setbufvar(currentBuffer, '&modeline', saveModeline)
			endtry
			return resultBuffer
		finally
			let s:isEditFileRunning = s:isEditFileRunning - 1
		endtry
	catch
		call s:ReportError(v:exception)
		return -1
	endtry
endfunction

" Section: Public functions {{{1

" Function: VCSCommandGetVCSType() {{{2
" Sets the b:VCSCommandVCSType variable in the given buffer to the
" appropriate source control system name.
"
" This uses the Identify extension function to test the buffer.  If the
" Identify function returns VCSCOMMAND_IDENTIFY_EXACT, the match is considered
" exact.  If the Identify function returns VCSCOMMAND_IDENTIFY_INEXACT, the
" match is considered inexact, and is only applied if no exact match is found.
" Multiple inexact matches is currently considered an error.

function! VCSCommandGetVCSType(buffer)
	let vcsType = getbufvar(a:buffer, 'VCSCommandVCSType')
	if strlen(vcsType) > 0
		return vcsType
	endif
	if exists("g:VCSCommandVCSTypeOverride")
		let fullpath = fnamemodify(bufname(a:buffer), ':p')
		for [path, vcsType] in g:VCSCommandVCSTypeOverride
			if match(fullpath, path) > -1
				call setbufvar(a:buffer, 'VCSCommandVCSType', vcsType)
				return vcsType
			endif
		endfor
	endif
	let matches = []
	for vcsType in keys(s:plugins)
		let identified = s:plugins[vcsType][1].Identify(a:buffer)
		if identified
			if identified == g:VCSCOMMAND_IDENTIFY_EXACT
				let matches = [vcsType]
				break
			else
				let matches += [vcsType]
			endif
		endif
	endfor
	if len(matches) == 1
		call setbufvar(a:buffer, 'VCSCommandVCSType', matches[0])
		return matches[0]
	elseif len(matches) == 0
		throw 'No suitable plugin'
	else
		throw 'Too many matching VCS:  ' . join(matches)
	endif
endfunction

" Function: VCSCommandChdir(directory) {{{2
" Changes the current directory, respecting :lcd changes.

function! VCSCommandChdir(directory)
	let command = 'cd'
	if exists("*haslocaldir") && haslocaldir()
		let command = 'lcd'
	endif
	execute command escape(a:directory, ' ')
endfunction

" Function: VCSCommandChangeToCurrentFileDir() {{{2
" Go to the directory in which the given file is located.

function! VCSCommandChangeToCurrentFileDir(fileName)
	let oldCwd = getcwd()
	let newCwd = fnamemodify(resolve(a:fileName), ':p:h')
	if strlen(newCwd) > 0
		call VCSCommandChdir(newCwd)
	endif
	return oldCwd
endfunction

" Function: VCSCommandGetOriginalBuffer(vcsBuffer) {{{2
" Attempts to locate the original file to which VCS operations were applied
" for a given buffer.

function! VCSCommandGetOriginalBuffer(vcsBuffer)
	let origBuffer = getbufvar(a:vcsBuffer, 'VCSCommandOriginalBuffer')
	if origBuffer
		if bufexists(origBuffer)
			return origBuffer
		else
			" Original buffer no longer exists.
			throw 'Original buffer for this VCS buffer no longer exists.'
		endif
	else
		" No original buffer
		return a:vcsBuffer
	endif
endfunction

" Function: VCSCommandRegisterModule(name, file, commandMap) {{{2
" Allows VCS modules to register themselves.

function! VCSCommandRegisterModule(name, path, commandMap, mappingMap)
	let s:plugins[a:name] = [a:path, a:commandMap, a:mappingMap]
	if !empty(a:mappingMap)
				\ && !VCSCommandGetOption('VCSCommandDisableMappings', 0)
				\ && !VCSCommandGetOption('VCSCommandDisableExtensionMappings', 0)
		for shortcut in keys(a:mappingMap)
			let expansion = ":call <SID>ExecuteExtensionMapping('" . shortcut . "')<CR>"
			call s:CreateMapping(shortcut, expansion, a:name . " extension mapping " . shortcut)
		endfor
	endif
	return s:VCSCommandUtility
endfunction

" Function: VCSCommandDoCommand(cmd, cmdName, statusText, [options]) {{{2
" General skeleton for VCS function execution.  The given command is executed
" after appending the current buffer name (or substituting it for
" <VCSCOMMANDFILE>, if such a token is present).  The output is captured in a
" new buffer.
"
" The optional 'options' Dictionary may contain the following options:
" 	allowNonZeroExit:  if non-zero, if the underlying VCS command has a
"		non-zero exit status, the command is still considered
"		successfuly.  This defaults to zero.
" Returns: name of the new command buffer containing the command results

function! VCSCommandDoCommand(cmd, cmdName, statusText, options)
	let allowNonZeroExit = 0
	if has_key(a:options, 'allowNonZeroExit')
		let allowNonZeroExit = a:options.allowNonZeroExit
	endif

	let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
	if originalBuffer == -1
		throw 'Original buffer no longer exists, aborting.'
	endif

	let path = resolve(bufname(originalBuffer))

	" Work with netrw or other systems where a directory listing is displayed in
	" a buffer.

	if isdirectory(path)
		let fileName = '.'
	else
		let fileName = fnamemodify(path, ':t')
	endif

	if match(a:cmd, '<VCSCOMMANDFILE>') > 0
		let fullCmd = substitute(a:cmd, '<VCSCOMMANDFILE>', fileName, 'g')
	else
		let fullCmd = a:cmd . ' -- "' . fileName . '"'
	endif

	" Change to the directory of the current buffer.  This is done for CVS, but
	" is left in for other systems as it does not affect them negatively.

	let oldCwd = VCSCommandChangeToCurrentFileDir(path)
	try
		let output = s:VCSCommandUtility.system(fullCmd)
	finally
		call VCSCommandChdir(oldCwd)
	endtry

	" HACK:  if line endings in the repository have been corrupted, the output
	" of the command will be confused.
	let output = substitute(output, "\r", '', 'g')

	if v:shell_error && !allowNonZeroExit
		if strlen(output) == 0
			throw 'Version control command failed'
		else
			let output = substitute(output, '\n', '  ', 'g')
			throw 'Version control command failed:  ' . output
		endif
	endif

	if strlen(output) == 0
		" Handle case of no output.  In this case, it is important to check the
		" file status, especially since cvs edit/unedit may change the attributes
		" of the file with no visible output.

		checktime
		return 0
	endif

	call s:EditFile(a:cmdName, originalBuffer, a:statusText)

	silent 0put=output

	" The last command left a blank line at the end of the buffer.  If the
	" last line is folded (a side effect of the 'put') then the attempt to
	" remove the blank line will kill the last fold.
	"
	" This could be fixed by explicitly detecting whether the last line is
	" within a fold, but I prefer to simply unfold the result buffer altogether.

	if has('folding')
		normal zR
	endif

	$d
	1

	" Define the environment and execute user-defined hooks.

	silent do VCSCommand User VCSBufferCreated
	return bufnr('%')
endfunction

" Function: VCSCommandGetOption(name, default) {{{2
" Grab a user-specified option to override the default provided.  Options are
" searched in the window, buffer, then global spaces.

function! VCSCommandGetOption(name, default)
	if has_key(s:optionOverrides, a:name) && len(s:optionOverrides[a:name]) > 0
		return s:optionOverrides[a:name][-1]
	elseif exists('w:' . a:name)
		return w:{a:name}
	elseif exists('b:' . a:name)
		return b:{a:name}
	elseif exists('g:' . a:name)
		return g:{a:name}
	else
		return a:default
	endif
endfunction

" Function: VCSCommandDisableBufferSetup() {{{2
" Global function for deactivating the buffer autovariables.

function! VCSCommandDisableBufferSetup()
	let g:VCSCommandEnableBufferSetup = 0
	silent! augroup! VCSCommandPlugin
endfunction

" Function: VCSCommandEnableBufferSetup() {{{2
" Global function for activating the buffer autovariables.

function! VCSCommandEnableBufferSetup()
	let g:VCSCommandEnableBufferSetup = 1
	augroup VCSCommandPlugin
		au!
		au BufEnter * call s:SetupBuffer()
	augroup END

	" Only auto-load if the plugin is fully loaded.  This gives other plugins a
	" chance to run.
	if g:loaded_VCSCommand == 2
		call s:SetupBuffer()
	endif
endfunction

" Function: VCSCommandGetStatusLine() {{{2
" Default (sample) status line entry for VCS-controlled files.  This is only
" useful if VCS-managed buffer mode is on (see the VCSCommandEnableBufferSetup
" variable for how to do this).

function! VCSCommandGetStatusLine()
	if exists('b:VCSCommandCommand')
		" This is a result buffer.  Return nothing because the buffer name
		" contains information already.
		return ''
	endif

	if exists('b:VCSCommandVCSType')
				\ && exists('g:VCSCommandEnableBufferSetup')
				\ && g:VCSCommandEnableBufferSetup
				\ && exists('b:VCSCommandBufferInfo')
		return '[' . join(extend([b:VCSCommandVCSType], b:VCSCommandBufferInfo), ' ') . ']'
	else
		return ''
	endif
endfunction

" Section: Command definitions {{{1
" Section: Primary commands {{{2
com! -nargs=* VCSAdd call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Add', [<f-args>]))
com! -nargs=* -bang VCSAnnotate call s:VCSAnnotate(<q-bang>, <f-args>)
com! -nargs=* -bang VCSBlame call s:VCSAnnotate(<q-bang>, <f-args>)
com! -nargs=? -bang VCSCommit call s:VCSCommit(<q-bang>, <q-args>)
com! -nargs=* VCSDelete call s:ExecuteVCSCommand('Delete', [<f-args>])
com! -nargs=* VCSDiff call s:VCSDiff(<f-args>)
com! -nargs=0 -bang VCSGotoOriginal call s:VCSGotoOriginal(<q-bang>)
com! -nargs=* VCSInfo call s:ExecuteVCSCommand('Info', [<f-args>])
com! -nargs=* VCSLock call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Lock', [<f-args>]))
com! -nargs=* VCSLog call s:ExecuteVCSCommand('Log', [<f-args>])
com! -nargs=* VCSRemove call s:ExecuteVCSCommand('Delete', [<f-args>])
com! -nargs=0 VCSRevert call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Revert', []))
com! -nargs=? VCSReview call s:VCSReview(<f-args>)
com! -nargs=* VCSStatus call s:ExecuteVCSCommand('Status', [<f-args>])
com! -nargs=* VCSUnlock call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Unlock', [<f-args>]))
com! -nargs=0 VCSUpdate call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Update', []))
com! -nargs=* VCSVimDiff call s:VCSVimDiff(<f-args>)

" Section: VCS buffer management commands {{{2
com! VCSCommandDisableBufferSetup call VCSCommandDisableBufferSetup()
com! VCSCommandEnableBufferSetup call VCSCommandEnableBufferSetup()

" Allow reloading VCSCommand.vim
com! VCSReload let savedPlugins = s:plugins|let s:plugins = {}|call s:ClearMenu()|unlet! g:loaded_VCSCommand|runtime plugin/vcscommand.vim|for plugin in values(savedPlugins)|execute 'source' plugin[0]|endfor|unlet savedPlugins

" Section: Plugin command mappings {{{1
nnoremap <silent> <Plug>VCSAdd :VCSAdd<CR>
nnoremap <silent> <Plug>VCSAnnotate :VCSAnnotate<CR>
nnoremap <silent> <Plug>VCSCommit :VCSCommit<CR>
nnoremap <silent> <Plug>VCSDelete :VCSDelete<CR>
nnoremap <silent> <Plug>VCSDiff :VCSDiff<CR>
nnoremap <silent> <Plug>VCSGotoOriginal :VCSGotoOriginal<CR>
nnoremap <silent> <Plug>VCSClearAndGotoOriginal :VCSGotoOriginal!<CR>
nnoremap <silent> <Plug>VCSInfo :VCSInfo<CR>
nnoremap <silent> <Plug>VCSLock :VCSLock<CR>
nnoremap <silent> <Plug>VCSLog :VCSLog<CR>
nnoremap <silent> <Plug>VCSRevert :VCSRevert<CR>
nnoremap <silent> <Plug>VCSReview :VCSReview<CR>
nnoremap <silent> <Plug>VCSSplitAnnotate :VCSAnnotate!<CR>
nnoremap <silent> <Plug>VCSStatus :VCSStatus<CR>
nnoremap <silent> <Plug>VCSUnlock :VCSUnlock<CR>
nnoremap <silent> <Plug>VCSUpdate :VCSUpdate<CR>
nnoremap <silent> <Plug>VCSVimDiff :VCSVimDiff<CR>

" Section: Default mappings {{{1

let s:defaultMappings = [
			\['a', 'VCSAdd'],
			\['c', 'VCSCommit'],
			\['D', 'VCSDelete'],
			\['d', 'VCSDiff'],
			\['G', 'VCSClearAndGotoOriginal'],
			\['g', 'VCSGotoOriginal'],
			\['i', 'VCSInfo'],
			\['L', 'VCSLock'],
			\['l', 'VCSLog'],
			\['N', 'VCSSplitAnnotate'],
			\['n', 'VCSAnnotate'],
			\['q', 'VCSRevert'],
			\['r', 'VCSReview'],
			\['s', 'VCSStatus'],
			\['U', 'VCSUnlock'],
			\['u', 'VCSUpdate'],
			\['v', 'VCSVimDiff'],
			\]

if !VCSCommandGetOption('VCSCommandDisableMappings', 0)
	for [s:shortcut, s:vcsFunction] in VCSCommandGetOption('VCSCommandMappings', s:defaultMappings)
		call s:CreateMapping(s:shortcut, '<Plug>' . s:vcsFunction, '''' . s:vcsFunction . '''')
	endfor
	unlet s:shortcut s:vcsFunction
endif
unlet s:defaultMappings

" Section: Menu items {{{1

let s:menuEnabled = !VCSCommandGetOption('VCSCommandDisableMenu', 0)
let s:menuRoot = VCSCommandGetOption('VCSCommandMenuRoot', '&Plugin.VCS')
let s:menuPriority = VCSCommandGetOption('VCSCommandMenuPriority', '')

for [s:shortcut, s:command] in [
			\['&Add', '<Plug>VCSAdd'],
			\['A&nnotate', '<Plug>VCSAnnotate'],
			\['&Commit', '<Plug>VCSCommit'],
			\['Delete', '<Plug>VCSDelete'],
			\['&Diff', '<Plug>VCSDiff'],
			\['&Info', '<Plug>VCSInfo'],
			\['&Log', '<Plug>VCSLog'],
			\['Revert', '<Plug>VCSRevert'],
			\['&Review', '<Plug>VCSReview'],
			\['&Status', '<Plug>VCSStatus'],
			\['&Update', '<Plug>VCSUpdate'],
			\['&VimDiff', '<Plug>VCSVimDiff']
			\]
	call s:VCSCommandUtility.addMenuItem(s:shortcut, s:command)
endfor
unlet s:shortcut s:command

" Section: Autocommands to restore vimdiff state {{{1
augroup VimDiffRestore
	au!
	au BufUnload * call s:VimDiffRestore(str2nr(expand('<abuf>')))
augroup END

" Section: Optional activation of buffer management {{{1

if VCSCommandGetOption('VCSCommandEnableBufferSetup', 0)
	call VCSCommandEnableBufferSetup()
endif

" Section: VIM shutdown hook {{{1

" Close all result buffers when VIM exits, to prevent them from being restored
" via viminfo.

" Function: s:CloseAllResultBuffers() {{{2
" Closes all vcscommand result buffers.
function! s:CloseAllResultBuffers()
	" This avoids using bufdo as that may load buffers already loaded in another
	" vim process, resulting in an error.
	let buffnr = 1
	let buffmaxnr = bufnr('$')
	while buffnr <= buffmaxnr
		if getbufvar(buffnr, 'VCSCommandOriginalBuffer') != ""
			execute 'bw' buffnr
		endif
		let buffnr = buffnr + 1
	endwhile
endfunction

augroup VCSCommandVIMShutdown
	au!
	au VimLeavePre * call s:CloseAllResultBuffers()
augroup END

" Section: Plugin completion {{{1

let loaded_VCSCommand = 2

silent do VCSCommand User VCSPluginFinish

let &cpo = s:save_cpo
