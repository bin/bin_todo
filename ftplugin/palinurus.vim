" Set item prefixes and sub-item prefix to be keywords
" Also set = be a keyword (for the date string)
setlocal iskeyword+=!,*,~,.,=

command Newday execute ":call check_todo_sort_newday()"
