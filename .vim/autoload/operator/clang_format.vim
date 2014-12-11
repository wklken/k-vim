function! s:is_empty_region(begin, end)
    return a:begin[1] > a:end[1] || (a:begin[1] == a:end[1] && a:end[2] < a:begin[2])
endfunction

function! s:restore_screen_pos()
    let line_diff = line('w0') - g:operator#clang_format#save_screen_pos
    if line_diff > 0
        execute 'silent normal!' line_diff."\<C-y>"
    elseif line_diff < 0
        execute 'silent normal!' (-line_diff)."\<C-e>"
    endif
endfunction

function! operator#clang_format#do(motion_wise)
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    call clang_format#replace(getpos("'[")[1], getpos("']")[1])

    " Do not move cursor and screen
    if exists('g:operator#clang_format#save_pos')
        call setpos('.', g:operator#clang_format#save_pos)
        unlet g:operator#clang_format#save_pos
    endif

    if exists('g:operator#clang_format#save_screen_pos')
        call s:restore_screen_pos()
        unlet g:operator#clang_format#save_screen_pos
    endif
endfunction
