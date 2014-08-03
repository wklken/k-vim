"browser.vim Super lightweight browser for vim (uses lynx Dump)
" Script Info and Documentation  {{{
"=============================================================================
"    Copyright: Copyright (C) 2008 Michael Brown
"      License: The MIT License
"               
"               Permission is hereby granted, free of charge, to any person obtaining
"               a copy of this software and associated documentation files
"               (the "Software"), to deal in the Software without restriction,
"               including without limitation the rights to use, copy, modify,
"               merge, publish, distribute, sublicense, and/or sell copies of the
"               Software, and to permit persons to whom the Software is furnished
"               to do so, subject to the following conditions:
"               
"               The above copyright notice and this permission notice shall be included
"               in all copies or substantial portions of the Software.
"               
"               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"               OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"               MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"               IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"               CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"               TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"               SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" Name Of File: browser.vim
"  Description: Simple internal web browser for vim
"   Maintainer: Michael Brown 
"  Last Change:
"          URL:
"      Version: 0.1
"
"        Usage:
"
"               This script requires the lynx browser
"
"               Place browser.vim in your plugin folder
"
"               This plugin opens a website by making a lynx -dump call behind
"               the scenes and takes advantage of the dumps link references so
"               you can click on links and browse through a site.
"
"               It seems to work well on wikipedia and any text friendly sites
"               when all you want is a quick definition etc.
"
"               :WebBrowser <url>
"               To open a web page
"
"               :Wikipedia <search term>
"               Will open en.wikipedia.org/wiki/<search term> 
"
"               :Google <serch term>
"               Opens google to the search term
"
"               :GoogleLucky <serch term>
"               Opens Lucky Google search 
"
"               you can also create your own site specific googling eg.  
"               com! -nargs=+ GooglePythonDoc call OpenGoogle(<q-args>, 0 , 'docs.python.org')
"               (make the second arg 1 for lucky)
"               
"               Within the browser view the <tab> key cycles through links and
"               pressing <cr> will open a link
"
"               the u key seems to work ok as a back button 
"
"
"         Bugs:
"               Internal url's with #anchor will not work
"               Clicking on an image link will not work 
"               Not yet ACID compliant. 
"
"
"        To Do:
"               Please send in any filetype keywordprg hacks you have for any
"               specific languages and I'll add them to the script
"
"               (mjbrownie at please dont spam my gmail.com account )

"
"Configuration
"
"Possible mappings if your not using the default keywordprg
"map K :Wikipedia <c-r><c-w><cr>
"au FileType php map K :call OpenPhpFunction('<c-r><c-w>')<cr>
"au FileType python map K :GooglePythonDoc <cword><cr>

com! -nargs=+ Wikipedia       call OpenWikipedia(<q-args>)
com! -nargs=+ Dictionary      call OpenDictionary(<q-args>)
com! -nargs=+ WebBrowser      call OpenWebBrowser(<q-args>)
com! -nargs=+ GoogleLucky     call OpenGoogle(<q-args>, 1, '')
com! -nargs=+ Google          call OpenGoogle(<q-args>, 0 , '')
com! -nargs=+ GooglePythonDoc call OpenGoogle(<q-args>, 0 , 'docs.python.org')


fun! OpenWebBrowser (address)
    exe "split"
    exe "enew"
    exe "set buftype=nofile"
    exe "silent r!lynx -dump " . a:address
    syn reset
    "add some syntax rules (thanks to jamesson on #vim)
    syn match Keyword /\[\d*\]\w*/ contains=Ignore
    syn match Ignore /\[\d*\]/ contained 
    exe "norm gg"
    exe "nnoremap <buffer> <tab> /\\d*\\]\\w*<cr>"
    exe 'nnoremap <buffer> <cr> F[h/^ *<c-r><c-w>. http<cr>fh"py$:call OpenLink("<c-r>p")<cr>'
    echo "reading " . a:address
endfun

fun! OpenGoogle (sentence,lucky,site)
    if a:site != ''
        let site_clause = '\+site\%3A' . a:site
    else
        let site_clause = ''
    endif

    if a:lucky == 1
        let type = 'btnI'
    else
        let type = 'btnG'
    endif

    let topic = substitute(a:sentence, " ", "+", "g") 
    let address = 'http://www.google.com/search\?'.type.'=yes\&q=' . topic .site_clause
    call OpenWebBrowser(address)
endfun

fun! OpenWikipedia (sentence)
    let topic = substitute(a:sentence, " ", "_", "g") 
    let address = 'http://www.wikipedia.org/wiki/' . topic
    "echo address
    call OpenWebBrowser(address)
    exe "norm 5dd"
endfun

fun! OpenDictionary (sentence)
    let topic = substitute(a:sentence, " ", "_", "g") 
    "let address = 'http://www.thefreedictionary.com/' . topic
    let address = 'http://en.wiktionary.org/wiki/' . topic
    "echo address
    call OpenWebBrowser(address)
endfun
"
fun! OpenPhpFunction (keyword)
    "let address = 'http://www.php.net/' . a:keyword
    "call OpenWebBrowser(address)
    let proc_keyword = substitute(a:keyword , '_', '-', 'g')
    exe 'split'
    exe 'enew'
    exe "set buftype=nofile"
    exe 'silent r!lynx -dump -nolist http://www.php.net/manual/en/print/function.'.proc_keyword.'.php' 
    exe 'norm gg'
    exe 'call search ("' . a:keyword .'")'
    exe 'norm dgg'
    exe 'call search("User Contributed Notes")' 
    exe 'norm dGgg'
endfun

fun! OpenLink (address)
    exe "norm ggdG"
    let clean_address = ''
    let clean_address = substitute(a:address, '%', '\\%','g')
    let clean_address = substitute(clean_address, '#', '\\#','g')
    let clean_address = substitute(clean_address, '&', '\\&','g')
    exe "silent r!lynx -dump " . clean_address
    syn reset
    syn match Keyword /\[\d*\]\w*/ contains=Ignore
    syn match Ignore /\[\d*\]/ contained 
    exe "norm gg"
    echo "reading " . a:address
endfun

