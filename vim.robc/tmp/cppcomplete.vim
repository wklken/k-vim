" This plugin helps you complete things like:
" variableName.abc
" variableName->abc
" typeName::abc
" from the members of the struct/class/union that starts with abc.
" If you just type abc will the script complete it with the names that 
" starts with abc and ignore any current scope.
"
" The default key mapping to complete the code are:
" Alt+l in insert mode will try to find the possible completions and display
" them in a popup menu. Also normal completions to the names in
" cppcomplete.tags.
" Alt+j in insert mode will show the popup menu with the last results.
" Selecting one of the  items will paste the text.
" F8/F9 will work in a similar way as Ctrl+N, Ctrl+P in unextended vim so the
" script can be used without the popup menu.
" F5 in insert mode will lookup the class and display it in a preview window
" The key mapping are only tested under Windows and linux and they will not
" work on all platforms. Changing the mappings is easy.
" 
" The plugin is depending on that exuberant ctags has generated a tags file
" called cppcomplete.tags with the same options as in the following example:
" ctags -n -f cppcomplete.tags --fields=+ai --C++-types=+p *
" The script has a command called GenerateTags that executes the above ctags
" command. The tag file cppcomplete.tags is local to the script so you can
" use other tag files without affecting cppcomplete. 
" Java users do not need the --C++-types flag.
"
" For C/C++ can the script generate the cppcomplete.tags from the included
" files for you. This is based on vims checkpath function. The path must be
" set correct, see the vim documentation.
"
" This script do not requires grep anymore but it is supported. If the option
" is set to build an internal list with derived classes and the first
" completion takes a very long time may grep speed things up. 
" For Windows does the DJGPP  port of grep works. 
" You only need grep.exe from the grep'version'b.zip file.
" A good place for grep.exe could be the compilers bin directory.
" The zip file is in the v2gnu directory, it can be downloaded from here:
" http://www.delorie.com/djgpp/getting.html
"
" It is possible to define a set of lines from cppcomplete.tags with regular
" expressions. I call the set for a block. The functions for this:
" BuildBlockFromRegexp the command to build the block, see below.
" NextInBlock jump to the line described in the block, can be called by Shift+F8 
" PrevInBlock same as the above but in the other direction, use Shift+F9
" EchoBlock shows the block itself
" BuildMenuFromBlock builds a menu in GUI mode from the block
" The jumps are done with an internal function so the tag stack will not be
" affected.
"
" Some simple examples there > is the prompt:
" >class:l
" Gives a block with all members that has a scope of a class beginning with l
" >^a.*\ts\t
" all structures beginning with an a
" >^\(a\|b\|c)
" Everything that starts with a,b or c
" The full vim history mechanism can be used.
"
" The script has a number of variables that can be set from the menu in the 
" GUI or wildmenu versions. They are at the top of the script file with descriptions if
" you want to change them more permanent.
"
" For Java do you probably want to generate a cppcomplete.tags file from the
" sources of the Java SDK. The use is like with C/C++ but you will get a
" better result if you change some of the configuration variables.
" The default access is treated as if it was public. 
"
" If you are new to vim and have not heard about ctags, regexp, grep are they
" all described in the online documentation. Just type :help followed by the word you
" want more information about. They are excellent tools that can be used for
" many things.


" BUGS/Features
" This plugin does not really understand any C/C++ code, it is not a real parser.
" It works surprisingly well but can of course give a surprising result. :)
" The current scope is unknown.
" Multidimensional arrays should not have a space between ][, e.g.
" xyz[1][2].abc should be OK but not xyz[1] [2].abc
" The script does not accept functions, e.g. xyc()->abc will not be completed or rather
" it will be completed but from all names beginning with abc.
" (GTK) If the mouse leaves and then reenters the popup menu is the text cursor affected.
" (GTK) The popup is displayed at the mouse position and not the text cursor position.
" For internal use is register c used.
" Requires exuberant ctags.
" The only tested platforms for the popup menu are GTK (linux) and Windows.
" + probably a lot of other issues
"
" Anyway, I have done some testing with MFC, DX9 framework (not COM), Java SDK, STL with
" good results.


" Here is the configuration variables.
"
" The following two options only applies to Windows.
" This is the only tested grep program under windows and the only one that
" works with command.com. If grep is used depends on s:useBuffer and
" s:neverUseGrep.
let s:useDJGPP=has("win32") || has("win16") || has("dos16") || has("dos32")

" This is the only way to get a popup menu under Windows so it should always
" be set if you are running under Windows.
let s:useWinMenu=has("gui_running") && has("gui_win32")

" The rest is platform independent.
" Use an internal buffer instead of grep?
" This should be the fastest option but in some cases is it much faster to use
" grep. See s:neverUseGrep below.
let s:useBuffer=1

" Using an internal buffer probably makes the searches faster but building a
" variable line by line is very expensive in a vim script. The reason is that
" you do not have real variables like in C/C++ but more like names for values. 
" If s:useInternalList is not set will this variable not matter.
let s:neverUseGrep= has("win32") || has("win16") || has("dos16") || has("dos32") 

" The script can make a list with the classes that is derived from another
" classes. This may be faster than looking in cppcomplete.tags but the
" problem is that the list can take a very long time to build. 
" If s:useBuffer is not true is an internal list always used.
let s:useInternalList=0

" Search for typedefs?
let s:searchTDefs=1

" search for macros?
" this is not well supported
let s:searchMacros=0

" How many lines can the menu have?
" Not used under Windows.
let s:maxNMenuLines=35

" Search cppcomplete.tags for class members?
" It is _really_ recommended that this is on or the script will not know of
" classes that is members in other classes.  
let s:searchClassMembers=1

" This is similar to the above but check if xxx in xxx.abc is a class type.
let s:searchClassTags=1

" Search cppcomplete.tags for global variables?
" If they are declared in the current file should the script find them but I turned
" it on anyway. 
let s:searchGlobalVars=1

" ctags sometimes miss to set the access so the check is disabled by default.
" If you are using Java should I turn on this check because ctags does not
" miss the access for Java in the same way as for C++.
let s:accessCheck=0

" I like the preview window but the default is not to display it. 
let s:showPreview=0

" The default language is C/C++, the other option is Java.
let s:currLanguage="C/C++"

" The max size of the popup menu. Perhaps is 50 more than that is useful.
" If you set this to some big value may it take a long time before the
" script has finished.
let s:tooBig=50

" The max number of items that the popup menu will be built from if you 
" are not using an internal buffer on linux.
" This is to prevent very long lists being built internally since this could
" be very slow. The best value depends on how many identical identifiers it is
" in cppcomplete.tags.
" If you are running gvim will you get a warning if the limit is reached.
let s:maxGrepHits=9999

" Setting this option on means that the ancestor can be anything.
" This is a good idea since the script does not know the current scope and
" ctags also (sometimes) treats namespaces as class scopes.
let s:relaxedParents=1

" How the grep program is invoked. The GNU grep has an --mmap option
" for faster memory mapping. This can be set from the menu.
let s:grepPrg="grep"

" Should the access information be displayed on the popup?
let s:showAccess=0

" Should :: show the whole scope with items from the ancestors?
" This does not seems to be the case in MSVC and that is probably a sensible
" way to handle it concerning the main use in class implementation. 
" The default is anyway the more correct show everything alternative.
let s:colonNoInherit=0

" Extra help.
let s:nannyMode=1

" Complete all identifiers from cppcomplete.tags?
" Pretty much the same is already in vim but I prefer the popup instead of
" single stepping with Ctrl-N or Ctrl-P.
let s:completeOrdinary=1

" Max recursive depth search for typedefs. This is mostly to prevent the
" script to enter an endless loop for some special cases.
let s:maxDepth=3

" A new option to give console users with wildmenu access to the menus.
let s:useWildMenu=&wildmenu

" Mappings
" Take them as suggestions only.
imap <F5> <ESC>:PreviewClass<CR>a
if has("gui_running") 
	if (s:useWinMenu)
		imap <A-j> <ESC>:popup PopUp<CR>a
		imap <A-l> <ESC>:BuildMenu<CR>a
	else
		imap <A-l> <ESC>:BuildMenu<CR><RightMouse>a
		imap <A-j> <ESC><RightMouse>a
	endif
endif
imap <F8> <ESC>:InsNextHit<CR>a
imap <F9> <ESC>:InsPrevHit<CR>a
map <S-F9> <ESC>:PrevInBlock<CR>
map <S-F8> <ESC>:NextInBlock<CR>


" From this line should you be more careful if you change anything.
" 
" Commands 
command! -nargs=0 AppendFromCheckpath call s:AppendFromCheckpath()
command! -nargs=0 GenerateFromCheckpath call s:GenerateFromCheckpath()
command! -nargs=0 GenerateTags call s:GenerateTags()
command! -nargs=0 PreviewClass call s:PreCl()
if has("gui_running") || s:useWildMenu
	command! -nargs=0 BuildMenu call s:BuildMenu()
	command! -nargs=0 DoMenu call s:DoMenu()
	command! -nargs=0 RestorePopup call s:SetStandardPopup()
	command! -nargs=0 RefreshMenu call s:RefreshMenu()
	command! -nargs=0 ClearFromTags call s:ClearFromTags()
	command! -nargs=0 InsertToTags call s:InsertToTags()
	command! -nargs=0 ToggleTDefs call s:ToggleTDefs()
	command! -nargs=0 ToggleMacros call s:ToggleMacros()
	command! -nargs=0 BrowseNFiles call s:BrowseNFiles()
	command! -nargs=0 GenerateAndAppend call s:GenerateAndAppend()
	command! -nargs=1 PreviewEntry call s:PreviewEntry(<f-args>)
	command! -nargs=0 ToggleAccess call s:ToggleAccess()
	command! -nargs=0 ToggleGD call s:ToggleGD()
	command! -nargs=0 TogglePreview call s:TogglePreview()
	command! -nargs=0 SetLanguage call s:SetLanguage()
	command! -nargs=0 ToggleRelaxed call s:ToggleRelaxed()
	command! -nargs=0 ToggleGlobalVars call s:ToggleGlobalVars()
	command! -nargs=0 ToggleClassMembers call s:ToggleClassMembers()
	command! -nargs=0 ToggleClassTags call s:ToggleClassTags()
	command! -nargs=0 ToggleFastGrep call s:ToggleFastGrep()
	command! -nargs=0 ToggleShowAccess call s:ToggleShowAccess()
	command! -nargs=0 ToggleInheritance call s:ToggleInheritance()
	command! -nargs=0 ToggleNanny call s:ToggleNanny()
	command! -nargs=0 ShowCurrentSettings call s:ShowCurrentSettings()
	command! -nargs=0 SetMaxHits call s:SetMaxHits()
	command! -nargs=0 BuildMenuFromBlock call s:BuildMenuFromBlock()
endif
command! -nargs=0 InsPrevHit call s:InsPrevHit()
command! -nargs=0 InsNextHit call s:InsNextHit()

command! -nargs=0 BuildBlockFromRegexp call s:BuildBlockFromRegexp()
command! -nargs=0 NextInBlock call s:NextInBlock()
command! -nargs=0 PrevInBlock call s:PrevInBlock()
command! -nargs=0 EchoBlock call s:EchoBlock()
command! -nargs=1 JumpToLineInBlock call s:JumpToLineInBlock(<f-args>)


" some variables for internal use
let s:listAge=0
let s:bufAge=0
let s:lastHit=0
let s:hitList=""
let s:regexBlock=""
let s:nannyAsked="\n"
if s:useBuffer
	let s:cutBack='\@>'
	let s:groupS='\%('
else
	let s:cutBack=''
	let s:groupS='\('
endif

if has("win32") || has("win16") || has("dos16") || has("dos32")
	let s:ctagsTemp=tempname()
	let s:grepTemp=tempname()
endif
" build the gui menu
if has("gui_running") || s:useWildMenu
	set mousemodel=popup
	silent! aunmenu &cppcomplete
	silent! tunmenu &cppcomplete
	amenu &cppcomplete.&GenerateTags.&Rebuild\ from\ current\ directory<Tab>:GenerateTags   :GenerateTags<CR>
	tmenu &cppcomplete.&GenerateTags.&Rebuild\ from\ current\ directory Generate a new cppcomplete.tags file from the files in the current dorectory
	amenu &cppcomplete.&GenerateTags.&Append\ from\ current\ directory<Tab>:GenerateAndAppend   :GenerateAndAppend<CR>
	tmenu &cppcomplete.&GenerateTags.&Append\ from\ current\ directory Append instead of creating a totally new one.
	amenu &cppcomplete.&GenerateTags.&Browse\ file\ to\ append<Tab>:BrowseNFiles   :BrowseNFiles<CR>
	tmenu &cppcomplete.&GenerateTags.&Browse\ file\ to\ append Append a file using the file browser.
	amenu &cppcomplete.&GenerateTags.A&uto\ Generate\ a\ new\ one<Tab>:GenerateFromCheckpath   :GenerateFromCheckpath<CR>
	tmenu &cppcomplete.&GenerateTags.A&uto\ Generate\ a\ new\ one Auto generate a new cppcomplete.tags file for C/C++.
	amenu &cppcomplete.&GenerateTags.Aut&o\ Generate\ and\ append<Tab>:AppendFromCheckpath   :AppendFromCheckpath<CR>
	tmenu &cppcomplete.&GenerateTags.Aut&o\ Generate\ and\ append Auto generate and append.
	amenu &cppcomplete.&Use\ generated\ tag\ file\ in\ tags.&No<TAB>:ClearFromTags   :ClearFromTags<CR>
	tmenu &cppcomplete.&Use\ generated\ tag\ file\ in\ tags.&No Do not use cppcomplete.tags as an ordinary tag file
	amenu &cppcomplete.&Use\ generated\ tag\ file\ in\ tags.&Yes<Tab>:InsertToTags   :InsertToTags<CR>
	tmenu &cppcomplete.&Use\ generated\ tag\ file\ in\ tags.&Yes Use cppcomplete.tags as an ordinary tag file
	amenu &cppcomplete.-SEP1-   <NOP>
	amenu &cppcomplete.&Toggle\ search\ options.&Typedefs<Tab>:ToggleTDefs   :ToggleTDefs<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.&Typedefs Toggle search for typedefs
	amenu &cppcomplete.&Toggle\ search\ options.&Macros<Tab>:ToggleMacros   :ToggleMacros<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.&Macros Toggle search for macros
	amenu &cppcomplete.&Toggle\ search\ options.&Access\ check<Tab>:ToggleAccess  :ToggleAccess<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.&Access\ check Should only  items with the proper access be displayed?
	amenu &cppcomplete.&Toggle\ search\ options.&Relaxed\ ancestor\ check<Tab>:ToggleRelaxed   :ToggleRelaxed<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.&Relaxed\ ancestor\ check Allow inner classes that may be wrong but hard to check?
	amenu &cppcomplete.&Toggle\ search\ options.Global\ &variables<Tab>:ToggleGlobalVars  :ToggleGlobalVars<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.Global\ &variables Search cppcomplete.tags for global variables?
	amenu &cppcomplete.&Toggle\ search\ options.&Classes\ as\ class\ members<Tab>:ToggleClassMembers  :ToggleClassMembers<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.&Classes\ as\ class\ members Complete classes that is members of other classes?
	amenu &cppcomplete.&Toggle\ search\ options.Inner\ class\ &names\ in\ tags<Tab>:ToggleClassTags  :ToggleClassTags<CR>
	tmenu &cppcomplete.&Toggle\ search\ options.Inner\ class\ &names\ in\ tags Search cppcomplete.tags for classes that is defined in other classes scope?
	amenu &cppcomplete.Toggle\ &misc\ options.&Show\ access<Tab>:ToggleShowAccess  :ToggleShowAccess<CR>
	tmenu &cppcomplete.Toggle\ &misc\ options.&Show\ access Should the popup menu also display access information?
	amenu &cppcomplete.Toggle\ &misc\ options.&Inheritance\ for\ ::<Tab>:ToggleInheritance  :ToggleInheritance<CR>
	tmenu &cppcomplete.Toggle\ &misc\ options.&Inheritance\ for\ :: Should :: also show inherited items?
	amenu &cppcomplete.Toggle\ &misc\ options.&Nanny\ mode<Tab>:ToggleNanny  :ToggleNanny<CR>
	tmenu &cppcomplete.Toggle\ &misc\ options.&Nanny\ mode Try to give some extra help.
	amenu &cppcomplete.Toggle\ &misc\ options.&Fast\ grep<Tab>:ToggleFastGrep  :ToggleFastGrep<CR>
	tmenu &cppcomplete.Toggle\ &misc\ options.&Fast\ grep --mmap option for GNU grep
	amenu &cppcomplete.Toggle\ &misc\ options.&Preview<Tab>:TogglePreview   :TogglePreview<CR>
	tmenu &cppcomplete.Toggle\ &misc\ options.&Preview Open a preview window after completion?
	amenu &cppcomplete.-SEP2-   <NOP>
	amenu &cppcomplete.&Preview\ menu.Scan\ for\ new\ &items<Tab>:RefreshMenu   :RefreshMenu<CR>
	tmenu &cppcomplete.&Preview\ menu.Scan\ for\ new\ &items Scan cppcomplete.tags for classes, structures and unions
	amenu &cppcomplete.&Preview\ menu.&Classes.*****\ \ \ Nothing\ yet\ \ \ *****   <NOP>
	amenu &cppcomplete.&Preview\ menu.&Structures.*****\ \ \ Nothing\ yet\ \ \ ******   <NOP>
	amenu &cppcomplete.&Preview\ menu.&Unions.*****\ \ \ Nothing\ yet\ \ \ *****   <NOP>
	amenu &cppcomplete.&Block\ menu.&Build\ Menu\ From\ Block<Tab>:BuildMenuFromBlock   :BuildMenuFromBlock<CR>
	tmenu &cppcomplete.&Block\ menu.&Build\ Menu\ From\ Block Build a menu from the items in the current block.
	amenu &cppcomplete.-SEP3-   <NOP>
	amenu &cppcomplete.S&et\ C/C++\ or\ Java<Tab>:SetLanguage   :SetLanguage<CR>
	tmenu &cppcomplete.S&et\ C/C++\ or\ Java Set the current language used.
	amenu &cppcomplete.Set\ max\ number\ of\ &hits\ displayed<Tab>:SetMaxHits   :SetMaxHits<CR>
	tmenu &cppcomplete.Set\ max\ number\ of\ &hits\ displayed How many items should the popup menu have?
	amenu &cppcomplete.&Show\ current\ settings<Tab>ShowCurrentSettings   :ShowCurrentSettings<CR>
	tmenu &cppcomplete.&Show\ current\ settings List the current settings.
	amenu &cppcomplete.-SEP4-   <NOP>
	amenu &cppcomplete.&RestorePopUp<Tab>:RestorePopup :RestorePopup<CR>
	tmenu &cppcomplete.&RestorePopUp Restores the popup menu.
endif

function! s:PreCl()
	if &previewwindow		
		call confirm("You are not supposed to do this then you\nalready are in the Preview window.","&OK",1,"Error")
		return
	endif
	if ! s:CheckForTagFile()
		return
	endif
	let oldParents=s:relaxedParents
	call s:GetPieces()
	let s:relaxedParents=oldParents
	if (s:gotCType)
		call s:PreviewEntry(s:clType)
	endif
endfunction
function! s:PreviewEntry(entry)
	if &previewwindow		
		call confirm("You are not supposed to do this then you\nalready are in the Preview window.","&OK",1,"Error")
		return
	endif
	if ! s:CheckForTagFile()
		return
	endif
	if (a:entry!="")
		let tagsSav=&tags
		let &tags="cppcomplete.tags" 
		execute "ptag " . a:entry
		silent! wincmd P
		if &previewwindow
			normal! zt
			silent! wincmd p
		endif
		let &tags=tagsSav
	endif
endfunction
function! s:TogglePreview()
	let s:showPreview=!s:showPreview
endfunction
function! s:ToggleAccess()
	let s:accessCheck=!s:accessCheck
	if s:accessCheck
		let cText="Access check enabled"
	else
		let cText="Access check disabled"
	endif
	call confirm(cText, "&OK",1,"Info")
endfunction
function! s:ToggleTDefs()
	let s:searchTDefs=!s:searchTDefs
	if (s:searchTDefs)
		let cText="Typedefs is now included in the search"
	else
		let cText="Further searches will not look for typedefs"
	endif
	call confirm(cText,"&OK",1,"Info")
endfunction
function! s:ToggleMacros()
	let s:searchMacros=!s:searchMacros
	if (s:searchMacros)
		let cText="Macros is now included in the search"
	else
		let cText="Further searches will not look for macros"
	endif
	call confirm(cText,"&OK",1,"Info")
endfunction
function! s:ToggleRelaxed()
	let s:relaxedParents=! s:relaxedParents
	if s:relaxedParents
		let cText="Ancestor check is now set to relaxed"
	else
		let cText="Strict ancestor check is now enabled"
	endif
	call confirm(cText, "&OK",1,"Info")
endfunction
function! s:ToggleClassMembers()
	let s:searchClassMembers=! s:searchClassMembers
	if s:searchClassMembers
		let cText="Search for classes as class members is enabled"
	elseif confirm("This is not recommended if your classes\contains other classes as members","&Do it anyway\n&Cancel",2,"Warning")==1
		let cText="No search for classes as class members"
	else
		let s:searchClassMembers=1
		return
	endif
	call confirm(cText, "&OK",1, "Info")
endfunction
function! s:ToggleClassTags()
	let s:searchClassTags=! s:searchClassTags
	if s:searchClassTags
		let cText="Search for class names is enabled"
	else
		let cText="No search for class names"
	endif
	call confirm(cText, "&OK",1, "Info")
endfunction
function! s:ToggleFastGrep()
	if (s:grepPrg=="grep")
		let s:grepPrg="grep --mmap"
		let cText="Fast GNU grep enabled"
	else
		let s:grepPrg="grep"
		let cText="Standard grep is now used"
	end
	call confirm(cText, "&OK",1, "Info")
endfunction
function! s:ToggleInheritance()
	let s:colonNoInherit=! s:colonNoInherit
	if s:colonNoInherit
		let cText=":: will not show items from the ancestors"
	else
		let cText=":: will show the whole scope with items from the ancestors"
	endif
	call confirm(cText, "&OK",1, "Info")
endfunction
function! s:ToggleNanny()
	let s:nannyMode=! s:nannyMode
	if s:nannyMode
		let cText="Nanny mode enabled"
	else
		let cText="Nanny mode disabled"
	endif
	call confirm(cText,"&OK",1,"Info")
endfunction
function! s:ToggleShowAccess()
	let s:showAccess=! s:showAccess
	if s:showAccess
		let cText="Access information will be displayed if available on the popup menu"
	else
		let cText="No access information will be displayed"
	endif
	call confirm(cText, "&OK",1, "Info")
endfunction
function! s:ToggleGlobalVars()
	let s:searchGlobalVars=! s:searchGlobalVars
	if s:searchGlobalVars
		let cText="Search for global variables is enabled"
	else
		let cText="No search for global variables"
	endif
	call confirm(cText, "&OK",1, "Info")
endfunction
function! s:InsertToTags()
	if (match(&tags, "cppcomplete.tags,",0)>=0)
		call confirm("cppcomplete.tags is already in tags","&OK",1,"Info")
	else
		let &tags="cppcomplete.tags," . &tags
	endif
endfunction
function! s:ClearFromTags()
	if (match(&tags,"cppcomplete.tags")<0)
		call confirm("tags did not include cppcomplete.tags","&OK",1,"Info")
	else
		let &tags=substitute(&tags,"cppcomplete.tags.","","g")
	endif
endfunction

function! s:SetGrepArg(argtxt)
	silent! call delete(s:grepTemp)
	split
	silent! execute "edit! " s:grepTemp
	let @c=a:argtxt
	normal! "cp
	silent! w
	silent! bwipeout
endfunction
function! s:RefreshMenu()	
	if ! s:CheckForTagFile()
		return
	endif
	let spaceAfter="[^!\t]\\+\t"
	let res=confirm("If you have a big cppcomplete.tags file may strange things happen", "&All\n&Just items in the current directory\n&Cancel",2,"Warning")
	if res==1
		let fileSelect=spaceAfter
	elseif res==3
		return
	else
		let fileSelect="[^\\/\t]\\+\t"
	endif
	silent! aunmenu cppcomplete.Preview.Classes
	silent! aunmenu cppcomplete.Preview.Structures
	silent! aunmenu cppcomplete.Preview.Unions
	let cf=0
	let sf=0
	let uf=0
	if s:useBuffer && s:neverUseGrep
		split
		let items=""
		call s:CheckHiddenLoaded()
		let x=line(".")
		execute ":call search('^" . spaceAfter . fileSelect . spaceAfter . "\\%(c\\|s\\|u\\)','W')"
		while line(".")!=x
			let x=line(".")
			normal! "cyy$
			let items=items . @c
			execute ":call search('^" . spaceAfter . fileSelect . spaceAfter . "\\%(c\\|s\\|u\\)','W')"
		endwhile
		quit
	elseif s:useDJGPP
		call s:SetGrepArg("'^" . spaceAfter . fileSelect . spaceAfter . s:groupS . "c\\|s\\|u\\)' cppcomplete.tags")
		silent! let items=system(s:grepPrg . " @" . s:grepTemp)
	else
		let items=system(s:grepPrg . " '^" . spaceAfter . fileSelect . spaceAfter . s:groupS . "c\\|s\\|u\\)' cppcomplete.tags")
	endif
	let nextM=0
	let nclines=0
	let nslines=0
	let nulines=0
	let cMore=""
	let sMore=""
	let uMore=""

	while match(items,"\t",nextM)>0
		let oldM=nextM
		let @c=strpart(items,nextM,match(items,"\t",nextM)-nextM)
		let nextM=matchend(items,"\n",nextM)
		if nextM<0
			let nextM=strlen(items)
		endif
		let mc=match(items,"^[^\t]*\t[^\t]*\t[^\t]*\tc",oldM)
		let ms=match(items,"^[^\t]*\t[^\t]*\t[^\t]*\ts.*",oldM)
		if (mc>=0) && (mc<nextM)
			let cf=1
			execute "amenu .200 &cppcomplete.&Preview.&Classes." . cMore . @c . " :PreviewEntry " . @c ."<CR>" 
			let nclines=nclines+1
			if (! s:useWinMenu)
				if (nclines%s:maxNMenuLines)==0
					let cMore=cMore . "More."
				endif
			endif
		elseif (ms>=0) && (ms<nextM)
			let sf=1
			execute "amenu .300 &cppcomplete.&Preview.&Structures." . sMore . @c . " :PreviewEntry " . @c ."<CR>"
			let nslines=nslines+1
			if (! s:useWinMenu)
				if (nslines%s:maxNMenuLines)==0
					let sMore=sMore . "More."
				endif
			endif

		else
			let uf=1
			execute "amenu .400 &cppcomplete.&Preview.&Unions." . uMore . @c . " :PreviewEntry " . @c ."<CR>"
			let nulines=nulines+1
			if (! s:useWinMenu)
				if (nulines%s:maxNMenuLines)==0
					let uMore=uMore . "More."
				endif
			endif

		endif
	endwhile
	if cf==0
		amenu &cppcomplete.&Preview.&Classes.*****\ \ \ no\ classes\ found\ \ \ ***** <NOP>
	endif
	if sf==0
		amenu &cppcomplete.&Preview.&Structures.*****\ \ \ no\ structures\ found\ \ \ ***** <NOP>
	endif
	if uf==0
		amenu &cppcomplete.&Preview.&Unions.*****\ \ \ no\ unions\ found\ \ \ ***** <NOP>
	endif
endfunction

function! s:BuildMenuFromBlock()
	let hittedList="\n"
	if s:regexBlock==""
		call confirm("No block to build the menu from.\nYou must first create the block with the\n:BuildBlockFromRegexp command.","&OK",1,"Error")
		return
	endif
	silent! aunmenu cppcomplete.Block\ menu.menu\ built\ from\ regexp
	let spaceAfter="[^!\t]\\+\t"
	let nLines=0
	let skippedLines=0
	let nextM=0
	let grouped=confirm("Which type of menu","&Grouped by visibility\n&Not grouped",1,"Question")
	if grouped!=1
		if grouped!=2
			return
		else
			let grouped=0
		endif
	endif
	let bMore=""
	let uMore=""
	let uLines=0
	while match(s:regexBlock, "\t", nextM)>0
		let oldM=nextM
		let nLines=nLines+1
		let @c=strpart(s:regexBlock, nextM, match(s:regexBlock,"\t",nextM)-nextM)
		let nextM=matchend(s:regexBlock,"\n",nextM)
		if nextM<0
			let nextM=strlen(s:regexBlock)
		endif
		if grouped
			let gStart=matchend(s:regexBlock,"^[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t" . s:groupS . "class\\|struct\\|union\\|\\<interface\\):",oldM)
			if gStart>matchend(s:regexBlock,"\n",oldM)
				let gStart=-1
			endif
			if gStart<0
				let uLines=uLines+1
				if !s:useWinMenu
					if (uLines % s:maxNMenuLines)==0
						let uMore=uMore . "More."
					endif
				endif
				let group="uncategorized." . uMore 
			else
				let gEnd=match(s:regexBlock,"[\n\t]",gStart)
				let group=strpart(s:regexBlock, gStart, gEnd-gStart) . "."
			endif
		else
			let group=""
			if !s:useWinMenu
				if ((nLines-skippedLines) % s:maxNMenuLines)==0
					let bMore=bMore . "More."
				endif
			endif
		endif
		if match(hittedList, "\n" . group . @c . "\n")<0
			let hittedList=hittedList . group . @c . "\n"
			execute "amenu &cppcomplete.&Block\\ menu.menu\\ built\\ from\\ regexp." . bMore . group . @c . " :JumpToLineInBlock " . nLines . "<CR>"
		else
			let skippedLines=skippedLines+1
		endif
	endwhile
	if nLines==0
		call confirm("Could not build the menu", "&OK",1,"Error")
	elseif skippedLines==0
		call confirm("A menu with " . nLines . " items has been built.\nIt is placed in the Block menu", "&OK", 1, "Info")
	else
		call confirm("From the original " . nLines . " items was " . skippedLines . "\n skipped because of name clashes.\nThe resulting menu can be reached from the Block menu.", "&OK", 1, "Info")
	endif
endfunction

function! s:SetStandardPopup()
	aunmenu PopUp
	" The popup menu
	an 1.10 PopUp.&Undo			u
	an 1.15 PopUp.-SEP1-			<Nop>
	vnoremenu 1.20 PopUp.Cu&t		"+x
	vnoremenu 1.30 PopUp.&Copy		"+y
	cnoremenu 1.30 PopUp.&Copy		<C-Y>
	nnoremenu 1.40 PopUp.&Paste		"+gP
	cnoremenu 1.40 PopUp.&Paste		<C-R>+
	if has("virtualedit")
		vnoremenu <script> 1.40 PopUp.&Paste	"-c<Esc><SID>Paste
		inoremenu <script> 1.40 PopUp.&Paste	<Esc><SID>Pastegi
	else
		vnoremenu <script> 1.40 PopUp.&Paste	"-c<Esc>gix<Esc><SID>Paste"_x
		inoremenu <script> 1.40 PopUp.&Paste	x<Esc><SID>Paste"_s
	endif
	vnoremenu 1.50 PopUp.&Delete		x
	an 1.55 PopUp.-SEP2-			<Nop>
	vnoremenu 1.60 PopUp.Select\ Blockwise	<C-V>
	an 1.70 PopUp.Select\ &Word		vaw
	an 1.80 PopUp.Select\ &Line		V
	an 1.90 PopUp.Select\ &Block		<C-V>
	an 1.100 PopUp.Select\ &All		ggVG
endfunction
function! s:BuildIt()
	let s:nHits=0
	let s:hitList="\n"
	if has("gui_running") || s:useWildMenu
		aunmenu PopUp
	endif
	if (s:matches=="")
		if has("gui_running") || s:useWildMenu
			amenu PopUp.****\ \ no\ completions\ found\ \ *****   :let @c=''<CR>
		endif
		return
	endif
	let nextM=0
	let line=1
	let pMore=""
	let totHits=0

	while (s:tooBig>s:nHits) && (match(s:matches,"\t",nextM)>0)
		let totHits=totHits+1
		let @c=strpart(s:matches, nextM, match(s:matches,"\t",nextM)-nextM)
		if match(s:hitList,"\n" . substitute(@c,"\\~", ":","g") . "\n")<0
			let sAcc=matchend(s:matches,"access:",nextM)
			let accEnd=match(s:matches,"\n",nextM) 
			if (accEnd<0)
				let accEnd=strlen(s:matches)
			endif
			if (sAcc>0) && (sAcc<accEnd) && s:showAccess
				let accStr="<Tab>" . strpart(s:matches, sAcc, accEnd-sAcc) 
			else
				let accStr=""
			endif
			if has("gui_running") || s:useWildMenu
				execute "silent amenu PopUp." . pMore . @c . accStr . "  :let @c=\"" . @c ."\"<Bar>DoMenu<CR>"
			endif
			let s:hitList=s:hitList . substitute(@c,"\\~", ":","g") . "\n"
			let s:nHits=s:nHits+1
			let line=line+1
			if (! s:useWinMenu)
				if (line % s:maxNMenuLines)==0
					let pMore=pMore  . "More."
				endif
			endif
		endif
		let nextM=matchend(s:matches,"\n",nextM)
		if nextM<0
			let nextM=strlen(s:matches)
		endif
	endwhile
	let s:hitList=strpart(s:hitList,1)
	if (s:nHits>=s:tooBig)
		let s:nHits=s:nHits+1
		let s:hitList=s:hitList . "xxxxxxMAX_NR_OF_HITSxxxxxx\n"
		if has("gui_running") || s:useWildMenu 
			if !s:useWinMenu
				execute "amenu PopUp." . pMore . "xxxxxxMAX_NR_OF_HITSxxxxxx <NOP>"
			else
				amenu PopUp.****\ \ Max\ number\ of\ hits\ reched\ **** <NOP>
			endif
		endif
		call confirm( "Max number of hits reached", "&OK", 1,"Warning")
	elseif totHits>=s:maxGrepHits
		call confirm("The number of items the popup was built from\nis equal to s:maxGrepHits.\nMore completions may exists.","&OK",1,"Warning")
	endif
	if s:nHits==0 && (has("gui_running") || s:useWildMenu)
		amenu PopUp.*****\ \ Strange\ output\ from\ grep\ \ *****  :let @c=""<CR>
	endif
endfunction
function! s:xAndBack()
	let colP = col(".")
	normal! x
	if (col(".")==colP)
		normal! h
	endif
endfunction
function! s:RemoveTyped()
	if (s:uTyped=="\\~")
		call s:xAndBack()
	elseif (s:uTyped!="")
		if (strlen(s:uTyped)>1)
			if (strlen(s:uTyped)==3) && (match(s:uTyped,"\\~")>=0)
				call s:xAndBack()
			else
				normal! db
			endif
		endif
		call s:xAndBack()
	endif
	let c = getline(line("."))[col(".") - 1]
	if (c=="~")
		call s:xAndBack()
	endif
endfunction
function! s:DoMenu()
	if @c==""
		return
	endif
	let colP = col(".")
	normal! l
	if colP!=col(".")
		normal! hh
		let strangeFix=1
	else
		let strangeFix=0
	endif
	call s:RemoveTyped()
	normal! "cp
	if (strangeFix)
		normal! l
	endif
	if (s:showPreview)
		call s:PreviewEntry(@c)
	endif
	let s:uTyped=""
endfunction
function! s:InsNextHit()
	if (s:IsHitted())
		call s:DelHit()
		let s:lastHit=s:lastHit+1
		if (s:lastHit>s:nHits)
			let s:lastHit=1
		endif
		call s:InsHit()
	else
		let s:lastHit=1
		let winMenuSav=s:useWinMenu
		let s:useWinMenu=0
		call s:BuildMenu()
		let s:useWinMenu=winMenuSav
		if (s:nHits>0)
			call s:RemoveTyped()
			call s:InsHit()
		else
			call confirm("No completions was found","&OK",1,"Error")
			let s:lastHit=0
		endif
	endif
endfunction
function! s:InsPrevHit()
	if (s:IsHitted())
		call s:DelHit()
		let s:lastHit=s:lastHit-1
		if (s:lastHit<1)
			let s:lastHit=s:nHits
		endif
		call s:InsHit()
	else
		let winMenuSav=s:useWinMenu
		let s:useWinMenu=0
		call s:BuildMenu()
		let s:useWinMenu=winMenuSav
		let s:lastHit=s:nHits
		if (s:nHits>0)
			call s:RemoveTyped()
			call s:InsHit()
		else
			call confirm("No completions was found","&OK",1,"Error")
		endif
	endif
endfunction

function! s:IsHitted()	
	if (s:lastHit>0) && expand("<cword>")==substitute(s:CurrentHit(),":","","g")
		return expand("<cword>")!=""
	endif
	return 0
endfunction
function! s:CurrentHit()
	let prevM=0
	let nextM=matchend(s:hitList,"\n")
	let toGo=s:lastHit
	while (toGo>1) && match(s:hitList, "\n", nextM)
		let prevM=nextM
		let nextM=matchend(s:hitList,"\n",nextM)
		if (nextM<0)
			let nextM=strlen(s:hitList)
		endif
		let toGo=toGo-1
	endwhile
	if (toGo==1)
		return strpart(s:hitList, prevM, nextM-prevM-1)
	endif
	return ""
endfunction
function! s:DelHit()
	let prevTyped=s:uTyped
	let s:uTyped=substitute(s:CurrentHit(),":","\\~","g")
	call s:RemoveTyped()
	let s:uTyped=prevTyped
endfunction
function! s:InsHit()
	let @c=substitute(s:CurrentHit(),":","\\~","g")
	normal! "cp
	if (s:showPreview)
		call s:PreviewEntry(@c)
	endif
endfunction

function! s:UpdateInheritList()
	let spaceAfter="[^!\t]\\+\t"
	let after3=spaceAfter . spaceAfter . spaceAfter
	if (s:listAge!=getftime("cppcomplete.tags"))
		if s:useBuffer && s:neverUseGrep
			split
			let s:inheritsList="\n"
			call s:CheckHiddenLoaded()
			let x=line(".")
			execute ":call search('^" . after3 . ".*inherits:','W')"
			while line(".")!=x
				let x=line(".")
				normal! "cyy$
				let s:inheritsList=s:inheritsList . @c
				execute ":call search('^" . after3 . ".*inherits:','W')"
			endwhile
			quit
		elseif s:useDJGPP
			call s:SetGrepArg("'^" . after3 . ".*" ."inherits:.*' cppcomplete.tags")
			silent! let s:inheritsList="\n" . system(s:grepPrg . " @" . s:grepTemp)
		else
			let s:inheritsList="\n" . system(s:grepPrg . " '^" . after3 . ".*" ."inherits:.*' cppcomplete.tags")
		endif
		let s:listAge=getftime("cppcomplete.tags")
	endif
endfunction
function! s:BuildSinglePass()
	if s:tooBig<=s:nHits
		return
	endif
	normal! ^
	call search("\t")
	normal! "cy^
	if match(s:hitList, "\n" . substitute(@c,"\\~",":","g") . "\n")<0
		if has("gui_running") || s:useWildMenu
			execute "amenu PopUp." . s:menuMore . @c . "  :let @c=\"" . @c ."\"<Bar>DoMenu<CR>"
		endif
		let s:hitList=s:hitList . substitute(@c,"\\~", ":", "g") . "\n"
		let s:nHits=s:nHits+1
		if (s:nHits%s:maxNMenuLines)==0
			if ! s:useWinMenu
				let s:menuMore=s:menuMore . "More."
			endif
		endif
	endif
endfunction

function! s:SetMatchesFromBuffer(grepArg)
	let s:nHits=0
	let s:hitList="\n"
	let s:menuMore=""
	let s:matches=""
	if has("gui_running") || s:useWildMenu
		if ! s:showAccess
			aunmenu PopUp
		endif
	endif
	split
	call s:CheckHiddenLoaded()
	silent! execute s
	if s:uTyped!=""
		if s:showAccess
			silent! execute s:RangeOf(s:uTyped) . "global/" . a:grepArg . '/let s:matches=s:matches . getline(".") . "\n"'
			call histdel("search",-1)
			quit
			return
		else
			silent! execute s:RangeOf(s:uTyped) . "global/" . a:grepArg . "/call s:BuildSinglePass()"
			call histdel("search",-1)
		endif
	else
		if s:showAccess
			silent! execute "1,$ global/" . a:grepArg . '/let s:matches=s:matches . getline(".") . "\n"'
			call histdel("search",-1)
			quit
			return
		else
			silent! execute "1,$ global/" . a:grepArg . "/call s:BuildSinglePass()"
			call histdel("search",-1)
		endif
	endif
	quit
	let s:hitList=strpart(s:hitList,1)
	if (s:nHits>=s:tooBig)
		let s:nHits=s:nHits+1
		let s:hitList=s:hitList . "xxxxxxMAX_NR_OF_HITSxxxxxx\n"
		if has("gui_running") || s:useWildMenu
			if !s:useWinMenu
				execute "amenu PopUp." . s:menuMore . "xxxxxxMAX_NR_OF_HITSxxxxxx <NOP>"
			else
				amenu PopUp.****\ \ Max\ number\ of\ hits\ reched\ **** <NOP>
			endif
		endif	
		call confirm( "Max number of hits reached", "&OK", 1,"Warning")
	elseif (s:nHits==0)
		if has("gui_running") || s:useWildMenu
			amenu PopUp.****\ \ no\ completions\ found\ \ *****   :let @c=''<CR>
		endif
	endif
endfunction

function! s:BuildFromOrdinary()
	let maxGrep=" --max-count=" . s:maxGrepHits
	if s:useBuffer
		call s:SetMatchesFromBuffer("^" . s:uTyped . s:groupS . "[^ \t]*\\)" . s:cutBack . "\t")
	elseif s:useDJGPP
		call s:SetGrepArg("'^" . s:uTyped . "[^ \t]*\t'")
		let s:matches=system(s:grepPrg . " @" . s:grepTemp . " cppcomplete.tags")
	else
		let s:matches=system(s:grepPrg . maxGrep . " '^" . s:uTyped . "[^ \t]*\t' cppcomplete.tags")
	endif
endfunction

function! s:BuildMenu()
	if &previewwindow		
		call confirm("Dont do this is the Preview window","&OK",1,"Error")
		return
	endif
	let s:nHits=0
	if ! s:CheckForTagFile()
		return
	endif
	call s:UpdatehiddenBuffer()
	let oldParents=s:relaxedParents
	call s:GetPieces()
	if (s:gotCType)
		let spaceAfter=s:groupS . "[^! \t]\\+\\)" . s:cutBack . "\t"
		let someSpaceAfter=s:groupS . "[^\t]\\+\\)" . s:cutBack . "\t"
		let after3=spaceAfter . someSpaceAfter . someSpaceAfter

		if s:useInternalList || (! s:useBuffer)
			call s:UpdateInheritList()
		endif
		let accSav=s:accessCheck
		if s:colonSep && s:colonNoInherit
			let s:classList=s:clType . "\t"
			let s:accessCheck=0
			let s:colonSep=0
		else
			call s:GetParents()
		endif
		let firstPart=s:uTyped . after3 . "[a-z]\t" . s:groupS .  "\\<class\\|\\<struct\\|\\<union\\|\\<interface\\)" . s:cutBack . ":"
		if ! s:colonSep
			if s:accessCheck
				if s:currLanguage=="Java"
					let secondPart=s:groupS . "file:\t\\)\\?\\<access:" . s:groupS . "\\<default\\>\\|\\<public\\>\\)"
				else
					let secondPart=s:groupS . "file:\t\\)\\?\\<access:public"
				endif
			else
				let secondPart=""
			endif
		elseif s:accessCheck
			if s:currLanguage=="Java"
				let secondPart=s:groupS . "file:\t\\)\\?\\<access:" . s:groupS . "\\<public\\>\\|\\<default\\>\\|\\<protected\\>\\)\\|"
			else
				let secondPart=s:groupS . "file:\t\\)\\?\\<access:" . s:groupS . "\\<public\\>\\|\\<protected\\>\\)\\|"
			endif
		else
			let secondPart="\\|"
		endif
		let maxGrep=" --max-count=" . s:maxGrepHits . " "
		if s:colonSep
			if s:useBuffer
				call s:SetMatchesFromBuffer("^" . s:groupS . firstPart . s:classList . secondPart . firstPart . s:clType . "\t\\)")
			elseif (s:useDJGPP)
				call s:SetGrepArg("'^" . s:groupS . firstPart . s:classList . secondPart . firstPart . s:clType . "\t\\)' cppcomplete.tags")
				silent! let s:matches=system(s:grepPrg . " @" . s:grepTemp)
			else
				let s:matches=system(s:grepPrg . maxGrep . " '^" . s:groupS . firstPart . s:classList . secondPart . firstPart . s:clType . "\t\\)' cppcomplete.tags")
			endif

		else
			if s:useBuffer
				call s:SetMatchesFromBuffer("^" . firstPart . s:classList . secondPart)
			elseif s:useDJGPP
				call s:SetGrepArg("'^" . firstPart . s:classList . secondPart . "'")
				silent! let s:matches=system(s:grepPrg . " @" . s:grepTemp . " cppcomplete.tags")
			else
				let s:matches=system(s:grepPrg . maxGrep . " '^" . firstPart . s:classList . secondPart . "' cppcomplete.tags")
			endif
		endif
		let s:accessCheck=accSav
		if (! s:useBuffer) || s:showAccess 
			call s:BuildIt()
		endif
	elseif s:completeOrdinary && (s:uTyped!="") && (! s:gotCSep)
		call s:BuildFromOrdinary()
		if (!s:useBuffer) || s:showAccess
			call s:BuildIt()
		endif
	else
		let s:matches=""
		call s:BuildIt()
	endif
	let s:relaxedParents=oldParents
	if s:useWinMenu
		let @c=""
		popup PopUp
	endif
endfunction

" Get the input and try to determine the class type
" I know that this code is ugly and that a version with regular
" expressions should be much shorter and nicer. 
" Anyway, I replaced it with a few lines using regexp but that was noticeable
" slower so I changed it back. 
function! s:GetPieces()
	let lineP = line(".")
	let colP = virtcol(".")

	let s:gotUTyped=0
	let s:gotCSep=0
	let s:gotCType=0
	let s:colonSep=0
	let s:uTyped=""
	let s:clType=""

	call s:GetUserTyped()
	if (s:gotUTyped>0)
		if line(".")!=lineP
			let lineP2 = line(".")
			let colP2 = virtcol(".")
			call search("//","bW")
			if (virtcol(".")!=colP2) && (lineP2==line("."))
				exe lineP.'normal! '.colP.'|'
				return
			else
				exe lineP2.'normal! '.colP2.'|'
			endif
		endif
		call s:GetClassSep()
		if (s:gotCSep)
			let s:innerStruct=0
			let s:currDepth=0
			let s:isStruct=0
			if (s:colonSep)
				let s:clType=expand("<cword>")
				let s:gotCType=(s:clType!="")
				call s:CheckClassType()
			else
				call s:GetClassType()
			endif
		endif
	endif
	exe lineP.'normal! '.colP.'|'
endfunction
" The stuff that was typed after  ::, -> or . 
function! s:GetUserTyped()
	let c = getline(line("."))[col(".") - 1]
	normal! wb
	if (c!="~") 
		let c = getline(line("."))[col(".") - 1]
		if (c=="]") 
			normal! e
			let c = getline(line("."))[col(".") - 1]
			normal! b
		endif
	else
		let s:uTyped="\\~"
		let s:gotUTyped=1
		return
	endif
	if ((c == "-") || (c == ".") || (c==":") || (c==">"))
		let s:uTyped=""
	else
		let s:uTyped = expand("<cword>")
		if (strlen(s:uTyped)>0)
			normal! h
			let c = getline(line("."))[col(".") - 1]
			normal! l
		endif
		if (c=="~")
			let s:uTyped="\\~" . s:uTyped
		endif
		normal! b
	endif
	let s:gotUTyped=1
endfunction
" the code is using w and b movements and that makes the code harder
" a better method is probably using single char moves
function! s:GetClassSep()
	let c = getline(line("."))[col(".") - 1]
	if ((c == "-")  || (c == "."))
		if c=="-"
			normal! l
			let c = getline(line("."))[col(".") - 1]
			if c!=">"
				return 0
			endif
			normal! h
		endif
		normal! b
		let s:gotCSep=1
	elseif (c==":")
		let s:gotCSep=1
		let s:colonSep=1

		normal! b
		let c = getline(line("."))[col(".") - 1]
		if (c==">")
			let nangle=1
			while ((nangle>0) && line(".")>1))
				normal! b
				let c = getline(line("."))[col(".") - 1]
				if (c==">")
					let nangle=nangle+1
				elseif (c="<")
					let nangle=nangle-1
				endif
			endwhile
			normal! b
		endif
	elseif (c==">")
		normal! l
		let c = getline(line("."))[col(".") - 1]
		if (c==":")
			let s:gotCSep=1
			let s:colonSep=1

			normal! b
			let c = getline(line("."))[col(".") - 1]
			if (c==">")
				let nangle=1
				while (nangle>0) && (line(".")>1)
					normal! b
					let c = getline(line("."))[col(".") - 1]
					if (c==">")
						let nangle=nangle+1
					elseif (c=="<")
						let nangle=nangle-1
					endif
				endwhile
				normal! b
			endif
		endif
	elseif (c=="]")
		normal! e
		let done=0
		while ! done
			let c = getline(line("."))[col(".") - 1]
			if (c==".") || (c==">")
				let s:gotCSep=1
				let done=1
			elseif (c==":")
				let s:colonSep=1
				let s:gotCSep=1
				let done=1
			elseif (c=="~")
				normal! h
			else
				let done=1
			endif
		endwhile
		normal! b
		if s:gotCSep
			let c = getline(line("."))[col(".") - 1]
			while (c!="[") && (line(".")>1)
				normal! b
				let c = getline(line("."))[col(".") - 1]
			endwhile
			if ! (line(".")>1)
				let s:gotCSep=0
			else 
				normal! b
			endif
		endif
	endif
endfunction

function! s:GetClassType()
	let lineT=line(".")
	let colT=virtcol(".")
	let last_buffer=bufnr("$")
	let hasTagJumped=s:JumpToDecl(0)
	if hasTagJumped==0
		exe lineT.'normal! '.colT.'|'
		let hasTagJumped=s:JumpToDecl(1)
		if hasTagJumped==0
			return
		endif
	endif
	if hasTagJumped==-2
		return
	elseif (hasTagJumped!=-1)
		call s:GetType()
	endif
	if hasTagJumped==1
		if bufnr("$")!=last_buffer
			bwipeout
		else
			quit
		endif
	endif
	if s:gotCType 
		call s:CheckClassType()
		if (s:gotCType)
			return
		endif
		let s:isStruct=0
	endif
	let s:innerStruct=0
	if hasTagJumped==2
		exe lineT.'normal! '.colT.'|'
		let hasTagJumped=s:JumpToDecl(1)
		if hasTagJumped>0
			call s:GetType()
			if hasTagJumped==1
				if bufnr("$")!=last_buffer
					bwipeout
				else
					quit
				endif
			endif
		endif
		if s:gotCType && (hasTagJumped!=-2)
			call s:CheckClassType()
		endif
	endif
endfunction
function! s:CheckClassType()
	let spaceAfter=s:groupS . "[^!\t]\\+\\)" . s:cutBack . "\t"
	let goodTypes="s\\|u\\|c\\|i"
	if s:searchTDefs
		let goodTypes=goodTypes . "\\|t"
	endif
	if s:searchMacros
		let goodTypes=goodTypes . "\\|d"
	endif
	let goodTypes=s:groupS . goodTypes . "\\)" . s:cutBack
	if s:useBuffer 
		split
		call s:CheckHiddenLoaded()
		let foundIt=""
		silent! execute s:RangeOf(s:clType) . "global/" . s:clType . "\t" . spaceAfter . spaceAfter . goodTypes . '/let foundIt=foundIt . getline(".") . "\n"'
		call histdel("search",-1)
		quit
	elseif s:useDJGPP
		call s:SetGrepArg("'^" . s:clType . "\t" . spaceAfter . spaceAfter . goodTypes . "' cppcomplete.tags")
		silent! let foundIt=system(s:grepPrg . " @" . s:grepTemp)
	else
		let foundIt=system(s:grepPrg . " '^" . s:clType . "\t" . spaceAfter . spaceAfter . goodTypes . "' cppcomplete.tags")
	endif
	if foundIt==""
		let s:gotCType=0
	elseif match(foundIt, "\t\\%(s\\|u\\|c\\|i\\)[\t\n]")<0
		let s:gotCType=0
		if match(foundIt, "\tt[\t\n]")>0
			if s:searchTDefs
				call s:GetTypedef(foundIt)
			endif
		else
			if s:searchMacros
				call s:GetMacro(foundIt)
			endif
		endif
	elseif match(foundIt, "\ts[\t\n]")>=0
		let s:isStruct=1
	endif
endfunction
function! s:IsTypedefStruct(wordCheck)
	let isStructSave=s:isStruct
	let s:isStruct=0
	let clTypeSave=s:clType
	let s:clType=a:wordCheck
	let s:currDepth=0
	call s:CheckClassType()
	if s:gotCType && (s:clType!=a:wordCheck)
		call s:CheckClassType()
	endif
	let res=s:isStruct && s:gotCType
	let s:isStruct=isStructSave
	let s:typeDefStruct=s:clType
	let s:clType=clTypeSave
	return res 
endfunction

function! s:JumpToDecl(jumpAllowed)
	let lineT=line(".")
	let colT=virtcol(".")
	let s:innerStruct=0
	if a:jumpAllowed && (s:searchGlobalVars || s:searchClassMembers || s:searchClassTags)
		if s:DoGlobalJump()
			if s:gotCType
				return -2
			else
				return 1
			endif
		endif
	endif
	exe lineT.'normal! '.colT.'|'
	normal! b
	let c = getline(line("."))[col(".") - 1]
	if a:jumpAllowed && (! s:searchClassTags) && ((c==".") || (c=="-") || (c==":"))
		let lucky=1
		if (c=="-")
			normal! l
			let c = getline(line("."))[col(".") - 1]
			if (c!=">")
				let lucky=0
			endif
			normal! h
		endif
		if lucky && (line(".")!=lineT)
			let lineT2=line(".")
			let colT2=virtcol(".")
			let newLine=line(".")
			if (search("//","bW")==newLine)
				let lucky=0
			endif
			exe lineT2.'normal! '.colT2.'|'
		endif
		normal! w
		if lucky
			let s:innerStruct=1
			let s:gotCType=1
			let s:clType = expand("<cword>")
			return -1
		endif
	endif
	exe lineT.'normal! '.colT.'|'
	if a:jumpAllowed
		return 0
	endif
	call s:Bettergd()
	if ((virtcol(".") == colT) && (line(".") == lineT))
		return 0
	endif
	return 2
endfunction
function! s:GetType()
	while (line(".")>1)
		normal! b
		let c = getline(line("."))[col(".") - 1]

		if (c == ")")
			let lineT2=line(".")
			let colT2=virtcol(".")
			normal! l
			let c = getline(line("."))[col(".") - 1]
			if (c==";") || (c=="{")
				return
			endif
			exe lineT2.'normal! '.colT2.'|'

			normal! [(b
			continue
		elseif (c=="]")
			while (c!="[") && (line(".")>1)
				normal! b
				let c = getline(line("."))[col(".") - 1]
			endwhile
			if ! (line(".")>1)
				return
			else
				continue
			endif
		elseif (c=="[")
			continue
		elseif (c==";") || (c=="{")
			return
		endif
		if (c == ",")
			normal! b
		elseif (c=="}")
			normal! [{
			if search('\(\<struct\>\|\<union\>\|\<class\>\).*\_s*\%#')>0
				let s:gotCType=1
				normal! w
				let s:clType = expand("<cword>")
			endif
			return
		else
			let s:clType = expand("<cword>")
			if ((c!="*") && (c!="&") && (s:clType!="const") && (s:clType!="static"))
				normal! w
				let c = getline(line("."))[col(".") - 1]
				normal! b
				if (c!=",")
					let prevLine=line(".")
					let c = getline(line("."))[col(".") - 1]
					normal! b
					if (line(".")!=prevLine)
						let lineT2=line(".")
						let colT2=virtcol(".")
						let newLine=line(".")
						if (search("//","bW")==newLine)
							let c2="x"
						else
							let c2 = getline(line("."))[col(".") - 1]
						endif
						exe lineT2.'normal! '.colT2.'|'
					else
						let c2 = getline(line("."))[col(".") - 1]
					endif
					let nangle=0
					if (c==">")
						if (c2==">")
							let nangle=2
						else
							let nangle=1
						endif
					elseif (c2==">")
						let nangle=1
					else
						if (c2==":") || (c2==".") || (c2=="-")
							let s:relaxedParents=1
						elseif (c2=="<")
							continue
						endif
						let s:gotCType=1
						return
					endif
					while((nangle>0) && (line(".")>1))
						normal! b
						let c = getline(line("."))[col(".") - 1]
						if (c==">")
							let nangle=nangle+1
						elseif (c=="<")
							let nangle=nangle-1
						endif
					endwhile
				endif
			elseif (c=="*")
				normal! l
				let c = getline(line("."))[col(".") - 1]
				normal! h
				if (c=="/")
					normal! [/
				endif
			endif
		endif
	endwhile
endfunction
function! s:InComment(lineT2, colT2)
	if search('\%' . a:lineT2 . 'l\/\/','bW')!=0
		return 1
	endif
	let ce=search('\*\/','W')
	if ce!=0
		let cs=search('\/\*','bW')	
		if cs<=a:lineT2
			return 1
		endif
		execute a:lineT2 . 'normal! ' . a:colT2 . '|'
	endif
	return 0
endfunction

function! s:Bettergd()
	let lineT2=line(".")
	let colT2=virtcol(".")
	let lStart=lineT2
	let cStart=colT2
	let searchFor=expand("<cword>")
	let s='\%(\(=.*\)\@<!\*\|&\|\_s\)'
	call search('\([[:alnum:]_]' . s . '*\_s\+\|,\|<.*[->]\@<!>\|\]\|}\(.*\<searchFor\>\)\@=\)' . s . '*' . searchFor . '\_s*\(;\|,\|=\|[\|(\|)\)','bW')
	while (line(".")!=lineT2) || (colT2!=virtcol("."))
		let lineT2=line(".")
		let colT2=virtcol(".")
		if s:InComment(lineT2, colT2)==0
			normal! [(
			if (lineT2!=line(".")) || (colT2!=virtcol("."))
				if search('\([[:alnum:]_]' . s . '*\_s\+\|<.*[->]\@<!>\|\[.*\]\)' . s . '*\<' . searchFor . '\>\_s*\(,\|[\|)\)','W')!=lineT2
					execute lineT2 . 'normal! ' . colT2 . '|'
				else
					call search('\<' . searchFor . '\>')
					return 
				endif
			else
				let c = getline(line("."))[col(".") - 1]
				if (c=='}')
					normal! [{
					if search('.*\(\<struct\>\|\<union\>\|\<class\>\).*\_s*\%#')>0
						execute lineT2 . 'normal! ' . colT2 . '|'
					else
						execute lineT2 . 'normal! ' . colT2 . '|'
						continue
					endif
				endif
				call search('\<' . searchFor . '\>')
				return
			endif
			call search('\([[:alnum:]_]' . s . '*\_s\+\|,\|<.*[->]\@<!>\|\]\|}\(.*\<searchFor\>\)\@=\)' . s . '*' . searchFor . '\_s*\(;\|,\|=\|[\|(\|)\)','bW')
		endif
	endwhile
	execute lStart . 'normal! ' . cStart . '|'

endfunction

function! s:JumpToInterestingLine(lines, i)
	let lEnd=match(a:lines, "\n", a:i)
	if lEnd<0
		let lEnd=strlen(a:lines)
	endif
	let lStart=0
	while (lEnd>match(a:lines, "\n", lStart))
		let lStart=matchend(a:lines, "\n", lStart)
		if lStart<0
			call s:DoTagLikeJump(strpart(a:lines,0,lEnd))
			return
		endif
	endwhile
	call s:DoTagLikeJump(strpart(a:lines,lStart,lEnd))
endfunction

" If a typedef was used
function! s:GetTypedef(foundIt)
	let s:gotCType=0
	let s:currDepth=s:currDepth+1
	if s:currDepth>=s:maxDepth
		return
	endif
	split
	let last_buffer=bufnr("$")
	call s:DoTagLikeJump(a:foundIt)
	call search(s:clType)
	let lineT=line(".")
	let colT=virtcol(".")
	call s:GetClassType()
	if ! s:gotCType
		exe lineT.'normal! '.colT.'|'
		call s:GetType()
	endif
	if bufnr("$")!=last_buffer
		bwipeout
	else
		quit
	endif
endfunction
" a simple approach for macros
function! s:GetMacro(foundIt)
	let last_buffer=bufnr("$")
	split
	call s:DoTagLikeJump(a:foundIt)
	normal! www
	let s:clType=expand("<cword>")
	if (s:clType=="class" || s:clType=="struct" || s:clType=="union")
		normal! w
		let s:clType=expand("<cword>")
	endif
	let s:gotCType=1
	if bufnr("$")!=last_buffer
		bwipeout
	else
		quit
	endif
endfunction
function! s:IsLocal(l)
	return match(a:l,"[^\t)*\t[^\t\\/]\\+\t")>=0
endfunction
" Get the ancestors, I do not think that ctags always gives a complete list
function! s:GetParents()
	let s:classList= "\\<" . s:clType . "\\>"
	let clName=s:clType
	let unsearched=""
	let searched=""
	let done=0

	if (! s:useInternalList ) && s:useBuffer
		split
		call s:CheckHiddenLoaded()
	endif
	while (! done)
		if s:useInternalList || (! s:useBuffer)
			let nextM=match(s:inheritsList,"\n\\<". clName . "\\>\t")
			if (nextM>=0)
				let nextM=nextM+1
				let inhLine=strpart(s:inheritsList, nextM, match(s:inheritsList,"\n",nextM)-nextM)
			else
				let inhLine=""
			endif
		else
			let inhLine=""
			silent! execute s:RangeOf(clName) . " global/" . "^" . clName . '\>\t\%([^\t]*\)\@>\t\%([^\t]*\)\@>\t[suci]\t.*\<inherits:/if (inhLine=="" || ! s:IsLocal(inhLine)) | let inhLine=getline(".") . "\n" | endif'  	
			call histdel("search",-1)
		endif
		if (inhLine!="")
			let i2=matchend(inhLine, "inherits:")
			let c=","
			while c==","
				let i=match(inhLine,"[,\t\n]",i2)
				let @c=strpart(inhLine,i2,i-i2)
				if  match(searched,":\\<" . @c . "\\>:")<0
					let searched=searched . ":" . @c . ":"
					if s:isStruct
						if s:IsTypedefStruct(@c)
							let @c=s:typeDefStruct
							let searched=searched . ":" . s:typeDefStruct . ":"
						else
							let @c=strpart(inhLine,i2,i-i2)
						endif
						let s:classList=s:classList . "\\|" . "\\<" . @c . "\\>"
					else
						let s:classList=s:classList . "\\|" . "\\<" . @c . "\\>"
					endif
					if (strlen(unsearched)>0)
						let unsearched=unsearched . ":" . @c 
					else
						let unsearched=@c
					endif
				endif
				let c=inhLine[i]
				let i2=i+1
			endwhile
		endif
		if (strlen(unsearched)<=0)
			let done=1
		elseif (match(unsearched,":")>0)
			let clName=strpart(unsearched, 0, match(unsearched,":"))
			let unsearched=strpart(unsearched, matchend(unsearched,":"))
		else
			let clName=unsearched
			let unsearched=""
		endif
	endwhile
	if (! s:useInternalList) && s:useBuffer
		quit
	endif
	if (s:innerStruct) 
		if s:classList!=s:clType
			let rest="\\|" . strpart(s:classList, matchend(s:classList,"|"))
		else
			let rest=""
		endif
		if s:currLanguage=="Java"
			let s:classList=s:groupS . "[^\\.]*\\.\\)*" s:groupS . ".*\\." . s:clType . rest . "\\)" . s:groupS . "\\.<anonymous>\\)*" . s:groupS . "\t"
		else
			let s:classList=s:groupS . "[^:]*::\\)*" . s:groupS . ".*::" . s:clType . rest . "\\)" . s:groupS . "::<anonymous>\\)*" . s:groupS . "\t\\|$\\)"
		endif
	elseif s:currLanguage=="Java"
		if s:relaxedParents
			let s:classList=s:groupS . s:groupS . s:groupS . "[^\\.\t]*\\)" . s:cutBack . "\\.\\)*\\)" . s:groupS . s:classList . "\\)" . s:groupS . "\\.<anonymous>\\)*\t"
		else
			let s:classList=s:groupS . "<anonymous>.\\)*" . s:groupS . s:classList . "\\)" . s:groupS . "\\.<anonymous>\\)*\t"
		endif
	else
		if s:relaxedParents
			let s:classList=s:groupS . s:groupS . s:groupS ."[^:\t]*\\)" . s:cutBack . "::\\)*\\)" . s:groupS . s:classList . "\\)" . s:groupS . "::<anonymous>\\)*" . s:groupS . "\t\\|$\\)"
		else
			let s:classList=s:groupS . "<anonymous>::\\)*" . s:groupS . s:classList . "\\)" . s:groupS . "::<anonymous>\\)*" . s:groupS . "\t\\|$\\)"
		endif
	endif
	" Uncommenting the following line can be useful if you have hacked the script but breaks the popup in GTK.
	"	 echo s:classList ."\n"
endfunction
function! s:JumpToLineInBlock(n)
	if s:regexBlock==""
		call confirm("The current block is empty","&OK",1,"Error")
		return
	endif
	let currLine=0
	let currPos=0
	let prevPos=0
	if (a:n>s:nLinesInBlock) || (a:n<1)
		return
	endif
	while a:n>currLine
		let prevPos=currPos
		let currPos=match(s:regexBlock, "\n", currPos+1)
		if currPos<0
			let currLine=a:n
			let currPos=strlen(s:regexBlock)
		else
			let currLine=currLine+1
		endif
	endwhile
	let s:currInBlock=a:n
	call s:DoTagLikeJump(strpart(s:regexBlock, prevPos, currPos-prevPos))
	normal! zt
endfunction

function! s:PrevInBlock()
	let s:currInBlock=s:currInBlock-1
	if s:currInBlock<=0
		let s:currInBlock=s:nLinesInBlock
	endif
	call s:JumpToLineInBlock(s:currInBlock) 
endfunction
function! s:NextInBlock()
	let s:currInBlock=s:currInBlock+1
	if s:currInBlock>s:nLinesInBlock
		let s:currInBlock=1
	endif
	call s:JumpToLineInBlock(s:currInBlock) 
endfunction
function! s:BuildBlock(regex)
	let s:regexBlock=""
	if has("gui_running") || s:useWildMenu
		silent! aunmenu cppcomplete.Block\ menu.menu\ built\ from\ regexp
	endif
	let s:nLinesInBlock=0
	let s:currInBlock=0
	if (a:regex=="")
		echo "no string"
		return
	endif
	if s:useBuffer
		split
		let s:regexBlock=""
		call s:CheckHiddenLoaded()
		let x=line(".")
		execute ":call search('" . a:regex . "','W')"
		while line(".")!=x
			let x=line(".")
			normal! "cyy$
			if @c[0]!="!" 
				let s:regexBlock=s:regexBlock . @c
			endif
			execute ":call search('" . a:regex . "','W')"
		endwhile
		quit
	elseif s:useDJGPP
		call s:SetGrepArg("'" . a:regex ."' cppcomplete.tags")
		let s:regexBlock=system(s:grepPrg . " @" . s:grepTemp . " | " . s:grepPrg . " '^[^!]'")
	else
		let s:regexBlock=system(s:grepPrg . " '" . a:regex ."' cppcomplete.tags | " . s:grepPrg ." '^[^!]'")
	endif
	if s:regexBlock==""
		echo "could not build the block"
	else
		let currPos=0
		while currPos>=0
			let s:nLinesInBlock=s:nLinesInBlock+1
			let currPos=matchend(s:regexBlock,"\n",currPos)
		endwhile
		let s:nLinesInBlock=s:nLinesInBlock-1
		echo "a block with " . s:nLinesInBlock . " lines was built"
	endif
endfunction
function! s:BuildBlockFromRegexp()
	highlight BlockLiteral cterm=bold ctermbg=NONE gui=bold guibg=NONE
	highlight BlockItalic cterm=italic ctermbg=NONE gui=italic guibg=NONE
	echo "Build from regular expression\n"
	echo "The format of cppcomplete.tags\n"
	echon "tag_name<TAB>file_name<TAB>ex_cmd;<TAB>" 
	echohl BlockItalic
	echon "kind"
	echohl None
	echon"<TAB>"
	echohl BlockItalic
	echon "visibility"
	echohl None
	echon "<TAB>"
	echohl BlockItalic
	echon "file"
	echohl None
	echon "<TAB>"
	echohl BlockItalic
	echon "access"
	echohl None
	echon "<TAB>"
	echohl BlockItalic
	echon "inherits\nkind "
	echohl None
	echohl BlockGroup
	echon "c d e f g m n p s t u v"
	echohl None
	echon "\tfor Java is it "
	echohl BlockGroup
	echon "c f i m p"
	echohl None
	echohl BlockItalic
	echon "\nvisibility "
	echohl BlockGroup
	echon "class: struct: union: and for Java also interface:"
	echohl BlockItalic
	echon "\nfile "
	echohl BlockGroup
	echon "file:"
	echohl BlockItalic
	echon "\naccess "
	echohl BlockGroup
	echon "access:"
	echohl None
	echon " followed by "
	echohl BlockGroup
	echon "public protected private friend default\n"
	echohl BlockItalic
	echon "inherits"
	echohl BlockGroup
	echon " inherits:"
	echohl None

	let regex=input("\n>")
	if regex!=""
		call s:BuildBlock(regex)
	else

		echo "no string"
	endif
endfunction
function! s:EchoBlock()
	echo s:regexBlock
endfunction
function! s:DoTagLikeJump(tagLine)
	let fStart=matchend(a:tagLine, "\t")
	let fEnd=match(a:tagLine, "\t", fStart)
	let jFile=strpart(a:tagLine, fStart, fEnd-fStart)
	let exStart=fEnd+1
	let exEnd=match(a:tagLine, "\t", exStart)
	let jEX=strpart(a:tagLine, exStart, exEnd-exStart)
	let bName=bufname("\\<" . fnamemodify(jFile,":t"))
	if bName!=""
		execute "buffer " . jFile 
	else
		execute "edit " . jFile
	endif
	silent! execute jEX
endfunction
function! s:BuildHashTable()
	let currChar="!"
	let s:hashTable="!:1"
	normal! gg
	while search("^[^" . currChar . "]","W")!=0
		let currChar = getline(line("."))[col(".") - 1]
		let s:hashTable=s:hashTable . ":" . currChar . ":" . line(".")
	endwhile
endfunction
function! s:RangeOf(c)
	if a:c[0]=='\'
		let startIndex=match(s:hashTable,":" . '\~')+2
	else
		let startIndex=match(s:hashTable,":" . a:c[0])+2
	endif
	if startIndex==1
		return "1,1"
	endif
	let endIndex=match(s:hashTable,":",startIndex+1)+3
	if endIndex<=2
		return strpart(s:hashTable,startIndex,strlen(s:hashTable)-startIndex) . ",$"
	endif
	let endOfEnd=match(s:hashTable, ":",endIndex)
	if endOfEnd<0
		let endOfEnd=strlen(s:hashTable)
	endif
	let endNr=strpart(s:hashTable, endIndex, endOfEnd-endIndex)
	return s:BinarySplit(strpart(s:hashTable,startIndex+1,endIndex-startIndex-4),endNr, strlen(a:c),a:c)
endfunction

function! s:BinarySplit(startLine, endLine, wordLength, wordToLookup)
	if ((a:wordLength==1) || ((a:endLine-a:startLine)<4)) 
		return a:startLine . "," . a:endLine
	endif
	let mid=(a:endLine-a:startLine)/2+a:startLine
	execute "normal! " . mid . "G"
	normal! ^
	call search("\t")
	normal! "cy^
	let nIndex=0
	let resComp=0
	while (nIndex+0) < (a:wordLength+0)
		if strlen(@c)<=nIndex
			let resComp=1
			let nIndex=a:wordLength+1
			continue
		endif
		let x1=char2nr(@c[nIndex])
		let x2=char2nr(a:wordToLookup[nIndex])
		if (x1!=x2)
			let nIndex=a:wordLength+1
			if (x1 < x2)
				let resComp=1
			else
				let resComp=-1
			endif
		else
			let nIndex=nIndex+1
		endif
	endwhile
	if resComp==0
		if (a:endLine-a:startLine)>32
			let bef=s:BinarySplit(a:startLine, mid, a:wordLength, a:wordToLookup)
			let aft=s:BinarySplit(mid, a:endLine, a:wordLength, a:wordToLookup)
			return strpart(bef, 0, matchend(bef,",")) . strpart(aft, matchend(aft,","))
		endif
		return a:startLine . "," . a:endLine
	elseif resComp==1
		return s:BinarySplit(mid, a:endLine, a:wordLength, a:wordToLookup)
	elseif resComp==-1
		return s:BinarySplit(a:startLine, mid, a:wordLength, a:wordToLookup)
	endif
endfunction
function! s:CheckHiddenLoaded()
	if (!bufexists("cppcomplete.tags")) || (getftime("cppcomplete.tags")!=s:bufAge)
		silent! execute "edit! cppcomplete.tags"
		let &buflisted=0
		let &bufhidden="hide"
		let &swapfile=0
		let s:bufAge=getftime("cppcomplete.tags")
		call s:BuildHashTable()
	else
		execute "buffer cppcomplete.tags"
	endif
	normal! gg^
endfunction

function! s:SimpleScopeGuess()
	if search('[[:alnum:]_]\+\s*\(\.\|->\)\s*\%#[[:alnum:]_]\+\s*\(\.\|->\)')>0
		return 1
	endif
	if s:currLanguage=="Java"
		return 0
	endif
	normal! [[
	if search("[[:alnum:]_]\s*::","Wb")==0
		return 0
	endif
	return 1
endfunction
function! s:DoGlobalJump()
	let spaceAfter=s:groupS . "[^!\t]\\+\\)" . s:cutBack . "\t"
	let tStr=""
	if s:searchClassMembers && s:searchGlobalVars
		if s:currLanguage=="Java"
			let tStr="m\\|f\\|v"
		else
			let tStr="m\\|v"
		endif
	elseif s:searchClassMembers 
		if s:currLanguage=="Java"
			let tStr="m\\|f"
		else
			let tStr="m"
		endif
	elseif s:searchGlobalVars
		let tStr="v"
	endif
	if s:searchClassTags
		if s:searchClassMembers || s:searchGlobalVars
			let tStr="s\\|u\\|c\\|i\\|" . tStr
		else
			let tStr="s\\|u\\|c\\|i"
		endif
	endif
	let tStr=s:groupS . tStr . "\\)" . s:cutBack
	let searchFor=expand("<cword>")
	if searchFor==""
		return 0
	endif
	if s:useBuffer 
		split
		let foundIt=""
		call s:CheckHiddenLoaded()
		execute s:RangeOf(searchFor) . "global/" ."^" . searchFor . "\t" . spaceAfter . spaceAfter . tStr . '/let foundIt=foundIt . getline(".") . "\n"'
		call histdel("search",-1)
		quit
	elseif s:useDJGPP
		call s:SetGrepArg("'^" . searchFor . "\t" . spaceAfter . spaceAfter . tStr . "' cppcomplete.tags")
		silent! let foundIt=system(s:grepPrg . " @" . s:grepTemp)
	else
		let foundIt=system(s:grepPrg . " '^" . searchFor . "\t" . spaceAfter . spaceAfter . tStr . "' cppcomplete.tags")
	endif
	if foundIt!=""
		if match(foundIt, "\t\\%(u\\|s\\|c\\|i\\)[\t\n]")<0 
			split
			let lineT=line(".")
			let colT=virtcol(".")
			let fsc=-1
			if s:SimpleScopeGuess() 
				let scop=expand("<cword>")
				execute lineT . 'normal! ' . colT . '|'
				let fsc=match(foundIt,scop)
			endif
			if fsc<0
				let fsc=match(foundIt, '\<' . searchFor . '\t[^\/\t\\]\+\t')
			endif
			if fsc<0
				let fsc=match(foundIt, '\t\m[\t\n]')
			endif
			if fsc<0
				let fsc=1
			endif
			call s:JumpToInterestingLine(foundIt, fsc)
			if (line(".")!=lineT) || (virtcol(".")!=colT)
				call search(searchFor)
			else
				quit
				return 0
			endif
		else
			let s:clType=searchFor
			let s:gotCType=1
		endif
		return 1
	endif
	return 0
endfunction
function! s:CheckForTagFile()
	if s:nannyMode && s:HasNotAsked()
		return s:NannyCheck()
	elseif getftime("cppcomplete.tags")==-1
		if s:nannyMode 
			return s:NannyCheck()
		endif
		call confirm("No cppcomplete.tags found","&OK",1,"Error")
		return 0
	endif
	return 1
endfunction
function! s:HasNotAsked()
	let cFile=substitute(expand("%"),"\\",":","g")
	if match(s:nannyAsked, "\n" . cFile . "\n")>=0
		return 0
	endif
	let s:nannyAsked=s:nannyAsked . cFile . "\n"
	return 1
endfunction
function! s:CheckFiletype()
	let fType=expand("%:e")
	if fType=="c" || fType=="C" || fType=="cpp" || fType=="h" || fType=="cxx" || fType=="hxx"
		if s:currLanguage=="Java"
			let ans=confirm("The name of the current file indicates\na C/C++ file but the current language is set to Java.\nDo you want to change it to C/C++?","&Yes, and change to recommended language settings\nYes, but &only change the current language\n&No",1,"Warning")
			if (ans==1) || (ans==2)
				let s:currLanguage="C/C++"
				if ans==1
					let s:searchTDefs=1
				endif
			endif
		endif
	elseif fType=="java" && (s:currLanguage!="Java")
		let ans=confirm("The name of the current file indicates\na Java file but the current language is C/C++.\nDo you want to change it to Java?","&Yes, and also change to recommended language settings\nYes, but &only change the current language\n&No",1,"Warning")
		if (ans==1) || (ans==2)
			let s:currLanguage="Java"
			if ans==1
				let s:searchTDefs=0
			endif
		endif
	endif
endfunction
function! s:NannyCheck()
	if getftime("cppcomplete.tags")==-1
		if s:currLanguage=="Java"
			let ans=confirm("No cppcomplete.tahs file found","&Generate from the files in the current directory\n&Cancel",1,"Question")
			if ans==1
				return s:GenerateTags()
			else
				return 0
			endif
		endif
		let ans=confirm("No cppcomplete.tags file found.","&Auto generate from included files\n&Generate from the files in the current directory\n&Cancel",1,"Question")
		if ans==1
			return s:GenerateFromCheckpath()
		elseif ans==2
			return s:GenerateTags()
		else
			return 0
		endif

	elseif s:currLanguage=="Java"
		let ans=confirm("A cppcomplete.tags file already exists.","&Use it\n&Generate new\nC&omplete it\n&Cancel",1,"Question")
		if ans==2
			call s:GenerateTags()
		elseif ans==3
			call s:GenerateAndAppend()
		elseif ans==4
			return 0
		elseif ans==1
			call s:CheckFiletype()
		endif
	else
		let ans=confirm("A cppcomplete.tags file already exists.","&Use it\nAu&to complete it\n&Auto generate new\n&Generate new\nC&omplete it\n&Cancel",1,"Question")
		if ans==2
			call s:AppendFromCheckpath()
		elseif ans==3
			call s:GenerateFromCheckpath()
		elseif ans==4
			call s:GenerateTags()
		elseif ans==5
			call s:GenerateAndAppend()
		elseif ans==6
			return 0
		elseif ans==1
			call s:CheckFiletype()
		endif
	endif
	return 1
endfunction

function! s:SetMaxHits()
	let res=inputdialog("Current value for max hits is " . s:tooBig . "\nEnter the new value")
	if res!=""
		let s:tooBig=res
	endif
endfunction
function! s:SetLanguage()
	let res=confirm("Set the current language to use", "&C/C++\nJava",s:currLanguage=="Java" ? 2 : 1,"Question")
	if res==2
		let s:currLanguage="Java"
		let s:searchTDefs=0
	elseif res==1
		let s:currLanguage="C/C++"
		let s:searchTDefs=1
	endif
endfunction
function! s:ShowCurrentSettings()
	let setStr="Current language is " . (s:currLanguage=="Java" ? "Java" : "C/C++")
	let setStr=setStr . "\nAccess check is " . (s:accessCheck==0 ? "disabled" : "enabled")
	let setStr=setStr . "\nSearch for typedefs is " . (s:searchTDefs==0 ? "disabled" : "enabled")
	let setStr=setStr . "\nSearch for macros is " . (s:searchMacros==0 ? "disabled" : "enabled")
	let setStr=setStr . "\nPreview mode is " . (s:showPreview==0 ? "off" : "on")
	let setStr=setStr . "\nAncestor check is " . (s:relaxedParents!=0 ? "relaxed" : "strict")
	let setStr=setStr . "\nSearch for global variables is " . (s:searchGlobalVars==0 ? "disabled" : "enabled")
	let setStr=setStr . "\nSearch for class members is " . (s:searchClassMembers==0 ? "disabled" : "enabled")
	let setStr=setStr . "\nSearch for class names is " . (s:searchClassTags==0 ? "disabled" : "enabled")
	let setStr=setStr . "\nCurrent value for max hits is " . s:tooBig
	if s:useBuffer && s:neverUseGrep
		let setStr=setStr . "\nAll searches is being done with the internal buffer"
	else
		if s:useBuffer
			let setStr=setStr . "\nSearches is being done with grep and the internal buffer"
		else
			let setStr=setStr . "\nGrep is doing all searches"
		endif
		let setStr=setStr . "\nSearches with grep is being done with " . (s:grepPrg=="grep" ? "standard grep" : "fast grep")
	endif
	let setStr=setStr . "\nThe scope resolution operator :: will " . (s:colonNoInherit ? "not " : "") . "show everything in the scope"
	let setStr=setStr . "\nNanny mode is " . (s:nannyMode ? "enabled" : "disabled")
	call confirm(setStr, "&OK",1,"Info")
endfunction
function! s:GetIncludeFiles()
	call s:CheckFiletype() 
	if s:currLanguage=="Java"
		call confirm("This command is not supported for Java","&OK",1,"Error")
		return 0
	endif
	let includeSav=&include
	let &include='^\s*#\s*include'
	silent redir @c
	silent! checkpath!
	redir END
	let &include=includeSav
	if match(@c,"No included files")>=0
		return 0
	endif
	if has("win32") || has("win16") || has("dos16") || has("dos32")
		let sep="\n"
	else
		let sep=" "
	endif
	let s:includedFiles=expand("%") . sep
	let nextM=matchend(@c, "Included files [^\n]*\n")
	let totalIncFiles=0
	let missedIncFiles=0
	echon "\r                                             "
	echon "\rsearching for included files..."
	redraw
	while (nextM<strlen(@c))
		let totalIncFiles=totalIncFiles+1
		let prevM=nextM
		let nextM=match(@c, "\n",prevM+1)
		if (nextM<0)
			let nextM=strlen(@c)
		endif
		let thisLine=strpart(@c, prevM, nextM-prevM)
		if match(thisLine, "NOT FOUND")>0
			let missedIncFiles=missedIncFiles+1
			continue
		elseif match(thisLine, "(Already listed)")>0
			continue
		elseif (match(thisLine, " -->")>0)
			continue
		else
			let firstC=matchend(thisLine,"[\"<]")
			let lastC=match(thisLine, "[\">]", firstC)
			let fName=substitute(strpart(thisLine, firstC, lastC-firstC),"\n","","g")
			if (fName=="")
				continue
			endif
			let s:includedFiles=s:includedFiles . globpath(&path,fName) . sep

		endif
	endwhile
	if missedIncFiles>0
		let str1="Of " . totalIncFiles . " files was " . missedIncFiles . " not found."
		if 2*missedIncFiles>totalIncFiles 
			let pStr="\nYour path is set to " . &path . "\nIs this really correct?"
			if confirm(str1 . pStr, "&Generate it\n&Cancel",2,"Error")!=1
				return 0
			endif
		else
			if confirm(str1 . "\nThe :checkpath command lists the missing files", "&OK\n&Cancel",1,"Warning")==2
				return 0
			endif
		endif
	else	
		echon "\r                                                           "
		echon "\rcould findd all files... generating cppcomplete.tags"
	endif
	return 1
endfunction
function! s:UpdatehiddenBuffer()
	if s:useBuffer || (! s:useInternalList)
		split
		call s:CheckHiddenLoaded()
		quit
	endif
endfunction
function! s:AnotherLongCommandLinePatchForWindows()
	silent! call delete(s:ctagsTemp)
	split
	silent! execute "edit! " s:ctagsTemp
	let @c=s:includedFiles
	normal! "cp
	silent! w
	silent! bwipeout
endfunction
function! s:GenerateFromCheckpath()
	if getftime("cppcomplete.tags")!=-1
		let dial=confirm("You already have a cppcomplete.tags file, do you really want to destroy it?", "&Yes, I really want to replace it\n&No, I keep the old one",2,"Warning")
		if (dial!=1)
			return 0
		endif
		call delete("cppcomplete.tags")
	endif
	if (! s:GetIncludeFiles())
		return 0
	endif
	if has("win32") || has("win16") || has("dos16") || has("dos32")
		call s:AnotherLongCommandLinePatchForWindows()
		call system("ctags -n --language-force=C++ -f cppcomplete.tags --fields=+ai --C++-types=+p -L " . s:ctagsTemp)
	else
		call system("ctags -n --language-force=C++ -f cppcomplete.tags --fields=+ai --C++-types=+p " . s:includedFiles)
	endif
	call s:UpdatehiddenBuffer()
	return 1
endfunction
function! s:AppendFromCheckpath()
	if (! s:GetIncludeFiles())
		return 0
	endif
	if has("win32") || has("win16") || has("dos16") || has("dos32")
		call s:AnotherLongCommandLinePatchForWindows()
		call system("ctags --append -n  --language-force=C++  -f cppcomplete.tags --fields=+ai --C++-types=+p " . s:ctagsTemp)
	else
		call system("ctags -n -a --language-force=C++ -f cppcomplete.tags --fields=+ai --C++-types=+p " . s:includedFiles)
	endif
	call s:UpdatehiddenBuffer()
	return 1
endfunction

function! s:BrowseNFiles()
	call s:CheckFiletype() 
	let browseFile=""
	let browseFile=browse(0, "File to include in cppcomplete.tags","./","")
	if (browseFile!="")
		if (s:currLanguage=="Java")
			call system("ctags -n -a -f cppcomplete.tags --fields=+ai " . browseFile)
		else
			call system("ctags -n -a -f cppcomplete.tags --fields=+ai --C++-types=+p " . browseFile)
		endif
		call s:UpdatehiddenBuffer()
	endif
endfunction
function! s:GenerateAndAppend()
	call s:CheckFiletype() 
	if (s:currLanguage=="Java")
		call system("ctags -n -a -f cppcomplete.tags --fields=+ai *")
	else
		call system("ctags -n -a -f cppcomplete.tags --fields=+ai --C++-types=+p *")
	endif
	call s:UpdatehiddenBuffer()
	return 1
endfunction

" shows how the tags should be generated
function! s:GenerateTags()
	call s:CheckFiletype() 
	if getftime("cppcomplete.tags")!=-1
		let dial=confirm("You already have a cppcomplete.tags file, do you really want to destroy it?", "&Yes, I really want to replace it\n&No, I keep the old one",2,"Warning")
		if (dial!=1)
			return 0
		endif
		call delete("cppcomplete.tags")
	endif
	if (s:currLanguage=="Java")
		execute "!ctags -n -f cppcomplete.tags --fields=+ai *"
	else
		execute "!ctags -n -f cppcomplete.tags --fields=+ai --C++-types=+p *"
	endif
	call s:UpdatehiddenBuffer()
	return 1
endfunction
