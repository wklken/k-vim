" matrix.vim - Don Yang (uguu.org)
"
" Matrix screensaver for VIM.
"
"Usage:
" After loading the script, use :Matrix to start.
" Press any key a few times to exit.
"
" You will need to edit s:mindelay and s:maxdelay below to match your
" machine speed and window size.
"
"Known Issues:
" Sometimes you need to press keys a few times to exit instead of just
" once.  Press and hold is another way to go... feels like getchar is
" checking for keypress state instead of keystroke availability.
"
" If the window is too small, script will not run.  If the window is
" resized and become too small (less than 8 rows or 10 columns) after
" the script started, script will abort and *buffers may be lost*, so
" don't do that.  Resizing the window to most other sizes will be fine.
"
" Doesn't work if multiple windows exist before script started.  In
" that case the script will abort with error message.
"
" If the current buffer is modified, some error messages will appear
" before the script starts, and an extra window is left behind after
" the script exits.  Workaround: save your buffers first.
"
"Other Info:
" Inspired by cmatrix...
" Didn't feel inspired enough to start using pico/nano, of course ^_^;
"
" 05/13/08 - disable cursorline, cursorcolumn and spell
"            (thanks to Diederick Niehorster for the suggestion).
" 12/21/06 - multiwindow support by S. Lockwood-Childs.
" 10/03/05 - added silent! to cursor positioning code to stop drawing
"            numbers during animation (thanks to David Eggum for the
"            suggestion).
" 10/02/05 - disable showmatch
" 03/16/05 - make new buffer modifiable before running
" 01/27/05 - added sleep to consume less CPU
"            removed frame counter
" 01/26/05 - initial version
"
" This script is released under MIT license.


" Speed range, must be positive.  Lower delay = faster.
let s:mindelay = 1
let s:maxdelay = 5

" Session file for preserving original window layout
let s:session_file = tempname()


function! s:Rand()
   let b:seed = b:seed * 22695477 + 1
   if b:seed < 0
      return -b:seed
   endif
   return b:seed
endfunction

function! s:CreateObject(i)
   while 1
      let b:x{a:i} = s:Rand() % b:columns
      if b:reserve{b:x{a:i}} > 4
         break
      endif
   endwhile
   let b:y{a:i} = 1
   let b:t{a:i} = s:Rand() % b:s{b:x{a:i}}
   let b:head{a:i} = s:Rand() % 4
   let b:len{a:i} = s:Rand() % b:h + 3
   let b:reserve{b:x{a:i}} = 1 - b:len{a:i}
endfunction

function! s:DrawObject(i)
   let x = b:x{a:i} * 2 + 1
   let y = b:y{a:i}

   " Draw head
   if y <= b:h
      if b:head{a:i}
         silent! exec 'norm! :' . y . nr2char(13) . x . '|R' . b:d[s:Rand()%b:dl] . '_' . nr2char(27)
         if y > 1
            silent! exec 'norm! kR' . ((s:Rand() % 2) ? '`' : ' ') . nr2char(27)
         endif
      else
         let a = ((s:Rand() % 2) ? '`' : ' ') . nr2char(27)
         silent! exec 'norm! :'. y . nr2char(13) . x . '|R' . b:d[s:Rand() % b:dl] . a
      endif
   else
      if b:head{a:i} && y == b:h + 1
         silent! exec 'norm! :' . b:h . nr2char(13) . (x + 1) . '|R' . ((s:Rand() % 2) ? '`' : ' ') . nr2char(27)
      endif
   endif

   " Draw tail
   let y = y - b:len{a:i}
   if 1 <= y && y <= b:h
      silent! exec 'norm! :'. y . nr2char(13) . x . '|R  ' . nr2char(27)
   endif
   let b:reserve{b:x{a:i}} = y
endfunction

function! s:Animate()
   let i = 0

   while i < b:objcount
      " Animate object
      if b:t{i} <= 0
         if b:y{i} - b:len{i} <= b:h
            " Draw
            call s:DrawObject(i)
            let b:t{i} = b:s{b:x{i}}
            let b:y{i} = b:y{i} + 1
         else
            " Regenerate
            call s:CreateObject(i)
         endif
      endif

      let b:t{i} = b:t{i} - 1
      let i = i + 1
   endwhile
   redraw
   if getchar(1)
      let b:run = 0
   endif
   sleep 20m
endfunction

function! s:Reset()
   " Clear screen
   let b:w = winwidth(0)
   let b:h = winheight(0)
   exec 'norm! gg"_dG' . b:h . 'O' . nr2char(27) . 'gg'
   redraw
   if b:w < 10 || b:h < 8
      let b:run = 0
      return
   endif

   " Set number of columns.  This is rounded down due to line wrapping
   " at the last column if the screen width is even.  So you end up
   " seeing the cursor blinking a lot at the right side of the screen.
   " Alternatively, ':set rl' before running the script to have it
   " blink on the left side.
   let b:columns = (b:w - 1) / 2

   " Initialize columns.
   let i = 0
   while i < b:columns
      " Set delay time.  Each column gets the same delay time.
      let b:s{i} = s:Rand() % (s:maxdelay - s:mindelay) + s:mindelay

      " Unreserve column
      let b:reserve{i} = b:h
      let i = i + 1
   endwhile

   " Initialize objects
   let b:objcount = b:columns - 2
   let i = 0
   while i < b:objcount
      call s:CreateObject(i)
      let i = i + 1
   endwhile
endfunction

function! s:Init()
   " Create new buffer and hide the existing buffers.  Hiding the
   " existing buffers without switching to a new buffer preserves
   " undo history.
   exec 'mksession! ' . s:session_file
   let s:num_orig_win = winnr("$")

   " move to top window, so created window will become window 1,
   " then attempt to create new window
   1 wincmd w
   silent! new

   " check that there really is an additional window
   if winnr("$") != s:num_orig_win + 1
      return 1
   endif
   let s:newbuf = bufnr('%')

   " close all but window 1, which is the new window
   only

   setl bh=delete bt=nofile ma nolist nonu noro noswf tw=0 nowrap

   " Set GUI options
   if has('gui')
      let s:o_gcr = &gcr
      let s:o_go = &go
      set gcr=a:ver1-blinkon0 go=
   endif
   if has('cmdline_info')
      let s:o_ru = &ru
      let s:o_sc = &sc
      set noru nosc
   endif
   if has('title')
      let s:o_ts = &titlestring
      exec 'set titlestring=\ '
   endif
   if v:version >= 700
      let s:o_spell = &spell
      let s:o_cul = &cul
      let s:o_cuc = &cuc
      set nospell nocul nocuc
   endif
   let s:o_ch = &ch
   let s:o_ls = &ls
   let s:o_lz = &lz
   let s:o_siso = &siso
   let s:o_sm = &sm
   let s:o_smd = &smd
   let s:o_so = &so
   let s:o_ve = &ve
   set ch=1 ls=0 lz nosm nosmd siso=0 so=0 ve=all

   " Initialize PRNG
   let b:seed = localtime()
   let b:run = 1

   " Clear screen and initialize objects
   call s:Reset()

   " Set colors.  Output looks better if your color scheme has black
   " background.  I would rather not have the script change the
   " current color scheme since there is no good way to restore them
   " afterwards.
   hi MatrixHidden ctermfg=Black ctermbg=Black guifg=#000000 guibg=#000000
   hi MatrixNormal ctermfg=DarkGreen ctermbg=Black guifg=#008000 guibg=#000000
   hi MatrixBold ctermfg=LightGreen ctermbg=Black guifg=#00ff00 guibg=#000000
   hi MatrixHead ctermfg=White ctermbg=Black guifg=#ffffff guibg=#000000
   sy match MatrixNormal /^.*/ contains=MatrixHidden
   sy match MatrixHidden contained /.`/ contains=MatrixBold
   sy match MatrixHidden contained /._/ contains=MatrixHead
   sy match MatrixBold contained /.\(`\)\@=/
   sy match MatrixHead contained /.\(_\)\@=/

   " Create random char dictionary
   let b:d = ''
   let i = 33
   while i < 127
      if i != 95 && i != 96
         let b:d = b:d . nr2char(i)
      endif
      let i = i + 1
   endwhile
   let b:dl = strlen(b:d)
   return 0
endfunction

function! s:Cleanup()
   " Restore options
   if has('gui')
      let &gcr = s:o_gcr
      let &go = s:o_go
      unlet s:o_gcr s:o_go
   endif
   if has('cmdline_info')
      let &ru = s:o_ru
      let &sc = s:o_sc
      unlet s:o_ru s:o_sc
   endif
   if has('title')
      let &titlestring = s:o_ts
      unlet s:o_ts
   endif
   if v:version >= 700
      let &spell = s:o_spell
      let &cul = s:o_cul
      let &cuc = s:o_cuc
      unlet s:o_cul s:o_cuc
   endif
   let &ch = s:o_ch
   let &ls = s:o_ls
   let &lz = s:o_lz
   let &siso = s:o_siso
   let &sm = s:o_sm
   let &smd = s:o_smd
   let &so = s:o_so
   let &ve = s:o_ve
   unlet s:o_ch s:o_ls s:o_lz s:o_siso s:o_sm s:o_smd s:o_so s:o_ve

   " Restore old buffers
   exec 'source ' . s:session_file
   exec 'bwipe ' . s:newbuf
   unlet s:newbuf

   " Clear keystroke
   let c = getchar(0)
endfunction

function! Matrix()
   if s:Init()
      echohl ErrorMsg
      echon 'Can not create window'
      echohl None
      return
   endif

   while b:run
      if b:w != winwidth(0) || b:h != winheight(0)
         call s:Reset()
      else
         call s:Animate()
      endif
   endwhile

   call s:Cleanup()
endfunction


if !has('virtualedit') || !has('windows') || !has('syntax')
   echohl ErrorMsg
   echon 'Not enough features, need at least +virtualedit, +windows and +syntax'
   echohl None
else
   command! Matrix call Matrix()
endif
