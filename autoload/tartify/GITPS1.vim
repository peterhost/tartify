" TODO: add the "time since last commit"
" -------- FUNCTIONS ------------------{{{1


function!  tartify#GITPS1#statusline(item, ...)

  if match(expand("%f"), g:tartify_buffNameToAvoid) >= 0 | return "" | endif

  " CACHING
  " as the pr0n master once said, "we gawts to cache"
  " (all this calling external bash function is resource intensive and
  " suboptimall too)
  if !exists("b:statusline_tartifyGIT")
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
    let b:statusline_tartifyGIT = {}
    "  execute predefined shell commands
    "     __gitps1_repo_name TRUE"
    "     __gitps1_branch TRUE TRUE"
    "     __gitps1_remote TRUE"
    "     __gitps1_stash TRUE"
    for l:key in ['repo_name', 'branch', 'remote', 'stash']
      let b:statusline_tartifyGIT[l:key] = system( l:cdlocaldir . "__gitps1_" . l:key . " TRUE")
      "Catchall :unexpected error from shell function (report please)
      if !v:shell_error == 0
        echomsg "TARTIFY: GITPS1 ERROR [" . l:key . "][". v:shell_error . "] RES=" . b:statusline_tartifyGIT[l:key]
      endif
    endfo

  endif

  "PROCESSING
  "
  "no a git repo
  if b:statusline_tartifyGIT['repo_name'] == ""
    return ""


  "git repo, all fine
  else
    if a:item == "repository"
      return b:statusline_tartifyGIT['repo_name']
    elseif a:item == "remote"
      return b:statusline_tartifyGIT['remote']
    elseif a:item == "stash"
      return b:statusline_tartifyGIT['stash']
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
          let l:args = split(b:statusline_tartifyGIT['branch'], '|')

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






function tartify#GITPS1#tests()


endfunction



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
