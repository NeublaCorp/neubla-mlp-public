" Verify if already loaded
if exists("loaded_Doxygen")
finish
endif
let loaded_Doxygen = 1

" Common standard constants
let g:Doxygen_authorName  = "Who"
let g:Doxygen_authorEmail = "username@neubla.com"
let g:Doxygen_briefTag    = "@brief "
let g:Doxygen_paramTag    = "@param "
let g:Doxygen_returnTag   = "@retval "
let g:Doxygen_remarkTag   = "@remark "
let g:Doxygen_fileTag     = "@file "
let g:Doxygen_versionTag  = "@version "
let g:Doxygen_dateTag     = "@date "
let g:Doxygen_authorTag   = "@author "
let g:Doxygen_ingroupTag  = "@ingroup "
let g:Doxygen_sectionTag  = "@section "
let g:Doxygen_pageTag     = "@page "
let g:Doxygen_subsectionTag = "@subsection "

let g:Doxygen_moduleStartCommentTag = "/**"
let g:Doxygen_moduleEndCommentTag   = "**/"
let g:Doxygen_moduleInterCommentTag = "  "
let g:Doxygen_fileStartCommentTag   = "//------------------------------------------------------------------------------"
let g:Doxygen_fileEndCommentTag     = "//------------------------------------------------------------------------------"
let g:Doxygen_startCommentTag       = "//------------------------------------------------------------------------------"
let g:Doxygen_interCommentTag       = "/// "
let g:Doxygen_pythonFileStartCommentTag = "##"
let g:Doxygen_pythonInterCommentTag     = "#  "
let g:Doxygen_pythonStartCommentTag = "\"\"\"!"
let g:Doxygen_pythonEndCommentTag   = "\"\"\""
let g:Doxygen_endCommentTag = " "
let g:Doxygen_ignoreForReturn = "inline static virtual void"
let g:Doxygen_ext = expand('%:e')

""""""""""""""""""""""""""
" Doxygen comment function
  """"""""""""""""""""""""""
function! <SID>DoxygenCommentFunc()

  let l:argBegin = "\("
  let l:argEnd = "\)"
  let l:argSep = ','
  let l:sep = "\ "
  let l:voidStr = "void"

  let l:classDef = 0

  " Save standard comment expension
  let l:oldComments = &comments
  let &comments = ""

  " Save indentation settings
  let l:oldAutoIndent = &autoindent
  let l:oldCIndent = &cindent
  let &autoindent=1
  let &cindent=0

  echo "g:Doxygen_ext: " g:Doxygen_ext

  " temporarily disable indentation
  set paste

  " skip blank lines
  let l:cur_line_no = line(".")
  while ( l:cur_line_no < line("$") && strlen(substitute(getline(l:cur_line_no), "^\s+", "", "")) == 0 )
    exec "normal j"
    let l:cur_line_no = l:cur_line_no + 1
  endwhile

  " mark on the current line
  mark d

  " Store function in a buffer
  let l:indent_below = ""
  let l:lineBuffer = getline(line("."))
  if ( g:Doxygen_ext =~ "py" )
    " mark on the current line
    mark d

    " skip blank lines right below function signature itself
    let l:cur_line_no = line(".") + 1
    while ( l:cur_line_no < line("$") && strlen(substitute(getline(l:cur_line_no), "^\s+", "", "")) == 0 )
      exec "normal j"
      let l:cur_line_no = l:cur_line_no + 1
    endwhile
    let l:indent_below = strpart(getline(l:cur_line_no), 0, indent(l:cur_line_no))

    " return to the marked line
    exec "normal `d"
  else
    let l:cur_line_no = line(".")
    let l:indent_below = strpart(getline(l:cur_line_no), 0, indent(l:cur_line_no))
  endif

  echo "0.current_line: " . getline(line("."))
  echo "1.l:indent_below: " . strlen(l:indent_below)
  echo "2.l:indent_below: " . l:indent_below

  mark d

  let l:count = 1
  " Return of function can be defined on other line than the one of the
  " function.
  while ( l:lineBuffer !~ l:argBegin && l:count < 4 )
    " This is probably a class (or something else definition)
    if ( l:lineBuffer =~ "class" || l:lineBuffer =~ "{" || l:lineBuffer =~ ";" )
      let l:classDef = 1
      break
    endif
    exec "normal j"
    let l:line = getline(line("."))
    let l:lineBuffer = l:lineBuffer . ' ' . l:line
    let l:count = l:count + 1
  endwhile

  if ( l:classDef == 0 )
    if ( l:count == 4 )
      " Restore standard comment expension
      let &comments = l:oldComments
      " Restore indentation settings
      let &autoindent = l:oldAutoIndent
      let &cindent = l:oldCIndent
      return
    endif

    " Get the entire function
    let l:count = 0
    while ( l:lineBuffer !~ l:argEnd && l:count < 10 )
      exec "normal j"
      let l:line = getline(line("."))
      let l:lineBuffer = l:lineBuffer . ' ' . l:line
      let l:count = l:count + 1
    endwhile

    " Function definition seem to be too long...
    if ( l:count == 10 )
      " Restore standard comment expension
      let &comments = l:oldComments
      " Restore indentation settings
      let &autoindent = l:oldAutoIndent
      let &cindent = l:oldCIndent
      return
    endif
  endif

  " Start creating doxygen pattern
  if ( g:Doxygen_ext =~ "py" )
    exec "normal `d"
    exec "normal o" . l:indent_below . g:Doxygen_pythonStartCommentTag
    exec "normal o" . l:indent_below . g:Doxygen_briefTag
    mark d
    exec "normal `d"
  else
    exec "normal `d"
    exec "normal O" . l:indent_below .  g:Doxygen_interCommentTag . g:Doxygen_briefTag
    mark d
    exec "normal `d"
  endif

  " Class definition, let's start with brief tag
  if ( l:classDef == 1 )
    if ( g:Doxygen_ext =~ "py" )
      exec "normal o" . l:indent_below . g:Doxygen_ingroupTag . expand("%:p:h:t")
      exec "normal o" . l:indent_below . g:Doxygen_pythonEndCommentTag
    else
      exec "normal o" . l:indent_below . g:Doxygen_interCommentTag . g:Doxygen_ingroupTag . expand("%:p:h:t")
      exec "normal o" . l:indent_below . g:Doxygen_interCommentTag
      exec "normal o" . l:indent_below . g:Doxygen_interCommentTag
    endif

    " Restore standard comment expension
    let &comments = l:oldComments
    " Restore indentation settings
    let &autoindent = l:oldAutoIndent
    let &cindent = l:oldCIndent

    startinsert!
    return
  endif

  " Substitute function pointer into normal argument
  let l:lineBuffer = substitute(l:lineBuffer, '(\s*\*\(.*\))\s*(.*)\s*\([,)]\)', '\1\2', "g")

  " Delete space just after and just before parenthesis
  let l:lineBuffer = substitute(l:lineBuffer, "\t", "\ ", "g")
  let l:lineBuffer = substitute(l:lineBuffer, "(\ ", "(", "")
  let l:lineBuffer = substitute(l:lineBuffer, "\ )", ")", "")

  " Delete recursively all double spaces
  while ( match(l:lineBuffer, "\ \ ") != -1 )
    let l:lineBuffer = substitute(l:lineBuffer, "\ \ ", "\ ", "g")
  endwhile

  " Delete first space (if any)
  if ( match(l:lineBuffer, ' ') == 0 )
    let l:lineBuffer = strpart(l:lineBuffer, 1)
  endif

  " Add return tag if function do not return void
  let l:beginArgPos = match(l:lineBuffer, l:argBegin)
  let l:beginP = 0        " Name can start at the beginning of l:lineBuffer, it is usually between spaces or space and parenthesis
  let l:endP = 0
  let l:returnFlag = -1   " At least one name (function name) do not correspond to the list of ignored values.
  while ( l:endP != l:beginArgPos )
    let l:endP = match(l:lineBuffer, ' ', l:beginP )
    if ( l:endP > l:beginArgPos || l:endP == -1 )
      let l:endP = l:beginArgPos
    endif
    let l:name = strpart(l:lineBuffer, l:beginP, l:endP - l:beginP)
    let l:beginP = l:endP + 1
    if ( l:name[0] != '~' && match(g:Doxygen_ignoreForReturn, l:name) == -1 )
      let l:returnFlag = l:returnFlag + 1
    endif
  endwhile
  if ( l:returnFlag >= 1 )
    if ( g:Doxygen_ext =~ "py" )
      exec "normal o" . l:indent_below . g:Doxygen_returnTag
      exec "normal o" . l:indent_below . g:Doxygen_pythonEndCommentTag
    else
      exec "normal o" . l:indent_below . g:Doxygen_interCommentTag
      exec "normal o" . l:indent_below . g:Doxygen_interCommentTag . g:Doxygen_returnTag
    endif
  endif
  "exec "normal o" . g:Doxygen_interCommentTag . g:Doxygen_remarkTag

  " Looking for argument name in line buffer
  exec "normal `d"
  let l:argList = 0    " ==0 -> no argument, !=0 -> at least one arg

  let l:beginP = 0
  let l:endP = 0
  let l:prevBeginP = 0

  " Arguments start after opening parenthesis
  let l:beginP = match(l:lineBuffer, l:argBegin, l:beginP) + 1
  let l:prevBeginP = l:beginP
  let l:endP = l:beginP

  " Test if there is something into parenthesis
  let l:beginP = l:beginP
  if ( l:beginP == match(l:lineBuffer, l:argEnd, l:beginP) )
    " Restore standard comment expension
    let &comments = l:oldComments
    " Restore indentation settings
    let &autoindent = l:oldAutoIndent
    let &cindent = l:oldCIndent

    startinsert!
    return
  endif

  let l:once = 0

  " Enter into main loop
  while ( l:beginP > 0 && l:endP > 0 )

    " Looking for arg separator
    let l:endP1 = match(l:lineBuffer, l:argSep, l:beginP)
    let l:endP = match(l:lineBuffer, l:argEnd, l:beginP)

    if ( l:endP1 != -1 && l:endP1 < l:endP )
      let l:endP = l:endP1
    endif
    let l:endP = l:endP - 1

    if ( l:endP > 0 )
      let l:strBuf = ReturnArgName(l:lineBuffer, l:beginP, l:endP)
      " void parameter
      if ( l:strBuf == l:voidStr )
        " Restore standard comment expension
        let &comments = l:oldComments
        " Restore indentation settings
        let &autoindent = l:oldAutoIndent
        let &cindent = l:oldCIndent

        startinsert!
        break
      elseif ( l:once != 1 )
        if ( g:Doxygen_ext =~ "py" )
          exec "normal o"
        else
          exec "normal o" . l:indent_below . g:Doxygen_interCommentTag
        endif
        let l:once = 1
      endif
      if ( l:strBuf != "")
        if ( g:Doxygen_ext =~ "py")
          exec "normal o" . l:indent_below . g:Doxygen_paramTag . l:strBuf . " "
        else
          exec "normal o" . l:indent_below . g:Doxygen_interCommentTag . g:Doxygen_paramTag . l:strBuf . " "
        endif
      endif
      let l:beginP = l:endP + 2
      let l:argList = 1
    endif
  endwhile

  " move the cursor to the correct position (after brief tag)
  exec "normal `d"

  " Restore standard comment expension
  let &comments = l:oldComments
  " Restore indentation settings
  let &autoindent = l:oldAutoIndent
  let &cindent = l:oldCIndent

  " restore indentation mode
  set nopaste
  set expandtab

  startinsert!
endfunction

  """"""""""""""""""""""""""
  " Extract the name of argument
  """"""""""""""""""""""""""
function ReturnArgName(argBuf, beginP, endP)

  " Name of argument is at the end of argBuf if no default (id arg = 0)
  let l:equalP = match(a:argBuf, "=", a:beginP)
  if ( l:equalP == -1 || l:equalP > a:endP )
    " Look for arg name begining
    let l:beginP = a:beginP
    let l:prevBeginP = l:beginP
    while ( l:beginP < a:endP && l:beginP != -1 )
      let l:prevBeginP = l:beginP
      let l:beginP = match(a:argBuf, " ", l:beginP + 1)
    endwhile
    let l:beginP = l:prevBeginP
    let l:endP = a:endP
  else
    " Look for arg name begining
    let l:addPos = 0
    let l:beginP = a:beginP
    let l:prevBeginP = l:beginP
    let l:doublePrevBeginP = l:prevBeginP
    while ( l:beginP < l:equalP && l:beginP != -1 )
      let l:doublePrevBeginP = l:prevBeginP
      let l:prevBeginP = l:beginP + l:addPos
      let l:beginP = match(a:argBuf, " ", l:beginP + 1)
      let l:addPos = 1
    endwhile

    " Space just before equal
    if ( l:prevBeginP == l:equalP )
      let l:beginP = l:doublePrevBeginP
      let l:endP = l:prevBeginP - 2
    else
      " No space just before so...
      let l:beginP = l:prevBeginP
      let l:endP = l:equalP - 1
    endif
  endif

  " We have the begining position and the ending position...
  let l:newBuf = strpart(a:argBuf, l:beginP, l:endP - l:beginP + 1)

  " Delete leading '*' or '&'
  if ( match(l:newBuf, "*") == 1 || match(l:newBuf, "&") == 1 )
    let l:newBuf = strpart(l:newBuf, 2)
  endif

  " Delete tab definition ([])
  let l:delTab = match(newBuf, "[")
  if ( l:delTab != -1 )
    let l:newBuf = strpart(l:newBuf, 0, l:delTab)
  endif

  " Eventually clean argument name...
  let l:newBuf = substitute(l:newBuf, " ", "", "g")
  return l:newBuf

endfunction


  """"""""""""""""""""""""""
  " Doxygen file comment function
  """"""""""""""""""""""""""
function! <SID>DoxygenFileCommentFunc()

  if ( g:Doxygen_ext =~ 'py')
    " Save standard comment expension
    let l:oldComments = &comments
    let &comments = ""

    " Save indentation settings
    let l:oldAutoIndent = &autoindent
    let l:oldCIndent = &cindent
    let &autoindent=0
    let &cindent=0
    let l:filename = expand("%:p:t")
    let l:pathname = expand("%:p:h:t")

    exec "normal 1G"
    exec "normal O". g:Doxygen_pythonFileStartCommentTag
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_fileTag . " " . filename
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_ingroupTag . " " . pathname
    exec "normal o". g:Doxygen_pythonInterCommentTag
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_briefTag
    mark d
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_authorTag . " " . g:Doxygen_authorName . "<" . g:Doxygen_authorEmail . ">"
    exec "normal o". g:Doxygen_pythonInterCommentTag
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_sectionTag . "changelog_section Change Log"
    exec "normal o". g:Doxygen_pythonInterCommentTag . strftime("%Y/%m/%d") . " " . g:Doxygen_authorName . " created"
    exec "normal o". g:Doxygen_pythonInterCommentTag
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_sectionTag . "copyright_section Copyright"
    exec "normal o". g:Doxygen_pythonInterCommentTag . "©" . " " . strftime("%Y") . ", Neubla Corporation"
    exec "normal o". g:Doxygen_pythonInterCommentTag
    exec "normal o". g:Doxygen_pythonInterCommentTag . g:Doxygen_sectionTag . "license_section License"
    exec "normal o". g:Doxygen_pythonInterCommentTag . "Creative Commons 4.0 CC BY-NC-ND License"

    " move the cursor to the correct position (after brief tag)
    exec "normal `d"

    " Restore standard comment expension
    let &comments = l:oldComments
    " Restore indentation settings
    let &autoindent = l:oldAutoIndent
    let &cindent = l:oldCIndent

    startinsert!

  else
    " Save standard comment expension
    let l:oldComments = &comments
    let &comments = ""

    " Save indentation settings
    let l:oldAutoIndent = &autoindent
    let l:oldCIndent = &cindent
    let &autoindent=0
    let &cindent=0
    let l:filename = expand("%:p:t")
    let l:pathname = expand("%:p:h:t")

    exec "normal 1G"
    exec "normal O". g:Doxygen_fileStartCommentTag
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_fileTag . " " . filename
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_ingroupTag . " " . pathname
    exec "normal o". g:Doxygen_interCommentTag
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_briefTag
    mark d
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_authorTag . " " . g:Doxygen_authorName . "<" . g:Doxygen_authorEmail . ">"
    exec "normal o". g:Doxygen_interCommentTag
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_sectionTag . "changelog_section Change Log"
    exec "normal o". g:Doxygen_interCommentTag . strftime("%Y/%m/%d") . " " . g:Doxygen_authorName . " created"
    exec "normal o". g:Doxygen_interCommentTag
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_sectionTag . "copyright_section Copyright"
    exec "normal o". g:Doxygen_interCommentTag . "©" . " " . strftime("%Y") . ", Neubla Corporation"
    exec "normal o". g:Doxygen_interCommentTag
    exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_sectionTag . "license_section License"
    exec "normal o". g:Doxygen_interCommentTag . "Creative Commons 4.0 CC BY-NC-ND License"
    exec "normal o". g:Doxygen_fileEndCommentTag

    " move the cursor to the correct position (after brief tag)
    exec "normal `d"

    " Restore standard comment expension
    let &comments = l:oldComments
    " Restore indentation settings
    let &autoindent = l:oldAutoIndent
    let &cindent = l:oldCIndent

    startinsert!
  endif
endfunction


  """"""""""""""""""""""""""
  " Doxygen module comment function
  """"""""""""""""""""""""""
function! <SID>DoxygenModuleCommentFunc()

  " Save standard comment expension
  let l:oldComments = &comments
  let &comments = ""

  " Save indentation settings
  let l:oldAutoIndent = &autoindent
  let l:oldCIndent = &cindent
  let &autoindent=0
  let &cindent=0

  let l:indent_below = strpart(getline(line(".")+1), 0, indent(line(".")+1))
  if ( strlen(substitute(getline(line(".")), "^\s+", "", "")) != 0 && indent(line(".")+1) >= indent(line(".")) )
    let l:indent_below = ""
  endif

  exec "normal O". l:indent_below . g:Doxygen_interCommentTag
  exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_pageTag
  mark d
  exec "normal o". g:Doxygen_interCommentTag
  exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_sectionTag
  exec "normal o". g:Doxygen_interCommentTag
  exec "normal o". g:Doxygen_interCommentTag . g:Doxygen_subsectionTag
  exec "normal o". g:Doxygen_interCommentTag
  exec "normal `d"

  " Restore standard comment expension
  let &comments = l:oldComments
  " Restore indentation settings
  let &autoindent = l:oldAutoIndent
  let &cindent = l:oldCIndent

  startinsert!
endfunction



  """"""""""""""""""""""""""
  " Doxygen variable comment function
  """"""""""""""""""""""""""
function! <SID>DoxygenVarCommentFunc()

  " Save standard comment expension
  let l:oldComments = &comments
  let &comments = ""

  " Save indentation settings
  let l:oldAutoIndent = &autoindent
  let l:oldCIndent = &cindent
  let &autoindent=0
  let &cindent=0
  let l:filename = expand("%:p:t")
  let l:pathname = expand("%:p:h:t")

  let l:indent_below = strpart(getline(line(".")+1), 0, indent(line(".")+1))
  if ( strlen(substitute(getline(line(".")), "^\s+", "", "")) != 0 && indent(line(".")+1) >= indent(line(".")) )
    let l:indent_below = ""
  endif

  exec "normal o" . l:indent_below . g:Doxygen_interCommentTag . g:Doxygen_briefTag
  mark d
  exec "normal `d"

  " Restore standard comment expension
  let &comments = l:oldComments
  " Restore indentation settings
  let &autoindent = l:oldAutoIndent
  let &cindent = l:oldCIndent

  startinsert!

endfunction

  """"""""""""""""""""""""""
  " Shortcuts...
  """"""""""""""""""""""""""
command! -nargs=0 Dox :call <SID>DoxygenCommentFunc()
command! -nargs=0 DoxFile :call <SID>DoxygenFileCommentFunc()
command! -nargs=0 DoxVar :call <SID>DoxygenVarCommentFunc()
command! -nargs=0 DoxMod :call <SID>DoxygenModuleCommentFunc()

