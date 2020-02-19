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
syntax match bin_todo_date "[0-9]{1,2}\.[0-9]{1,2}\%(\.[0-9]{2,4}\)\?"
" Date for separating list blocks
syntax region bin_todo_block_date start="^= " end=" =" contains=bin_todo_date

" Match any top-level item
"asyntax region bin_todo_top_level start="^\t\!\|\*\|\~\|\. " contains=Date
" Match specific items
syntax match bin_todo_bang "^\t\! .*"
syntax match bin_todo_bullet "^\t\* .*"
syntax match bin_todo_tilde "^\t\~ .*"
syntax match bin_todo_dot "^\t\. .*"
syntax match bin_todo_plus "^\t\t\+ .*"
" Match dates on items
" Date matching is the same as bin_todo_block_date regex
syntax region bin_todo_item_date start="^\t\!\|\*\|\~\|\. \[" end="\]" contains=bin_todo_date

"syntax match bin_dummy_test ".*"

highlight bin_todo_block_date ctermfg=LightSkyBlue3 guifg=#87afd7
highlight bin_todo_item_date ctermfg=SteelBlue1 guifg=#5fafff
highlight bin_todo_bang ctermfg=IndianRed1 guifg=#d75f87
highlight bin_todo_bullet ctermfg=Gold1 guifg=#ffd700
highlight bin_todo_tilde ctermfg=DarkSeaGreen4 guifg=#5faf5f
highlight bin_todo_dot ctermfg=Gray15 guifg=#262626
highlight bin_todo_plus ctermfg=Orange3 guifg=#d78700
"highlight bin_dummy_test ctermfg=Orange3 guifg=#d78700

let b:current_syntax = "bin_todo"
