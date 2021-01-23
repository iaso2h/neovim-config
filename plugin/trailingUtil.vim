" Add trailing ;
function! TrailingChar(trailingChar)
    let l:cursor = getpos('.')
    execute "keepjumps normal g_"
    let l:currentChar = strcharpart(getline("."), col(".") - 1, 1)
    execute "normal! a" . a:trailingChar
    if l:currentChar !=# a:trailingChar
    endif
    call cursor(l:cursor[1], l:cursor[2])
endfunction

function! TrailingLinebreak(direction)
    let l:cursor = getpos('.')
    if a:direction ==# "down"
        execute "normal A\<cr>"
        call cursor(l:cursor[1], l:cursor[2])
    elseif a:direction ==# "up"
    endif
endfunction

