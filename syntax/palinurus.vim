syntax keyword palinurus_keywords
	\ !
	\ *
	\ ~
	\ .
	\ #
	\ =

" Match entries
syntax region bang start="^\t*\! " end=".*$"
syntax region bullet start="^\t*\* " end=".*$"
syntax region tilde start="^\t*\~ " end=".*$"
syntax region dot start="^\t*\. " end=".*$"
syntax region done start="^\t*\# " end=".*$"

" Highlight entries
" #ff5f5f/203: red
" #ffd700/220: yellow
" #87d787/114: green
" #00afff/39: blue
" #585858/240: gray
highlight bang ctermfg=203 guifg=#ff5f5f
highlight bullet ctermfg=220 guifg=#ffd700
highlight tilde ctermfg=114 guifg=#87d787
highlight dot ctermfg=39 guifg=#00afff
highlight done ctermfg=240 guifg=#585858

let b:current_syntax = "palinurus"
