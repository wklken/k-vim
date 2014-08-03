" Vim script file                                           vim600:fdm=marker:
" FileType:     XML
" Author:       Rene de Zwart <renez (at) lightcon.xs4all.nl> 
" Maintainer:   Rene de Zwart <renez (at) lightcon.xs4all.nl>
" Last Change:  Date: 2009-11-12 
" Version:      Revision: 1.37
" 
" Licence:      This program is free software; you can redistribute it
"               and/or modify it under the terms of the GNU General Public
"               License.  See http://www.gnu.org/copyleft/gpl.txt
" Credits:      Devin Weaver <vim (at) tritarget.com>  et all
"               for the original code.  Guo-Peng Wen for the self
"               install documentation code.
"               Bart vam Deenen for makeElement function
"               Rene de Zwart


" Observation   - If you want to do something to a match pair most of the time
"               you must do first the close tag. Because doing first the open
"               tag could change the close tag position.

" NOTE          with filetype index on de standard indent/html.vim interferes
"               with xml.vim. You can
"                 1) set filetype indent off in .vimrc
"                 2) echo "let b:did_indent = 1" > .vim/indent/html.vim


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal commentstring=<!--%s-->

" XML:  thanks to Johannes Zellner and Akbar Ibrahim
" - case sensitive
" - don't match empty tags <fred/>
" - match <!--, --> style comments (but not --, --)
" - match <!, > inlined dtd's. This is not perfect, as it
"   gets confused for example by
"       <!ENTITY gt ">">
if exists("loaded_matchit")
    let b:match_ignorecase=0
    let b:match_words =
     \  '<:>,' .
     \  '<\@<=!\[CDATA\[:]]>,'.
     \  '<\@<=!--:-->,'.
     \  '<\@<=?\k\+:?>,'.
     \  '<\@<=\([^ \t>/]\+\)\%(\s\+[^>]*\%([^/]>\|$\)\|>\|$\):<\@<=/\1>,'.
     \  '<\@<=\%([^ \t>/]\+\)\%(\s\+[^/>]*\|$\):/>'
endif

" Script rgular expresion used. Documents those nasty criters      {{{1
let s:NoSlashBeforeGt = '\(\/\)\@\<!>'
" Don't check for quotes around attributes!!!
let s:Attrib =  '\(\(\s\|\n\)\+\([^>= \t]\+=[^>&]\+\)\(\s\|\n\)*\)'
let s:OptAttrib = s:Attrib . '*'. s:NoSlashBeforeGt
let s:ReqAttrib = s:Attrib . '\+'. s:NoSlashBeforeGt
let s:OpenTag = '<[^!/?][^>]*' . s:OptAttrib
let s:OpenOrCloseTag = '<[^!?][^>]*'. s:OptAttrib
let s:CloseTag = '<\/[^>]*'. s:NoSlashBeforeGt
let s:SpaceInfront = '^\s*<'
let s:EndofName = '\($\|\s\|>\)'

" Buffer variables                                                  {{{1
let b:emptyTags='^\(area\|base\|br\|col\|command\|embed\|hr\|img\|input\|keygen\|link\|meta\|param\|source\|track\|wbr\)$'
let b:firstWasEndTag = 0
let b:html_mode =((&filetype =~ 'x\?html') && !exists("g:xml_no_html"))
let b:haveAtt = 0
let b:lastTag = ""
let b:lastAtt = ""
let b:suffix = (exists('g:makeElementSuf') ? g:makeElementSuf : ';;')
let b:xml_use_xhtml = 0
if exists('g:xml_use_xhtml')
	let b:xml_use_xhtml = g:xml_use_xhtml
elseif &filetype == 'xhtml'
	let b:xml_use_xhtml = 1
en

let b:undo_ftplugin = "setlocal cms< isk<"
  \ . "| unlet b:match_ignorecase b:match_words"



" NewFileXML -> Inserts <?xml?> at top of new file.                  {{{1
if !exists("*NewFileXML")
function! NewFileXML( )
    " Where is g:did_xhtmlcf_inits defined?
    if &filetype == 'xml' || 
			\ (!exists ("g:did_xhtmlcf_inits") &&
			\ b:xml_use_xhtml &&
			\ (&filetype =~ 'x\?html'))
        if append (0, '<?xml version="1.0"?>')
            normal! G
        endif
    endif
endfunction
endif



" Callback -> Checks for tag callbacks and executes them.            {{{1
if !exists("*s:Callback")
function! s:Callback( xml_tag, isHtml )
    let text = 0
    if a:isHtml == 1 && exists ("*HtmlAttribCallback")
        let text = HtmlAttribCallback (a:xml_tag)
    elseif exists ("*XmlAttribCallback")
        let text = XmlAttribCallback (a:xml_tag)
    endif       
    if text != '0'
        execute "normal! i " . text ."\<Esc>l"
    endif
endfunction
endif

" SavePos() saves position  in bufferwide variable                        {{{1
fun! s:SavePos()	
	retu 'call cursor('.line('.').','. col('.'). ')'
endf

" findOpenTag()                         {{{1
fun! s:findOpenTag(flag)	
	call search(s:OpenTag,a:flag)
endf

" findCloseTag()                         {{{1
fun! s:findCloseTag(flag)	
	call search(s:CloseTag,a:flag)
endf

" GetTagName() Gets the tagname from start position                     {{{1
"Now lets go for the name part. The namepart are xmlnamechars which
"is quite a big range. We assume that everything after '<' or '</' 
"until the first 'space', 'forward slash' or '>' ends de name part.
if !exists('*s:GetTagName')
fun! s:GetTagName(from)
	  let l:end = match(getline('.'), s:EndofName,a:from)
	  return strpart(getline('.'),a:from, l:end - a:from )
endf
en
" hasAtt() Looks for attribute in open tag                           {{{1
" expect cursor to be on <
fun! s:hasAtt()
	"Check if this open tag has attributes
	let l:line = line('.') | let l:col = col('.') 
	if search(b:tagName . s:ReqAttrib,'W') > 0
    if l:line == line('.') && l:col == (col('.')-1)
			let b:haveAtt = 1
		en
	en
endf
 

" TagUnderCursor()  Is there a tag under the cursor?               {{{1
" Set bufer wide variable
"  - b:firstWasEndTag
"  - b:tagName
"  - b:endcol & b:endline only used by Match()
"  - b:gotoCloseTag (if the tag under the cursor is one)
"  - b:gotoOpenTag  (if the tag under the cursor is one)
" on exit
"    - returns 1 (true)  or 0 (false)
"    - position is at '<'
if !exists('*s:TagUnderCursor')
fun! s:TagUnderCursor()
	let b:firstWasEndTag = 0
	let l:haveTag = 0
	let b:haveAtt = 0
	
	"Lets find forward a < or a >.  If we first find a > we might be in a tag.
	"If we find a < first or nothing we are definitly not in a tag

	if getline('.')[col('.') - 1] == '>'
		let b:endcol  = col('.')
		let b:endline = line('.')
		if getline('.')[col('.')-2] == '/'
				"we don't work with empty tags
			retu l:haveTag
		en
    " begin: gwang customization for JSP development
		if getline('.')[col('.')-2] == '%'
				"we don't work with jsp %> tags
			retu l:haveTag
		en
    " end: gwang customization for JSP development
    " begin: gwang customization for PHP development
		if getline('.')[col('.')-2] == '?'
				"we don't work with php ?> tags
			retu l:haveTag
		en
    " end: gwang customization for PHP development
	elseif search('[<>]','W') >0
		if getline('.')[col('.')-1] == '>'
			let b:endcol  = col('.')
			let b:endline = line('.')
			if getline('.')[col('.')-2] == '-'
				"we don't work with comment tags
				retu l:haveTag
			en
			if getline('.')[col('.')-2] == '/'
				"we don't work with empty tags
				retu l:haveTag
			en
		el
			retu l:haveTag
		en
	el
		retu l:haveTag
	en
	
	if search('[<>]','bW' ) >=0
		if getline('.')[col('.')-1] == '<'
			if getline('.')[col('.')] == '/'
				let b:firstWasEndTag = 1
				let b:gotoCloseTag = s:SavePos()
			elseif getline('.')[col('.')] == '?' ||  getline('.')[col('.')] == '!'
				"we don't deal with processing instructions or dtd
				"related definitions
				retu l:haveTag
			el
				let b:gotoOpenTag = s:SavePos()
			en
		el
			retu l:haveTag
		en
	el
		retu l:haveTag
	en

	"we have established that we are between something like
	"'</\?[^>]*>'
	
	let b:tagName = s:GetTagName(col('.') + b:firstWasEndTag)
	"echo 'Tag ' . b:tagName 

  "begin: gwang customization, do not work with an empty tag name
  if b:tagName == '' 
		retu l:haveTag
  en
  "end: gwang customization, do not work with an empty tag name

	let l:haveTag = 1
	if b:firstWasEndTag == 0
		call s:hasAtt()
		exe b:gotoOpenTag
	en
	retu l:haveTag
endf
en
 
" Match(tagname) Looks for open or close tag of tagname               {{{1
" Set buffer wide variable
"  - b:gotoCloseTag (if the Match tag is one)
"  - b:gotoOpenTag  (if the Match tag is one)
" on exit
"    - returns 1 (true) or 0 (false)
"    - position is at '<'
if !exists('*s:Match')
fun! s:Match(name)
	let l:pat = '</\=' . a:name . s:OptAttrib
	if  b:firstWasEndTag
		exe b:gotoCloseTag
		let l:flags='bW'
		let l:level = -1
	el
		exe  'normal! '.b:endline.'G0'.(b:endcol-1).'l'
		let l:flags='W'
		let l:level = 1
	en
	while l:level &&  search(l:pat,l:flags) > 0
		let l:level = l:level + (getline('.')[col('.')] == '/' ? -1 : 1)
	endwhile
	if l:level
		echo "no matching tag!!!!!"
		retu l:level
	en
	if b:firstWasEndTag
		let b:gotoOpenTag = s:SavePos()
		call s:hasAtt()
		exe b:gotoOpenTag
	el
		let b:gotoCloseTag = s:SavePos()
	en
	retu l:level == 0
endf
en

" InComment()  Is there a Comment under the cursor?               {{{1
"    - returns 1 (true)  or 0 (false)

if !exists('*s:InComment')
fun! s:InComment()
let b:endcom=0
let b:begcom=0

	"Lets find forward a < or a >.  If we first find a > we might be in a comment.
	"If we find a < first or nothing we are definitly not in a Comment

	if getline('.')[col('.') - 1] == '>'
		if getline('.')[col('.')-2] == '-' && getline('.')[col('.')-3] == '-'
			let b:endcomcol=col('.')
			let b:endcomline=line('.')
			let b:endcom=1
			retu 1
		en
	elseif  getline('.')[col('.')-1] == '<' && getline('.')[col('.')]   == '!'
		 \ && getline('.')[col('.')+1] == '-' && getline('.')[col('.')+2] == '-' 
			let b:begcomcol= col('.')
			let b:begcomline=line('.')
			let b:begcom=1
			retu 1
	en
	"We are not standing on a begin/end comment
	"Is the first > an ending comment?
	if search('[<>]','W') >0
		if getline('.')[col('.')-1] == '>'
			if getline('.')[col('.')-2] == '-' && getline('.')[col('.')-3] == '-'
			let b:endcomcol=col('.')
			let b:endcomline=line('.')
			let b:endcom=1
				retu 1
			en
		en
	en
	"Forward is not a ending comment
	"is backward a starting comment
	
	if search('[<>]','bW' ) >=0
		if getline('.')[col('.')-1] == '<' && getline('.')[col('.')]   == '!'
		 \ && getline('.')[col('.')+1] == '-' && getline('.')[col('.')+2] == '-' 
			let b:begcomcol=col('.')
			let b:begcomline=line('.')
			let b:begcom=1
			retu 1
		en
	en
	retu 0
endf
en
 
" DelComment()  Is there a Comment under the cursor?               {{{1
"    - returns 1 (true)  or 0 (false)

if !exists('*s:DelComment')
fun! s:DelComment()
	
	let l:restore =  s:SavePos()
	if s:InComment()
		if b:begcom
			if search('-->','W' ) >=0
				normal! hh3x	
		   	call cursor(b:begcomline,b:begcomcol)
				normal! 4x
				retu 1
			en
		el
			if search('<!--','bW' ) >=0
				normal! 4x
		   	call cursor(b:endcomline,b:endcomcol)
				normal! hh3x	
				retu 1
			en
		en
	en
	exe l:restore
	retu 0
endf
en
 
" DelCommentSection()  Is there a Comment under the cursor?               {{{1
"    - returns 1 (true)  or 0 (false)

if !exists('*s:DelCommentSection')
fun! s:DelCommentSection()
	
	let l:restore =  s:SavePos()
	if s:InComment()
		let l:sentinel = 'XmLSeNtInElXmL'
		let l:len = strlen(l:sentinel)
		if b:begcom
			if search('-->','W' ) >=0
				exe "normal! f>a".l:sentinel."\<Esc>"
		   	call cursor(b:begcomline,b:begcomcol)
				exe "normal! \"xd/".l:sentinel."/e-".l:len."\<Cr>"
				exe "normal! ".l:len."x"
				retu 1
			en
		el
			if search('<!--','bW' ) >=0
				let l:restore =  s:SavePos()
		   	call cursor(b:endcomline,b:endcomcol)
				exe "normal! a".l:sentinel."\<Esc>"
				exe l:restore
				exe "normal! \"xd/".l:sentinel."/e-".l:len."\<Cr>"
				exe "normal! ".l:len."x"
				retu 1
			en
		en
	en
	exe l:restore
	retu 0
endf
en
 
" DelCData()  Is there a CData under the cursor?               {{{1
"    - returns 1 (true)  or 0 (false)

if !exists('*s:DelCData')
fun! s:DelCData()
	
	let l:restore =  s:SavePos()
	if s:InCData()
		if b:begdat
			if search(']]>','W' ) >=0
				normal! hh3x	
		   	call cursor(b:begdatline,b:begdatcol)
				normal! 9x
				retu 1
			en
		el
			if search('<![CDATA[','bW' ) >=0
				normal! 9x
		   	call cursor(b:enddatline,b:enddatcol)
				normal! hh3x	
				retu 1
			en
		en
	en
	exe l:restore
	retu 0
endf
en
 
" InCData()  Is there a CData under the cursor?               {{{1
"    - returns 1 (true)  or 0 (false)

if !exists('*s:InCData')
fun! s:InCData()
let b:enddat=0
let b:begdat=0

	"Lets find forward a < or a >.  If we first find a > we might be in a comment.
	"If we find a < first or nothing we are definitly not in a Comment

	if getline('.')[col('.') - 1] == '>'
		if getline('.')[col('.')-2] == ']' && getline('.')[col('.')-3] == ']'
			let b:enddatcol=col('.')
			let b:enddatline=line('.')
			let b:enddat=1
			retu 1
		en
	elseif  getline('.')[col('.')-1] == '<' 
		if  match(getline('.'),'<![CDATA[') > 0
			let b:begdatcol= col('.')
			let b:begdatline=line('.')
			let b:begdat=1
			retu 1
		en
	en
	"We are not standing on a begin/end comment
	"Is the first > aending comment?
	if search('[<>]','W') >0
		if getline('.')[col('.')-1] == '>'
			if getline('.')[col('.')-2] == ']' && getline('.')[col('.')-3] == ']'
			let b:enddatcol=col('.')
			let b:enddatline=line('.')
			let b:enddat=1
				retu 1
			en
		en
	en
	"Forward is not a ending datment
	"is backward a starting comment
	
	if search('[<>]','bW' ) >=0
		if getline('.')[col('.')-1] == '<' 
			if  match(getline('.'),'<![CDATA[') > 0
		let l:newname = inputdialog('Found CDATA')
				let b:begdatcol=col('.')
				let b:begdatline=line('.')
				let b:begdat=1
				retu 1
			en
		en
	en
	retu 0
endf
en
 
 
" DelCDataSection()  Is there a CData under the cursor?               {{{1
"    - returns 1 (true)  or 0 (false)

if !exists('*s:DelCDataSection')
fun! s:DelCDataSection()
	
	let l:restore =  s:SavePos()
	if s:InCData()
		let l:sentinel = 'XmLSeNtInElXmL'
		let l:len = strlen(l:sentinel)
		if b:begdat
			if search(']]>','W' ) >=0
				exe "normal! f>a".l:sentinel."\<Esc>"
		   	call cursor(b:begdatline,b:begdatcol)
				exe "normal! \"xd/".l:sentinel."/e-".l:len."\<Cr>"
				exe "normal! ".l:len."x"
				retu 1
			en
		el
			if search('<![CDATA[','bW' ) >=0
				let l:restore =  s:SavePos()
		   	call cursor(b:enddatline,b:enddatcol)
				exe "normal! a".l:sentinel."\<Esc>"
				exe l:restore
				exe "normal! \"xd/".l:sentinel."/e-".l:len."\<Cr>"
				exe "normal! ".l:len."x"
				retu 1
			en
		en
	en
	exe l:restore
	retu 0
endf
en
 
 
" Matches()  Matches de tagname under de cursor                       {{{1
if !exists('*s:Matches')
fun! s:Matches()	
	let l:restore =  s:SavePos()
	if s:TagUnderCursor()
		if s:Match(b:tagName)
			retu
		en
	en
	exe l:restore
endf
en

" MatchesVisual()  Matches de tagname under de cursor                       {{{1
if !exists('*s:MatchesVisual')
fun! s:MatchesVisual()	
	let l:restore =  s:SavePos()
	if s:TagUnderCursor()
		if b:firstWasEndTag
			normal! f>
		en
		normal! gv
		if s:Match(b:tagName)
			if b:firstWasEndTag == 0
				normal! f>
			en 
			retu
		en
		normal! v
	en
	exe l:restore
endf
en

" makeElement() makes the previous woord an tag and close                {{{1
if !exists('*s:makeElement')
function! s:makeElement()
	let b:tagName = @@
	let b:haveAtt = 0
	let l:alone = (match(getline('.'),'^\s*>\s*$') >= 0)
	let l:endOfLine = ((col('.')+1) == col('$'))
	normal! i<pf>
	if b:html_mode && b:tagName =~? b:emptyTags
		if b:haveAtt == 0
			call s:Callback (b:tagName, b:html_mode)
		endif
		if b:xml_use_xhtml
			exe "normal! i/\<Esc>l"
		en
		if  l:endOfLine
			start!
		el
			normal! l
			start
		en
	el
		if b:haveAtt == 0
			call s:Callback (b:tagName, b:html_mode)
		end
		if l:alone
			exe 'normal! o</pa>Ox>>$x'
			start!
		el
			exe 'normal! a</pa>F<'
			start 
		en
	en
endfunction
en

" CloseTagFun() closing the tag which is being typed                  {{{1
if !exists('*s:CloseTagFun')
fun! s:CloseTagFun()	
	let l:restore =  s:SavePos()
	let l:endOfLine = ((col('.')+1) == col('$'))
	if col('.') > 1 && getline('.')[col('.')-2] == '>'
	"Multiline request. <t>></t> -->
	"<t>
	"	    cursor comes here
	"</t>
    normal! h
		if s:TagUnderCursor()
			if b:firstWasEndTag == 0
        if exists('b:did_indent') && b:did_indent == 1
          exe "normal! 2f>s\<Cr>\<Esc>Ox\<Esc>$x"
        else
          exe "normal! 2f>s\<Cr>\<Esc>Ox\<Esc>>>$x"
        en
				start!
				retu
			en
		en
	elseif s:TagUnderCursor()
		if b:firstWasEndTag == 0
			exe "normal! />\<Cr>"
			if b:html_mode && b:tagName =~?  b:emptyTags
				if b:haveAtt == 0
					call s:Callback (b:tagName, b:html_mode)
				en
				if b:xml_use_xhtml
					exe "normal! i/\<Esc>l"
				en
				if l:endOfLine
					start!
					retu
				el
					normal! l
					start
					retu
				en
			el
				if b:haveAtt == 0
					call s:Callback (b:tagName, b:html_mode)
				en
				exe "normal! a</" . b:tagName . ">\<Esc>F<"
				start
				retu
			en
		en
	en
	exe l:restore
	if (col('.')+1) == col("$")
		startinsert!
	else
		normal! l
		startinsert
	en
endf
en

" BlockTag() Surround a visual block with a tag                       {{{1
" Be carefull where You place the block 
" the top    is done with insert!
" the bottem is done with append!
if !exists('*s:BlockTag')
fun! s:BlockTag(multi)
	let l:newname = inputdialog('Surround block  with : ',b:lastTag)
	if strlen( l:newname) == 0
		retu
	en
	let b:lastTag =  l:newname
	let l:newatt = inputdialog('Attributes for '.l:newname.' : ',b:lastAtt)
	if strlen(l:newatt)
		let b:lastAtt = l:newatt
	en

	"Get at the end of the block
	if col('.') == col("'<") && line('.') == line("'<")
		normal! gvov
	en
	if a:multi
		exe "normal! a\<Cr></".l:newname.">\<Cr>\<Esc>"
		let l:eline = line('.')
		normal! gvov
		if col('.') == col("'>") && line('.') == line("'>")
			normal! gvov
		en
		let l:sline = line(".") + 2
		exe "normal! i\<Cr><".l:newname.
			\ (strlen(l:newatt) ? ' '.l:newatt : '' )
			\ .">\<Cr>\<Esc>"
			let l:rep=&report
			let &report=999999
			exe l:sline.','.l:eline.'>'
			let &report= l:rep
			exe 'normal! '.l:sline.'G0mh'.l:eline."G$v'hgq"
	el
		exe "normal! a</".l:newname.">\<Esc>gvov"
		if col('.') == col("'>") && line('.') == line("'>")
			normal! gvov
		en
		exe "normal! i<".l:newname.
			\ (strlen(l:newatt) ? ' '.l:newatt : '' )
			\ .">\<Esc>"
	en
endf
en
" BlockWith() Surround a visual block with a open and a close          {{{1
" Be carefull where You place the block 
" the top    is done with insert!
" the bottem is done with append!
if !exists('*s:BlockWith')
fun! s:BlockWith(open,close)
	if col('.') == col("'<") && line('.') == line("'<")
		normal! gvov
	en
	exe "normal! a\<Cr>;x\<Esc>0cfx".a:close."\<Cr>\<Esc>"
	normal! gvov
	exe "normal! i\<Cr>;x\<Esc>0cfx".a:open."\<Cr>\<Esc>"
endf
en
" vlistitem() Surround a visual block with a listitem para tag      {{{1
" Be carefull where You place the block 
" the top    is done with insert!
" the bottem is done with append!
if !exists('*s:vlistitem')
fun! s:vlistitem()
	"Get at the end of the block
	if col('.') == col("'<") && line('.') == line("'<")
		normal! gvov
	en
	exe "normal! a</para>\<Cr></listitem>\<Esc>mh"
	normal! gvov
	exe "normal! i\<Cr><listitem>\<Cr>\<Tab><para>\<Esc>'h/listitem>/e+1\<Cr>"
endf
en
" Change() Only renames the tag                                         {{{1
if !exists('*s:Change')
fun! s:Change()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:newname = inputdialog('Change tag '.b:tagName.' to : ',b:lastTag) 
		if strlen( l:newname) == 0
			retu
		en
		let b:lastTag =  l:newname
		if s:Match(b:tagName)
			exe b:gotoCloseTag
			exe 'normal! 2lcw' . l:newname . "\<Esc>"
			exe b:gotoOpenTag
			exe 'normal! lcw' . l:newname . "\<Esc>"
		en
	en
endf
en

" Join() Joins two the same tag adjacent sections                    {{{1
if !exists('*s:Join')
fun! s:Join()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:pat = '<[^?!]\S\+\($\| \|\t\|>\)'
		let l:flags='W'
		if  b:firstWasEndTag == 0
			let l:flags='Wb'
		en
		if search(s:OpenOrCloseTag,l:flags) > 0

			let l:secondChar = getline('.')[col('.')]
			if l:secondChar == '/' && b:firstWasEndTag ||l:secondChar != '/' && !b:firstWasEndTag
				exe l:restore
				retu
			en
			let l:end = 0
			if l:secondChar == '/'
				let l:end = 1
			en
			let l:name = s:GetTagName(col('.') + l:end)
			if l:name == b:tagName
				if b:firstWasEndTag
					let b:gotoOpenTag = s:SavePos()
				el
					let b:gotoCloseTag = s:SavePos()
				en
				let l:DeleteTag  = "normal! d/>/e\<Cr>"
				exe b:gotoCloseTag
				exe l:DeleteTag
				exe b:gotoOpenTag
				exe l:DeleteTag
			en
		en
	en
	exe l:restore
endf
en

" ChangeWholeTag() removes attributes and rename tag                     {{{1
if !exists('*s:ChangeWholeTag')
fun! s:ChangeWholeTag()
	if s:TagUnderCursor()
		let l:newname = inputdialog('Change whole tag '.b:tagName.' to : ',b:lastTag)
		if strlen(l:newname) == 0
			retu
		en
		let b:lastTag =  l:newname
		let l:newatt = inputdialog('Attributes for '.l:newname.' : ',b:lastAtt)
		if strlen(l:newatt)
			let b:lastAtt = l:newatt
		en
		if s:Match(b:tagName)
			exe b:gotoCloseTag
			exe "normal! 2lc/>\<Cr>".l:newname."\<Esc>"
			exe b:gotoOpenTag
			exe "normal! lc/>/\<Cr>".l:newname.
			\ (strlen(l:newatt) ? ' '.l:newatt : '' )
			\."\<Esc>"
		en
	en
endf
en

" Delete() Removes a tag '<a id="a">blah</a>' --> 'blah'            {{{1
if !exists('*s:Delete')
fun! s:Delete()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		if s:Match(b:tagName)
			let l:DeleteTag  = "normal! d/>/e\<Cr>"
			exe b:gotoCloseTag
			exe l:DeleteTag
			exe b:gotoOpenTag
			exe l:DeleteTag
		en
	else
		exe l:restore
	en
endf
en


" DeleteSection() Deletes everything between start of open tag and end of  {{{1
" closing tag
if !exists('*s:DeleteSection')
fun! s:DeleteSection()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		if s:Match(b:tagName)
			let l:sentinel = 'XmLSeNtInElXmL'
			let l:len = strlen(l:sentinel)
			let l:rep=&report
			let &report=999999
			exe b:gotoCloseTag
			exe "normal! />\<Cr>a".l:sentinel."\<Esc>"
			exe b:gotoOpenTag
			exe "normal! \"xd/".l:sentinel."/e-".l:len."\<Cr>"
			exe "normal! ".l:len."x"
			let &report= l:rep
		en
	en
endf
en
"
" FoldTag() Fold the tag under the cursor                           {{{1
if !exists('*s:FoldTag')
fun! s:FoldTag()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
	let l:sline = line('.')
		if s:Match(b:tagName)
			if b:firstWasEndTag
				exe '.,'.l:sline.'fold'
			el
				exe l:sline.',.fold'
			en
		en
	el
		exe l:restore
	en
endf
en

" FoldTagAll() Fold all tags of under the cursor             {{{1
" If no tag under the cursor it asks for a tag
if !exists('*s:FoldTagAll')
fun! s:FoldTagAll()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:tname = b:tagName
	el
		let l:tname = inputdialog('Which tag to fold : ',b:lastTag)
		if strlen(l:tname) == 0
			exe l:restore
			retu
		en
		let b:lastTag =  l:tname
	en
	normal! G$
	let l:flag='w'
	while search('<'.l:tname.s:OptAttrib,l:flag) > 0
		let l:flag='W'
		let l:sline = line('.')
		let l:level = 1
		while l:level && search('</\='.l:tname.s:OptAttrib,'W') > 0
			let l:level = l:level + (getline('.')[col('.')] == '/' ? -1 : 1)
		endwhile
		if l:level == 0
			exe l:sline.',.fold'
		el
			let l:tmp = 
				\ inputdialog("The tag ".l:tname."(".l:sline.") doesn't have a closetag")
			break
		en
	endwhile
	exe l:restore
endf
en


" StartTag() provide the opening tag                                    {{{1
if !exists('*s:StartTag')
fun! s:StartTag()
	let l:restore = s:SavePos()
	let l:level = 1
	if getline('.')[col('.')-1] == '<'
	  if s:TagUnderCursor()
	    if b:firstWasEndTag 
				exe 'normal! i<'. b:tagName.">\<Esc>F<"
				retu
			el
	      let l:level = l:level + 1
	    en
		en
	  exe l:restore
	en
	while l:level && search(s:OpenOrCloseTag ,'W') > 0 
		let l:level = l:level + (getline('.')[col('.')] == '/' ? -1 : 1)
	endwhile
	if l:level == 0
	  let l:Name = s:GetTagName(col('.') + 1)
	  exe l:restore
	  exe 'normal! i<'. l:Name.">\<Esc>"
	en
	exe l:restore
endf
en



" EndTag() search for open tag and produce endtaf                 {{{1
if !exists('*s:EndTag')
fun! s:EndTag()
	let l:restore = s:SavePos()
	let l:level = -1
	while l:level && search(s:OpenOrCloseTag,'bW') > 0
		let l:level = l:level + (getline('.')[col('.')] == '/' ? -1 : 1)
	endwhile
	if l:level == 0
	  let l:Name = s:GetTagName(col('.'))
	  exe  l:restore
	  exe 'normal! a</'. l:Name.">\e"
	el
	  exe  l:restore
	en
endf
en


" BeforeTag() surrounds the current tag with a new one                   {{{1
if !exists('*s:BeforeTag')
fun! s:BeforeTag()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:newname =
			\ inputdialog('Surround Before Tag '.b:tagName.' with : ',b:lastTag)
		if strlen(l:newname) == 0
			retu
		en
		let b:lastTag = l:newname
		let l:newatt = inputdialog('Attributes for '.l:newname.' : ',b:lastAtt)
		if strlen(l:newatt)
			let b:lastAtt = l:newatt
		en
		if s:Match(b:tagName)
			exe b:gotoCloseTag
			exe "normal! />\<Cr>a\<Cr></" . l:newname . ">\<Esc>"
			let l:To = line('.')
			exe b:gotoOpenTag
			exe 'normal! i<' . l:newname . 
				\ (strlen(l:newatt) ? ' '.l:newatt : '' )
				\.">\<Cr>\<Esc>"
			let l:rep=&report
			let &report=999999
			exe line('.').','.l:To.'>'
			let &report= l:rep
		en
		exe  l:restore
	en
endf
en

" CommentTag() surrounds the current tag with a new one                   {{{1
if !exists('*s:CommentTag')
fun! s:CommentTag()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		if s:Match(b:tagName)
			exe b:gotoCloseTag
			exe "normal! />\<Cr>a\<Cr>-->\<Esc>"
			let l:To = line('.')
			exe b:gotoOpenTag
			exe "normal! i<!--\<Cr>\<Esc>"
			let l:rep=&report
			let &report=999999
			exe line('.').','.l:To.'>'
			let &report= l:rep
		en
	else
		exe  l:restore
	en
endf
en
" AfterTag() surrounds the tags after the current one with new      {{{1
if !exists('*s:AfterTag')
fun! s:AfterTag()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:newname =
			\ inputdialog('Add Tag After '.b:tagName.' with : ',b:lastTag)
		if strlen(l:newname) == 0
			retu
		en
		let b:lastTag = l:newname
		let l:newatt = inputdialog('Attributes for '.l:newname.' : ',b:lastAtt)
		if strlen(l:newatt)
			let b:lastAtt = l:newatt
		en
		if s:Match(b:tagName)
			exe b:gotoCloseTag
			exe 'normal! i</' . l:newname . ">\<Cr>\<Esc>"
			let l:To = line('.')
			exe b:gotoOpenTag
			exe "normal! />\<Cr>a\<Cr><".l:newname.
				\ (strlen(l:newatt) ? ' '.l:newatt : '' )
				\.">\<Esc>"
			let l:rep=&report
			let &report=999999
			exe line('.').','.l:To.'>'
			let &report= l:rep
		en
	en
	exe  l:restore
endf
en
" ShiftRight() Shift the tag to the right                               {{{1
if !exists('*s:ShiftRight')
fun! s:ShiftRight()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:sline = line('.')
		if s:Match(b:tagName)
			let l:eline = line('.')
			if b:firstWasEndTag
				exe l:eline.','.l:sline.'>'
			el
				exe l:sline.','.l:eline.'>'
			en
		en
	en
endf
en

" ShiftLeft() Shift the tag to the left                                {{{1
if !exists('*s:ShiftLeft')
fun! s:ShiftLeft()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:sline = line('.')
		if s:Match(b:tagName)
			let l:eline = line('.')
			if b:firstWasEndTag
				exe l:eline.','.l:sline.'<'
			el
				exe l:sline.','.l:eline.'<'
			en
		en
	en
endf
en
" FormatTag() visual select the block and use gq                    {{{1
if !exists('*s:FormatTag')
fun! s:FormatTag()
	if s:TagUnderCursor()
		if s:Match(b:tagName)
			exe b:gotoCloseTag
			normal! hhmh
			exe b:gotoOpenTag
			exe "normal! />/e+1\<Cr>v'hgq"
		en
	en
endf
en




" FormatTagAll() Format all tags of name under the cursor             {{{1
" If no tag under the cursor it asks for a tag
if !exists('*s:FormatTagAll')
fun! s:FormatTagAll()
	let l:restore = s:SavePos()
	if s:TagUnderCursor()
		let l:tname = b:tagName
	el
		let l:tname = inputdialog('Format every tag : ')
		if strlen(l:tname) == 0
			exe l:restore
			retu
		en
	en
	normal! G$
	let l:flag = 'w'
	while search('<'.l:tname . s:OptAttrib, l:flag) > 0
		let l:flag = 'W'
		let l:sline = line('.')
		let l:level = 1
		exe "normal! />/e+1\<cr>mh"
		while l:level &&  search('</\='.l:tname . s:EndofName,'W') > 0
			let l:level = l:level + (getline('.')[col('.')] == '/' ? -1 : 1)
		endwhile
		if l:level == 0
			normal! hv'hogq
		el
			let l:tmp = 
				\ inputdialog("The tag ".l:tname."(".l:sline.") doesn't have a closetag")
			break
		en
	endwhile
	exe l:restore
endf
en


" IndentAll() indent all tags multiline                            {{{1
if !exists('*s:IndentAll')
fun! s:IndentAll()

	let l:restore = s:SavePos()
			let l:rep=&report
			let &report=999999
	"shift everything left
	normal! 1G<G<G<G<G<G<GG$
	if search(s:OpenTag,'w') > 0
		let l:level = 1
		normal! f>
		"if there is something after the tag move that to the next line
		if col('.')+1 != col('$')
			echo "after tag".line('.')
			exe "normal! a\<Cr>\<Esc>"
		el
			normal! j
		en
		normal! >Gk$
		while search(s:OpenOrCloseTag,'W') > 0
			"if there is text before the tag then move the tag to the next line
			if  match(getline('.'),s:SpaceInfront) == -1
				exe "normal! i\<Cr>\<Esc>l"
			en
			if getline('.')[col('.')] == '/'
				normal! <G0f>
				"if there is something after the tag move that to the next line
				if col('.')+1 != col('$')
					exe "normal! a\<Cr>\<Esc>"
				en
				let l:level = l:level - 1
			el
				normal! f>
				"if there is something after the tag move that to the next line
				if col('.')+1 != col('$')
					exe "normal! a\<Cr>\<Esc>"
				el
					normal! j0
				en
				normal! >Gk$
				let l:level = l:level + 1
			en
		endwhile
		if l:level 
			let l:tmp = 
			\ inputdialog("The tags opening and closing are unbalanced ".l:level)
		en
	en
	exe l:restore
	let &report= l:rep
endf
en


" Menu options: {{{1
augroup XML_menu_autos
au!
autocmd BufLeave,BufWinLeave *
 \ if &filetype == "xml" ||  &filetype == "html" ||  &filetype == "xhtml" |
   \ amenu disable Xml |
   \ amenu disable Xml.* |
 \ endif
autocmd BufEnter,BufWinEnter *
 \ if &filetype == "xml" ||  &filetype == "html" ||  &filetype == "xhtml" |
   \ amenu enable Xml |
   \ amenu enable Xml.* |
 \ endif
au BufNewFile *
 \ if &filetype == "xml" ||  &filetype == "html" ||  &filetype == "xhtml" |
		 \ call NewFileXML() |
	 \ endif
augroup END
if !exists("g:did_xml_menu")
	let g:did_xml_menu = 1
	:1011 vmenu <script> &Xml.BlockTag\ multi<Tab>V  <Esc>:call <SID>BlockTag(1)<Cr>
	vmenu <script> Xml.BlockTag\ inline<Tab>v  <Esc>:call <SID>BlockTag(0)<CR>
	vmenu <script> Xml.Insert\ listitem<Tab>l <Esc>:call <SID>vlistitem()<CR>
	vmenu <script> Xml.Comment<Tab>< <Esc>:call <SID>BlockWith('<!--','-->')<Cr>
	vmenu <script> Xml.Comment\ With\ CData<Tab>c <Esc>:call <SID>BlockWith('<![CDATA[',']]>')<Cr>
	nmenu <script> Xml.Comment\ Tag<Tab>= <Esc>:call <SID>CommentTag()<Cr>
	imenu <script> Xml.Comment\ Tag<Tab>= <Esc>:call <SID>CommentTag()<Cr>
	nmenu <script> Xml.Change<Tab>c  :call <SID>Change()<CR>
	imenu <script> Xml.Change<Tab>c  <C-C>:call <SID>Change()<CR>
	nmenu <script> Xml.Change\ Whole\ Tag<Tab>C  :call <SID>ChangeWholeTag()<CR>
	imenu <script> Xml.Change\ Whole\ Tag<Tab>C  <C-C>:call <SID>ChangeWholeTag()<CR>
	nmenu <script> Xml.Delete\ Comment<Tab>]  :call <SID>DelComment()<CR>
	imenu <script> Xml.Delete\ Comment<Tab>]  <C-C>:call <SID>DelComment()<CR>
	nmenu <script> Xml.Delete\ Comment\ Section<Tab>}  :call <SID>DelCommentSection()<CR>
	imenu <script> Xml.Delete\ Comment\ Section<Tab>}  <C-C>:call <SID>DelCommentSection()<CR>
	nmenu <script> Xml.Delete\ CData<Tab>[  :call <SID>DelCData()<CR>
	imenu <script> Xml.Delete\ CData<Tab>[  <C-C>:call <SID>DelCData()<CR>
	nmenu <script> Xml.Delete\ CData\ Section<Tab>[  :call <SID>DelCDataSection()<CR>
	imenu <script> Xml.Delete\ CData\ Section<Tab>[  <C-C>:call <SID>DelCDataSection()<CR>
	nmenu <script> Xml.Delete\ Tag<Tab>d  :call <SID>Delete()<CR>
	imenu <script> Xml.Delete\ Tag<Tab>d  <C-C>:call <SID>Delete()<CR>
	nmenu <script> Xml.Delete\ Section<Tab>D  :call <SID>DeleteSection()<CR>
	imenu <script> Xml.Delete\ Section<Tab>D  <C-C>:call <SID>DeleteSection()<CR>
	nmenu <script> Xml.End\ Tag<Tab>e  :call <SID>EndTag()<CR>
	imenu <script> Xml.End\ Tag<Tab>e  <C-C>:call <SID>EndTag()<CR>
	nmenu <script> Xml.Fold\ Comment  :?<!--?,/-->/fo<CR>
	nmenu <script> Xml.Fold\ CData  :?<!\[CDATA\[?,/\]\]>/fo<CR>
	nmenu <script> Xml.Fold\ Processing\ instruc  :?<\?[a-zA-Z]*?,/?>/fo<CR>
	nmenu <script> Xml.Fold\ Tag<Tab>f  :call <SID>FoldTag()<CR>
	nmenu <script> Xml.Fold\ All\ Tags<Tab>F  :call <SID>FoldTagAll()<CR>
	nmenu <script> Xml.Format\ Tags<Tab>g  :call <SID>FormatTag()<CR>
	nmenu <script> Xml.Format\ All\ Tags<Tab>G  :call <SID>FormatTagAll()<CR>
	nmenu <script> Xml.Join<Tab>j  :call <SID>Join()<CR>
	imenu <script> Xml.Join<Tab>j  <C-C>:call <SID>Join()<CR>
	nmenu <script> Xml.Open\ After\ Tag<Tab>O  :call <SID>AfterTag()<CR>
	imenu <script> Xml.Open\ After\ Tag<Tab>O  <C-C>:call <SID>AfterTag()<CR>
	nmenu <script> Xml.open\ Before\ Tag<Tab>o  :call <SID>BeforeTag()<CR>
	imenu <script> Xml.open\ Before\ Tag<Tab>o  <C-C>:call <SID>BeforeTag()<CR>
	nmenu <script> Xml.Match<Tab>5  :call <SID>Matches()<CR>
	imenu <script> Xml.Match<Tab>5  <C-C>:call <SID>Matches()<CR><C-\><C-G>
	nmenu <script> Xml.Shift\ Left<Tab><  :call <SID>ShiftLeft()<CR>
	imenu <script> Xml.Shift\ Left<Tab><  <C-C>:call <SID>ShiftLeft()<CR><C-\><C-G>
	nmenu <script> Xml.Shift\ Right<Tab>>  :call <SID>ShiftRight()<CR>
	imenu <script> Xml.Shift\ Right<Tab>>  <C-C>:call <SID>ShiftRight()<CR><C-\><C-G>
	nmenu <script> Xml.Start\ Tag<Tab>s  :call <SID>StartTag()<CR>
	imenu <script> Xml.Start\ Tag<Tab>s  <C-C>:call <SID>StartTag()<CR><C-\><C-G>
en

" Section: Doc installation                                                {{{1
" Function: s:XmlInstallDocumentation(full_name, revision)              {{{2
"   Install help documentation.
" Arguments:
"   full_name: Full name of this vim plugin script, including path name.
"   revision:  Revision of the vim script. #version# mark in the document file
"              will be replaced with this string with 'v' prefix.
" Return:
"   1 if new document installed, 0 otherwise.
" Note: Cleaned and generalized by guo-peng Wen
"'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function! s:XmlInstallDocumentation(full_name, revision)
    " Name of the document path based on the system we use:
    if (has("unix"))
        " On UNIX like system, using forward slash:
        let l:slash_char = '/'
        let l:mkdir_cmd  = ':silent !mkdir -p '
    else
        " On M$ system, use backslash. Also mkdir syntax is different.
        " This should only work on W2K and up.
        let l:slash_char = '\'
        let l:mkdir_cmd  = ':silent !mkdir '
    endif

    let l:doc_path = l:slash_char . 'doc'
    "let l:doc_home = l:slash_char . '.vim' . l:slash_char . 'doc'

    " Figure out document path based on full name of this script:
    let l:vim_plugin_path = fnamemodify(a:full_name, ':h')
    "let l:vim_doc_path   = fnamemodify(a:full_name, ':h:h') . l:doc_path
    let l:vim_doc_path    = matchstr(l:vim_plugin_path, 
            \ '.\{-}\ze\%(\%(ft\)\=plugin\|macros\)') . l:doc_path
    if (!(filewritable(l:vim_doc_path) == 2))
        echomsg "Doc path: " . l:vim_doc_path
        execute l:mkdir_cmd . l:vim_doc_path
        if (!(filewritable(l:vim_doc_path) == 2))
            " Try a default configuration in user home:
            "let l:vim_doc_path = expand("~") . l:doc_home
            let l:vim_doc_path = matchstr(&rtp,
                  \ escape($HOME, ' \') .'[/\\]\%(\.vim\|vimfiles\)')
            if (!(filewritable(l:vim_doc_path) == 2))
                execute l:mkdir_cmd . l:vim_doc_path
                if (!(filewritable(l:vim_doc_path) == 2))
                    " Put a warning:
                    echomsg "Unable to open documentation directory"
                    echomsg " type :help add-local-help for more informations."
                    return 0
                endif
            endif
        endif
    endif

    " Exit if we have problem to access the document directory:
    if (!isdirectory(l:vim_plugin_path)
        \ || !isdirectory(l:vim_doc_path)
        \ || filewritable(l:vim_doc_path) != 2)
        return 0
    endif

    " Full name of script and documentation file:
    let l:script_name = 'xml.vim'
    let l:doc_name    = 'xml-plugin.txt'
    let l:plugin_file = l:vim_plugin_path . l:slash_char . l:script_name
    let l:doc_file    = l:vim_doc_path    . l:slash_char . l:doc_name

    " Bail out if document file is still up to date:
    if (filereadable(l:doc_file)  &&
        \ getftime(l:plugin_file) < getftime(l:doc_file))
        return 0
    endif

    " Prepare window position restoring command:
    if (strlen(@%))
        let l:go_back = 'b ' . bufnr("%")
    else
        let l:go_back = 'enew!'
    endif

    " Create a new buffer & read in the plugin file (me):
    setl nomodeline
    exe 'enew!'
    exe 'r ' . l:plugin_file

    setl modeline
    let l:buf = bufnr("%")
    setl noswapfile modifiable

    norm zR
    norm gg

    " Delete from first line to a line starts with
    " === START_DOC
    1,/^=\{3,}\s\+START_DOC\C/ d

    " Delete from a line starts with
    " === END_DOC
    " to the end of the documents:
    /^=\{3,}\s\+END_DOC\C/,$ d

    " Remove fold marks:
    "% s/{\{3}[1-9]/    /

    " Add modeline for help doc: the modeline string is mangled intentionally
    " to avoid it be recognized by VIM:
    call append(line('$'), '')
    call append(line('$'), ' v' . 'im:tw=78:ts=8:fen:fdm=marker:ft=help:norl:')

    " Replace revision:
    exe "normal! :1,5s/#version#/ v" . a:revision . "/\<CR>"

    " Save the help document:
    exe 'w! ' . l:doc_file
    exe l:go_back
    exe 'bw ' . l:buf

    " Build help tags:
    exe 'helptags ' . l:vim_doc_path

    return 1
endfunction
" }}}2

let s:revision=
      \ substitute("$Revision: 1.36 $",'\$\S*: \([.0-9]\+\) \$','\1','')
silent! let s:install_status =
    \ s:XmlInstallDocumentation(expand('<sfile>:p'), s:revision)
if (s:install_status == 1)
    echom expand("<sfile>:t:r") . '-plugin v' . s:revision .
        \ ': Help-documentation installed.'
endif


" Mappings of keys to functions                                      {{{1
nnoremap <silent> <buffer> <LocalLeader>5 :call <SID>Matches()<Cr>
vnoremap <silent> <buffer> <LocalLeader>5 <Esc>:call <SID>MatchesVisual()<Cr>
nnoremap <silent> <buffer> <LocalLeader>% :call <SID>Matches()<Cr>
vnoremap <silent> <buffer> <LocalLeader>% <Esc>:call <SID>MatchesVisual()<Cr>
nnoremap <silent> <buffer> <LocalLeader>c :call <SID>Change()<Cr>
nnoremap <silent> <buffer> <LocalLeader>C :call <SID>ChangeWholeTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>d :call <SID>Delete()<Cr>
nnoremap <silent> <buffer> <LocalLeader>D :call <SID>DeleteSection()<Cr>
nnoremap <silent> <buffer> <LocalLeader>e :call <SID>EndTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>] :call <SID>DelComment()<Cr>
nnoremap <silent> <buffer> <LocalLeader>} :call <SID>DelCommentSection()<Cr>
nnoremap <silent> <buffer> <LocalLeader>f :call <SID>FoldTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>F :call <SID>FoldTagAll()<Cr>
nnoremap <silent> <buffer> <LocalLeader>g :call <SID>FormatTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>G :call <SID>FormatTagAll()<Cr>
nnoremap <silent> <buffer> <LocalLeader>I :call <SID>IndentAll()<Cr>
nnoremap <silent> <buffer> <LocalLeader>j :call <SID>Join()<Cr>
nnoremap <silent> <buffer> <LocalLeader>O :call <SID>BeforeTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>= :call <SID>CommentTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>o :call <SID>AfterTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>s :call <SID>StartTag()<Cr>
nnoremap <silent> <buffer> <LocalLeader>[ :call <SID>DelCData()<Cr>
nnoremap <silent> <buffer> <LocalLeader>{ :call <SID>DelCDataSection()<Cr>
nnoremap <silent> <buffer> <LocalLeader>> :call <SID>ShiftRight()<Cr>
nnoremap <silent> <buffer> <LocalLeader>< :call <SID>ShiftLeft()<Cr>
vnoremap <silent> <buffer> <LocalLeader>l <Esc>:call <SID>vlistitem()<Cr>
vnoremap <silent> <buffer> <LocalLeader>v <Esc>:call <SID>BlockTag(0)<Cr>
vnoremap <silent> <buffer> <LocalLeader>V <Esc>:call <SID>BlockTag(1)<Cr>
vnoremap <silent> <buffer> <LocalLeader>c <Esc>:call <SID>BlockWith('<![CDATA[',']]>')<Cr>
vnoremap <silent> <buffer> <LocalLeader>< <Esc>:call <SID>BlockWith('<!--','-->')<Cr>

" Move around functions.
noremap <silent><buffer> [[ m':call <SID>findOpenTag("bW")<CR>
noremap <silent><buffer> ]] m':call <SID>findOpenTag( "W")<CR>
noremap <silent><buffer> [] m':call <SID>findCloseTag( "bW")<CR>
noremap <silent><buffer> ][ m':call <SID>findCloseTag( "W")<CR>

" Move around comments
noremap <silent><buffer> ]" :call search('^\(\s*<!--.*\n\)\@<!\(\s*-->\)', "W")<CR>
noremap <silent><buffer> [" :call search('\%(^\s*<!--.*\n\)\%(^\s*-->\)\@!', "bW")<CR>


setlocal iskeyword=@,48-57,_,192-255,58  
exe 'inoremap <silent> <buffer> '.b:suffix. " ><Esc>db:call <SID>makeElement()<Cr>"
if !exists("g:xml_tag_completion_map")
    inoremap <silent> <buffer> > ><Esc>:call <SID>CloseTagFun()<Cr>
else
    execute "inoremap <silent> <buffer> " . g:xml_tag_completion_map . " ><Esc>:call <SID>CloseTagFun()<Cr>"
endif



finish

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""/*}}}*/
" Section: Documentation content                                          {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
=== START_DOC
*xml-plugin.txt*  Help edit XML and SGML documents.                  #version#

				   XML Edit  ~

A filetype plugin to help edit XML and SGML documents.

This script provides some convenience when editing XML (and some SGML
including HTML) formated documents. It allows you to jump to the
beginning or end of the tag block your cursor is in. '%' will jump
between '<' and '>' within the tag your cursor is in. When in insert
mode and you finish a tag (pressing '>') the tag will be completed. If
you press '>' twice it will place the cursor in the middle of the tags
on it's own line (helps with nested tags).

Usage: Place this file into your ftplugin directory. To add html support
Sym-link or copy this file to html.vim in your ftplugin directory. To activte
the script place 'filetype plugin on' in your |.vimrc| file. See |ftplugins|
for more information on this topic.

If the file edited is of type "html" and "xml_use_html" is  defined then
the following tags will not auto complete: <img>, <input>, <param>,
<frame>, <br>, <hr>, <meta>, <link>, <base>, <area>
        
If the file edited is of type 'html' and 'xml_use_xhtml' is defined the
above tags will autocomplete the xml closing staying xhtml compatable.
ex. <hr> becomes <hr /> (see |xml-plugin-settings|)

Known Bugs {{{1 ~

- < & > marks inside of a CDATA section are interpreted as actual XML tags
  even if unmatched.
- The script can not handle leading spaces such as < tag></ tag> it is
  illegal XML syntax and considered very bad form.
- Placing a literal `>' in an attribute value will auto complete despite that
  the start tag isn't finished. This is poor XML anyway you should use
  &gt; instead.


------------------------------------------------------------------------------
                                                         *xml-plugin-settings*
Options {{{1

(All options must be placed in your |.vimrc| prior to the |ftplugin|
command.)

xml_tag_completion_map
	Use this setting to change the default mapping to auto complete a
	tag. By default typing a literal `>' will cause the tag your editing
	to auto complete; pressing twice will auto nest the tag. By using
	this setting the `>' will be a literal `>' and you must use the new
	mapping to perform auto completion and auto nesting. For example if
	you wanted Control-L to perform auto completion inmstead of typing a
	`>' place the following into your .vimrc: >
            let xml_tag_completion_map = "<C-l>"
<
xml_no_auto_nesting (Not Working!!!!!)
	This turns off the auto nesting feature. After a completion is made
	and another `>' is typed xml-edit automatically will break the tag
	accross multiple lines and indent the curser to make creating nested
	tqags easier. This feature turns it off. Enter the following in your
	.vimrc: >
            let xml_no_auto_nesting = 1
<
xml_use_xhtml
	When editing HTML this will auto close the short tags to make valid
	XML like <hr/> and <br/>. Enter the following in your vimrc to
	turn this option on: >
            let xml_use_xhtml = 1
	if the filetype is xhtml and g:xml_use_xhtml doesn't exists
	the script defines it to be 1. (This also assumes that you have linked
	xml.vim to xhtml.vim. Otherwise this item is moot)
	For a file to be of xhtml type there need to be a doctype declaration!!
	just naming a file something.xhtml doesn't make it type xhtml!
<
xml_no_html
	This turns of the support for HTML specific tags. Place this in your
        .vimrc: >
            let xml_no_html = 1
<
------------------------------------------------------------------------------
                                                        *xml-plugin-mappings*

Mapings and their functions {{{1

Typing '>' will start the tag closing routine.
Typing (Where | means cursor position)
           <para>|
results in
           <para>|</para>

Typing
           <para>>|</para>
results in
           <para>
                |
           </para>
typing a lone '>' and no '<' in front of it accepts the '>' (But having
lone '>' or '<' in a XML file is frown upon except in <!CDATA> sections,
and that will throw of the plugin!!).

Typing </tag> or <tag/> also results in na expanding. So when editing
html type <input .... />

The closing routing also ignores DTD tags '<!,,>' and processing
instructions '<?....?>'. Thus typing these result in no expansion.


<LocalLeader> is a setting in VIM that depicts a prefix for scripts and
plugins to use. By default this is the backslash key `\'. See |mapleader|
for details.

;;              make element out previous word and close it         {{{2
          - when typing a word;; wil create <word>|</word>
						when word on its own line it will be
						<word>
               |
						</word>
            the suffix can be changed by setting 
						let makeElementSuf = ',,,' in your .vimrc
						Thanks to Bart van Deenen
						(http://www.vim.org/scripts/script.php?script_id=632)
						
[ and ] mappings                            {{{2
          <LocalLeader>[        Delete <![CDATA[ ]]> delimiters
          <LocalLeader>{        Delete <![CDATA[ ]]> section
          <LocalLeader>]        Delete <!-- -->      delimiters
          <LocalLeader>}        Delete <!-- -->      section
          [[        Goto to the previous open tag 
          [[        Goto to the next open tag 
          []        Goto to the previous close tag 
          ][        Goto to the next  close tag 
          ["        Goto to the next  comment
          ]"        Goto the previous comment
<LocalLeader>5  Jump to the matching tag.                           {{{2
<LocalLeader>%  Jump to the matching tag.   


<LocalLeader>c  Rename tag                                          {{{2

<LocalLeader>C  Rename tag and remove attributes                    {{{2
		Will ask for attributes

<LocalLeader>d  Deletes the surrounding tags from the cursor.       {{{2
            <tag1>outter <tag2>inner text</tag2> text</tag1>
               |
       Turns to: 
            outter <tag2>inner text</tag2> text
            |

<LocalLeader>D  Deletes the tag and it contents                     {{{2
        - and put it in register x.
            <tag1>outter <tag2>inner text</tag2> text</tag1>
                           |
       Turns to: 
            <tag1>outter text</tag1>

<LocalLeader>e  provide endtag for open tags.                       {{{2
        - provide endtag for open tags. Watch where de cursor is
            <para><listitem>list item content
                                            |
        pressing \e twice produces
            <para><listitem>list item content</para></listitem>

<LocalLeader>f  fold the tag under the cursor                       {{{2
          <para>
            line 1
            line 2
            line 3
          </para>
        \f produces
        +--  5 lines: <para>--------------------------


<LocalLeader>F  all tags of name 'tag' will be fold.                {{{2
      - If there isn't a tag under
        the cursor you will be asked for one.
                  
<LocalLeader>g  Format (Vim's gq function)                          {{{2
			- will make a visual block of tag under cursor and then format using gq

                  
<LocalLeader>G  Format all tags under cursor (Vim's gq function)    {{{2
      - If there isn't a tag under
        the cursor you will be asked for one.

                  
<LocalLeader>I  Indent all tags     {{{2
      - will create a multiline layout every opening tag will be shifted out
				and every closing tag will be shifted in. Be aware that the rendering
				of the XML through XSLT and/or DSSSL, might be changed by this.
				Be aware tha if the file is big, more than 1000 lines, the reformatting
				takes a long time because vim has to make a big undo buffer.
				For example using \I on the example below:
        
				<chapter><title>Indent</title><para>The documentation</para></chapter>

			- Becomes

				<chapter>
					<title>
						Indent
					</title>
					<para>
						The documentation
					</para>
				</chapter>

                  
<LocalLeader>j  Joins two the SAME sections together.               {{{2
      -  The sections must be next to each other. 
			<para> This is line 1
			 of a paragraph. </para>
			<para> This is line 2
			|
			 of a paragraph. </para>
		\j produces
			<para> This is line 1
			 of a paragraph. 
			 This is line 2
			 of a paragraph. </para>

<LocalLeader>l  visual surround the block with listitem and para     {{{2 
				When marking up docbook tekst you have the issue that listitems
				consist of 2 item. This key combination inserts them both,

        blaah
          |
        \l produces
        <listitem>
            <para>blaah</para>
        </listitem>
    
<LocalLeader>o  Insert a tag inside the current one (like vim o)     {{{2
				You are asked for tag and attributes.

        <tag1><tag2><tag3>blaah</tag3></tag2></tag1>
          |
        \o produces
        <tag1>
            <aftertag><tag2><tag3>blaah</tag3></tag2></aftertag>
        </tag1>
    
<LocalLeader>O  Insert a tag outside the current one (like vim O)     {{{2
				You are asked for tag and attributes.
        <tag1><tag2><tag3>blaah</tag3></tag2></tag1>
          |
    \O produces
        <beforetag>
          <tag1><tag2><tag3>blaah</tag3></tag2></tag1>
        </beforetag>

<LocalLeader>s  Insert an opening tag for an closing tag.           {{{2
            list item content</para></listitem>
            |
        pressing \s twice produces
            <para><listitem>list item content</para></listitem>

<LocalLeader>[        Delete <![CDATA[ ]]> delimiters               {{{2
								Removes Only <CDATA[ and ]]> 
								handy when you want	to uncomment a section.
								You need to stand in the tag and not on an other tag
								<![CDATA[  <tag> ]]>
								if you  cursor is outside <tag> but inside the
								CDATA tag the delition works.
<LocalLeader>{        Delete <![CDATA[ ]]> section                  {{{2
								Removes everything tag and Content
<LocalLeader>]        Delete <!-- -->      delimiters               {{{2
								Uncommnet a block.
<LocalLeader>}        Delete <!--  -->      section                  {{{2
								Removes everything tag and Content
<LocalLeader>>  shift right opening tag and closing tag.           {{{2
                shift everything between the tags 1 shiftwide right
<LocalLeader><  shift left opening tag and closing tag.           {{{2
                shift everything between the tags 1 shiftwide left
<LocalLeader>c  Visual Place a CDATA section around the selected text.  {{{2
			Place Cdata section around the block
<LocalLeader><  Visual Place a Comment around the selected text.  {{{2
			Place comment around the block
<LocalLeader>5  Extend the visual selection to the matching tag.  {{{2
<LocalLeader>%  
			Extend the visual selection to the matching tag. Make sure you are at
			the start of the opening tag or the end of the closing tag.
<LocalLeader>v  Visual Place a tag around the selected text.       {{{2
        - You are asked for tag and attributes. You
        need to have selected text in visual mode before you can use this
        mapping. See |visual-mode| for details.
        Be careful where you place the marks.
        The top uses append
        The bottom uses append
        Useful when marking up a text file

------------------------------------------------------------------------------
                                                        *xml-plugin-callbacks*

Callback Functions {{{2 ~

A callback function is a function used to customize features on a per tag
basis. For example say you wish to have a default set of attributs when you
type an empty tag like this:
    You type: <tag>
    You get:  <tag default="attributes"></tag>

This is for any script programmers who wish to add xml-plugin support to
there own filetype plugins.

Callback functions recive one attribute variable which is the tag name. The
all must return either a string or the number zero. If it returns a string
the plugin will place the string in the proper location. If it is a zero the
plugin will ignore and continue as if no callback existed.

The following are implemented callback functions:

HtmlAttribCallback
	This is used to add default attributes to html tag. It is intended
	for HTML files only.

XmlAttribCallback
	This is a generic callback for xml tags intended to add attributes.

							     *xml-plugin-html*
Callback Example {{{2 ~

The following is an example of using XmlAttribCallback in your .vimrc
>
        function XmlAttribCallback (xml_tag)
            if a:xml_tag ==? "my-xml-tag"
                return "attributes=\"my xml attributes\""
            else
                return 0
            endif
        endfunction
<
The following is a sample html.vim file type plugin you could use:
>
  " Vim script file                                       vim600:fdm=marker:
  " FileType:   HTML
  " Maintainer: Devin Weaver <vim (at) tritarget.com>
  " Location:   http://www.vim.org/scripts/script.php?script_id=301

  " This is a wrapper script to add extra html support to xml documents.
  " Original script can be seen in xml-plugin documentation.

  " Only do this when not done yet for this buffer
  if exists("b:did_ftplugin")
    finish
  endif
  " Don't set 'b:did_ftplugin = 1' because that is xml.vim's responsability.

  let b:html_mode = 1

  if !exists("*HtmlAttribCallback")
  function HtmlAttribCallback( xml_tag )
      if a:xml_tag ==? "table"
          return "cellpadding=\"0\" cellspacing=\"0\" border=\"0\""
      elseif a:xml_tag ==? "link"
          return "href=\"/site.css\" rel=\"StyleSheet\" type=\"text/css\""
      elseif a:xml_tag ==? "body"
          return "bgcolor=\"white\""
      elseif a:xml_tag ==? "frame"
          return "name=\"NAME\" src=\"/\" scrolling=\"auto\" noresize"
      elseif a:xml_tag ==? "frameset"
          return "rows=\"0,*\" cols=\"*,0\" border=\"0\""
      elseif a:xml_tag ==? "img"
          return "src=\"\" width=\"0\" height=\"0\" border=\"0\" alt=\"\""
      elseif a:xml_tag ==? "a"
          if has("browse")
	      " Look up a file to fill the href. Used in local relative file
	      " links. typeing your own href before closing the tag with `>'
	      " will override this.
              let cwd = getcwd()
              let cwd = substitute (cwd, "\\", "/", "g")
              let href = browse (0, "Link to href...", getcwd(), "")
              let href = substitute (href, cwd . "/", "", "")
              let href = substitute (href, " ", "%20", "g")
          else
              let href = ""
          endif
          return "href=\"" . href . "\""
      else
          return 0
      endif
  endfunction
  endif

  " On to loading xml.vim
  runtime ftplugin/xml.vim
<
=== END_DOC
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" v im:tw=78:ts=8:ft=help:norl:
" vim600: set foldmethod=marker  tabstop=8 shiftwidth=2 softtabstop=2 smartindent smarttab  :
"fileencoding=iso-8859-15 
=== END_DOC
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""






" Vim settingѕ                                                            {{{1
" vim:tw=78:ts=2:ft=help:norl:
" vim: set foldmethod=marker  tabstop=2 shiftwidth=2 softtabstop=2 smartindent smarttab  :
"fileencoding=utf-8

