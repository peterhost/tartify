
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
