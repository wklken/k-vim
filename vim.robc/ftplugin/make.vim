" ------------------------------------------------------------------------------
"
" Vim filetype plugin file (part of the c.vim plugin)
"
"   Language :  make 
"     Plugin :  c.vim 
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"   Revision :  $Id: make.vim,v 1.2 2010/12/28 18:55:03 mehner Exp $
"
" ------------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_make_ftplugin")
  finish
endif
let b:did_make_ftplugin = 1

 map    <buffer>  <silent>  <LocalLeader>rm         :call C_Make()<CR>
 map    <buffer>  <silent>  <LocalLeader>rmc        :call C_MakeClean()<CR>
 map    <buffer>  <silent>  <LocalLeader>rme        :call C_MakeExeToRun()<CR>
 map    <buffer>  <silent>  <LocalLeader>rma        :call C_MakeArguments()<CR>

imap    <buffer>  <silent>  <LocalLeader>rm    <C-C>:call C_Make()<CR>
imap    <buffer>  <silent>  <LocalLeader>rmc   <C-C>:call C_MakeClean()<CR>
imap    <buffer>  <silent>  <LocalLeader>rme   <C-C>:call C_MakeExeToRun()<CR>
imap    <buffer>  <silent>  <LocalLeader>rma   <C-C>:call C_MakeArguments()<CR>

