syntax keyword bin_todo_keywords
	\ !
	\ *
	\ ~
	\ .
	\ +
	\ =

" Match dates
" Matches one or two digits for month, then a dot
" Matches one or two digits for day, then a dot
" Matches year group or not
" 	If so, matches a dot, then two or four digits for year
"""syntax region bin_todo_date start="[0-9]\{1,2}\.[0-9]\{1,2}\(\.[0-9]\{2,4}\)\?" end="" contained
" Date for separating list blocks
syntax match bin_todo_block_date "^= [0-9]\{1,2}\.[0-9]\{1,2}\(\.[0-9]\{2,4}\)\? =$"

" Match any top-level item
" syntax region bin_todo_top_level start="^\t\!\|\*\|\~\|\. " contains=Date
" Match specific items
syntax region bin_todo_bang start="^\t*\! " end=".*" contains=bin_todo_item_date
syntax region bin_todo_bullet start="^\t*\* " end=".*" contains=bin_todo_item_date
syntax region bin_todo_tilde start="^\t*\~ " end=" .*" contains=bin_todo_block_date
syntax region bin_todo_dot start="^\t*\. " end=" .*" contains=bin_todo_block_date
" syntax region bin_todo_plus start="^\t\t+ " end=" .*" contains=bin_todo_block_date
" Match dates on items
" Date matching is the same as bin_todo_block_date regex
syntax match bin_todo_item_date "\[[0-9]\{1,2}\.[0-9]\{1,2}\(\.[0-9]\{2,4}\)\?\]"

"syntax match bin_dummy_test ".*"

highlight bin_todo_block_date ctermfg=109 guifg=#87afd7
highlight bin_todo_bang ctermfg=203 guifg=#d75f87
highlight bin_todo_bullet ctermfg=220 guifg=#ffd700
highlight bin_todo_tilde ctermfg=65 guifg=#5faf5f
highlight bin_todo_dot ctermfg=242 guifg=#6c6c6c
highlight bin_todo_plus ctermfg=172 guifg=#d78700
highlight bin_todo_item_date ctermfg=75 guifg=#5fafff
"highlight bin_todo_date ctermfg=75 guifg=#5fafff
"highlight bin_dummy_test ctermfg=Orange3 guifg=#d78700

let b:current_syntax = "bin_todo"
