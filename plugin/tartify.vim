"______________________________________________________________________________
" -------- WTF ------------------------{{{1
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"       Filename:  statusbar.vim
"
"    Description:  STATUS LINE with GIT support
"
"                  Colored status line adapted to GIT repository. VERY
"                  colorfull, not for the faint hearted
"
"  Configuration:  source this file in your .vimrc
"
"                     source /path/to/statusbar.vim
"
"   Dependencies:  REQUIRED : you need to have the "bashps1" file
"                  sourced in your ".bashrc" or ".bash_profile", as this
"                  vimscript calls external shell functions it depends
"                  on
"
"                  Depends on GIT, might work on windows with Cygwin

"
"   GVIM Version:  1.7+ (?)
"
"         Author:  Pierre Lhoste
"        Twitter:  http://twitter.com/peterhost
"
"        Version:  0.1
"        Created:  01.05.2011
"        License:  WTFPL V2
"
" DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE Version 2, December 2004
"
" Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
"
" Everyone is permitted to copy and distribute verbatim or modified
" copies of this license document, and changing it is allowed as long as
" the name is changed.
"
"            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE TERMS AND
"            CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
"
"  0. You just DO WHAT THE FUCK YOU WANT TO.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



"-------------------------------TRIVIA-----------------------------------------
" Authoritative References in the matter of Status Line for Vim, alas for your
" chastized ears, are chaps from the pr0n business:
" http://got-ravings.blogspot.com/2008/08/vim-pr0n-making-statuslines-that-own.html
" http://got-ravings.blogspot.com/2008/10/vim-pr0n-statusline-whitespace-flags.html
"         (A F*$!NG LOT was stolen from those two references)
" http://www.reddit.com/r/vim/comments/e19bu/whats_your_status_line/
"------------------------------------------------------------------------------
"
"
"
"1}}}
" TODO:{{{1
"
"   <***> move code to "autoload" and prevent tartify to fully load if autostart
"         is disabled (which is the default)
"
"   <***> custom "tartify command", with autocompletion, like :colorscheme
"
"   <**>  "contrast" adjustment (+/-) based on Statusline guibg value for User{N}
"         colors
"
"   <*>   "custom separator" for elements of a sequence, single sep. or pairs
"         ( "-", "_", "[]",...)
"
"1}}}

let s:production = 1  "0: dev mode, 1: production mode
                      " (dev mode deactivates loaded_tartify)

"______________________________________________________________________________
" -------- Preliminay Checks ----------{{{1
"Only load once{{{
" Check if we should continue loading
if exists( "loaded_tartify" ) && s:production == 1
  finish
endif
let loaded_tartify= 1

"}}}
"Helper function{{{
function! s:errmsg(msg)
  redraw
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

"}}}
"Bail if not on *nix{{{
if has("win32") || has("win64") || has("win16") || has("win95")
  call s:errmsg("Tartify will only work in Cygwin's version of Vim on windows.")
  finish
endif

"}}}
" Bail if Vim isn't compiled with status line support{{{
if has( "statusline" ) == 0
  call s:errmsg("Tartify requires Vim to have +statusline support.")
  finish
endif

"}}}
"" Bail if the environment does not contain the "Tartify shell functions"{{{
"if $__tartify_shell_loaded != 1
"    call s:errmsg("It seems that your environment does not contain Tartify's predefined functions. Tartify disabled (:h tartify for more)")
"  finish
"endif

"}}}



"1}}}

"______________________________________________________________________________
" -------- Initialization -------------{{{1
" MISC globs{{{

let s:install_dir         = expand('<sfile>:p:h')
let s:tart_themeDir       = s:install_dir . '/../tarts/themes/'
let s:tart_pluginDir      = s:install_dir . '/../tarts/plugins/'
let s:tart_defaultTheme   = s:install_dir . '/../tarts/themes/default.vim'
let g:tartify_root_dir    = s:install_dir . '/..'

" used in RC files
let g:tartify_forceColor = {'light': {1:{},2:{},3:{},4:{},5:{},6:{},7:{},8:{},9:{}}, 'dark': {1:{},2:{},3:{},4:{},5:{},6:{},7:{},8:{},9:{}} }




"}}}
" Store former statusline for restoration in Toggling{{{
if &statusline != ""
  if s:production == 0
    call Decho("THERE IS A STATUSLINE")
    let g:tartify_slbackup = escape(&statusline, " ")
  endif
else
  if s:production == 0
    call Decho("NO STATUSLINE")
    "fallback to (little-more-than-)default statusline
    let g:tartify_slbackup ='%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P'
  endif
endif




"}}}
" INIT -> Show Tartify's statusline at vim startup ?{{{2
"       0  : hidden
"       1  : visible

let s:tartify_show = (g:tartify_auto_enable == 1)? 1: 0


"2}}}


"1}}}

"______________________________________________________________________________
" -------- SMART User{N} Colors -------{{{1
" -------- WTF ------------------------{{{2
" --------------------------------------------------------------------------
"
" PROBLEM1: When coloring Vim's StatusLine, we have two options :
"
"     - Use predefined (default) Highlight Groups and hope the
"     "Tartification" is not too extreme
"
"     - Define our own User{N} highlight groups
"
" PROBLEM2: However hard you try, you always break the default
"           statusline's background color, creating UGLY HOLES in it
"           that break its visual continuity, hence destroying it's
"           "STATUSLINE-NESS"
"
" PROBLEM3: When using standard Highlight groups, there is no way of
"           handling the fact that the background color for the
"           statusline changes according to the window being current or
"           not (StatusLine & StatusLineNC). On the other hand,
"           "User{N}" highlight groups handle that automatically
"           (:helpg The difference between User{N})
"
" SOLUTION: Define "User{N}" highlight groups which adapt to
"
"  - Dark/Light background (maximize our chances of them looking good
"    everywhere)
"
"  - Use the current Colorcheme's own predefined StatusLine parameters
"    (especially background color, but try to catch as much as possible) for our
"    custom "User{N}" highlight groups
"
"
" WARN: BIG GOTCHA 1
"
"       if the StatusLine Highlight contains :
"         - term=reverse
"         - cterm=reverse
"         - gui=reverse
"        the termfg/termbg, ctermfg/ctermbg, and guifg/guibg couples
"        have to be substituted one for another, when leeching colors from a
"        highlight group.
"
"       BIG GOTCHA 2

"       Quite a few colorschemes out there won't work well with tartify. Main
"       reason is bad use of StatuslineNC (or see it another way, a small bug
"       in Vim).
"
"       Implicitely, User{N} highlight groups are belong to the StatusLine
"       highlight group :
"
"       When using a User{N} in a statusline, Vim automatically does a
"       substraction between the StatusLine and StatusLineNC highlights when
"       calculating the resulting User{N} highlight for a non-active window.
"
"       But if the StatusLine contains "gui=reverse" and StatusLineNC doesn't,
"       when rendering the statusline for an inactive window, Vim removes the
"       "reverse" directive from User{N}, but does not swap the fg and bg
"       colors hardcoded in User{N}, back, and UGLINESS ENSUES
"
"       SOLUTION: Tartify will warn you




"2}}}
" -------- Custom Colors --------------{{{2
"
" Define the 9 User{N} color themes (across "term", "cterm" and "gui") in one
" go
"
" format is a coma separated list of the standard values :
" "bold", "italic", "reverse", "inverse", "standout",
" "underline", "undercurl"
"
"
" That's it : just fill this dictionary and you're set. the function
" s:smartHighligths will then generate the {CurrentColorscheme}compatible
" Statusbar Highlights for you in User1,...,User9

" NOTE: the generated User{N} highlight groups  will overload the
"       current Colorscheme's "StatusLine Highlight group"
" IE: adding a hue or format directive will add up to the statusbar default,
"     for this precise UserN group.
" EX: adding a "format='underline'" to color "1" when your statusbar highlight
"     group has "term=italic cterm=italic,bold gui=undercurl ", will result in
"     "term=underline,italic cterm=underline,italic,bold gui=underline,undercurl"
"     for the color "User1"
"
"
"   let g:tartify_adaptativeHighlights  = {
"        \'light': {
"          \ 1: {'hue': 'lightblue',   'format': 'underline,italic'},
"          \ 2: {'hue': 'blue',        'format': ''},
"          \ 3: {'hue': 'lightred',    'format': 'underline,italic'},
"          \ 4: {'hue': 'red',         'format': 'underline,italic'},
"          \ 5: {'hue': 'lightgreen',  'format': 'underline,italic'},
"          \ 6: {'hue': 'green',       'format': 'underline,italic'},
"          \ 7: {'hue': 'magenta',     'format': 'underline,italic'},
"          \ 8: {'hue': 'lightyellow', 'format': ''},
"          \ 9: {'hue': 'yellow',      'format': ''}
"          \ },
"      \'dark': {
"          \ 1: {'hue': 'blue',        'format': 'underline,italic'},
"          \ 2: {'hue': 'darkblue',    'format': ''},
"          \ 3: {'hue': 'red',         'format': 'underline,italic'},
"          \ 4: {'hue': 'darkred',     'format': 'underline,italic'},
"          \ 5: {'hue': 'green',       'format': 'underline,italic'},
"          \ 6: {'hue': 'darkgreen',   'format': 'underline,italic'},
"          \ 7: {'hue': 'magenta',     'format': 'underline,italic'},
"          \ 8: {'hue': 'yellow',      'format': ''},
"          \ 9: {'hue': 'darkyellow',  'format': ''}
"          \ }
"      \}



function! s:loadTheme()
  "
  "COLORS: load theme-specific User{N} colors
  "
  "
  "check if a colorscheme is enabled otherwise fallback on 'default', and
  "define g:colors_name as "default" (as it might not be set) then check if a
  "custom (tartify) theme exists for current colorscheme

  if s:production == 0
    call Decho("loadTheme()")
  endif

  if ! exists("g:colors_name")
    let g:colors_name = "default"
    if s:production == 0
      call Decho("no colorscheme -> assigning default")
    endif
  endif
  let l:themefile = s:tart_themeDir . g:colors_name . ".vim"

  "
  " Force specific Theme ?
  "
  if exists("g:tartify_forceTheme")
    let l:altThemefile = s:tart_themeDir . g:tartify_forceTheme . ".vim"
    if filereadable(l:altThemefile)
      let l:themefile = l:altThemefile
    else
      call s:errmsg("TARTIFY: Unknown theme '" . l:altThemefile ."' (in 'let g:tartify_forceTheme=...')")
    endif
  endif
  "
  "Load ColorSheme's Theme (if any)
  "
  if filereadable(l:themefile)
    execute "source " . l:themefile

    "Valid Theme ?
    if ! exists("g:tartify_adaptativeHighlights")
      call s:errmsg("TARTIFY: theme '" . g:tartify_forceTheme ."' is not a correct TARTIFY theme")
      execute "source " . s:tart_defaultTheme
    endif

  "
  "Fallback to default Theme
  "
  else
    execute "source " . s:tart_defaultTheme
  endif
  "
  "overwrite Theme colors with user defined ones if they exist
  "
  if exists("g:tartify_forceColor")
    call s:forceRCcolors("light")
    call s:forceRCcolors("dark")
  endif
  "
  " SEQUENCE:
  "
  " Overwrite statusline Sequence with Theme's (if exists)
  "
  "call s:forceThemeSequence()
  "
  " Overwrite statusline Sequence with user defined if exists
  "

endfunction



" Force (possible) color directives from a rc file (vimrc,...)
function! s:forceRCcolors(background)
  if exists("g:tartify_forceColor[a:background]")
    if s:production == 0
      call Decho("->PROCESSING " . a:background)
      for [l:nb, l:val] in items(g:tartify_forceColor[a:background])
          if exists("l:val.hue")
            let g:tartify_adaptativeHighlights[a:background][l:nb].hue = l:val.hue
            call Decho("--->ADDED " . l:val.hue)
          endif
          if exists("l:val.format")
            let g:tartify_adaptativeHighlights[a:background][l:nb].format = l:val.format
            call Decho("--->ADDED " . l:val.format)
          endif
      endfo
    endif
  endif
endfunction


"2}}}
" -------- Leech ColorScheme ----------{{{2



" WARN: For some reason, the call :
"
"   synIDattr(synIDtrans(hlID(GroupName)), {what}, {mode})
"
"  does not work as expected if {mode} equals "gui",in a FOR loop. It
"  must have stg to do with the scope AND my being an ass, but for the
"  moment, let's just process the following calls sequentially like a
"  dumb fuck.
"
" TODO: do that with redir(), then parse with regex. Might be faster


" avoid the "-1" value when encountered cause we don't want to feed it back to
" the Highlight command
function! s:noNEG1(arg)
  return (a:arg == "-1")? "" : a:arg
endfunction


function! s:statuslineHighlightConcat()"
  " WHAT:
  " "name", "fg", "bg", "font", "sp", "fg#", "bg#", "sp#",
  " "bold", "italic", "reverse", "inverse", "standout",
  " "underline", "undercurl"
  " MODE:
  " "term", "cterm", "gui"


  let s:statusLineGroupAttr = {}
  let l:thisID = synIDtrans(hlID("StatusLine"))

  let s:statusLineGroupAttr["term"]    =         ( synIDattr(l:thisID, "bold",        "term") ? "bold,"       : "" )
  let s:statusLineGroupAttr["term"]   .=         ( synIDattr(l:thisID, "italic",      "term") ? "italic,"     : "" )
  let s:statusLineGroupAttr["term"]   .=         ( synIDattr(l:thisID, "reverse",     "term") ? "reverse,"    : "" )
" let s:statusLineGroupAttr["term"]   .=         ( synIDattr(l:thisID, "inverse",     "term") ? "inverse,"    : "" )
  let s:statusLineGroupAttr["term"]   .=         ( synIDattr(l:thisID, "standout",    "term") ? "standout,"   : "" )
  let s:statusLineGroupAttr["term"]   .=         ( synIDattr(l:thisID, "underline",   "term") ? "underline,"  : "" )
  let s:statusLineGroupAttr["term"]   .=         ( synIDattr(l:thisID, "undercurl",   "term") ? "undercurl,"  : "" )

  let s:statusLineGroupAttr["cterm"]   =         ( synIDattr(l:thisID, "bold",        "cterm") ? "bold,"      : "" )
  let s:statusLineGroupAttr["cterm"]  .=         ( synIDattr(l:thisID, "italic",      "cterm") ? "italic,"    : "" )
  let s:statusLineGroupAttr["cterm"]  .=         ( synIDattr(l:thisID, "reverse",     "cterm") ? "reverse,"   : "" )
" let s:statusLineGroupAttr["cterm"]  .=         ( synIDattr(l:thisID, "inverse",     "cterm") ? "inverse,"   : "" )
  let s:statusLineGroupAttr["cterm"]  .=         ( synIDattr(l:thisID, "standout",    "cterm") ? "standout,"  : "" )
  let s:statusLineGroupAttr["cterm"]  .=         ( synIDattr(l:thisID, "underline",   "cterm") ? "underline," : "" )
  let s:statusLineGroupAttr["cterm"]  .=         ( synIDattr(l:thisID, "undercurl",   "cterm") ? "undercurl," : "" )
  let s:statusLineGroupAttr["ctermfg"] = s:noNEG1( synIDattr(l:thisID, "fg",          "cterm") )
  let s:statusLineGroupAttr["ctermbg"] = s:noNEG1( synIDattr(l:thisID, "bg",          "cterm") )
" let s:statusLineGroupAttr["ctermsp"] =          synIDattr(l:thisID, "sp",          "cterm")


  let s:statusLineGroupAttr["gui"]     =         ( synIDattr(l:thisID, "bold",        "gui") ? "bold,"       : "" )
  let s:statusLineGroupAttr["gui"]    .=         ( synIDattr(l:thisID, "italic",      "gui") ? "italic,"     : "" )
  let s:statusLineGroupAttr["gui"]    .=         ( synIDattr(l:thisID, "reverse",     "gui") ? "reverse,"    : "" )
" let s:statusLineGroupAttr["gui"]    .=         ( synIDattr(l:thisID, "inverse",     "gui") ? "inverse,"    : "" )
  let s:statusLineGroupAttr["gui"]    .=         ( synIDattr(l:thisID, "standout",    "gui") ? "standout,"   : "" )
  let s:statusLineGroupAttr["gui"]    .=         ( synIDattr(l:thisID, "underline",   "gui") ? "underline,"  : "" )
  let s:statusLineGroupAttr["gui"]    .=         ( synIDattr(l:thisID, "undercurl",   "gui") ? "undercurl,"  : "" )
  let s:statusLineGroupAttr["guifg"]   =           synIDattr(l:thisID, "fg",          "gui")
  let s:statusLineGroupAttr["guibg"]   =           synIDattr(l:thisID, "bg",          "gui")
" let s:statusLineGroupAttr["guisp"]   =           synIDattr(l:thisID, "sp",          "gui")
" let s:statusLineGroupAttr["guifg"]  .=           synIDattr(l:thisID, "fg#",         "gui")
" let s:statusLineGroupAttr["guibg"]  .=           synIDattr(l:thisID, "bg#",         "gui")
" let s:statusLineGroupAttr["guisp"]  .=           synIDattr(l:thisID, "sp#",         "gui")
" let s:statusLineGroupAttr["font"]    =           synIDattr(l:thisID, "font"              )

  "Concatenate the resulting HighLight syntax
  let l:result = ""
  for [l:key, l:val] in items(s:statusLineGroupAttr)
    if l:val != ""
      let l:result .= l:key . "=" . l:val . " "
    endif
  endfo


  "setup the global (script-scoped) variable
  let s:statusLineHighlightExtract = l:result

  "warn User if colorscheme is improper
  call s:detectBuggyColorScheme()

endfunction


" Detect when one argument of highlight group StatusLine or StatusLineNC has
" the value "reverse" and the other one hasn't
function! s:detectBuggyColorScheme()

  "TODO: for now, limited to 'dev' mode. Rehabilitate this for production
  "mode!

  if s:production == 0
    let l:statuslineNC_ID    = synIDtrans(hlID("StatusLineNC"))
    let l:listargs = [ "term", "cterm", "gui" ]

    for l:key in l:listargs
      let l:testArgument = synIDattr(l:statuslineNC_ID, "reverse", l:key)
      call Decho("  DETECTBUG KEY=" . l:key . " - NC " . l:testArgument . " - orig: " . s:statusLineGroupAttr[l:key])
      let l:ttt = "TARTIFY : incompatibility detected with colorscheme " . g:colors_name
      if  ( l:testArgument == 1 && s:statusLineGroupAttr[l:key] !~ "reverse")
        let l:ttt .=  " ('reverse' present in StatusLineNC (" . l:key . "=...), not in StatusLine)  (':help tartify' for more)"
        call Decho("----> BUG!!!")
        redraw
        echohl ErrorMsg
        echomsg l:ttt
        echohl None
      elseif ( l:testArgument != 1 && s:statusLineGroupAttr[l:key] =~ "reverse")
        let l:ttt .=  " ('reverse' present in StatusLine (" . l:key . "=...), not in StatusLineNC)  (':help tartify' for more)"
        call Decho("----> BUG!!!")
        redraw
        echohl ErrorMsg
        echomsg l:ttt
        echohl None
      endif
    endfo
  endif
endfunction



"2}}}
" -------- RE-inject Colorscheme ------{{{2
"
"
"
"

function! s:smartHighligths()
  "let l:bgTmp = (&background)? &background : "dark"


  "if exists(&background)
    "let l:bgTmp = &background
  "else
    "let l:bgTmp = "dark"
  "endif


  " using the global setting &background
  for [l:nb, l:val] in items(g:tartify_adaptativeHighlights[&background])

    "FIRST : inject the styles leeched from the current StatusLine highlight
    "group (for current ColorScheme)
    let l:highlight = s:statusLineHighlightExtract

    "SECOND : inject our custom styles on top of that
    if l:val.hue != ""
      let l:highlight .= s:injectHue(l:val.hue)
    endif
    if l:val.format != ""
      let l:highlight .= s:injectFormat(l:val.format)
    endif

    "THIRD : load the composited highlight group
    execute "highlight User" . l:nb . " " . l:highlight
  endfo
endfunction



function! s:injectHue(string)
  "
  "GOTCHA: carefull. If a HighLight contains "reverse", then we need to swap
  "        "termfg" for "termbg" and "guifg" for "guibg"
  "
  let l:ttmp = (s:statusLineGroupAttr.cterm=~ 'reverse') ? " ctermbg=" : " ctermfg="
  let l:ttmp .= a:string
  let l:ttmp .= (s:statusLineGroupAttr.gui=~  'reverse') ? " guibg="   : " guifg="
  let l:ttmp .= a:string
  return l:ttmp
  "return " ctermfg=" . a:string . " guifg=" . a:string
endfunction


function! s:injectFormat(string)
  let l:ttmp = ""
  let l:ttmp .= " term="  . s:statusLineGroupAttr.term  . a:string
  let l:ttmp .= " cterm=" . s:statusLineGroupAttr.cterm . a:string
  let l:ttmp .= " gui="   . s:statusLineGroupAttr.gui   . a:string
  return l:ttmp
endfunction



"2}}}
" -------- Auto Commands --------------{{{2

"
" AUTOMATE: in case of ColorScheme change
"
"
function! s:resetTartification()
  call s:loadTheme()
  call s:statuslineHighlightConcat()
  call s:smartHighligths()
endfunction

" Activate the nested autocmd only after all scripts/plugins are loaded,
" otherwise called before the statusline theme (g:tartify_adaptativeHighlights) is
"defined (by s:loadTheme() )

if has("autocmd")
  "autocmd VimEnter *
  "      \   call s:loadTheme()
  "      \ | call s:resetTartification()
  "      \ | call Decho("VIMENTER")
  "      \ | autocmd ColorScheme * call s:resetTartification()
  if s:production == 0
    autocmd VimEnter *
          \   call s:resetTartification()
          \ | call Decho("VIMENTER")
          \ | autocmd ColorScheme * call s:resetTartification()
  else
    autocmd VimEnter *
          \   call s:resetTartification()
          \ | autocmd ColorScheme * call s:resetTartification()
  endif


endif




"2}}}


"1}}}

"______________________________________________________________________________
" -------- Plugins --------------------{{{1
" -------- Initialization -------------{{{2



" SEQUENCE: this is the default statusline provided by Tartify. It's heavy and
" uses almost all the features provided.
"
" WTF:
"
" this variable stores misc statuslines, and enables to loop through them
" a "theme" can define its own default sequence, and others

let g:tartify_sequence = {}
let g:tartify_sequence.default = {}

let g:tartify_sequence.default.left = [
      \ "insertmodeMark", "file_cut30",
      \ "warn_non_unix", "warn_non_utf8", "helpf_tag", "file_type",
      \ "warn_readonly", "warn_mofified", "GIT_repo", "GIT_branch",
      \ "GIT_remote", "GIT_stash", "GIT_lastcommit", "warn_mixed_indent",
      \ "warn_trail_space", "syntastic", "warn_paste" ]

let g:tartify_sequence.default.right = [
      \ "warn_long_lines", "curr_highlight", "autocollapse",
      \ "minimized" ]


" GLOBAL_OPTIONS: things that are too generic or don't fit anywhere else
"
" WTF:
"
" "smart" : statusline adapts to special buffers by not showing certain infos,
" such as filename, git infos, mixed-indenting,...  (fugitive, NERDTree,...)
"
" "smartNtart" : same as before, plus some additional, buffer specific
" tartification (help buffer,...) : title,...
"
" "nocolors" : self expl.
"
" "oldschool" : no colors, cryptic symbols & all

let g:tartify_globals = {}
let g:tartify_globals.default = ["smart", "nocolors"]




"  2}}}
" -------- activate SL sequence --------{{{2



"TODO: ugly as shit, shorten that
function! s:activateSequence()

  " default
  if s:production == 0
    call Decho("Loading sequence : Default")
  endif
  let g:tartify_sequence.this = g:tartify_sequence.default

  " theme-specific sequences ENABLED
  if ! exists("g:tartify_sequence_ignore")
    "current Colorscheme has a corresp. Theme
    if exists("g:tartify_sequence['g:colors_name']")
      if s:production == 0
        call Decho("Loading sequence : " . g:colors_name)
      endif
      let g:tartify_sequence.this = g:tartify_sequence["g:colors_name"]
    endif
  endif

  " user-defined sequence exists
  if exists("g:tartify_sequence.user")
    let g:tartify_sequence.this = g:tartify_sequence.user
  endif
endfunction

call s:activateSequence()



"2}}}
" -------- Functions ------------------{{{2


"visual marker if minimized window
function! IsMinimized()
  if winheight(0) <= &winminheight
    return '[↓]'
  else
    return ''
  endif
endfunction


"Visual marker if window is autocollapsible
function! StatuslineAutoCollapsibleMark()
  if exists("w:autoCollapsible") &&  winheight(0) > &winminheight
    return '[↑⇈]'
    "return w:autoCollapsible
  else
    return ""
  endif
endfunction


" Only way I've found to gather in one function a branching condition
" for the displaying of the %f,%h,... items in the statusline. Not
" optimal, but does the job

let g:tartify_buffNameToAvoid = '__Tag_List__\|COMMIT_EDITMSG'
"let g:tartify_disablePlugin4Buf = { "'__Tag_List__\|COMMIT_EDITMSG'

"TODO: try use the ":~" modifier for path pattern
function! CleverInsert(expandme, ...)

  if match(expand("%f"), g:tartify_buffNameToAvoid) >= 0 | return "" | endif

  "if expand('%H') >= 0
  ""if expand("%H") == "HLP" && a:1 == "TOTO"
  " return "HLP&" . expand("%H") . "]"
  "endif

  "help  *filename-modifiers*
  "return strpart(expand( "%:f" ) . " ", 0, 30)
  return expand( a:expandme ) . " "
endfunction







"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction


"2}}}




"1}}}

"______________________________________________________________________________
" -------- StatusLine setup ------------{{{1
" -------- StatusLine directives ------{{{2
"
" help  *statusline*
" help  *filename-modifiers*

"TODO:
"     - incorporate an FileChangedShellPost warning for files changed outside
"       of vim

function! s:tartify_set_statusline()
  "statusline setup
  set statusline=

  "show the mode we are in
  "TODO : only highlight insert mode
  set statusline+=%{(mode()=='i')?'[i]\ ':''}

  "set statusline+=%f       "tail of the filename
  set statusline+=%.30{CleverInsert('%t')}

  "display a warning if fileformat isnt unix
  set statusline+=%#warningmsg#
  set statusline+=%{&ff!='unix'?'['.&ff.']':''}
  set statusline+=%*

  "display a warning if file encoding isnt utf-8
  set statusline+=%#warningmsg#
  set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
  set statusline+=%*

  set statusline+=%h      "help file flag

  set statusline+=%y      "filetype
  "set statusline+=%{strlen(&ft)?&ft:'ZOMG'}
  set statusline+=%8*
  set statusline+=%y


  "set statusline+=%{CleverInsert('%y')}      "filetype
  "set statusline+=%{CleverInsert('%y','TOTO')}      "filetype
  set statusline+=%r      "read only flag
  set statusline+=%#warningmsg#
  set statusline+=%m      "modified flag
  "set statusline+=%{CleverInsert('%m')}      "modified flag
  set statusline+=%*


  " display current git branch
  set statusline+=%7*
  set statusline+=%{fugitive#statusline()}
  set statusline+=%*


"TODO:
"WARN: 
"TARTIFY désactivé dans statusline pour pouvoir quand même utiliser le plugin
"!!!
"TODO : rendre le plugin plus rapide
"TODO : et réactiver la ligne suivante
"
">>>>CELLE CI !!!
"call tartify#GITPS1#setstatusline()
"<<<< CELLE LA !





  ""_____________________________
  "set statusline+=%1*
  "set statusline+=%{tartify#GITPS1#statusline('repository')}

  "" here I wished to reproduct the colored approach to showing the
  "" 'extras' (unstaged files, uncommited changes,...) in a colored
  "" way, as is done in the bashps1 shell script, instead of using
  "" the usual *+%^ symbols usual in GIT_PS1, as I never can
  "" remember which is which.
  "" So this too will be "**Tartified**"
  ""
  "set statusline+=%7*
  ""set statusline+=%#DiffAdd#
  "set statusline+=%{tartify#GITPS1#statusline('branch','unstaged')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','unstagedWithUntracked')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','uncommited')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','TOTOLESALAUD')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','uncommitedWithUntracked')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','unpushed')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','unpushedWithUntracked')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','ok')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','okWithUntracked')}
  "set statusline+=%{tartify#GITPS1#statusline('branch','insideGitDir')}

  "set statusline+=%3*
  "set statusline+=%{tartify#GITPS1#statusline('remote')}

  "set statusline+=%4*
  "set statusline+=%{tartify#GITPS1#statusline('stash')}

  "set statusline+=%*

          ""        > this will return a "M" symbol which will be prepended
          ""          to the branchname
          ""
          ""         "unmerged"

  "
  " 20 ITEMS LEFT
  "

  "display a warning if &et is wrong, or we have mixed-indenting
  set statusline+=%#error#
  set statusline+=%{StatuslineTabWarning()}
  set statusline+=%*

  set statusline+=%{StatuslineTrailingSpaceWarning()}

  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*

  "display a warning if &paste is set
  set statusline+=%#error#
  set statusline+=%{&paste?'[paste]':''}
  set statusline+=%*



  if  exists("*SyntasticStatuslineFlag")
  "ADDED
    let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
  endif


  set statusline+=%=      "left/right separator
  set statusline+=%2*
  set statusline+=%{StatuslineLongLineWarning()}
  set statusline+=%*
  set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
  set statusline+=%9*     "custom color 9
  set statusline+=%c     "cursor column
  set statusline+=%*,      "reset color
  set statusline+=%l/%L   "cursor line/total lines
  set statusline+=\ %P    "percent through file

  set statusline+=%6*
  set statusline+=\ %{StatuslineAutoCollapsibleMark()}    "window b:autoCollapsible value

  "marker for minimized window
  set statusline+=%5*
  set statusline+=%{IsMinimized()}
  set statusline+=%*

  set laststatus=2        " Always show status line


endfunction


"2}}}
" -------- StatusLine Toggle ----------{{{2

" Toggle between Tartify's statusline and the default one (or a user defined
" one if one was set somewhere else)
" GOTTA: map this baby to a key
"
function! g:tartify_statusline_toggle()
  let s:tartify_show = (s:tartify_show == 0)? 1 : 0
  set statusline=
  if s:tartify_show == 0
    " Restore last statusline
    " (hack from daethorian on #vim)
    exec "set stl=".g:tartify_slbackup
  else
    call s:tartify_set_statusline()
  endif
endfunction


"2}}}
" -------- Statusline Switcher --------{{{2
" -------- WTF ------------------------{{{3
" The ease of switching between colorschemes in Vim is one of the editor's
" best features. I wanted something like that for statuslines


"TODO:
command! -bar Tartify :call pathogen#helptags()


"3}}}




"2}}}
" -------- Set SL Autocommand ---------{{{2


"we want that to happen when all else is done (vimrc,...)
if has("autocmd")
  autocmd VimEnter * if s:tartify_show == 1 | call s:tartify_set_statusline() | endif
endif



"2}}}



"1}}}


"______________________________________________________________________________
" -------- MISC helpers ---------------{{{1

"TODO: temporary solution for 'dev' mode (DECHO messages) fix that in final
"version

function! g:tartify_list(arg)
  if match(a:arg , 'plug|plugin|plugins')
    "for f in split(glob('/Users/plhoste/.vim/bundle/tartify/*' ), '\n')
    for f in split(glob(s:tart_pluginDir . "*"), '\n')
      if s:production == 0
        call Decho(f)
      endif
    endfor
    "let l:dirlist = get(s:tart_pluginDir)
    "let l:dirlist = split(glob("s:tart_pluginDir/*"), '\n')
    "call Decho("Dir contains\n" .  l:dirlist )
  else
    if s:production == 0
      call Decho("unknown arg for g:tart_pluginDir()")
    endif
  endif
endfunction




"1}}}
" vim:foldmethod=marker
