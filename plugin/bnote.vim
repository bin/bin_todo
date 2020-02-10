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
	while getline(curr_line) !~# '^=.*'
		let curr_line -= 1
	endwhile
	let g:top_line = curr_line + 1

	" find bottom of block
	let curr_line = line('.')
	while getline(curr_line) !~# '^=.*'
		let curr_line += 1
	endwhile
	let g:bottom_line = curr_line - 1
endfunction

function sort_block()
	let i = g:top_line
	let last_type = ""
	while i >= g:top_line && i <= g:bottom_line
		let g:bullet_elems = []
		let g:bang_elems = []
		let g:tilde_elems = []
		let g:dot_elems = []

		" TODO: get sub-point lines
		let line = getline(i)
		if line =~# '\t\* .*'
			add(bullet_elems, line)
			let last_type = "bullet"
		elseif line =~# '\t\! .*'
			add(bang_elems, line)
			let last_type = "bang"
		elseif line =~# '\t\~ .*'
			add(tilde_elems, line)
			let last_type = "tilde"
		elseif line =~# '\t\. .*'
			add(dot_elems, line)
			let last_type = "dot"
		else
			if last_type = "bullet"
				add(bullet_elems, line)
			elseif last_type = "bang"
				add(bang_elems, line)
			elseif last_type = "tilde"
				add(tilde_elems, line)
			elseif last_type = "dot"
				add(dot_elems, line)
			endif
		endif

		let i += 1
	endwhile
endfunction

function write_sorted()
	" back up starting line
	let orig_line = line('.')
	" jump to top line
	execute normal! g:top_line
	" delete old
	let difference = g:bottom_line - g:top_line
	let difference += 1
	execute normal! "d"difference
	let g = g:bullet_elems
	execute normal! put=g
	" TODO: add color here

endfunction

" TODO: ensure that the cursor ends on the same line we start.  Maybe save
" number and jump back?
