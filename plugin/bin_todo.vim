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
	let g:num_processed = a:pos
	let last_type = ""
	let l:bullet_elems_nodate = []
	let l:bullet_elems_date = []
	let l:bang_elems_nodate = []
	let l:bang_elems_date = []
	let l:tilde_elems_nodate = []
	let l:tilde_elems_date = []
	let l:dot_elems_nodate = []
	let l:dot_elems_date= []
	let l:date = ""
	let l:has_date = 0
	while g:num_processed <= g:bottom_line
		let line = getline(g:num_processed)
		let s:tabs = 0
		for s:char in split(line, '\zs')
			if s:char =~# '\t'
				let s:tabs += 1
			else
				break
			endif
		endfor
		if s:tabs == a:depth + 1
			"let date = substitute(line, '^\t*. \[\(.*\)\] .*$', '\1', '')
			let date = substitute(line, '^\t*. \[\(.*\)\] .*$', '\1', '')
			" If no date is found, substitute() returns the whole line 
			" so first char will be tab
			if split(line, '\zs')[0] != '\t'
				let l:has_date = 1
			else
				let l:has_date = 0
			endif
			if line =~# '^\t*\! .*'
				call add(l:bang_elems_nodate, line)
				let last_type = 0
			elseif line =~# '^\t*\* .*'
				call add(l:bullet_elems_nodate, line)
				let last_type = 1
			elseif line =~# '^\t*\~ .*'
				call add(l:tilde_elems_nodate, line)
				let last_type = 2
			elseif line =~# '^\t*\. .*'
				call add(l:dot_elems_nodate, line)
				let last_type = 3
			endif
		elseif s:tabs > a:depth + 1
			if last_type == 0
				call add(l:bang_elems_nodate, s:_sort_block(a:depth + 1, g:num_processed))
			elseif last_type == 1
				call add(l:bullet_elems_nodate, s:_sort_block(a:depth + 1, g:num_processed))
			elseif last_type == 2
				call add(l:tilde_elems_nodate, s:_sort_block(a:depth + 1, g:num_processed))
			elseif last_type == 3
				call add(l:dot_elems_nodate, s:_sort_block(a:depth + 1, g:num_processed))
			endif
		else
			return [l:bang_elems_nodate, l:bullet_elems_nodate, l:tilde_elems_nodate, l:dot_elems_nodate]
		endif
		let g:num_processed += 1
	endwhile
	return [l:bang_elems_nodate, l:bullet_elems_nodate, l:tilde_elems_nodate, l:dot_elems_nodate]
endfunction

" Sort first by entry type (bang|bullet|tilde|dot) or date?
" Stupid idea: multiply entry "score" (bang = 4, bullet = 3, tilde = 2, dot = 1)
" by days from current day?  E.g. medium importance (tilde) * 3 days out = 6 pts
" Then, just sort by points?
function s:_sort_block(pos, list)
	let s:curr = a:list
	let s:depth = 0
	let s:parent_list = []
	while g:num_processed <= g:bottom_line
		let line = getline(g:num_processed)
		let s:tabs = 0
		for s:char in split(line, '\zs')
			if s:char =~# '\t'
				let s:tabs += 1
			else
				break
			endif
		endfor
		if s:curr[0]["depth"]
			s:depth = s:curr[0]["depth"]
		endif
		if s:depth == s:tabs
			let l:tmp = {}
			let l:tmp["depth"] = s:tabs
			let l:tmp["date"] = substitute(line, '^\t*. \[\(.*\)\] .*$', '\1', '')
			if line =~# '^\t*\! .*'
				let l:tmp["type"] = "bang"
			elseif line =~# '^\t*\* .*'
				let l:tmp["type"] = "bullet"
			elseif line =~# '^\t*\~ .*'
				let l:tmp["type"] = "tilde"
			elseif line =~# '^\t*\. .*'
				let l:tmp["type"] = "dot"
			endif
			let l:tmp["content"] = substitute(line, '^\t*. \([.*]\)? \(.*\)$', '\1', '')
			let l:tmp["children"] = []
			call add(s:curr, l:tmp)
		else if s:tabs > s:depth
			let l:tmp = {}
			let l:tmp["depth"] = s:tabs
			let l:tmp["date"] = substitute(line, '^\t*. \[\(.*\)\] .*$', '\1', '')
			if line =~# '^\t*\! .*'
				let l:tmp["type"] = "bang"
			elseif line =~# '^\t*\* .*'
				let l:tmp["type"] = "bullet"
			elseif line =~# '^\t*\~ .*'
				let l:tmp["type"] = "tilde"
			elseif line =~# '^\t*\. .*'
				let l:tmp["type"] = "dot"
			endif
			let l:tmp["content"] = substitute(line, '^\t*. \([.*]\)? \(.*\)$', '\1', '')
			let l:tmp["children"] = []
			call add(s:curr[-1]["children"], l:tmp)
			call add(l:parent_list, s:curr)
			let s:curr = l:tmp
		else if s:tabs < a:depth
			let l:i = s:tabs
			while s:curr[-1]["depth"] == s:tabs
				s:curr = l:parent_list[-1]
			endwhile
		endif
	endwhile
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

" list orig - original list
" list in - list to insert
" index - insert before this index
" returns joined list
function s:_insert_list_before_index(orig, in, index)
	let end = index - 1
	let tmp = orig[0:end]
	let tmp += in
	let tmp += [in:]
	return tmp
endfunction

function s:_check_todo_sort()
	let g:num_processed = 0
	call s:_get_curr_block_lines()
	let s:sorted = s:_sort_block(0, g:top_line)
	let s:flat_sorted = s:_flatten_sorted(s:sorted)
	call s:_write_sorted(s:flat_sorted)
endfunction

autocmd InsertLeave todo.txt call s:_check_todo_sort()
