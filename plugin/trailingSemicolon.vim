" Add trailing ;
function! s:TrailingSemicolon()
    execute "keepjumps normal! mzg_"
    let l:currentChar = strcharpart(getline("."), col(".") - 1, 1)
    if l:currentChar !=# ';'
        execute "normal! a;"
    endif
    execute "keepjumps normal! `z<CR>"
endfunction
" command! -nargs=0 TrailingSemicolon :call <SID>TrailingSemicolon()
nmap <silent> <Plug>trailingSemicolon :call <SID>TrailingSemicolon()<CR>
