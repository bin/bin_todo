" bin_todo.vim - Todo list
" Author: 	bin
" Version:	0.1

if exists("g:_loaded_bin_todo") || &cp || v:version < 800
	finish
endif
let g:_loaded_bin_todo = 1

" Find the line numbers of current block
" Blocks are delimited by dates of the following form:
" = mm.dd.yyyy =
" Searches up to find the top and down to find the bottom; the plugin operates 
" only on the current block
" Line numbers don't include the date lines but do include newlines
function s:_get_curr_block_lines()
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

function s:_sort_block()
	" Find items beginning with !, *, ~, or .  Keep a separate list for each 
	" symbol and append each line to the appropriate list.
	" Sub-items aren't re-ordered.  Store the last top-level item type seen.
	" When we hit a sub-item, append it to the list of the last top-level 
	" item.
	" TODO: Might there be a more-efficient sort, even if I don't care about 
	" in-place sorting?
	let i = g:top_line
	let last_type = ""
	let l:bullet_elems = []
	let l:bang_elems = []
	let l:tilde_elems = []
	let l:dot_elems = []
	while i >= g:top_line && i <= g:bottom_line
		let line = getline(i)
		if line =~# '^\t\! .*'
			call add(l:bang_elems, line)
			let last_type = 0
		elseif line =~# '^\t\* .*'
			call add(l:bullet_elems, line)
			let last_type = 1
		elseif line =~# '^\t\~ .*'
			call add(l:tilde_elems, line)
			let last_type = 2
		elseif line =~# '^\t\. .*'
			call add(l:dot_elems, line)
			let last_type = 3
		elseif line =~# '^\t\t\+'
			if last_type == 0
				call add(l:bang_elems, line)
			elseif last_type == 1
				call add(l:bullet_elems, line)
			elseif last_type == 2
				call add(l:tilde_elems, line)
			elseif last_type == 3
				call add(l:dot_elems, line)
			endif
		endif

		let i += 1
	endwhile
	return [l:dot_elems, l:tilde_elems, l:bullet_elems, l:bang_elems]
endfunction

function s:_write_sorted(sorted)
	" store starting position
	"let orig_line = line('.')
	"let orig_col = col('.')
	let orig_pos = winsaveview()
	let new_top = g:top_line - 1
	" jump to top line of block
	execute g:top_line
	" delete old block
	let difference = g:bottom_line - g:top_line
	let difference += 1
	execute "d" . difference

	" Output re-ordered block.
	" append() appends to the current line by inserting below it.  It 
	" doesn't move the cursor.  Append()ing more stuff pushes the previous 
	" stuff down, so stuff is re-inserted in reverse order to account for 
	" this.
	"call append(new_top, g:dot_elems)
	"call append(new_top, g:tilde_elems)
	"call append(new_top, g:bullet_elems)
	"call append(new_top, g:bang_elems)
	call append(new_top, sorted[0])
	call append(new_top, sorted[1])
	call append(new_top, sorted[2])
	call append(new_top, sorted[3])

	"execute orig_line
	"call cursor(orig_line, orig_col)
	call winrestview(orig_pos)
endfunction

function s:_check_todo_sort()
	call s:_get_curr_block_lines()
	call s:_write_sorted(s:_sort_block())
endfunction

autocmd InsertLeave todo.txt call s:_check_todo_sort()