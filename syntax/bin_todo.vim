syntax keyword bin_todo_keywords
	\ !
	\ *
	\ ~
	\ .
	\ #
	\ =

" Match entries
" Any number of tabs, followed by priority character, followed by arbitrary
" text.
syntax region bin_todo_bang start="^\t*\! " end=".*$"
syntax region bin_todo_bullet start="^\t*\* " end=".*$"
syntax region bin_todo_tilde start="^\t*\~ " end=".*$"
syntax region bin_todo_dot start="^\t*\. " end=".*$"
syntax region bin_todo_done start="^\t*\# " end=".*$"

" highlight bin_todo_block_date ctermfg=109 guifg=#87afd7
highlight bin_todo_bang ctermfg=203 guifg=#ff5f5f
highlight bin_todo_bullet ctermfg=220 guifg=#ffd700
highlight bin_todo_tilde ctermfg=114 guifg=#87d787
highlight bin_todo_dot ctermfg=39 guifg=#00afff
highlight bin_todo_done ctermfg=240 guifg=#585858
highlight bin_todo_plus ctermfg=172 guifg=#d78700

let b:current_syntax = "bin_todo"
