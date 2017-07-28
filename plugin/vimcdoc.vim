" Vim plugin to set the default help language to Chinese
" Maintainer:	Willis (http://vimcdoc.sf.net)
" Last Change: 2008 Dec 12

if exists("g:loaded_vimcdoc")
  finish
endif
let g:loaded_vimcdoc = 1

if version >= 603
  set helplang=cn
endif

" vim: ts=8 sw=2
