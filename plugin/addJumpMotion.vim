" Add jump location for thoese motion :
" j, k with count sepcified
" g,/g;
function! NewAddJumpMotion()
    echom v:count
endfunction

function! AddJumpMotion(reserveCount, normalKeystroke)
    if !a:reserveCount
        normal! mz`z
        execute "normal! " . a:normalKeystroke
    else
        if v:count
            let l:saveCount = v:count
            normal! mz`z
            for i in range(l:saveCount) | execute "normal! " . a:normalKeystroke | endfor
        else
            execute "normal! " . a:normalKeystroke
        endif
    endif
endfunction
