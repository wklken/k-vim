let s:save_cpo = &cpo
set cpo&vim

" helper functions {{{
function! s:has_vimproc()
    if !exists('s:exists_vimproc')
        try
            silent call vimproc#version()
            let s:exists_vimproc = 1
        catch
            let s:exists_vimproc = 0
        endtry
    endif
    return s:exists_vimproc
endfunction

function! s:system(str, ...)
    let command = a:str
    let input = a:0 >= 1 ? a:1 : ''

    if a:0 == 0
        let output = s:has_vimproc() ?
                    \ vimproc#system(command) : system(command)
    elseif a:0 == 1
        let output = s:has_vimproc() ?
                    \ vimproc#system(command, input) : system(command, input)
    else
        " ignores 3rd argument unless you have vimproc.
        let output = s:has_vimproc() ?
                    \ vimproc#system(command, input, a:2) : system(command, input)
    endif

    return output
endfunction

function! s:make_style_options()
    let extra_options = ""
    for [key, value] in items(g:clang_format#style_options)
        let extra_options .= printf(", %s: %s", key, value)
    endfor
    return printf("'{BasedOnStyle: %s, IndentWidth: %d, UseTab: %s%s}'",
                        \ g:clang_format#code_style,
                        \ (exists('*shiftwidth') ? shiftwidth() : &l:shiftwidth),
                        \ &l:expandtab==1 ? "false" : "true",
                        \ extra_options)
endfunction

function! s:success(result)
    return (s:has_vimproc() ? vimproc#get_last_status() : v:shell_error) == 0
                \ && a:result !~# '^YAML:\d\+:\d\+: error: unknown key '
                \ && a:result !~# '^\n\?$'
endfunction

function! s:error_message(result)
    echoerr "clang-format has failed to format."
    if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
        echohl ErrorMsg
        for l in split(a:result, "\n")[0:1]
            echomsg l
        endfor
        echohl None
    endif
endfunction

function! clang_format#get_version()
    if &shell =~# 'csh$' && executable('/bin/bash')
        let shell_save = &shell
        set shell=/bin/bash
    endif
    try
        return matchlist(s:system(g:clang_format#command.' --version 2>&1'), '\(\d\+\)\.\(\d\+\)')[1:2]
    finally
        if exists('l:shell_save')
            let &shell = shell_save
        endif
    endtry
endfunction

function! clang_format#is_invalid()
    if !exists('s:command_available')
        if ! executable(g:clang_format#command)
            return 1
        endif
        let s:command_available = 1
    endif

    if !exists('s:version')
        let v = clang_format#get_version()
        if v[0] < 3 || (v[0] == 3 && v[1] < 4)
            return 2
        endif
        let s:version = v
    endif

    return 0
endfunction

function! s:verify_command()
    let invalidity = clang_format#is_invalid()
    if invalidity == 1
        echoerr "clang-format is not found. check g:clang_format#command."
    elseif invalidity == 2
        echoerr 'clang-format 3.3 or earlier is not supported for the lack of aruguments'
    endif
endfunction
" }}}

" variable definitions {{{
function! s:getg(name, default)
    " backward compatibility
    if exists('g:operator_'.substitute(a:name, '#', '_', ''))
        echoerr 'g:operator_'.substitute(a:name, '#', '_', '').' is deprecated. Please use g:'.a:name
        return g:operator_{substitute(a:name, '#', '_', '')}
    else
        return get(g:, a:name, a:default)
    endif
endfunction

let g:clang_format#command = s:getg('clang_format#command', 'clang-format')
let g:clang_format#extra_args = s:getg('clang_format#extra_args', "")
if type(g:clang_format#extra_args) == type([])
    let g:clang_format#extra_args = join(g:clang_format#extra_args, " ")
endif

let g:clang_format#code_style = s:getg('clang_format#code_style', 'google')
let g:clang_format#style_options = s:getg('clang_format#style_options', {})

let g:clang_format#detect_style_file = s:getg('clang_format#detect_style_file', 1)
let g:clang_format#auto_format = s:getg('clang_format#auto_format', 0)
let g:clang_format#auto_format_on_insert_leave = s:getg('clang_format#auto_format_on_insert_leave', 0)
let g:clang_format#auto_formatexpr = s:getg('clang_format#auto_formatexpr', 0)
" }}}

" format codes {{{
function! s:detect_style_file()
    let dirname = expand('%:p:h')
    let style_file_name = has('win32') || has('win64') ? '_clang-format' : '.clang-format'
    return findfile(style_file_name, dirname.';') != ''
endfunction

function! clang_format#format(line1, line2)
    let args = printf(" -lines=%d:%d", a:line1, a:line2)
    if ! (g:clang_format#detect_style_file && s:detect_style_file())
        let args .= printf(" -style=%s ", s:make_style_options())
    else
        let args .= " -style=file "
    endif
    let args .= g:clang_format#extra_args
    let clang_format = printf("%s %s --", g:clang_format#command, args)
    return s:system(clang_format, join(getline(1, '$'), "\n"))
endfunction
" }}}

" replace buffer {{{
function! clang_format#replace(line1, line2)

    call s:verify_command()

    let pos_save = getpos('.')
    let sel_save = &l:selection
    let &l:selection = "inclusive"
    let [save_g_reg, save_g_regtype] = [getreg('g'), getregtype('g')]

    try
        let formatted = clang_format#format(a:line1, a:line2)

        if s:success(formatted)
            try
                " Note:
                " Replace current buffer with workaround not to move
                " the cursor on undo (issue #8)
                "
                " The points are:
                "   - Do not touch the first line.
                "   - Use :put (p, P and :put! is not available).
                "
                " To meet above condition:
                "   - Delete all lines except for the first line.
                "   - Put formatted text except for the first line.
                "
                let i = stridx(formatted, "\n")
                if i == -1 || getline(1) !=# formatted[:i-1]
                    throw "fallback"
                endif

                call setreg('g', formatted[i+1:], 'V')
                undojoin | silent normal! 2gg"_dG
                silent put g
            catch
                " Fallback:
                " The previous way.  It lets the cursor move to the first line
                " on undo.
                call setreg('g', formatted, 'V')
                silent keepjumps normal! ggVG"gp
            endtry
        else
            call s:error_message(formatted)
        endif
    finally
        call setreg('g', save_g_reg, save_g_regtype)
        let &l:selection = sel_save
        call setpos('.', pos_save)
    endtry

    return 1
endfunction
" }}}

" auto formatting on insert leave {{{
let s:pos_on_insertenter = []

function! s:format_inserted_area()
    let pos = getpos('.')
    " When in the same buffer
    if &modified && ! empty(s:pos_on_insertenter) && s:pos_on_insertenter[0] == pos[0]
        call clang_format#replace(s:pos_on_insertenter[1], line('.'))
        let s:pos_on_insertenter = []
    endif
endfunction

function! clang_format#enable_format_on_insert()
    augroup plugin-clang-format-auto-format-insert
        autocmd!
        autocmd InsertEnter <buffer> let s:pos_on_insertenter = getpos('.')
        autocmd InsertLeave <buffer> call s:format_inserted_area()
    augroup END
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
