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
" function s:get_curr_block_lines()
function Get_curr_block_lines()
	" find top of block
	let curr_line = line('.')
	while getline(curr_line) !~# '^=.*' && curr_line >= 0
		let curr_line -= 1
	endwhile
	let g:top_line = curr_line + 1

	" find bottom of block
	let curr_line = line('.')
	while getline(curr_line) !~# '^=.*' && curr_line <= line("$")
		let curr_line += 1
	endwhile
	let g:bottom_line = curr_line - 1
endfunction

" function s:sort_block()
function Sort_block()
	let i = g:top_line
	let last_type = ""
	let g:bullet_elems = []
	let g:bang_elems = []
	let g:tilde_elems = []
	let g:dot_elems = []
	while i >= g:top_line && i <= g:bottom_line
		" TODO: get sub-point lines
		let line = getline(i)
		if line =~# '\t\* .*'
			call add(g:bullet_elems, line)
			let last_type = 0
		elseif line =~# '\t\! .*'
			call add(g:bang_elems, line)
			let last_type = 1
		elseif line =~# '\t\~ .*'
			call add(g:tilde_elems, line)
			let last_type = 2
		elseif line =~# '\t\. .*'
			call add(g:dot_elems, line)
			let last_type = 3
		elseif line =~# '\t\t\+'
			echo "Matched line " . i . " as sub elem"
			if last_type == 0
				call add(g:bullet_elems, line)
			elseif last_type == 1
				call add(g:bang_elems, line)
			elseif last_type == 2
				call add(g:tilde_elems, line)
			elseif last_type == 3
				call add(g:dot_elems, line)
			endif
		endif

		let i += 1
	endwhile
endfunction

" function s:write_sorted()
function Write_sorted()
	" back up starting line
	let orig_line = line('.')
	let new_top = g:top_line - 1
	" jump to top line
	execute g:top_line
	" delete old
	let difference = g:bottom_line - g:top_line
	let difference += 1
	execute "d" . difference

	" this just appends to the current line and doesn't move the cursor
	" so the first things appended gets pushed down as more lines are appended
	" so append in reverse order to get final order correct
	call append(new_top, g:dot_elems)
	call append(new_top, g:tilde_elems)
	call append(new_top, g:bullet_elems)
	call append(new_top, g:bang_elems)
	" TODO: add color here

	execute orig_line
endfunction

function Check_todo_sort()
	call Get_curr_block_lines()
	call Sort_block()
	call Write_sorted()
endfunction

autocmd InsertLeave todo.txt call Check_todo_sort()

" TODO: ensure that the cursor ends on the same line we start.  Maybe save
" number and jump back?
