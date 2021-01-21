" Add trailing ;
function! TrailingSemicolon()
    execute "keepjumps normal! mzg_"
    let l:currentChar = strcharpart(getline("."), col(".") - 1, 1)
    if l:currentChar !=# ';'
        execute "normal! a;"
    endif
    execute "keepjumps normal! `z<CR>"
endfunction

function! TrailingLinebreak()
    let l:cursor = getpos('.')
    execute "normal A\<cr>"
    call cursor(l:cursor[1], l:cursor[2])
endfunction

