" TODO: add the "time since last commit"
" -------- FUNCTIONS ------------------{{{1


" TODO: VIRER !!
function! s:errmsg(msg)
  redraw
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

function!  tartify#GITPS1#statusline(item, ...)

  if match(expand("%f"), g:tartify_buffNameToAvoid) >= 0 | return "" | endif

  " CACHING
  " as the pr0n master once said, "we gawts to cache"
  if !exists("b:statusline_tartifyGIT")
    "
    " we simply call the "tartify" shell script with the "v" option
    "
    "     tartify v
    "
    " from wherever we might be (working dir), split the result, and
    " process it
    "

    let l:cd_workdir = "cd `dirname " . shellescape(expand('%:p')) . "`; "
    let s:tartifyShellScript = g:tartify_root_dir . "/bin/tartify "
    let b:tart_answer = system( l:cd_workdir . s:tartifyShellScript . "v")
    let b:tart_answer = b:tart_answer==''? '' : b:tart_answer

    "Catchall :unexpected error from shell function (report please)
    let b:statusline_tartify_error = 0
    if !v:shell_error == 0
      echomsg "TARTIFY: GITPS1 ERROR [". v:shell_error . "] RES=" . b:tart_answer
      let b:statusline_tartify_error = 1
    endif

    " NOTA: 1 : keep empty
    "       'vimsplitsep' : don't fucking touch that

    let b:tart_answer_split = split(b:tart_answer, 'vimsplitsep', 1)

    let b:statusline_tartifyGIT = {}
    let l:index=0
    for l:key in ['repo_name', 'branch', 'remote', 'stash', 'time']
      " get        : to pass empty string as default
      " substitute : to get rid of the added "'" when string-converting the (1 element) extraxted list
      let b:statusline_tartifyGIT[l:key] = 
            \substitute(
              \string ( get(b:tart_answer_split, l:index, "") ),
              \"'", "", 'g')
      let l:index = l:index + 1
    endfo


  endif

  "PROCESSING
  "
  "shell error    > return error and exit
  if b:statusline_tartify_error == 1
    if a:item == "repository"
      return "TARTIFY-ERROR"
    else
      return ""
    endif

  "no a git repo  > return naught
  elseif b:statusline_tartifyGIT['repo_name'] == ""
    return ""

  "git repo       > proceed
  else
    if a:item == "repository"
      return b:statusline_tartifyGIT['repo_name']
    elseif a:item == "remote"
      return b:statusline_tartifyGIT['remote']
    elseif a:item == "stash"
      return b:statusline_tartifyGIT['stash']
    elseif a:item == "time"
      return b:statusline_tartifyGIT['time']
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
        "       > each of the following, return the branchname and the "set
        "       laststatus" command will apply a different color to the
        "       result. The resulting status line snippet is only the
        "       branchname + colors
        "
        "
        "         "unstaged",     "unstagedWithUntracked", "uncommited",
        "         "uncommitedWithUntracked", "unpushed",
        "         "unpushedWithUntracked", "ok",           "okWithUntracked",
        "         "insideGitDir"
        "
        "
        "        > this will return a "M" symbol which will be prepended to
        "        the branchname
        "
        "         "unmerged"
        "
        "
        "   the "branch" part of the return value of the "`tartify v`" shell
        "   script , is of the form :
        "
        "   "$nocolor_info|$branch_name|$merge_infos"
        "
        "     where $nocolor_info =~ "[U]?[S]?[IDAONGBE][T]?"
        "
        "        "[U]nstaged modif(s)"
        "        "[S]taged modif(s)"
        "
        "       "d[I]verged from remote"
        "   "behin[D] remote"
        "        "[A]head of remote"
        "        "[O]K (remote == HEAD)"
        "        "[N]o tracked remote"
        "        "[G]it directory"
        "        "[B]are repository"
        "        "[E]mpty repository"
        "
        "      "un[T]racked files",
        "
        "     and $merge_infos : either one of these values, or "" :
        "
        "        "REBASE-i", "REBASE-m", "REBASE", "AM", "AM/REBASE",
        "        "MERGING", "CHERRY-PICKING", "BISECTING"
        "
        "     NB: $merge_infos most of the time empty
        "
        "       $nci\|$branchname\|$merge_status
        "
        "     nci =~ /[U]?[S]?[AONGBE][T]?/    (nci : no colors info)
        "
        "        [U]nstaged modif(s)
        "
        "        [S]taged modif(s)
        "
        "       d[I]vergd from remote
        "   behin[D] remote
        "        [A]head of remote
        "        [O]K (remote == HEAD)
        "        [N]o tracked remote
        "        [G]it directory
        "        [B]are repository
        "        [E]mpty repository
        "
        "        un[T]racked files,
        "
        "     merge_infos : either one of these values, or "" :
        "
        "        REBASE-i, REBASE-m, REBASE, AM, AM/REBASE, MERGING, CHERRY-PICKING,
        "        BISECTING

         let l:arglist =
                     \"unstaged|unstagedWithUntracked|
                     \uncommited|uncommitedWithUntracked|
                     \unpushed|unpushedWithUntracked|
                     \ok|okWithUntracked|insideGitDir|
                     \unmerged"
        if  !match(l:branchstate, l:arglist)
          return "BAD arg" . l:branchstate
        else
            " 1) separate $nocolor_info from $branch_name and $merge_infos
          let l:args = split(b:statusline_tartifyGIT['branch'], '|', 1)

          " 2) split $nocolor_info
          let l:commit_status     = ""
          let l:unstaged_status   = ""
          let l:staged_status     = ""
          let l:untracked_status  = ""

          for b:tmp_str in split(l:args[0], '\zs')
            if match(b:tmp_str, '^[IDAONGBE]$')
              let l:commit_status = b:tmp_str
            elseif match(b:tmp_str, '^U$')
              let l:unstaged_status = b:tmp_str
            elseif match(b:tmp_str, '^S$')
              let l:staged_status = b:tmp_str
            elseif match(b:tmp_str, '^T$')
              let l:untracked_status = b:tmp_str
            endif
          endfo

          "if l:branchstate == "unstaged" && l:commit_status == "S"
          "  return string(l:args[1])
          "endif

          "TMP: very temporary fix
          if l:branchstate == "unstaged"

            return 
                  \substitute(string(l:args[0]), "'", "", 'g')
                  \. "["
                  \. substitute(string(l:args[1]), "'", "", 'g')
                  \. "]"
                  \. substitute(string(get(l:args, 2, "''")), "'", "", 'g')
          endif
        endif
      endif
    endif
  endif
  return ""

endfunction




"TODO: i added ! to function to avoid 'already exists' errors
"      --> INVESTIGATE why they get defined more than once

"function! tartify#gitps1#tests()
"  return "true"
"endfunction



"function! tartify#gitps1#cost()
"  return "20"
"endfunction



"1}}}
" -------- STATUSLINE -----------------{{{1
function tartify#GITPS1#setstatusline()
  set statusline+=%1*
  set statusline+=%{tartify#GITPS1#statusline('repository')}

  " here I wished to reproduct the colored approach to showing the
  " 'extras' (unstaged files, uncommited changes,...) in a colored
  " way, as is done in the bashps1 shell script, instead of using
  " the usual *+%^ symbols usual in GIT_PS1, as I never can
  " remember which is which.
  " So this too will be "**Tartified**"
  "
  set statusline+=%7*
  "set statusline+=%#DiffAdd#
  set statusline+=%{tartify#GITPS1#statusline('branch','unstaged')}
  set statusline+=%{tartify#GITPS1#statusline('branch','unstagedWithUntracked')}
  set statusline+=%{tartify#GITPS1#statusline('branch','uncommited')}
  set statusline+=%{tartify#GITPS1#statusline('branch','TOTOLESALAUD')}
  set statusline+=%{tartify#GITPS1#statusline('branch','uncommitedWithUntracked')}
  set statusline+=%{tartify#GITPS1#statusline('branch','unpushed')}
  set statusline+=%{tartify#GITPS1#statusline('branch','unpushedWithUntracked')}
  set statusline+=%{tartify#GITPS1#statusline('branch','ok')}
  set statusline+=%{tartify#GITPS1#statusline('branch','okWithUntracked')}
  set statusline+=%{tartify#GITPS1#statusline('branch','insideGitDir')}

  set statusline+=%3*
  set statusline+=%{tartify#GITPS1#statusline('remote')}

  set statusline+=%4*
  set statusline+=%{tartify#GITPS1#statusline('stash')}

  set statusline+=%5*
  set statusline+=%{tartify#GITPS1#statusline('time')}

  set statusline+=%*

          "        > this will return a "M" symbol which will be prepended
          "          to the branchname
          "
          "         "unmerged"


endfunction


"1}}}
" -------- CACHING Autocmd ------------{{{1

"recalculate the Gitps1 when idle, and after saving
autocmd cursorhold,CursorHoldI,bufwritepost * unlet! b:statusline_tartifyGIT

"next one too slow for my taste :
"recalculate Gitps1 when idle, after saving, on window change
"autocmd cursorhold,CursorHoldI,bufwritepost,InsertLeave,WinEnter,WinLeave * unlet! b:statusline_tartifyGIT


"  1}}}
