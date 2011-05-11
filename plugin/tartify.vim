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


" TODO:
"
"   *** move code to autoload and prevent tartify to fully load if autostart
"       is disabled (which is the default)
"
"   *   custom :tartify command, with autocompletion, like :colorscheme
"
"

let s:production = 0  "0: dev mode, 1: production mode
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
  echohl ErrorMsg
  echo a:msg
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
" Bail if the environment does not contain the "Tartify shell functions"{{{
if $__tartify_shell_loaded != 1
    call s:errmsg("It seems that your environment does not contain Tartify's predefined functions. Tartify disabled (:h tartify for more)")
  finish
endif

"}}}



"1}}}



"______________________________________________________________________________
" -------- Initialization -------------{{{1
" MISC globs{{{

let s:install_dir         = expand('<sfile>:p:h')
let s:tart_themeDir       = s:install_dir . '/../tarts/themes/'
let s:tart_defaultTheme   = s:install_dir . '/../tarts/themes/default.vim'

" used in RC files 
let g:tartify_forceColor = {'light': {1:{},2:{},3:{},4:{},5:{},6:{},7:{},8:{},9:{}}, 'dark': {1:{},2:{},3:{},4:{},5:{},6:{},7:{},8:{},9:{}} }




"}}}
" Store former statusline for restoration in Toggling{{{
if &statusline != ""
  call Decho("THERE IS A STATUSLINE")
  let g:tartify_slbackup = escape(&statusline, " ")
else
  call Decho("NO STATUSLINE")
  "fallback to (little-more-than-)default statusline
  let g:tartify_slbackup ='%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P'
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
" WARN: BIG GOTCHA
"
"       if the StatusLine Highlight contains :
"         - term=reverse
"         - cterm=reverse
"         - gui=reverse
"        the termfg/termbg, ctermfg/ctermbg, and guifg/guibg couples
"        have to be substituted one for another, when leeching colors from a
"        highlight group.
"
"




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

" Nota Bene : the generated User{N} highlight groups  will overload the
" current Colorscheme's "StatusLine Highlight group" (ie: adding underline on
" an (already) underlined statusbar highlight group, as per definition of your
" current ColorScheme, won't do nothing more)
function! s:defineUserColors()
  let g:tartify_adaptativeHighlights  = {
        \'light': {
          \ 1: {'hue': 'lightblue',   'format': 'underline,italic'},
          \ 2: {'hue': 'blue',        'format': ''},
          \ 3: {'hue': 'lightred',    'format': 'underline,italic'},
          \ 4: {'hue': 'red',         'format': 'underline,italic'},
          \ 5: {'hue': 'lightgreen',  'format': 'underline,italic'},
          \ 6: {'hue': 'green',       'format': 'underline,italic'},
          \ 7: {'hue': 'magenta',     'format': 'underline,italic'},
          \ 8: {'hue': 'lightyellow', 'format': ''},
          \ 9: {'hue': 'yellow',      'format': ''}
          \ },
      \'dark': {
          \ 1: {'hue': 'blue',        'format': 'underline,italic'},
          \ 2: {'hue': 'darkblue',    'format': ''},
          \ 3: {'hue': 'red',         'format': 'underline,italic'},
          \ 4: {'hue': 'darkred',     'format': 'underline,italic'},
          \ 5: {'hue': 'green',       'format': 'underline,italic'},
          \ 6: {'hue': 'darkgreen',   'format': 'underline,italic'},
          \ 7: {'hue': 'magenta',     'format': 'underline,italic'},
          \ 8: {'hue': 'yellow',      'format': ''},
          \ 9: {'hue': 'darkyellow',  'format': ''}
          \ }
      \}
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
"  dummy.
"
" TODO: do that with redir(), then parse with regex. Might be faster


" avoid the "-1" value cause we don't want to feed it back to the
" Highlight command
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

endfunction






"2}}}
" -------- RE-inject Colorscheme ------{{{2
"
"
"
"

function! s:smartHighligths()

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
  call s:statuslineHighlightConcat()
  call s:smartHighligths()
endfunction


if has("autocmd")
  autocmd VimEnter * call s:defineUserColors() | call s:resetTartification()
  autocmd ColorScheme * call s:resetTartification()
endif



"2}}}




"1}}}
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

  "marker for minimized window
  set statusline+=%5*
  set statusline+=%{IsMinimized()}
  set statusline+=%*

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


  "" display current git branch
  "set statusline+=%2*
  "set statusline+=%{fugitive#statusline()}
  "set statusline+=%*


  set statusline+=%1*
  set statusline+=%{StatuslineGitTartify('repository')}

  " here I wished to reproduct the colored approach to showing the
  " 'extras' (unstaged files, uncommited changes,...) in a colored
  " way, as is done in the bashps1 shell script, instead of using
  " the usual *+%^ symbols usual in GIT_PS1, as I never can
  " remember which is which.
  " So this too will be "**Tartified**"
  "
  set statusline+=%7*
  "set statusline+=%#DiffAdd#
  set statusline+=%{StatuslineGitTartify('branch','unstaged')}
  set statusline+=%{StatuslineGitTartify('branch','unstagedWithUntracked')}
  set statusline+=%{StatuslineGitTartify('branch','uncommited')}
  set statusline+=%{StatuslineGitTartify('branch','TOTOLESALAUD')}
  set statusline+=%{StatuslineGitTartify('branch','uncommitedWithUntracked')}
  set statusline+=%{StatuslineGitTartify('branch','unpushed')}
  set statusline+=%{StatuslineGitTartify('branch','unpushedWithUntracked')}
  set statusline+=%{StatuslineGitTartify('branch','ok')}
  set statusline+=%{StatuslineGitTartify('branch','okWithUntracked')}
  set statusline+=%{StatuslineGitTartify('branch','insideGitDir')}

  set statusline+=%3*
  set statusline+=%{StatuslineGitTartify('remotes')}

  set statusline+=%4*
  set statusline+=%{StatuslineGitTartify('stash')}

  set statusline+=%*

          "        > this will return a "M" symbol which will be prepended
          "          to the branchname
          "
          "         "unmerged"

  "
  " 21 ITEMS LEFT
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

"we want that to happen when all else is done (vimrc,...)
if has("autocmd")
  autocmd VimEnter * if s:tartify_show == 1 | call s:tartify_set_statusline() | endif
endif

"2}}}




"1}}}
" -------- Functions ------------------{{{1


" Only way I've found to gather in one function a branching condition
" for the displaying of the %f,%h,... items in the statusline. Not
" optimal, but does the job

let s:buffNameToAvoid = '__Tag_List__\|COMMIT_EDITMSG'

"TODO: try use the ":~" modifier for path pattern
function! CleverInsert(expandme, ...)
  let l:fname = expand("%f")
  if match(l:fname, s:buffNameToAvoid) >= 0
    return ""
  endif

  "if expand('%H') >= 0
  ""if expand("%H") == "HLP" && a:1 == "TOTO"
  " return "HLP&" . expand("%H") . "]"
  "endif

  "help  *filename-modifiers*
  "return strpart(expand( "%:f" ) . " ", 0, 30)
  return expand( a:expandme ) . " "
endfunction






"visual marker if minimized window
function! IsMinimized()
  if winheight(0) <= &winminheight
    return '[↓]'
  else
    return ''
  endif
endfunction




" TODO: add the "time since last commit"

function! StatuslineGitTartify(item, ...)

  let l:fname = expand("%f")
  if match(l:fname, s:buffNameToAvoid) >= 0
    return ""
  endif

  " CACHING
  " as the pr0n master once said, "we gawts to cache"
  " (all this calling external bash function is resource intensive and
  " suboptimall too)
  if !exists("b:statusline_tartify_repo")
    let l:cdlocaldir = "cd `dirname " . shellescape(expand('%:p')) . "`; "
    "
    " These shell functions have to exist in Vim's environment
    " ie : you have sourced "/bin/bashps1" in your bashrc
    "
    " nota:
    "
    " 1) the "TRUE" arguments passed to the shell functions tell them
    " to strip the ANSI color codes they throw by default for the PS1,
    " from the return value
    "
    " 2) the second "TRUE" argument taken by __gitps1_branch tells it
    " to also return additional infos about the branch (unstaged
    " files,...)
    "
    let b:statusline_tartify_repo     = system( l:cdlocaldir . "__gitps1_repo_name TRUE")
    let b:statusline_tartify_branch   = system( l:cdlocaldir . "__gitps1_branch TRUE TRUE"   )
    let b:statusline_tartify_remotes  = system( l:cdlocaldir . "__gitps1_remote TRUE"  )
    let b:statusline_tartify_stash    = system( l:cdlocaldir . "__gitps1_stash TRUE"    )
  endif

  "PROCESSING
  "
  "no a git repo
  if b:statusline_tartify_repo == ""
    return ""

  "Catchall :unexpected error from shell function (report please)
  elseif !v:shell_error == 0
    return " -ERROR- "

  "git repo, all fine
  else
    if a:item == "repository"
      return b:statusline_tartify_repo
    elseif a:item == "remotes"
      return b:statusline_tartify_remotes
    elseif a:item == "stash"
      return b:statusline_tartify_stash
    elseif a:item == "branch"
      "
      " "branch" calls for a second argument!
      "
      if len(a:000) != 1
        return " -NEED 2nd ARG- "

      " proceed
      else
        let l:branchstate = a:1
        "
        "   l:branchstate can have one of these values :
        "
        "       > each of the following, return the branchname and the
        "         "set laststatus" command will apply a different color
        "         to the result. The resulting status line snippet is
        "         only the branchname + colors
        "
        "
        "         "unstaged",     "unstagedWithUntracked",
        "         "uncommited",   "uncommitedWithUntracked",
        "         "unpushed",     "unpushedWithUntracked",
        "         "ok",           "okWithUntracked",
        "         "insideGitDir"
        "
        "
        "        > this will return a "M" symbol which will be prepended
        "          to the branchname
        "
        "         "unmerged"
        "
        "
        "   the return value of shell function __gitps1_branch followed by two
        "   "TRUE" arguments, is of the form :
        "
        "   "$nocolor_info|$branch_name"
        "
        "   where $nocolor_info is a string between 1 and 3 characters:
        "
        "     nocolor_info = "(S|C|P|O|G)(U)?(M)?"
        "
        "         S "unstaged", C "uncommited", P "unpushed", O "allisOK",
        "           G "insideDotGit"
        "
        "         U "untracked", M "unmerged"
        "
        "

         let l:arglist =
                     \"unstaged|unstagedWithUntracked|
                     \uncommited|uncommitedWithUntracked|
                     \unpushed|unpushedWithUntracked|
                     \ok|okWithUntracked|insideGitDir|
                     \unmerged"
        if  !match(l:branchstate, l:arglist)
          return "BAD arg" . l:branchstate
        else
            " 1) separate $nocolor_info from $branch_name
          let l:args = split(b:statusline_tartify_branch, '|')

          " 2) split $nocolor_info
          let l:commit_status     = ""
          let l:untracked_status  = ""
          let l:unmerged_status   = ""

          for b:tmp_str in split(l:args[0], '\zs')
            if match(b:tmp_str, '^[SCPOG]$')
              let l:commit_status = b:tmp_str
            endif
            if match(b:tmp_str, '^U$')
              let l:untracked_status = b:tmp_str
            endif
            if match(b:tmp_str, '^M$')
              let l:unmerged_status = b:tmp_str
            endif
          endfo

          if l:branchstate == "unstaged" && l:commit_status == "S"
            return l:args[1]
          endif
        endif
      endif
    endif
  endif
  return ""

endfunction




"recalculate the Gitps1 when idle, and after saving
autocmd cursorhold,CursorHoldI,bufwritepost * unlet! b:statusline_tartify_repo

"next one too slow for my taste :
"recalculate Gitps1 when idle, after saving, on window change
"autocmd cursorhold,CursorHoldI,bufwritepost,InsertLeave,WinEnter,WinLeave * unlet! b:statusline_tartify_repo







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


"1}}}
" vim:foldmethod=marker
