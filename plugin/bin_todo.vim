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

function s:_sort_block(depth, pos)
	" Find items beginning with !, *, ~, or .  Keep a separate list for each 
	" symbol and append each line to the appropriate list.
	" Sub-items aren't re-ordered.  Store the last top-level item type seen.
	" When we hit a sub-item, append it to the list of the last top-level 
	" item.
	" TODO: Might there be a more-efficient sort, even if I don't care about 
	" in-place sorting?
	let s:i = g:top_line - a:pos
	let last_type = ""
	let l:bullet_elems = []
	let l:bang_elems = []
	let l:tilde_elems = []
	let l:dot_elems = []
	while s:i <= g:bottom_line
		let line = getline(s:i)
		let s:tabs = 0
		for s:char in split(line, '\zs')
			if s:char =~# '\t'
				let s:tabs += 1
			else
				break
			endif
		endfor
		if s:tabs == a:depth + 1
			if line =~# '^\t*\! .*'
				call add(l:bang_elems, line)
				let last_type = 0
			elseif line =~# '^\t*\* .*'
				call add(l:bullet_elems, line)
				let last_type = 1
			elseif line =~# '^\t*\~ .*'
				call add(l:tilde_elems, line)
				let last_type = 2
			elseif line =~# '^\t*\. .*'
				call add(l:dot_elems, line)
				let last_type = 3
			endif
		elseif s:tabs > a:depth + 1
			if last_type == 0
				call add(l:bang_elems, s:_sort_block(a:depth + 1, s:i + 1))
			elseif last_type == 1
				call add(l:bullet_elems, s:_sort_block(a:depth + 1, s:i + 1))
			elseif last_type == 2
				call add(l:tilde_elems, s:_sort_block(a:depth + 1, s:i + 1))
			elseif last_type == 3
				call add(l:dot_elems, s:_sort_block(a:depth + 1, s:i + 1))
			endif
			let s:i += g:num_processed
		else
			return [l:bang_elems, l:bullet_elems, l:tilde_elems, l:dot_elems]
			let g:num_processed = s:i + 1
		endif
		let s:i += 1
	endwhile
	return [l:bang_elems, l:bullet_elems, l:tilde_elems, l:dot_elems]
endfunction

function s:_flatten_sorted(sorted)
" https://gist.github.com/3322468
	let val = []
	for elem in a:sorted
		if type(elem) == type([])
			call extend(val, s:_flatten_sorted(elem))
		else
			call add(val, elem)
		endif
		unlet elem
	endfor
	return val
endfunction

function s:_write_sorted(sorted)
	" store starting position
	let orig_pos = winsaveview()
	let new_top = g:top_line - 1
	" jump to top line of block
	execute g:top_line
	" delete old block
	let difference = g:bottom_line - g:top_line
	let difference += 1
	execute "d" . difference

	" Output re-ordered block.
	call append(new_top, a:sorted)

	" Restore window position
	call winrestview(orig_pos)
endfunction

function s:_check_todo_sort()
	let g:num_processed = 0
	call s:_get_curr_block_lines()
	let s:sorted = s:_sort_block(0, 0)
	let s:flat_sorted = s:_flatten_sorted(s:sorted)
	echo s:flat_sorted
	call s:_write_sorted(s:flat_sorted)
endfunction

autocmd InsertLeave todo.txt call s:_check_todo_sort()
