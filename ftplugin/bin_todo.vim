" C-style single-line comments starting with //
setlocal commentstring=//\ %s
" Set item prefixes and sub-item prefix to be keywords
" Also set = be a keyword (for the date string)
setlocal iskeyword+=!,*,~,.,+,=
" 8-char tabs are best
setlocal tabstop=8
setlocal softtabstop=8
" Spaces are heresy
setlocal expandtab!
" Same as tabstop
setlocal shiftwidth=8
" No completion
setlocal completefunc

command Newday execute ":call s:_check_todo_sort_newday()"
