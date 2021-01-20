function! InplaceCopy(modeType)
    if a:modeType ==# "v" || a:modeType ==# "V"
        execute "normal! gv"
        let l:pos = getpos('.')
        execute "normal! y"
        call cursor(l:pos[1], l:pos[2])
    endif
endfunction

function! InplaceDisableVisual(modeType)
    if a:modeType ==# "v" || a:modeType ==# "V"
        execute "normal! gv"
        let l:pos = getpos('.')
        execute "normal! \<esc>"
        call cursor(l:pos[1], l:pos[2])
    endif
endfunction
