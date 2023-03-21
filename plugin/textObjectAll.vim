function! s:isCurrentLineEmpty()
    return !len(getline('.'))
endfunction
" isCurrentLineEmpty
" TODO: camelcase convert tool

function! s:inside()
    keepjumps normal! gg^
    if s:isCurrentLineEmpty()
        call search('\v\w')
        keepjumps normal! ^
    endif
    keepjumps normal! vGg_
    if s:isCurrentLineEmpty()
        call search('\v\w', 'b')
        keepjumps normal! g_
    endif
endfunction

function! s:around()
    keepjumps normal! gg^vG$
endfunction

let s:save_cpo = &cpo
set cpo&vim

onoremap <silent> <Plug>(textObjInsideAll) :<C-U>call <SID>inside()<CR>
omap <silent> ig <Plug>(textObjInsideAll)
xnoremap <silent> <Plug>(textObjInsideAll) :<C-U>call <SID>inside()<CR>
xmap <silent> ig <Plug>(textObjInsideAll)

onoremap <silent> <Plug>(textObjectAroundAll) :<C-U>call <SID>around()<CR>
omap <silent> ag <Plug>(textObjectAroundAll)
xnoremap <silent> <Plug>(textObjectAroundAll) :<C-U>call <SID>around()<CR>
xmap <silent> ag <Plug>(textObjectAroundAll)


let &cpo = s:save_cpo
unlet s:save_cpo

