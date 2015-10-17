
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" File_Name__: srcexpl.vim                                                     "
" Abstract___: A (G)VIM plugin for exploring the source code based on 'tags'   "
"              and 'quickfix'. It works like the context window in 'Source     "
"              Insight'.                                                       "
" Author_____: Wenlong Che <wenlong.che@gmail.com>                             "
" Version____: 4.3                                                             "
" Last_Change: October 6, 2010                                                 "
" Licence____: This program is free software; you can redistribute it and / or "
"              modify it under the terms of the GNU General Public License as  "
"              published by the Free Software Foundation; either version 2, or "
"              any later version.                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NOTE: The graph below shows my work platform with some VIM plugins,          "
"       including 'Source Explorer', 'Taglist' and 'NERD tree'. And I usually  "
"       use a plugin named 'trinity.vim' to manage them.                       "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" +----------------------------------------------------------------------------+
" | File | Edit | Tools | Syntax | Buffers | Window | Help |                   |
" +----------------------------------------------------------------------------+
" |-demo.c-------- |-----------------------------------------|-/home/myprj/----|
" |function        | 1 void foo(void)     /* function 1 */   ||~ src/          |
" |  foo           | 2 {                                     || `-demo.c       |
" |  bar           | 3 }                                     |`-tags           |
" |                | 4 void bar(void)     /* function 2 */   |                 |
" |~ +----------+  | 5 {                                     |~ +-----------+  |
" |~ | Tag List |\ | 6 }                                     |~ | NERD Tree |\ |
" |~ +__________+ ||~        +-----------------+             |~ +___________+ ||
" |~ \___________\||~        | The Main Editor |\            |~ \____________\||
" |~               |~        +_________________+ |           |~                |
" |~               |~        \__________________\|           |~                |
" |~               |~                                        |~                |
" |-__Tag_List__---|-demo.c----------------------------------|-_NERD_tree_-----|
" |Source Explorer V4.3                                                        |
" |~                              +-----------------+                          |
" |~                              | Source Explorer |\                         |
" |~                              +_________________+ |                        |
" |~                              \__________________\|                        |
" |-Source_Explorer[Preview]---------------------------------------------------|
" |:TrinityToggleAll                                                           |
" +----------------------------------------------------------------------------+

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" The_setting_example_in_my_vimrc_file:-)                                      "
"                                                                              "
" // The switch of the Source Explorer                                         "
" nmap <F8> :SrcExplToggle<CR>
"                                                                              "
" // Set the height of Source Explorer window                                  "
" let g:SrcExpl_winHeight = 8
"                                                                              "
" // Set 100 ms for refreshing the Source Explorer                             "
" let g:SrcExpl_refreshTime = 100
"                                                                              "
" // Set "Enter" key to jump into the exact definition context                 "
" let g:SrcExpl_jumpKey = "<ENTER>"
"                                                                              "
" // Set "Space" key for back from the definition context                      "
" let g:SrcExpl_gobackKey = "<SPACE>"
"                                                                              "
" // In order to Avoid conflicts, the Source Explorer should know what plugins "
" // are using buffers. And you need add their bufname into the list below     "
" // according to the command ":buffers!"                                      "
" let g:SrcExpl_pluginList = [
"         \ "__Tag_List__",
"         \ "_NERD_tree_",
"         \ "Source_Explorer"
"     \ ]
"                                                                              "
" // Enable/Disable the local definition searching, and note that this is not  "
" // guaranteed to work, the Source Explorer doesn't check the syntax for now. "
" // It only searches for a match with the keyword according to command 'gd'   "
" let g:SrcExpl_searchLocalDef = 1
"                                                                              "
" // Do not let the Source Explorer update the tags file when opening          "
" let g:SrcExpl_isUpdateTags = 0
"                                                                              "
" // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to "
" //  create/update a tags file                                                "
" let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
"                                                                              "
" // Set "<F12>" key for updating the tags file artificially                   "
" let g:SrcExpl_updateTagsKey = "<F12>"
"                                                                              "
" Just_change_above_of_them_by_yourself:-)                                     "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Avoid reloading {{{

if exists('loaded_srcexpl')
    finish
endif

let loaded_srcexpl = 1
let s:save_cpo = &cpoptions

" }}}

" VIM version control {{{

" The VIM version control for running the Source Explorer

if v:version < 700
    echohl ErrorMsg
        echo "SrcExpl: Require VIM 7.0 or above for running the Source Explorer."
    echohl None
    finish
endif

set cpoptions&vim

" }}}

" User interfaces {{{

" User interface for opening the Source Explorer

command! -nargs=0 -bar SrcExpl
    \ call <SID>SrcExpl()

" User interface for closing the Source Explorer

command! -nargs=0 -bar SrcExplClose
    \ call <SID>SrcExpl_Close()

" User interface for switching the Source Explorer

command! -nargs=0 -bar SrcExplToggle
    \ call <SID>SrcExpl_Toggle()

" User interface for changing the height of the Source Explorer window
if !exists('g:SrcExpl_winHeight')
    let g:SrcExpl_winHeight = 8
endif

" User interface for setting the update time interval for each refreshing
if !exists('g:SrcExpl_refreshTime')
    let g:SrcExpl_refreshTime = 100
endif

" User interface to jump into the exact definition context
if !exists('g:SrcExpl_jumpKey')
    let g:SrcExpl_jumpKey = '<CR>'
endif

" User interface to go back from the definition context
if !exists('g:SrcExpl_gobackKey')
    let g:SrcExpl_gobackKey = '<SPACE>'
endif

" User interface for handling the conflicts between the
" Source Explorer and other plugins
if !exists('g:SrcExpl_pluginList')
    let g:SrcExpl_pluginList = [
            \ "__Tag_List__",
            \ "_NERD_tree_",
            \ "Source_Explorer"
        \ ]
endif

" User interface to enable local declaration searching
" according to command 'gd'
if !exists('g:SrcExpl_searchLocalDef')
    let g:SrcExpl_searchLocalDef = 1
endif

" User interface to control if update the 'tags' file when loading
" the Source Explorer, 0 for false, others for true
if !exists('g:SrcExpl_isUpdateTags')
    let g:SrcExpl_isUpdateTags = 1
endif

" User interface to create a 'tags' file using exact ctags
" utility, 'ctags --sort=foldcase -R .' as default
if !exists('g:SrcExpl_updateTagsCmd')
    let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
endif

" User interface to update tags file artificially
if !exists('g:SrcExpl_updateTagsKey')
    let g:SrcExpl_updateTagsKey = ''
endif

" }}}

" Global variables {{{

" Buffer caption for identifying myself among all the plugins
let s:SrcExpl_pluginCaption = 'Source_Explorer'

" Plugin switch flag
let s:SrcExpl_isRunning = 0

" }}}

" SrcExpl_UpdateTags() {{{

" Update tags file with the 'ctags' utility

function! g:SrcExpl_UpdateTags()

    " Go to the current work directory
    silent! exe "cd " . expand('%:p:h')
    " Get the amount of all files named 'tags'
    let l:tmp = len(tagfiles())

    " No tags file or not found one
    if l:tmp == 0
        " Ask user if or not create a tags file
        echohl Question
            \ | let l:tmp = <SID>SrcExpl_GetInput("\nSrcExpl: "
                \ . "The 'tags' file was not found in your PATH.\n"
            \ . "Create one in the current directory now? (y)es/(n)o?") |
        echohl None
        " They do
        if l:tmp == "y" || l:tmp == "yes"
            " We tell user where we create a tags file
            echohl Question
                echo "SrcExpl: Creating 'tags' file in (". expand('%:p:h') . ")"
            echohl None
            " Call the external 'ctags' utility program
            exe "!" . g:SrcExpl_updateTagsCmd
            " Rejudge the tags file if existed
            if !filereadable("tags")
                " Tell them what happened
                call <SID>SrcExpl_ReportErr("Execute 'ctags' utility program failed")
                return -1
            endif
        " They don't
        else
            echo ""
            return -2
        endif
    " More than one tags file
    elseif l:tmp > 1
        call <SID>SrcExpl_ReportErr("More than one tags file in your PATH")
        return -3
    " Found one successfully
    else
        " Is the tags file in the current directory ?
        if tagfiles()[0] ==# "tags"
            " Prompt the current work directory
            echohl Question
                echo "SrcExpl: Updating 'tags' file in (". expand('%:p:h') . ")"
            echohl None
            " Call the external 'ctags' utility program
            exe "!" . g:SrcExpl_updateTagsCmd
        " Up to other directories
        else
            " Prompt the whole path of the tags file
            echohl Question
                echo "SrcExpl: Updating 'tags' file in (". tagfiles()[0][:-6] . ")"
            echohl None
            " Store the current word directory at first
            let l:tmp = getcwd()
            " Go to the directory that contains the old tags file
            silent! exe "cd " . tagfiles()[0][:-5]
            " Call the external 'ctags' utility program
            exe "!" . g:SrcExpl_updateTagsCmd
           " Go back to the original work directory
           silent! exe "cd " . l:tmp
        endif
    endif

    return 0

endfunction " }}}

" SrcExpl_GoBack() {{{

" Move the cursor to the previous location in the mark history

function! g:SrcExpl_GoBack()

    " If or not the cursor is on the main editor window
    if &previewwindow || <SID>SrcExpl_AdaptPlugins()
        return -1
    endif

    " Just go back to the previous position
    return <SID>SrcExpl_GetMarkList()

endfunction " }}}

" SrcExpl_Jump() {{{

" Jump to the main editor window and point to the definition

function! g:SrcExpl_Jump()

    " Only do the operation on the Source Explorer
    " window is valid
    if !&previewwindow
        return -1
    endif

    " Do we get the definition already?
    if bufname("%") == s:SrcExpl_pluginCaption
        " No such definition
        if s:SrcExpl_status == 0
            return -2
        " Multiple definitions
        elseif s:SrcExpl_status == 2
            " If point to the jump list head, just avoid that
            if line(".") == 1
                return -3
            endif
        endif
    endif

    if g:SrcExpl_searchLocalDef != 0
        " We have already jumped to the main editor window
        let s:SrcExpl_isJumped = 1
    endif
    " Indeed go back to the main editor window
    silent! exe s:SrcExpl_editWin . "wincmd w"
    " Set the mark for recording the current position
    call <SID>SrcExpl_SetMarkList()

    " We got multiple definitions
    if s:SrcExpl_status == 2
        " Select the exact one and jump to its context
        call <SID>SrcExpl_SelToJump()
        " Set the mark for recording the current position
        call <SID>SrcExpl_SetMarkList()
        return 0
    endif

    " Open the buffer using main editor window
    exe "edit " . s:SrcExpl_currMark[0]
    " Jump to the context line of that symbol
    call cursor(s:SrcExpl_currMark[1], s:SrcExpl_currMark[2])
    " Match the symbol of definition
    call <SID>SrcExpl_MatchExpr()
    " Set the mark for recording the current position
    call <SID>SrcExpl_SetMarkList()

    " We got one local definition
    if s:SrcExpl_status == 3
        " Get the cursor line number
        let s:SrcExpl_csrLine = line(".")
        " Try to tag the symbol again
        let l:expr = '\<' . s:SrcExpl_symbol . '\>' . '\C'
        " Try to tag something
        call <SID>SrcExpl_TagSth(l:expr)
    endif

    return 0

endfunction " }}}

" SrcExpl_Refresh() {{{

" Refresh the Source Explorer window and update the status

function! g:SrcExpl_Refresh()

    " Tab page must be invalid
    if s:SrcExpl_tabPage != tabpagenr()
        return -1
    endif

    " If or not the cursor is on the main editor window
    if &previewwindow || <SID>SrcExpl_AdaptPlugins()
        return -2
    endif

    " Avoid errors of multi-buffers
    if &modified
        call <SID>SrcExpl_ReportErr("This modified file is not saved")
        return -3
    endif

    " Get the ID of main editor window
    let s:SrcExpl_editWin = winnr()

    " Get the symbol under the cursor
    if <SID>SrcExpl_GetSymbol()
        return -4
    endif

    let l:expr = '\<' . s:SrcExpl_symbol . '\>' . '\C'

    " Try to Go to local declaration
    if g:SrcExpl_searchLocalDef != 0
        if !<SID>SrcExpl_GoDecl(l:expr)
            return 0
        endif
    endif

    " Try to tag something
    call <SID>SrcExpl_TagSth(l:expr)

    return 0

endfunction " }}}

" SrcExpl_AdaptPlugins() {{{

" The Source Explorer window will not work when the cursor on the

" window of other plugins, such as 'Taglist', 'NERD tree' etc.

function! <SID>SrcExpl_AdaptPlugins()

    " Traversal the list of other plugins
    for item in g:SrcExpl_pluginList
        " If they acted as a split window
        if bufname("%") ==# item
            " Just avoid this operation
            return -1
        endif
    endfor

    " Safe
    return 0

endfunction " }}}

" SrcExpl_ReportErr() {{{

" Output the message when we get an error situation

function! <SID>SrcExpl_ReportErr(err)

    " Highlight the error prompt
    echohl ErrorMsg
        echo "SrcExpl: " . a:err
    echohl None

endfunction " }}}

" SrcExpl_EnterWin() {{{

" Operation when 'WinEnter' event happens

function! <SID>SrcExpl_EnterWin()

    " In the Source Explorer window
    if &previewwindow
        if has("gui_running")
            " Delete the SrcExplGoBack item in Popup menu
            silent! nunmenu 1.01 PopUp.&SrcExplGoBack
        endif
        " Unmap the go-back key
        if maparg(g:SrcExpl_gobackKey, 'n') ==
            \ ":call g:SrcExpl_GoBack()<CR>"
            exe "nunmap " . g:SrcExpl_gobackKey
        endif
        " Do the mapping for 'double-click'
        if maparg('<2-LeftMouse>', 'n') == ''
            nnoremap <silent> <2-LeftMouse>
                \ :call g:SrcExpl_Jump()<CR>
        endif
        " Map the user's key to jump into the exact definition context
        if g:SrcExpl_jumpKey != ""
            exe "nnoremap " . g:SrcExpl_jumpKey .
                \ " :call g:SrcExpl_Jump()<CR>"
        endif
    " In other plugin windows
    elseif <SID>SrcExpl_AdaptPlugins()
        if has("gui_running")
            " Delete the SrcExplGoBack item in Popup menu
            silent! nunmenu 1.01 PopUp.&SrcExplGoBack
        endif
        " Unmap the go-back key
        if maparg(g:SrcExpl_gobackKey, 'n') ==
            \ ":call g:SrcExpl_GoBack()<CR>"
            exe "nunmap " . g:SrcExpl_gobackKey
        endif
        " Unmap the exact mapping of 'double-click'
        if maparg("<2-LeftMouse>", "n") ==
                \ ":call g:SrcExpl_Jump()<CR>"
            nunmap <silent> <2-LeftMouse>
        endif
        " Unmap the jump key
        if maparg(g:SrcExpl_jumpKey, 'n') ==
            \ ":call g:SrcExpl_Jump()<CR>"
            exe "nunmap " . g:SrcExpl_jumpKey
        endif
    " In the main editor window
    else
        if has("gui_running")
            " You can use SrcExplGoBack item in Popup menu
            " to go back from the definition
            silent! nnoremenu 1.01 PopUp.&SrcExplGoBack
                \ :call g:SrcExpl_GoBack()<CR>
        endif
        " Map the user's key to go back from the definition context
        if g:SrcExpl_gobackKey != ""
            exe "nnoremap " . g:SrcExpl_gobackKey .
                \ " :call g:SrcExpl_GoBack()<CR>"
        endif
        " Unmap the exact mapping of 'double-click'
        if maparg("<2-LeftMouse>", "n") ==
                \ ":call g:SrcExpl_Jump()<CR>"
            nunmap <silent> <2-LeftMouse>
        endif
        " Unmap the jump key
        if maparg(g:SrcExpl_jumpKey, 'n') ==
            \ ":call g:SrcExpl_Jump()<CR>"
            exe "nunmap " . g:SrcExpl_jumpKey
        endif
    endif

endfunction " }}}

" SrcExpl_SetMarkList() {{{

" Set a new mark for back to the previous position

function! <SID>SrcExpl_SetMarkList()

    " Add one new mark into the tail of Mark List
    call add(s:SrcExpl_markList, [expand("%:p"), line("."), col(".")])

endfunction " }}}

" SrcExpl_GetMarkList() {{{

" Get the mark for back to the previous position

function! <SID>SrcExpl_GetMarkList()

    " If or not the mark list is empty
    if !len(s:SrcExpl_markList)
        call <SID>SrcExpl_ReportErr("Mark stack is empty")
        return -1
    endif

    " Avoid the same situation
    if get(s:SrcExpl_markList, -1)[0] == expand("%:p")
      \ && get(s:SrcExpl_markList, -1)[1] == line(".")
      \ && get(s:SrcExpl_markList, -1)[2] == col(".")
        " Remove the latest mark
        call remove(s:SrcExpl_markList, -1)
        " Get the latest mark again
        return <SID>SrcExpl_GetMarkList()
    endif

    " Load the buffer content into the main editor window
    exe "edit " . get(s:SrcExpl_markList, -1)[0]
    " Jump to the context position of that symbol
    call cursor(get(s:SrcExpl_markList, -1)[1], get(s:SrcExpl_markList, -1)[2])
    " Remove the latest mark now
    call remove(s:SrcExpl_markList, -1)

    return 0

endfunction " }}}

" SrcExpl_SelToJump() {{{

" Select one of multi-definitions, and jump to there

function! <SID>SrcExpl_SelToJump()

    let l:index = 0
    let l:fpath = ""
    let l:excmd = ""
    let l:expr  = ""

    " If or not in the Source Explorer window
    if !&previewwindow
        silent! wincmd P
    endif

    " Get the item data that the user selected just now
    let l:list = getline(".")
    " Traverse the prompt string until get the file path
    while !((l:list[l:index] == ']') &&
        \ (l:list[l:index + 1] == ':'))
        let l:index += 1
    endwhile
    " Offset
    let l:index += 3

    " Get the whole file path of the exact definition
    while !((l:list[l:index] == ' ') &&
        \ (l:list[l:index + 1] == '['))
        let l:fpath = l:fpath . l:list[l:index]
        let l:index += 1
    endwhile
    " Offset
    let l:index += 2

    " Traverse the prompt string until get the symbol
    while !((l:list[l:index] == ']') &&
        \ (l:list[l:index + 1] == ':'))
        let l:index += 1
    endwhile
    " Offset
    let l:index += 3

    " Get the EX command string
    while l:list[l:index] != ''
        let l:excmd = l:excmd . l:list[l:index]
        let l:index += 1
    endwhile

    " Indeed go back to the main editor window
    silent! exe s:SrcExpl_editWin . "wincmd w"
    " Open the file containing the definition context
    exe "edit " . l:fpath

    " Modify the EX Command to locate the tag exactly
    let l:expr = substitute(l:excmd, '/^', '/^\\C', 'g')
    let l:expr = substitute(l:expr,  '\*',  '\\\*', 'g')
    let l:expr = substitute(l:expr,  '\[',  '\\\[', 'g')
    let l:expr = substitute(l:expr,  '\]',  '\\\]', 'g')
    " Use EX Command to Jump to the exact position of the definition
    silent! exe l:expr

    " Match the symbol
    call <SID>SrcExpl_MatchExpr()

endfunction " }}}

" SrcExpl_SetCurrMark() {{{

" Save the current buf-win file path, line number and column number

function! <SID>SrcExpl_SetCurrMark()

    " Store the curretn position for exploring
    let s:SrcExpl_currMark = [expand("%:p"), line("."), col(".")]

endfunction " }}}

" SrcExpl_ColorExpr() {{{

" Highlight the symbol of definition

function! <SID>SrcExpl_ColorExpr()

    " Set the highlight color
    hi SrcExpl_HighLight term=bold guifg=Black guibg=Magenta ctermfg=Black ctermbg=Magenta
    " Highlight this
    exe 'match SrcExpl_HighLight "\%' . line(".") . 'l\%' .
        \ col(".") . 'c\k*"'

endfunction " }}}

" SrcExpl_MatchExpr() {{{

" Match the symbol of definition

function! <SID>SrcExpl_MatchExpr()

    call search("$", "b")
    let s:SrcExpl_symbol = substitute(s:SrcExpl_symbol,
        \ '\\', '\\\\', '')
    call search('\<' . s:SrcExpl_symbol . '\>' . '\C')

endfunction " }}}

" SrcExpl_PromptNoDef() {{{

" Tell users there is no tag that be found in your PATH

function! <SID>SrcExpl_PromptNoDef()

    " Do the Source Explorer existed already?
    let l:bufnum = bufnr(s:SrcExpl_pluginCaption)
    " Not existed, create a new buffer
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_pluginCaption
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif

    " Reopen the Source Explorer idle window
    exe "silent " . "pedit " . l:wcmd
    " Move to it
    silent! wincmd P
    " Done
    if &previewwindow
        " First make it modifiable
        setlocal modifiable
        " Not show its name on the buffer list
        setlocal nobuflisted
        " No exact file
        setlocal buftype=nofile
        " Report the reason why the Source Explorer
        " can not point to the definition
        " Delete all lines in buffer.
        1,$d _
        " Go to the end of the buffer put the buffer list
        $
        " Display the version of the Source Explorer
        put! ='Definition Not Found'
        " Cancel all the highlighted words
        match none
        " Delete the extra trailing blank line
        $ d _
        " Make it unmodifiable again
        setlocal nomodifiable
        " Go back to the main editor window
        silent! exe s:SrcExpl_editWin . "wincmd w"
    endif

endfunction " }}}

" SrcExpl_ListMultiDefs() {{{

" List multiple definitions into the preview window

function! <SID>SrcExpl_ListMultiDefs(list, len)

    " The Source Explorer existed already ?
    let l:bufnum = bufnr(s:SrcExpl_pluginCaption)
    " Not existed, create a new buffer
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_pluginCaption
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif

    " Is the tags file in the current directory ?
    if tagfiles()[0] ==# "tags"
        " We'll get the operating system environment
        " in order to judge the slash type
        if s:SrcExpl_isWinOS == 1
            " With the backward slash
            let l:path = expand('%:p:h') . '\'
        else
            " With the forward slash
            let l:path = expand('%:p:h') . '/'
        endif
    else
        let l:path = ''
    endif

    " Reopen the Source Explorer idle window
    exe "silent " . "pedit " . l:wcmd
    " Move to it
    silent! wincmd P
    " Done
    if &previewwindow
        " Reset the attribute of the Source Explorer
        setlocal modifiable
        " Not show its name on the buffer list
        setlocal nobuflisted
        " No exact file
        setlocal buftype=nofile
        " Delete all lines in buffer
        1,$d _
        " Get the tags dictionary array
        " Begin build the Jump List for exploring the tags
        put! = '[Jump List]: '. s:SrcExpl_symbol . ' (' . a:len . ') '
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_ColorExpr()
        " Loop key & index
        let l:indx = 0
        " Loop for listing each tag from tags file
        while 1
            " First get each tag list
            let l:dict = get(a:list, l:indx, {})
            " There is one tag
            if l:dict != {}
                " Go to the end of the buffer put the buffer list
                $
                " We should avoid the './' or '.\' in the whole file path
                if l:dict['filename'][0] == '.'
                    put! ='[File Path]: ' . l:path . l:dict['filename'][2:]
                        \ . ' ' . '[EX Command]: ' . l:dict['cmd']
                else
                    " Generated by 'ctags --sort=foldcase -R .'
                    if len(l:path) == 0
                        put! ='[File Path]: ' . l:path . l:dict['filename']
                    	    \ . ' ' . '[EX Command]: ' . l:dict['cmd']
                    " Generated by 'ctags -L cscope.files'
                    else
                        put! ='[File Path]: ' . l:dict['filename']
                    	    \ . ' ' . '[EX Command]: ' . l:dict['cmd']
                    endif
                endif
            " Traversal finished
            else
                break
            endif
            let l:indx += 1
        endwhile
    endif

    " Delete the extra trailing blank line
    $ d _
    " Move the cursor to the top of the Source Explorer window
    exe "normal! " . "gg"
    " Back to the first line
    setlocal nomodifiable
    " Go back to the main editor window
    silent! exe s:SrcExpl_editWin . "wincmd w"

endfunction " }}}

" SrcExpl_ViewOneDef() {{{

" Display the definition of the symbol into the preview window

function! <SID>SrcExpl_ViewOneDef(fpath, excmd)

    let l:expr = ""

    " The tags file is in the current directory and it
    " should be generated by 'ctags --sort=foldcase -R .'
    if tagfiles()[0] ==# "tags" && a:fpath[0] == '.'
        exe "silent " . "pedit " . expand('%:p:h') . '/' . a:fpath
    " Up to other directories
    else
        exe "silent " . "pedit " . a:fpath
    endif

    " Go to the Source Explorer window
    silent! wincmd P
    " Indeed back to the preview window
    if &previewwindow
        " Modify the EX Command to locate the tag exactly
        let l:expr = substitute(a:excmd, '/^', '/^\\C', 'g')
        let l:expr = substitute(l:expr,  '\*',  '\\\*', 'g')
        let l:expr = substitute(l:expr,  '\[',  '\\\[', 'g')
        let l:expr = substitute(l:expr,  '\]',  '\\\]', 'g')
        " Execute EX command according to the parameter
        silent! exe l:expr
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_ColorExpr()
        " Set the current buf-win attribute
        call <SID>SrcExpl_SetCurrMark()
        " Refresh all the screen
        redraw
        " Go back to the main editor window
        silent! exe s:SrcExpl_editWin . "wincmd w"
    endif

endfunction " }}}

" SrcExpl_TagSth() {{{

" Just try to find the tag under the cursor

function! <SID>SrcExpl_TagSth(expr)

    let l:len = -1

    " Is the symbol valid ?
    if a:expr != '\<\>\C'
        " We get the tag list of the expression
        let l:list = taglist(a:expr)
        " Then get the length of taglist
        let l:len = len(l:list)
    endif

    " One tag
    if l:len == 1
        " Get dictionary to load tag's file path and ex command
        let l:dict = get(l:list, 0, {})
        call <SID>SrcExpl_ViewOneDef(l:dict['filename'], l:dict['cmd'])
        " One definition
        let s:SrcExpl_status = 1
    " Multiple tags
    elseif l:len > 1
        call <SID>SrcExpl_ListMultiDefs(l:list, l:len)
        " Multiple definitions
        let s:SrcExpl_status = 2
    " No tag
    else
        " Ignore the repetitious situation
        if s:SrcExpl_status > 0
            call <SID>SrcExpl_PromptNoDef()
            " No definition
            let s:SrcExpl_status = 0
        endif
    endif

endfunction " }}}

" SrcExpl_GoDecl() {{{

" Search the local declaration using 'gd' command

function! <SID>SrcExpl_GoDecl(expr)

    " Get the original cursor position
    let l:oldline = line(".")
    let l:oldcol = col(".")

    " Try to search the local declaration
    if searchdecl(a:expr, 0, 1) != 0
        " Search failed
        return -1
    endif

    " Get the new cursor position
    let l:newline = line(".")
    let l:newcol = col(".")
    " Go back to the original cursor position
    call cursor(l:oldline, l:oldcol)

    " Preview the context
    exe "silent " . "pedit " . expand("%:p")
    " Go to the Preview window
    silent! wincmd P
    " Indeed in the Preview window
    if &previewwindow
        " Go to the new cursor position
        call cursor(l:newline, l:newcol)
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_ColorExpr()
        " Set the current buf-win attribute
        call <SID>SrcExpl_SetCurrMark()
        " Refresh all the screen
        redraw
        " Go back to the main editor window
        silent! exe s:SrcExpl_editWin . "wincmd w"
        " We got a local definition
        let s:SrcExpl_status = 3
    endif

    return 0

endfunction " }}}

" SrcExpl_GetSymbol() {{{

" Get the valid symbol under the current cursor

function! <SID>SrcExpl_GetSymbol()

    " Get the current character under the cursor
    let l:cchar = getline(".")[col(".") - 1]
    " Get the current word under the cursor
    let l:cword = expand("<cword>")

    " Judge that if or not the character is invalid,
    " because only 0-9, a-z, A-Z, and '_' are valid
    if l:cchar =~ '\w' && l:cword =~ '\w'
        " If the key word symbol has been explored
        " just now, we will not explore that again
        if s:SrcExpl_symbol ==# l:cword
            " Not in Local definition searching mode
            if g:SrcExpl_searchLocalDef == 0
                return -1
            else
                " Do not refresh when jumping to the main editor window
                if s:SrcExpl_isJumped == 1
                    " Get the cursor line number
                    let s:SrcExpl_csrLine = line(".")
                    " Reset the jump flag
                    let s:SrcExpl_isJumped = 0
                    return -2
                endif
                " The cursor is not moved actually
                if s:SrcExpl_csrLine == line(".")
                    return -3
                endif
            endif
        endif
        " Get the cursor line number
        let s:SrcExpl_csrLine = line(".")
        " Get the symbol word under the cursor
        let s:SrcExpl_symbol = l:cword
    " Invalid character
    else
        if s:SrcExpl_symbol == ''
            return -4 " Second, third ...
        else " First
            let s:SrcExpl_symbol = ''
        endif
    endif

    return 0

endfunction " }}}

" SrcExpl_GetInput() {{{

" Get the word inputed by user on the command line window

function! <SID>SrcExpl_GetInput(note)

    " Be sure synchronize
    call inputsave()
    " Get the input content
    let l:input = input(a:note)
    " Save the content
    call inputrestore()
    " Tell the Source Explorer
    return l:input

endfunction " }}}

" SrcExpl_GetEditWin() {{{

" Get the main editor window index

function! <SID>SrcExpl_GetEditWin()

    let l:i = 1
    let l:j = 1

    " Loop for searching the main editor window
    while 1
        " Traverse the plugin list for each sub-window
        for item in g:SrcExpl_pluginList
            if bufname(winbufnr(l:i)) ==# item
                \ || getwinvar(l:i, '&previewwindow')
                break
            else
                let l:j += 1
            endif
        endfor
        " We've found one
        if j >= len(g:SrcExpl_pluginList)
            return l:i
        else
            let l:i += 1
            let l:j = 0
        endif
        " Not found finally
        if l:i > winnr("$")
            return -1
        endif
    endwhile

endfunction " }}}

" SrcExpl_InitVimEnv() {{{

" Initialize Vim environment

function! <SID>SrcExpl_InitVimEnv()

    " Not highlight the word that had been searched
    " Because execute EX command will active a search event
    exe "set nohlsearch"
    " Auto change current work directory
    exe "set autochdir"
    " Let Vim find the possible tags file
    exe "set tags=tags;"

    " First set the height of preview window
    exe "set previewheight=". string(g:SrcExpl_winHeight)
    " Set the actual update time according to user's requestion
    " 100 milliseconds by default
    exe "set updatetime=" . string(g:SrcExpl_refreshTime)

    " Open all the folds
    if has("folding")
        " Open this file at first
        exe "normal " . "zR"
        " Let it works during the whole editing session
        exe "set foldlevelstart=" . "99"
    endif

endfunction " }}}

" SrcExpl_InitGlbVal() {{{

" Initialize global variables

function! <SID>SrcExpl_InitGlbVal()

    " We'll get the operating system environment
    " in order to judge the slash type (backward
    " or forward)
    if has("win16") || has("win32")
        \ || has("win64")
        let s:SrcExpl_isWinOS = 1
    else
        let s:SrcExpl_isWinOS = 0
    endif
    " Have we jumped to the main editor window ?
    let s:SrcExpl_isJumped = 0
    " Line number of the current cursor
    let s:SrcExpl_csrLine = 0
    " The ID of main editor window
    let s:SrcExpl_editWin = 0
    " The tab page number
    let s:SrcExpl_tabPage = 0
    " Source Explorer status:
    " 0: Definition not found
    " 1: Only one definition
    " 2: Multiple definitions
    " 3: Local declaration
    let s:SrcExpl_status = 0
    " The mark for the current position
    let s:SrcExpl_currMark = []
    " The mark list for exploring the source code
    let s:SrcExpl_markList = []
    " The key word symbol for exploring
    let s:SrcExpl_symbol = ''

endfunction " }}}

" SrcExpl_CloseWin() {{{

" Close the Source Explorer window

function! <SID>SrcExpl_CloseWin()

    " Just close the preview window
    pclose

endfunction " }}}

" SrcExpl_OpenWin() {{{

" Open the Source Explorer window under the bottom of (G)Vim,
" and set the buffer's attribute of the Source Explorer

function! <SID>SrcExpl_OpenWin()

    " Get the ID of main editor window
    let s:SrcExpl_editWin = winnr()
    " Get the tab page number
    let s:SrcExpl_tabPage = tabpagenr()

    " Has the Source Explorer existed already?
    let l:bufnum = bufnr(s:SrcExpl_pluginCaption)
    " Not existed, create a new buffer
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_pluginCaption
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif

    " Reopen the Source Explorer idle window
    exe "silent " . "pedit " . l:wcmd
    " Jump to the Source Explorer
    silent! wincmd P
    " Open successfully and jump to it indeed
    if &previewwindow
        " First make it modifiable
        setlocal modifiable
        " Not show its name on the buffer list
        setlocal nobuflisted
        " No exact file
        setlocal buftype=nofile
        " Delete all lines in buffer
        1,$d _
        " Go to the end of the buffer
        $
        " Display the version of the Source Explorer
        put! ='Source Explorer V4.3'
        " Delete the extra trailing blank line
        $ d _
        " Make it no modifiable
        setlocal nomodifiable
        " Put it on the bottom of (G)Vim
        silent! wincmd J
    endif

    " Indeed go back to the main editor window
    silent! exe s:SrcExpl_editWin . "wincmd w"

endfunction " }}}

" SrcExpl_CleanUp() {{{

" Clean up the rubbish and free the mapping resources

function! <SID>SrcExpl_CleanUp()

    " GUI version only
    if has("gui_running")
        " Delete the SrcExplGoBack item in Popup menu
        silent! nunmenu 1.01 PopUp.&SrcExplGoBack
    endif

    " Make the 'double-click' for nothing
    if maparg('<2-LeftMouse>', 'n') != ''
        nunmap <silent> <2-LeftMouse>
    endif

    " Unmap the jump key
    if maparg(g:SrcExpl_jumpKey, 'n') ==
        \ ":call g:SrcExpl_Jump()<CR>"
        exe "nunmap " . g:SrcExpl_jumpKey
    endif

    " Unmap the go-back key
    if maparg(g:SrcExpl_gobackKey, 'n') ==
        \ ":call g:SrcExpl_GoBack()<CR>"
        exe "nunmap " . g:SrcExpl_gobackKey
    endif

    " Unmap the update-tags key
    if maparg(g:SrcExpl_updateTagsKey, 'n') ==
        \ ":call g:SrcExpl_UpdateTags()<CR>"
        exe "nunmap " . g:SrcExpl_updateTagsKey
    endif

    " Unload the autocmd group
    silent! autocmd! SrcExpl_AutoCmd

endfunction " }}}

" SrcExpl_Init() {{{

" Initialize the Source Explorer properties

function! <SID>SrcExpl_Init()

    " Initialize script global variables
    call <SID>SrcExpl_InitGlbVal()

    " Initialize Vim environment
    call <SID>SrcExpl_InitVimEnv()

    " We must get the ID of main editor window
    let l:tmp = <SID>SrcExpl_GetEditWin()
    " Not found
    if l:tmp < 0
        " Can not find the main editor window
        call <SID>SrcExpl_ReportErr("Can not Found the editor window")
        return -1
    endif
    " Jump to that
    silent! exe l:tmp . "wincmd w"

    if g:SrcExpl_isUpdateTags != 0
        " Update the tags file right now
        if g:SrcExpl_UpdateTags()
            return -2
        endif
    endif

    if g:SrcExpl_updateTagsKey != ""
        exe "nnoremap " . g:SrcExpl_updateTagsKey .
            \ " :call g:SrcExpl_UpdateTags()<CR>"
    endif

    " Then we set the routine function when the event happens
    augroup SrcExpl_AutoCmd
        autocmd!
        au! CursorHold * nested call g:SrcExpl_Refresh()
        au! WinEnter * nested call <SID>SrcExpl_EnterWin()
    augroup end

    return 0

endfunction " }}}

" SrcExpl_Toggle() {{{

" The user interface function to open / close the Source Explorer

function! <SID>SrcExpl_Toggle()

    " Not yet running
    if s:SrcExpl_isRunning == 0
        " Initialize the properties
        if <SID>SrcExpl_Init()
            return -1
        endif
        " Create the window
        call <SID>SrcExpl_OpenWin()
        " We change the flag to true
        let s:SrcExpl_isRunning = 1
    else
        " Not in the exact tab page
        if s:SrcExpl_tabPage != tabpagenr()
            call <SID>SrcExpl_ReportErr("Not support multiple tab pages")
            return -2
        endif
        " Set the switch flag off
        let s:SrcExpl_isOpen = 0
        " Close the window
        call <SID>SrcExpl_CloseWin()
        " Do the cleaning work
        call <SID>SrcExpl_CleanUp()
        " We change the flag to false
        let s:SrcExpl_isRunning = 0
    endif

    return 0

endfunction " }}}

" SrcExpl_Close() {{{

" The user interface function to close the Source Explorer

function! <SID>SrcExpl_Close()

    " Already running
    if s:SrcExpl_isRunning == 1
        " Not in the exact tab page
        if s:SrcExpl_tabPage != tabpagenr()
            call <SID>SrcExpl_ReportErr("Not support multiple tab pages")
            return -1
        endif
        " Close the window
        call <SID>SrcExpl_CloseWin()
        " Do the cleaning work
        call <SID>SrcExpl_CleanUp()
        " We change the flag to false
        let s:SrcExpl_isRunning = 0
    else
        " Tell users the reason
        call <SID>SrcExpl_ReportErr("Source Explorer is close")
        return -2
    endif

    return 0

endfunction " }}}

" SrcExpl() {{{

" The user interface function to open the Source Explorer

function! <SID>SrcExpl()

    " Not yet running
    if s:SrcExpl_isRunning == 0
        " Initialize the properties
        if <SID>SrcExpl_Init()
            return -1
        endif
        " Create the window
        call <SID>SrcExpl_OpenWin()
        " We change the flag to true
        let s:SrcExpl_isRunning = 1
    else
        " Not in the exact tab page
        if s:SrcExpl_tabPage != tabpagenr()
            call <SID>SrcExpl_ReportErr("Not support multiple tab pages")
            return -2
        endif
        " Already running
        call <SID>SrcExpl_ReportErr("Source Explorer is running")
        return -3
    endif

    return 0

endfunction " }}}

" Avoid side effects {{{

set cpoptions&
let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" vim:foldmethod=marker:tabstop=4
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

