" hier.vim:		Highlight quickfix errors
" Last Modified: Tue 03. May 2011 10:55:27 +0900 JST
" Author:		Jan Christoph Ebersbach <jceb@e-jc.de>
" Version:		1.3

if (exists("g:loaded_hier") && g:loaded_hier) || &cp
    finish
endif
let g:loaded_hier = 1

let g:hier_enabled = get(g:, 'hier_enabled', 1)
let g:hier_highlight_group_qf  = get(g:, 'hier_highlight_group_qf', 'QFError')
let g:hier_highlight_group_qfw = get(g:, 'hier_highlight_group_qfw', 'QFWarning')
let g:hier_highlight_group_qfi = get(g:, 'hier_highlight_group_qfi', 'QFInfo')
let g:hier_highlight_group_loc	= get(g:, 'hier_highlight_group_loc', 'LocError')
let g:hier_highlight_group_locw = get(g:, 'hier_highlight_group_locw', 'LocWarning')
let g:hier_highlight_group_loci = get(g:, 'hier_highlight_group_loci', 'LocInfo')

function! s:Getlist(winnr, type)
	if a:type == 'qf'
		return getqflist()
	else
		return getloclist(a:winnr)
	endif
endfunction

function! s:Hier(clearonly)
	for m in getmatches()
		for h in [g:hier_highlight_group_qf, g:hier_highlight_group_qfw, g:hier_highlight_group_qfi, g:hier_highlight_group_loc, g:hier_highlight_group_locw, g:hier_highlight_group_loci]
			if m.group == h
				call matchdelete(m.id)
			endif
		endfor
	endfor

	if g:hier_enabled == 0 || a:clearonly == 1
		return
	endif

	let bufnr = bufnr('%')

	for type in ['qf', 'loc']
		for i in s:Getlist(0, type)
			if i.bufnr == bufnr
				let hi_group = eval('g:hier_highlight_group_'.type)
				if i.type == 'I' || i.type == 'info'
					let hi_group = eval('g:hier_highlight_group_'.type.'i')
				elseif i.type == 'W' || i.type == 'warning'
					let hi_group = eval('g:hier_highlight_group_'.type.'w')
				elseif eval('g:hier_highlight_group_'.type) == ""
					continue
				endif

				if i.lnum > 0 && i.col
					let lastcol = col([i.lnum, '$'])
					let c = (lastcol == i.col) ? max([0, i.col - 1]) : i.col
					call matchaddpos(hi_group, [[i.lnum, c, lastcol-c]])
				elseif i.lnum > 0
					call matchaddpos(hi_group, [[i.lnum]])
				elseif i.pattern != ''
					call matchadd(hi_group, i.pattern)
				endif
			endif
		endfor
	endfor
endfunction

command! -nargs=0 HierUpdate call s:Hier(0)
command! -nargs=0 HierClear call s:Hier(1)

command! -nargs=0 HierStart let g:hier_enabled = 1 | HierUpdate
command! -nargs=0 HierStop let g:hier_enabled = 0 | HierClear

augroup Hier
	au!
	au QuickFixCmdPost,BufEnter,WinEnter * :HierUpdate
augroup END
