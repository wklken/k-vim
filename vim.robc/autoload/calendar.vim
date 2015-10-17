if !exists("g:calendar_action")
  let g:calendar_action = "calendar#diary"
endif
if !exists("g:calendar_sign")
  let g:calendar_sign = "calendar#sign"
endif
if !exists("g:calendar_mark")
 \|| (g:calendar_mark != 'left'
 \&& g:calendar_mark != 'left-fit'
 \&& g:calendar_mark != 'right')
  let g:calendar_mark = 'left'
endif
if !exists("g:calendar_navi")
 \|| (g:calendar_navi != 'top'
 \&& g:calendar_navi != 'bottom'
 \&& g:calendar_navi != 'both'
 \&& g:calendar_navi != '')
  let g:calendar_navi = 'top'
endif
if !exists("g:calendar_navi_label")
  let g:calendar_navi_label = "Prev,Today,Next"
endif
if !exists("g:calendar_diary")
  let g:calendar_diary = "~/diary"
endif
if !exists("g:calendar_focus_today")
  let g:calendar_focus_today = 0
endif
if !exists("g:calendar_datetime")
 \|| (g:calendar_datetime != ''
 \&& g:calendar_datetime != 'title'
 \&& g:calendar_datetime != 'statusline')
  let g:calendar_datetime = 'title'
endif
if !exists("g:calendar_options")
  let g:calendar_options = "fdc=0 nonu"
  if has("+relativenumber")
    let g:calendar_options .= " nornu"
  endif
endif

"*****************************************************************
"* Default Calendar key bindings
"*****************************************************************
let s:calendar_keys = {
\ 'close'           : 'q',
\ 'do_action'       : '<CR>',
\ 'goto_today'      : 't',
\ 'show_help'       : '?',
\ 'redisplay'       : 'r',
\ 'goto_next_month' : '<RIGHT>',
\ 'goto_prev_month' : '<LEFT>',
\ 'goto_next_year'  : '<UP>',
\ 'goto_prev_year'  : '<DOWN>',
\}

if exists("g:calendar_keys") && type(g:calendar_keys) == 4
  let s:calendar_keys = extend(s:calendar_keys, g:calendar_keys)
end

"*****************************************************************
"* CalendarDoAction : call the action handler function
"*----------------------------------------------------------------
"*****************************************************************
function! calendar#action(...)
  " for navi
  if exists('g:calendar_navi')
    let navi = (a:0 > 0)? a:1 : expand("<cWORD>")
    let curl = line(".")
    if navi == '<' . get(split(g:calendar_navi_label, ','), 0, '')
      if b:CalendarMonth > 1
        call calendar#show(b:CalendarDir, b:CalendarYear, b:CalendarMonth-1)
      else
        call calendar#show(b:CalendarDir, b:CalendarYear-1, 12)
      endif
    elseif navi == get(split(g:calendar_navi_label, ','), 2, '') . '>'
      if b:CalendarMonth < 12
        call calendar#show(b:CalendarDir, b:CalendarYear, b:CalendarMonth+1)
      else
        call calendar#show(b:CalendarDir, b:CalendarYear+1, 1)
      endif
    elseif navi == get(split(g:calendar_navi_label, ','), 1, '')
      call calendar#show(b:CalendarDir)
      if exists('g:calendar_today')
        exe "call " . g:calendar_today . "()"
      endif
    else
      let navi = ''
    endif
    if navi != ''
      if g:calendar_focus_today == 1 && search("\*","w") > 0
        silent execute "normal! gg/\*\<cr>"
        return
      else
        if curl < line('$')/2
          silent execute "normal! gg0/".navi."\<cr>"
        else
          silent execute "normal! G$?".navi."\<cr>"
        endif
        return
      endif
    endif
  endif

  " if no action defined return
  if !exists("g:calendar_action") || g:calendar_action == ""
    return
  endif

  if b:CalendarDir
    let dir = 'H'
    if exists('g:calendar_weeknm')
      let cnr = col('.') - (col('.')%(24+5)) + 1
    else
      let cnr = col('.') - (col('.')%(24)) + 1
    endif
    let week = ((col(".") - cnr - 1 + cnr/49) / 3)
  else
    let dir = 'V'
    let cnr = 1
    let week = ((col(".")+1) / 3) - 1
  endif
  let lnr = 1
  let hdr = 1
  while 1
    if lnr > line('.')
      break
    endif
    let sline = getline(lnr)
    if sline =~ '^\s*$'
      let hdr = lnr + 1
    endif
    let lnr = lnr + 1
  endwhile
  let lnr = line('.')
  if(exists('g:calendar_monday'))
      let week = week + 1
  elseif(week == 0)
      let week = 7
  endif
  if lnr-hdr < 2
    return
  endif
  let sline = substitute(strpart(getline(hdr),cnr,21),'\s*\(.*\)\s*','\1','')
  if (col(".")-cnr) > 21
    return
  endif

  " extract day
  if g:calendar_mark == 'right' && col('.') > 1
    normal! h
    let day = matchstr(expand("<cword>"), '[^0].*')
    normal! l
  else
    let day = matchstr(expand("<cword>"), '[^0].*')
  endif
  if day == 0
    return
  endif
  " extract year and month
  if exists('g:calendar_erafmt') && g:calendar_erafmt !~ "^\s*$"
    let year = matchstr(substitute(sline, '/.*', '', ''), '\d\+')
    let month = matchstr(substitute(sline, '.*/\(\d\d\=\).*', '\1', ""), '[^0].*')
    if g:calendar_erafmt =~ '.*,[+-]*\d\+'
      let veranum = substitute(g:calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
      if year-veranum > 0
        let year = year-veranum
      endif
    endif
  else
    let year  = matchstr(substitute(sline, '/.*', '', ''), '[^0].*')
    let month = matchstr(substitute(sline, '\d*/\(\d\d\=\).*', '\1', ""), '[^0].*')
  endif
  " call the action function
  exe "call " . g:calendar_action . "(day, month, year, week, dir)"
endfunc

"*****************************************************************
"* Calendar : build calendar
"*----------------------------------------------------------------
"*   a1 : direction
"*   a2 : month(if given a3, it's year)
"*   a3 : if given, it's month
"*****************************************************************
function! calendar#show(...)

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ ready for build
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " remember today
  " divide strftime('%d') by 1 so as to get "1,2,3 .. 9" instead of "01, 02, 03 .. 09"
  let vtoday = strftime('%Y').strftime('%m').strftime('%d')

  " get arguments
  if a:0 == 0
    let dir = 0
    let vyear = strftime('%Y')
    let vmnth = matchstr(strftime('%m'), '[^0].*')
  elseif a:0 == 1
    let dir = a:1
    let vyear = strftime('%Y')
    let vmnth = matchstr(strftime('%m'), '[^0].*')
  elseif a:0 == 2
    let dir = a:1
    let vyear = strftime('%Y')
    let vmnth = matchstr(a:2, '^[^0].*')
  else
    let dir = a:1
    let vyear = a:2
    let vmnth = matchstr(a:3, '^[^0].*')
  endif

  " remember constant
  let vmnth_org = vmnth
  let vyear_org = vyear

  " start with last month
  let vmnth = vmnth - 1
  if vmnth < 1
    let vmnth = 12
    let vyear = vyear - 1
  endif

  " reset display variables
  let vdisplay1 = ''
  let vheight = 1
  let vmcnt = 0

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build display
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if exists("g:calendar_begin")
    exe "call " . g:calendar_begin . "()"
  endif
  while vmcnt < 3
    let vcolumn = 22
    let vnweek = -1
    "--------------------------------------------------------------
    "--- calculating
    "--------------------------------------------------------------
    " set boundary of the month
    if vmnth == 1
      let vmdays = 31
      let vparam = 1
      let vsmnth = 'Jan'
    elseif vmnth == 2
      let vmdays = 28
      let vparam = 32
      let vsmnth = 'Feb'
    elseif vmnth == 3
      let vmdays = 31
      let vparam = 60
      let vsmnth = 'Mar'
    elseif vmnth == 4
      let vmdays = 30
      let vparam = 91
      let vsmnth = 'Apr'
    elseif vmnth == 5
      let vmdays = 31
      let vparam = 121
      let vsmnth = 'May'
    elseif vmnth == 6
      let vmdays = 30
      let vparam = 152
      let vsmnth = 'Jun'
    elseif vmnth == 7
      let vmdays = 31
      let vparam = 182
      let vsmnth = 'Jul'
    elseif vmnth == 8
      let vmdays = 31
      let vparam = 213
      let vsmnth = 'Aug'
    elseif vmnth == 9
      let vmdays = 30
      let vparam = 244
      let vsmnth = 'Sep'
    elseif vmnth == 10
      let vmdays = 31
      let vparam = 274
      let vsmnth = 'Oct'
    elseif vmnth == 11
      let vmdays = 30
      let vparam = 305
      let vsmnth = 'Nov'
    elseif vmnth == 12
      let vmdays = 31
      let vparam = 335
      let vsmnth = 'Dec'
    else
      echo 'Invalid Year or Month'
      return
    endif
    if vyear % 400 == 0
      if vmnth == 2
        let vmdays = 29
      elseif vmnth >= 3
        let vparam = vparam + 1
      endif
    elseif vyear % 100 == 0
      if vmnth == 2
        let vmdays = 28
      endif
    elseif vyear % 4 == 0
      if vmnth == 2
        let vmdays = 29
      elseif vmnth >= 3
        let vparam = vparam + 1
      endif
    endif

    " calc vnweek of the day
    if vnweek == -1
      let vnweek = ( vyear * 365 ) + vparam
      let vnweek = vnweek + ( vyear/4 ) - ( vyear/100 ) + ( vyear/400 )
      if vyear % 4 == 0
        if vyear % 100 != 0 || vyear % 400 == 0
          let vnweek = vnweek - 1
        endif
      endif
      let vnweek = vnweek - 1
    endif

    " fix Gregorian
    if vyear <= 1752
      let vnweek = vnweek - 3
    endif

    let vnweek = vnweek % 7

    if exists('g:calendar_monday')
      " if given g:calendar_monday, the week start with monday
      if vnweek == 0
        let vnweek = 7
      endif
      let vnweek = vnweek - 1
    endif

    if exists('g:calendar_weeknm')
      " if given g:calendar_weeknm, show week number(ref:ISO8601)

      "vparam <= 1. day of month
      "vnweek <= 1. weekday of month (0-6)
      "viweek <= number of week
      "vfweek <= 1. day of year

      " mo di mi do fr sa so
      " 6  5  4  3  2  1  0  vfweek
      " 0  1  2  3  4  5  6  vnweek

      let vfweek =((vparam % 7)  -vnweek+ 14-2) % 7
      let viweek = (vparam - vfweek-2+7 ) / 7 +1

      if vfweek < 3
         let viweek = viweek - 1
      endif

      "vfweekl  <=year length
      let vfweekl = 52
      if (vfweek == 3)
        let vfweekl = 53
      endif

      if viweek == 0
        let viweek = 52
        if ((vfweek == 2) && (((vyear-1) % 4) != 0))
              \ || ((vfweek == 1) && (((vyear-1) % 4) == 0))
          let viweek = 53
        endif
      endif

      let vcolumn = vcolumn + 5
      if g:calendar_weeknm == 5
        let vcolumn = vcolumn - 2
      endif
    endif

    "--------------------------------------------------------------
    "--- displaying
    "--------------------------------------------------------------
    " build header
    if exists('g:calendar_erafmt') && g:calendar_erafmt !~ "^\s*$"
      if g:calendar_erafmt =~ '.*,[+-]*\d\+'
        let veranum = substitute(g:calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
        if vyear+veranum > 0
          let vdisplay2 = substitute(g:calendar_erafmt,'\(.*\),.*','\1','')
          let vdisplay2 = vdisplay2.(vyear+veranum).'/'.vmnth.'('
        else
          let vdisplay2 = vyear.'/'.vmnth.'('
        endif
      else
        let vdisplay2 = vyear.'/'.vmnth.'('
      endif
      let vdisplay2 = strpart("                           ",
        \ 1,(vcolumn-strlen(vdisplay2))/2-2).vdisplay2
    else
      let vdisplay2 = vyear.'/'.vmnth.'('
      let vdisplay2 = strpart("                           ",
        \ 1,(vcolumn-strlen(vdisplay2))/2-2).vdisplay2
    endif
    if exists('g:calendar_mruler') && g:calendar_mruler !~ "^\s*$"
      let vdisplay2 = vdisplay2 . get(split(g:calendar_mruler, ','), vmnth-1, '').')'."\n"
    else
      let vdisplay2 = vdisplay2 . vsmnth.')'."\n"
    endif
    let vwruler = "Su Mo Tu We Th Fr Sa"
    if exists('g:calendar_wruler') && g:calendar_wruler !~ "^\s*$"
      let vwruler = g:calendar_wruler
    endif
    if exists('g:calendar_monday')
      let vwruler = strpart(vwruler,stridx(vwruler, ' ') + 1).' '.strpart(vwruler,0,stridx(vwruler, ' '))
    endif
    let vdisplay2 = vdisplay2.' '.vwruler."\n"
    if g:calendar_mark == 'right'
      let vdisplay2 = vdisplay2.' '
    endif

    " build calendar
    let vinpcur = 0
    while (vinpcur < vnweek)
      let vdisplay2 = vdisplay2.'   '
      let vinpcur = vinpcur + 1
    endwhile
    let vdaycur = 1
    while (vdaycur <= vmdays)
      if vmnth < 10
         let vtarget = vyear."0".vmnth
      else
         let vtarget = vyear.vmnth
      endif
      if vdaycur < 10
         let vtarget = vtarget."0".vdaycur
      else
         let vtarget = vtarget.vdaycur
      endif
      if exists("g:calendar_sign") && g:calendar_sign != ""
        exe "let vsign = " . g:calendar_sign . "(vdaycur, vmnth, vyear)"
        if vsign != ""
          let vsign = vsign[0]
          if vsign !~ "[+!#$%&@?]"
            let vsign = "+"
          endif
        endif
      else
        let vsign = ''
      endif

      " show mark
      if g:calendar_mark == 'right'
        if vdaycur < 10
          let vdisplay2 = vdisplay2.' '
        endif
        let vdisplay2 = vdisplay2.vdaycur
      elseif g:calendar_mark == 'left-fit'
        if vdaycur < 10
          let vdisplay2 = vdisplay2.' '
        endif
      endif
      if vtarget == vtoday
        let vdisplay2 = vdisplay2.'*'
      elseif vsign != ''
        let vdisplay2 = vdisplay2.vsign
      else
        let vdisplay2 = vdisplay2.' '
      endif
      if g:calendar_mark == 'left'
        if vdaycur < 10
          let vdisplay2 = vdisplay2.' '
        endif
        let vdisplay2 = vdisplay2.vdaycur
      endif
      if g:calendar_mark == 'left-fit'
        let vdisplay2 = vdisplay2.vdaycur
      endif
      let vdaycur = vdaycur + 1

      " fix Gregorian
      if vyear == 1752 && vmnth == 9 && vdaycur == 3
        let vdaycur = 14
      endif

      let vinpcur = vinpcur + 1
      if vinpcur % 7 == 0
        if exists('g:calendar_weeknm')
          if g:calendar_mark != 'right'
            let vdisplay2 = vdisplay2.' '
          endif
          " if given g:calendar_weeknm, show week number
          if viweek < 10
            if g:calendar_weeknm == 1
              let vdisplay2 = vdisplay2.'WK0'.viweek
            elseif g:calendar_weeknm == 2
              let vdisplay2 = vdisplay2.'WK '.viweek
            elseif g:calendar_weeknm == 3
              let vdisplay2 = vdisplay2.'KW0'.viweek
            elseif g:calendar_weeknm == 4
              let vdisplay2 = vdisplay2.'KW '.viweek
            elseif g:calendar_weeknm == 5
              let vdisplay2 = vdisplay2.' '.viweek
            endif
          else
            if g:calendar_weeknm <= 2
              let vdisplay2 = vdisplay2.'WK'.viweek
            elseif g:calendar_weeknm == 3 || g:calendar_weeknm == 4
              let vdisplay2 = vdisplay2.'KW'.viweek
            elseif g:calendar_weeknm == 5
              let vdisplay2 = vdisplay2.viweek
            endif
          endif
          let viweek = viweek + 1

          if viweek > vfweekl
            let viweek = 1
          endif

        endif
        let vdisplay2 = vdisplay2."\n"
        if g:calendar_mark == 'right'
          let vdisplay2 = vdisplay2.' '
        endif
      endif
    endwhile

    " if it is needed, fill with space
    if vinpcur % 7
      while (vinpcur % 7 != 0)
        let vdisplay2 = vdisplay2.'   '
        let vinpcur = vinpcur + 1
      endwhile
      if exists('g:calendar_weeknm')
        if g:calendar_mark != 'right'
          let vdisplay2 = vdisplay2.' '
        endif
        if viweek < 10
          if g:calendar_weeknm == 1
            let vdisplay2 = vdisplay2.'WK0'.viweek
          elseif g:calendar_weeknm == 2
            let vdisplay2 = vdisplay2.'WK '.viweek
          elseif g:calendar_weeknm == 3
            let vdisplay2 = vdisplay2.'KW0'.viweek
          elseif g:calendar_weeknm == 4
            let vdisplay2 = vdisplay2.'KW '.viweek
          elseif g:calendar_weeknm == 5
            let vdisplay2 = vdisplay2.' '.viweek
          endif
        else
          if g:calendar_weeknm <= 2
            let vdisplay2 = vdisplay2.'WK'.viweek
		  elseif g:calendar_weeknm == 3 || g:calendar_weeknm == 4
		    let vdisplay2 = vdisplay2.'KW'.viweek
		  elseif g:calendar_weeknm == 5
		    let vdisplay2 = vdisplay2.viweek
          endif
        endif
      endif
    endif

    " build display
    let vstrline = ''
    if dir
      " for horizontal
      "--------------------------------------------------------------
      " +---+   +---+   +------+
      " |   |   |   |   |      |
      " | 1 | + | 2 | = |  1'  |
      " |   |   |   |   |      |
      " +---+   +---+   +------+
      "--------------------------------------------------------------
      let vtokline = 1
      while 1
        let vtoken1 = get(split(vdisplay1, "\n"), vtokline-1, '')
        let vtoken2 = get(split(vdisplay2, "\n"), vtokline-1, '')
        if vtoken1 == '' && vtoken2 == ''
          break
        endif
        while strlen(vtoken1) < (vcolumn+1)*vmcnt
          if strlen(vtoken1) % (vcolumn+1) == 0
            let vtoken1 = vtoken1.'|'
          else
            let vtoken1 = vtoken1.' '
          endif
        endwhile
        let vstrline = vstrline.vtoken1.'|'.vtoken2.' '."\n"
        let vtokline = vtokline + 1
      endwhile
      let vdisplay1 = vstrline
      let vheight = vtokline-1
    else
      " for virtical
      "--------------------------------------------------------------
      " +---+   +---+   +---+
      " | 1 | + | 2 | = |   |
      " +---+   +---+   | 1'|
      "                 |   |
      "                 +---+
      "--------------------------------------------------------------
      let vtokline = 1
      while 1
        let vtoken1 = get(split(vdisplay1, "\n"), vtokline-1, '')
        if vtoken1 == ''
          break
        endif
        let vstrline = vstrline.vtoken1."\n"
        let vtokline = vtokline + 1
        let vheight = vheight + 1
      endwhile
      if vstrline != ''
        let vstrline = vstrline.' '."\n"
        let vheight = vheight + 1
      endif
      let vtokline = 1
      while 1
        let vtoken2 = get(split(vdisplay2, "\n"), vtokline-1, '')
        if vtoken2 == ''
          break
        endif
        while strlen(vtoken2) < vcolumn
          let vtoken2 = vtoken2.' '
        endwhile
        let vstrline = vstrline.vtoken2."\n"
        let vtokline = vtokline + 1
        let vheight = vtokline + 1
      endwhile
      let vdisplay1 = vstrline
    endif
    let vmnth = vmnth + 1
    let vmcnt = vmcnt + 1
    if vmnth > 12
      let vmnth = 1
      let vyear = vyear + 1
    endif
  endwhile
  if exists("g:calendar_end")
    exe "call " . g:calendar_end . "()"
  endif
  if a:0 == 0
    return vdisplay1
  endif

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build window
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " make window
  let vwinnum = bufnr('__Calendar')
  if getbufvar(vwinnum, 'Calendar') == 'Calendar'
    let vwinnum = bufwinnr(vwinnum)
  else
    let vwinnum = -1
  endif

  if vwinnum >= 0
    " if already exist
    if vwinnum != bufwinnr('%')
      exe vwinnum . 'wincmd w'
    endif
    setlocal modifiable
    silent %d _
  else
    " make title
    if g:calendar_datetime == "title" && (!exists('s:bufautocommandsset'))
      auto BufEnter *Calendar let b:sav_titlestring = &titlestring | let &titlestring = '%{strftime("%c")}'
      auto BufLeave *Calendar let &titlestring = b:sav_titlestring
      let s:bufautocommandsset = 1
    endif

    if exists('g:calendar_navi') && dir
      if g:calendar_navi == 'both'
        let vheight = vheight + 4
      else
        let vheight = vheight + 2
      endif
    endif

    " or not
    if dir
      silent execute 'bo '.vheight.'split __Calendar'
      setlocal winfixheight
    else
      silent execute 'to '.vcolumn.'vsplit __Calendar'
      setlocal winfixwidth
    endif
    call s:CalendarBuildKeymap(dir, vyear, vmnth)
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    silent! exe "setlocal " . g:calendar_options
    let nontext_columns = &foldcolumn + &nu * &numberwidth
    if has("+relativenumber")
      let nontext_columns += &rnu * &numberwidth
    endif
    " Without this, the 'sidescrolloff' setting may cause the left side of the
    " calendar to disappear if the last inserted element is near the right
    " window border.
    setlocal nowrap
    setlocal norightleft
    setlocal modifiable
    setlocal nolist
    let b:Calendar = 'Calendar'
    setlocal filetype=calendar
    " is this a vertical (0) or a horizontal (1) split?
    exe vcolumn + nontext_columns . "wincmd |"
  endif
  if g:calendar_datetime == "statusline"
    setlocal statusline=%{strftime('%c')}
  endif
  let b:CalendarDir = dir
  let b:CalendarYear = vyear_org
  let b:CalendarMonth = vmnth_org

  " navi
  if exists('g:calendar_navi')
    let navi_label = '<'
        \.get(split(g:calendar_navi_label, ','), 0, '').' '
        \.get(split(g:calendar_navi_label, ','), 1, '').' '
        \.get(split(g:calendar_navi_label, ','), 2, '').'>'
    if dir
      let navcol = vcolumn + (vcolumn-strlen(navi_label)+2)/2
    else
      let navcol = (vcolumn-strlen(navi_label)+2)/2
    endif
    if navcol < 3
      let navcol = 3
    endif

    if g:calendar_navi == 'top'
      execute "normal gg".navcol."i "
      silent exec "normal! a".navi_label."\<cr>\<cr>"
      silent put! =vdisplay1
    endif
    if g:calendar_navi == 'bottom'
      silent put! =vdisplay1
      silent exec "normal! Gi\<cr>"
      execute "normal ".navcol."i "
      silent exec "normal! a".navi_label
    endif
    if g:calendar_navi == 'both'
      execute "normal gg".navcol."i "
      silent exec "normal! a".navi_label."\<cr>\<cr>"
      silent put! =vdisplay1
      silent exec "normal! Gi\<cr>"
      execute "normal ".navcol."i "
      silent exec "normal! a".navi_label
    endif
  else
    silent put! =vdisplay1
  endif

  setlocal nomodifiable
  " In case we've gotten here from insert mode (via <C-O>:Calendar<CR>)...
  stopinsert

  let vyear = vyear_org
  let vmnth = vmnth_org

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build highlight
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " today
  syn clear
  if g:calendar_mark =~ 'left-fit'
    syn match CalToday display "\s*\*\d*"
    syn match CalMemo display "\s*[+!#$%&@?]\d*"
  elseif g:calendar_mark =~ 'right'
    syn match CalToday display "\d*\*\s*"
    syn match CalMemo display "\d*[+!#$%&@?]\s*"
  else
    syn match CalToday display "\*\s*\d*"
    syn match CalMemo display "[+!#$%&@?]\s*\d*"
  endif
  " header
  syn match CalHeader display "[^ ]*\d\+\/\d\+([^)]*)"

  " navi
  if exists('g:calendar_navi')
    exec "silent! syn match CalNavi display \"\\(<"
        \.get(split(g:calendar_navi_label, ','), 0, '')."\\|"
        \.get(split(g:calendar_navi_label, ','), 2, '').">\\)\""
    exec "silent! syn match CalNavi display \"\\s"
        \.get(split(g:calendar_navi_label, ','), 1, '')."\\s\"hs=s+1,he=e-1"
  endif

  " saturday, sunday

  if exists('g:calendar_monday')
    if dir
      syn match CalSaturday display /|.\{15}\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
      syn match CalSunday display /|.\{18}\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
    else
      syn match CalSaturday display /^.\{15}\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
      syn match CalSunday display /^.\{18}\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
    endif
  else
    if dir
      syn match CalSaturday display /|.\{18}\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
      syn match CalSunday display /|\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
    else
      syn match CalSaturday display /^.\{18}\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
      syn match CalSunday display /^\s\([0-9\ ]\d\)/hs=e-1 contains=ALL
    endif
  endif

  " week number
  if !exists('g:calendar_weeknm') || g:calendar_weeknm <= 2
    syn match CalWeeknm display "WK[0-9\ ]\d"
  else
    syn match CalWeeknm display "KW[0-9\ ]\d"
  endif

  " ruler
  execute 'syn match CalRuler "'.vwruler.'"'

  if search("\*","w") > 0
    silent execute "normal! gg/\*\<cr>"
  endif

  return ''
endfunction

"*****************************************************************
"* make_dir : make directory
"*----------------------------------------------------------------
"*   dir : directory
"*****************************************************************
function! s:make_dir(dir)
  if(has("unix"))
    call system("mkdir " . a:dir)
    let rc = v:shell_error
  elseif(has("win16") || has("win32") || has("win95") ||
              \has("dos16") || has("dos32") || has("os2"))
    call system("mkdir \"" . a:dir . "\"")
    let rc = v:shell_error
  else
    let rc = 1
  endif
  if rc != 0
    call confirm("can't create directory : " . a:dir, "&OK")
  endif
  return rc
endfunc

"*****************************************************************
"* diary : calendar hook function
"*----------------------------------------------------------------
"*   day   : day you actioned
"*   month : month you actioned
"*   year  : year you actioned
"*****************************************************************
function! calendar#diary(day, month, year, week, dir)
  " build the file name and create directories as needed
  if !isdirectory(expand(g:calendar_diary))
    call confirm("please create diary directory : ".g:calendar_diary, 'OK')
    return
  endif
  let sfile = expand(g:calendar_diary) . "/" . a:year
  if isdirectory(sfile) == 0
    if s:make_dir(sfile) != 0
      return
    endif
  endif
  let sfile = sfile . "/" . a:month
  if isdirectory(sfile) == 0
    if s:make_dir(sfile) != 0
      return
    endif
  endif
  let sfile = expand(sfile) . "/" . a:day . ".md"
  let sfile = substitute(sfile, ' ', '\\ ', 'g')
  let vbufnr = bufnr('__Calendar')

  " load the file
  exe "wincmd w"
  exe "edit  " . sfile
  let dir = getbufvar(vbufnr, "CalendarDir")
  let vyear = getbufvar(vbufnr, "CalendarYear")
  let vmnth = getbufvar(vbufnr, "CalendarMonth")
  exe "auto BufDelete ".escape(sfile, ' \\')." call calendar#show(" . dir . "," . vyear . "," . vmnth . ")"
endfunc

"*****************************************************************
"* sign : calendar sign function
"*----------------------------------------------------------------
"*   day   : day of sign
"*   month : month of sign
"*   year  : year of sign
"*****************************************************************
function! calendar#sign(day, month, year)
  let sfile = g:calendar_diary."/".a:year."/".a:month."/".a:day.".md"
  return filereadable(expand(sfile))
endfunction

"*****************************************************************
"* CalendarVar : get variable
"*----------------------------------------------------------------
"*****************************************************************
function! s:CalendarVar(var)
  if !exists(a:var)
    return ''
  endif
  exec 'return ' . a:var
endfunction

"*****************************************************************
"* CalendarBuildKeymap : build keymap
"*----------------------------------------------------------------
"*****************************************************************
function! s:CalendarBuildKeymap(dir, vyear, vmnth)
  " make keymap
  nnoremap <silent> <buffer> <Plug>CalendarDoAction  :call calendar#action()<cr>
  nnoremap <silent> <buffer> <Plug>CalendarDoAction  :call calendar#action()<cr>
  nnoremap <silent> <buffer> <Plug>CalendarGotoToday :call calendar#show(b:CalendarDir)<cr>
  nnoremap <silent> <buffer> <Plug>CalendarShowHelp  :call <SID>CalendarHelp()<cr>
  execute 'nnoremap <silent> <buffer> <Plug>CalendarReDisplay :call calendar#show(' . a:dir . ',' . a:vyear . ',' . a:vmnth . ')<cr>'
  let pnav = get(split(g:calendar_navi_label, ','), 0, '')
  let nnav = get(split(g:calendar_navi_label, ','), 2, '')
  execute 'nnoremap <silent> <buffer> <Plug>CalendarGotoPrevMonth :call calendar#action("<' . pnav . '")<cr>'
  execute 'nnoremap <silent> <buffer> <Plug>CalendarGotoNextMonth :call calendar#action("' . nnav . '>")<cr>'
  execute 'nnoremap <silent> <buffer> <Plug>CalendarGotoPrevYear  :call calendar#show('.a:dir.','.(a:vyear-1).','.a:vmnth.')<cr>'
  execute 'nnoremap <silent> <buffer> <Plug>CalendarGotoNextYear  :call calendar#show('.a:dir.','.(a:vyear+1).','.a:vmnth.')<cr>'

  nmap <buffer> <2-LeftMouse> <Plug>CalendarDoAction

  execute 'nmap <buffer> ' . s:calendar_keys['close'] . ' <C-w>c'
  execute 'nmap <buffer> ' . s:calendar_keys['do_action'] . ' <Plug>CalendarDoAction'
  execute 'nmap <buffer> ' . s:calendar_keys['goto_today'] . ' <Plug>CalendarGotoToday'
  execute 'nmap <buffer> ' . s:calendar_keys['show_help'] . ' <Plug>CalendarShowHelp'
  execute 'nmap <buffer> ' . s:calendar_keys['redisplay'] . ' <Plug>CalendarRedisplay'

  execute 'nmap <buffer> ' . s:calendar_keys['goto_next_month'] . ' <Plug>CalendarGotoNextMonth'
  execute 'nmap <buffer> ' . s:calendar_keys['goto_prev_month'] . ' <Plug>CalendarGotoPrevMonth'
  execute 'nmap <buffer> ' . s:calendar_keys['goto_next_year'] . ' <Plug>CalendarGotoNextYear'
  execute 'nmap <buffer> ' . s:calendar_keys['goto_prev_year'] . ' <Plug>CalendarGotoPrevYear'
endfunction

"*****************************************************************
"* CalendarHelp : show help for Calendar
"*----------------------------------------------------------------
"*****************************************************************
function! s:CalendarHelp()
  let ck = s:calendar_keys
  let max_width = max(map(values(ck), 'len(v:val)'))
  let offsets = map(copy(ck), '1 + max_width - len(v:val)')

  echohl SpecialKey
  echo ck['goto_prev_month']  . repeat(' ', offsets['goto_prev_month']) . ': goto prev month'
  echo ck['goto_next_month']  . repeat(' ', offsets['goto_next_month']) . ': goto next month'
  echo ck['goto_prev_year']   . repeat(' ', offsets['goto_prev_year'])  . ': goto prev year'
  echo ck['goto_next_year']   . repeat(' ', offsets['goto_next_year'])  . ': goto next year'
  echo ck['goto_today']       . repeat(' ', offsets['goto_today'])      . ': goto today'
  echo ck['close']            . repeat(' ', offsets['close'])           . ': close window'
  echo ck['redisplay']        . repeat(' ', offsets['redisplay'])       . ': re-display window'
  echo ck['show_help']        . repeat(' ', offsets['show_help'])       . ': show this help'
  if g:calendar_action == "calendar#diary"
    echo ck['do_action']      . repeat(' ', offsets['do_action'])       . ': show diary'
  endif
  echo ''
  echohl Question

  let vk = [
  \ 'calendar_erafmt',
  \ 'calendar_mruler',
  \ 'calendar_wruler',
  \ 'calendar_weeknm',
  \ 'calendar_navi_label',
  \ 'calendar_diary',
  \ 'calendar_mark',
  \ 'calendar_navi',
  \]
  let max_width = max(map(copy(vk), 'len(v:val)'))

  for _ in vk
    let v = get(g:, _, '')
    echo _ . repeat(' ', max_width - len(_)) . ' = ' .  v
  endfor
  echohl MoreMsg
  echo "[Hit any key]"
  echohl None
  call getchar()
  redraw!
endfunction

hi def link CalNavi     Search
hi def link CalSaturday Statement
hi def link CalSunday   Type
hi def link CalRuler    StatusLine
hi def link CalWeeknm   Comment
hi def link CalToday    Directory
hi def link CalHeader   Special
hi def link CalMemo     Identifier
