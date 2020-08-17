" bin_todo.vim - Todo list
" Author: 	bin
" Version:	0.1

if exists("g:_loaded_bin_todo") || &cp || v:version < 800
	finish
endif
let g:_loaded_bin_todo = 1

" Options
set nowrap
set textwidth=0

" Find the line numbers of current block
" Blocks are delimited by dates of the following form:
" = mm/dd/yyyy =
" or
" = mm/dd/yy =
" or
" = mm/dd =
" Searches up to find the top and down to find the bottom; the plugin operates 
" only on the current block
" Line numbers don't include the date lines but do include newlines
function _get_curr_block_lines()
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

function _log5(in)
	" Pre-calculated
	let s:log10_5 = 0.6990
	return log10(a:in) / s:log10_5
endfunction

" Return the Julian date number of a date
" I honestly have no idea how this formula works, but subtracting two of these
" gives the difference in days.
" https://stackoverflow.com/a/12863278
function _julian_num(day, month, year)
	let l:month = (a:month + 9) % 12
	let l:year = a:year - (l:month / 10)
	return floor((365 * l:year) + (l:year / 4) - (l:year / 100) + (l:year / 400) + (((l:month * 306) + 5) / 10) + (a:day - 1))
endfunction

" Takes a date as mm/dd or mm/dd/yy and returns the number of days from today
function _date_diff(date)
	let l:curr_date = split(strftime('%m/%d/%y'), "/")
	let l:curr_month = l:curr_date[0]
	let l:curr_day = l:curr_date[1]
	let l:curr_year = l:curr_date[2]

	let l:parts = split(a:date, "/")
	let l:in_month = l:parts[0]
	let l:in_day = l:parts[1]
	" If mm/dd/yy use supplied year; else assume current year
	if len(l:parts) < 3
		let l:in_year = l:curr_year
	else
		let l:in_year = parts[2]
	endif

	let l:difference= 0
	let l:in_num = _julian_num(l:in_day, l:in_month, l:in_year)
	let l:curr_num = _julian_num(l:curr_day, l:curr_month, l:curr_year)

	return l:in_num - l:curr_num
endfunction

" Importance is a value 1-4 inclusive corresponding to . ~ * !
" Due is the due date, given as mm/dd or mm/dd/yy.
function _score(importance, due)
	let l:days = _date_diff(a:due)
	if l:days <= 0
		" Can't take log of a negative number and can't have division
		" by zero.  Anything due same-day or late is top-priority
		" anyway.
		let l:log_res = 0.01
	else
		let l:log_res = _log5(l:days)
	endif
	return a:importance / l:log_res
endfunction

" Read the todos for a given day into a trie structure.
"
" Importance:
" !: 5
" *: 4
" ~: 3
" .: 2
" #: 1
"
" Reading in works by looping through a nested list of tasks and storing them
" in a trie structure.  Each line is stored as a dictionary with the following
" attributes:
" Depth: The indentation of the line.  This is used to determine of which line
" a given line is a child.
" Date: The due date of an item.  This is optional but recommended.
" Importance: Ranked one to four based on the entry symbol used !|*|~|.|#,
" respectively.
" Content: The content of the item, that is, the actual to-do.
" Score: The importance score, calculated as outlined above.
" Children: A list of lines indented underneath, each of which may have
" children of it's own and is stored as outlined above.
"
" The list is represented as follows:
" 1. Read in a line.
" 2. Check the depth of the line by counting the number of tabs, then compare
" it to the number of tabs in the last line.
" 	- If the two are equal, the current line is part of the same line as
" 	above.  Append it to curr_list.
"	- If the current line is indented more than the previous line, it is a
"	child of the previous line and part of a new list.  Append the last
"	item of curr_list to parent_list, then set curr_list to the children
"	list the last item of curr_list, or curr_list = 
"	curr_list[-1]["children"].  Append the current line item to curr_list.
"	- If the current line is indented less than the previous line, the
"	existing list has ended.  Note that it is also possible that two
"	sub-lists have just ended, e.g.:
"	! a
"		* b
"		~ c
"			~ d
"			. e
"	~ f
"	Upon reading element f, two sub-lists have just ended.  Compare the
"	current indentation to the last element in curr_list, in other words,
"	compare tabs and curr_list[-1]["depth"].  For each tab of difference,
"	set curr_list equal to the last element of parent_list and remove the
"	last element of parent_list.  Then, process the current line into
"	curr_list.
let s:type_to_num = {
	\ "!": 5,
	\ "*": 4,
	\ "~": 3,
	\ ".": 2,
	\ "#": 1,
	\}
let s:num_to_type = {
	\ "5": "!",
	\ "4": "*",
	\ "3": "~",
	\ "2": ".",
	\ "1": "#",
	\}
function _read_list()
	let s:curr_list = []
	let s:parent_list = []
	let s:last_depth = 1
	let l:start = g:top_line
	while l:start <= g:bottom_line
		let l:line = getline(l:start)
		if l:line !~# '^\s*$'
			let s:tabs = 0
			for s:char in split(l:line, '\zs')
				if s:char =~# '\t'
					let s:tabs += 1
				else
					break
				endif
			endfor
			if s:tabs > s:last_depth
				" Child item
				call add(s:parent_list, s:curr_list)
				let s:curr_list = s:curr_list[-1]["children"]
			elseif s:tabs < s:last_depth
				" Sub-list(s) have ended; traverse back up the trie
				let l:difference = s:last_depth - s:tabs
				while l:difference > 0
					let s:curr_list = s:parent_list[-1]
					call remove(s:parent_list, -1)
					let l:difference -= 1
				endwhile
				"let l:i = s:tabs
				"while s:curr_list[-1]["depth"] == s:tabs
				"	let s:curr_list = s:parent_list[-1]
				"endwhile
				"let s:curr_list = s:parent_list
			endif
			" Nothing needed for items at the same depth as the priot item
			let l:tmp = {}
			let l:tmp["depth"] = s:tabs
			let l:type = substitute(line, '^\t*.\(\.\|\!\|\~\|\#\|\*\) \(\[.*\]\)\?.*$', '\1', '')
			let l:tmp["importance"] = s:type_to_num[l:type]
			let l:date = substitute(line, '^\t*..\(\[\(.*\)\]\)\? .*$', '\2', '')
			if l:date !~# '^\s*$'
				let l:tmp["date"] = l:date
				let l:tmp["score"] = _score(l:tmp["importance"], l:tmp["date"])
			else
				let l:tmp["score"] = 0
			endif
			let l:tmp["content"] = substitute(line, '^\t*..\(\[.*\]\)\? \(.*\)$', '\2', '')
			let l:tmp["children"] = []
			let s:last_depth = s:tabs
			call add(s:curr_list, l:tmp)
		endif
		let l:start += 1
	endwhile
	call add(s:parent_list, s:curr_list)
	return s:parent_list[0]
endfunction

function _read_list_mod()
	let s:curr_list = []
	let s:parent_list = []
	let s:last_depth = 1
	let l:start = g:top_line
	while l:start <= g:bottom_line
		let l:line = getline(l:start)
		if l:line !~# '^\s*$'
			let s:tabs = 0
			for s:char in split(l:line, '\zs')
				if s:char =~# '\t'
					let s:tabs += 1
				else
					break
				endif
			endfor
			if s:tabs > s:last_depth
				" Child item
				call add(s:parent_list, s:curr_list)
				let s:curr_list = s:curr_list[-1]["children"]
			elseif s:tabs < s:last_depth
				" Sub-list(s) have ended; traverse back up the trie
				let l:difference = s:last_depth - s:tabs
				while l:difference > 0
					let s:curr_list = s:parent_list[-1]
					call remove(s:parent_list, -1)
					let l:difference -= 1
				endwhile
				"let l:i = s:tabs
				"while s:curr_list[-1]["depth"] == s:tabs
				"	let s:curr_list = s:parent_list[-1]
				"endwhile
				"let s:curr_list = s:parent_list
			endif
			" Nothing needed for items at the same depth as the priot item
			let l:tmp = {}
			let l:tmp["depth"] = s:tabs
			let l:type = substitute(line, '^\t*.\(\.\|\!\|\~\|\#\|\*\) \(\[.*\]\)\?.*$', '\1', '')
			let l:tmp["importance"] = s:type_to_num[l:type]
			let l:date = substitute(line, '^\t*..\(\[\(.*\)\]\)\? .*$', '\2', '')
			if l:date !~# '^\s*$'
				let l:tmp["date"] = l:date
				let l:tmp["score"] = _score(l:tmp["importance"], l:tmp["date"])
			else
				let l:tmp["score"] = 0
			endif
			let l:tmp["content"] = substitute(line, '^\t*..\(\[.*\]\)\? \(.*\)$', '\2', '')
			let l:tmp["children"] = []
			let s:last_depth = s:tabs
			if l:tmp["importance"] != 1
				call add(s:curr_list, l:tmp)
			endif
		endif
		let l:start += 1
	endwhile
	call add(s:parent_list, s:curr_list)
	return s:parent_list[0]
endfunction

" There are three attributes to consider for a task:
" 1. Importance.  I assign this a score of one through four, inclusive, by
"    using the ! * ~ . system.  A greater importance should positively bias the
"    ranking of a task.
" 2. Due date.  A closer due date ought to positively bias the ranking of a
"    task.  A task with a very close due date ought to bias the ranking of the 
"    task to a significant degree.  While a task with a distant due date should
"    be negatively weighted, the negative weight should not increase
"    significantly between a five- and a thirty-day due date.  Otherwise, a
"    task due in thirty days, even one of high importance, would get stuck at
"    the bottom of the list until about five days before it were due.
" 3. Task complexity or length.  There's no simple answer as to how this
"    affects task prioritization.  While there are interesting ideas in queuing
"    theory about whether to tackle larger or smaller tasks first, the real
"    answer for man is to go for tasks which fit into one's calendar.  For
"    instance, a long project may be better suited to a three-hour block of
"    time in the afternoon than to an hour break between classes, while it
"    might be better to tackle a simple reading assignment in that same break.
"    So, ranking based on time would take calendar information which is a
"    problem for another day and likely outside the scope of a vim plugin.
"
" This uses the formula rank = importance / log5(days until due)
" Tasks due very soon receive significant rank increases, with all tasks due in
" less than five days receiving a rank increase that decreases quickly as the
" due date increases.  Those due after five days receive a negative
" modification to rank, but the modification does not significantly increase
" with increasing time.  This is to prevent a large task due in a month from
" sitting at the bottom of the list until a few days before.
" Because vim provides only a log10() function, a change of base is necessary.
" log5(x) = log10(x) / log10(5)
"
" Sorting is based on descending to the deepest non-leaf nodes, quick-sorting,
" ascending a level, repeat.  Sorting is done via quicksort.
"
" TODO: for some reason, this does not yet work on top-level items... why?
function _sort_trie(in)
	if len(a:in) > 0
			let i = 0
			while i < len(a:in)
				let a:in[i]["children"] = _sort_trie(a:in[i]["children"])
				let a:in[i]["children"] = sort(a:in[i]["children"], "_compare_dicts_by_score")
				let i += 1
			endwhile
	 endif
	 return sort(a:in, "_compare_dicts_by_score")
endfunction

" Function passed to vim's sort() to compare two dictionaries by score value
" If two elements both have scores (i.e. both have a date), the scores are 
" compared and the result is returned.  If they are equal, their importances
" are compared and the result is returned.
" If one element has a score (i.e. a date) and the other does not, the element
" with the score is always returned as greater.
" If both elements lack scores, the importance rankings are compared and the
" result is returned.
" Note: items with no score have their score field set to zero.
function _compare_dicts_by_score(d1, d2)
	let l:n1 = a:d1["score"]
	let l:n2 = a:d2["score"]
	if type(a:d1["score"]) == type("")
		let l:n1 = str2float(a:d1["score"])
	endif
	if type(a:d2["score"]) == type("")
		let l:n2 = str2float(a:d2["score"])
	endif
	if l:n1 == 0 && l:n2 != 0
		return 1
	elseif l:n1 != 0 && l:n2 == 0
		return -1
	elseif l:n1 == 0 && l:n2 == 0
		let l:n1 = str2nr(a:d1["importance"])
		let l:n2 = str2nr(a:d2["importance"])
	elseif l:n1 != 0 && l:n2 != 0 && l:n1 == l:n2
		let l:n1 = str2nr(a:d1["importance"])
		let l:n2 = str2nr(a:d2["importance"])
	endif

	if l:n1 < l:n2
		return 1
	elseif l:n1 > l:n2
		return -1
	else
		return 0
	endif
endfunction

" Flatten all the trie into one list
function _flatten_sorted(sorted)
	let val = []
	for elem in a:sorted
		let children = elem["children"]
		let elem["children"] = []
		call add(val, elem)
		if len(children) > 0
			call extend(val, _flatten_sorted(children))
			let elem["children"] = []
		endif
		unlet elem
	endfor
	return val
endfunction

" Turn the flattened trie into a list of formatted lines
function _fmt_flattened(flattened)
	let val = []
	for elem in a:flattened
		let str = ""
		let i = 0
		while i < elem["depth"]
			let str .= "\t"
			let i += 1
		endwhile
		let str .= s:num_to_type[elem["importance"]] . ' '
		if has_key(elem, "date")
			let str .= "[" . elem["date"] . "] "
		endif
		let str .= elem["content"]
		call add(val, str)
	endfor
	return val
endfunction

function _write_fmtd(formatted)
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
	call append(new_top, a:formatted)

	" Restore window position
	call winrestview(orig_pos)
endfunction

function _write_fmtd_mod(formatted)
	execute 0
	" New date block
	call append(0, "= " . strftime('%m/%d/%y') . " =")
	" Output re-ordered block.
	call append(0, a:formatted)
endfunction

function _check_todo_sort()
	let g:num_processed = 0
	call _get_curr_block_lines()
	let s:trie = _read_list()
	let s:sorted = _sort_trie(s:trie)
	let s:flat = _flatten_sorted(s:sorted)
	let s:fmtd = _fmt_flattened(s:flat)
	call _write_fmtd(s:fmtd)
endfunction

function _check_todo_sort_newday()
	let g:num_processed = 0
	call _get_curr_block_lines()
	let s:trie = _read_list_mod()
	let s:sorted = _sort_trie(s:trie)
	let s:flat = _flatten_sorted(s:sorted)
	let s:fmtd = _fmt_flattened(s:flat)
	call _write_fmtd_mod(s:fmtd)
endfunction

autocmd InsertLeave todo.txt call _check_todo_sort()
