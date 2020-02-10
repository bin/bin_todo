" bnote.vim - Note taking
" Author: 	bin
" Version:	0.1

if exists("g:loaded_bnote") || &cp || v:version < 800
	finish
endif
let g:loaded_bnote = 1

" Find the line numbers of current block (day)
" Top line is line num of first line after the date (including newlines)
" Bottom line is line num of last line before next date (including newlines)
function get_curr_block_lines()
	" find top of block
	let curr_line = line('.')
	while getline(curr_line) !~# ^=.*
		let curr_line -= 1
	endwhile
	let g:top_line = curr_line + 1

	" find bottom of block
	let curr_line = line('.')
	while getline(curr_line) !~# ^=.*
		let curr_line += 1
	endwhile
	let g:bottom_line = curr_line - 1
endfunction


