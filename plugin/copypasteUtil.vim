function! VSCodeLineCopy(modeType, copyDirection)
    if a:modeType ==# "V"
        normal! gv
        let saved_reg = @@
        let l:col = col(".")
        let l:row = line(".")
        let l:rowStart = line("'<") 
        let l:rowEnd = line("'>") 
        if l:row ==# l:rowStart
            let l:selectDirection = "up"
        else
            let l:selectDirection = "down"
        endif
        if a:copyDirection ==# "up"
            normal! yP
            if l:selectDirection ==# "up"
                call cursor(l:rowEnd, 0)
                normal! V
                call cursor(l:row, l:col)
            else
                normal! V
                call cursor(l:rowEnd, l:col)
            endif
        elseif a:copyDirection ==# "down"
            normal! y
            call cursor(l:rowEnd, 0)
            normal! p
            if l:selectDirection ==# "down"
                call cursor(l:rowEnd + 1, 0)
                normal! V
                call cursor(l:row + l:rowEnd - l:rowStart + 1, l:col)
            else
                call cursor(l:rowEnd + l:rowEnd - l:rowStart + 1, l:col)
                normal! V
                call cursor(l:rowEnd + 1, 0)
            endif
        endif
        let @@ = saved_reg
    elseif a:modeType ==# "n"
        let saved_reg = @@
        let l:col = col(".")
        let l:row = line(".")
        if a:copyDirection ==# "up"
            normal! yyP
            call cursor(l:row, l:col)
        elseif a:copyDirection ==# "down"
            normal! yyp
            call cursor(l:row + 1, l:col)
        endif
        let @@ = saved_reg
    endif
endfunction

" function! InplacePaste(type)
    " Echo a:type
    " if a:type ==# "char"
        " silent execute "normal! p"
    " elseif a:type ==# "line"
        " Echo getpos("'[")
        " Echo getpos("']")
        " Echo visualmode()
        " silent execute "normal! p"
    " else
        " silent execute "normal! gvp"
    " endif
    " call cursor(g:inplcaPastePos[1], g:inplcaPastePos[2])
" endfunction

" function! SetInplacePaste()
    " let g:inplcaPastePos = getpos('.')
    " set opfunc=InplacePaste
    " Echo 'g@'
    " return 'g@'
" endfunction

function! InplaceCopy(type, ...)
    if a:type ==# "char"
        silent execute "normal! `[v`]y"
    elseif a:type ==# "line"
        silent execute "normal! `[V`]y"
    else
        silent execute "normal! gvy"
    endif
    call cursor(g:inplcaCopyPos[1], g:inplcaCopyPos[2])
endfunction

function! SetInplaceCopy()
    let g:inplcaCopyPos = getpos('.')
    set opfunc=InplaceCopy
    return 'g@'
endfunction

function! InplaceDisableVisual()
    normal! gv
    execute "normal! \<esc>"
endfunction

function! HighlightNewPaste()
    let l:pos = getpos('.')
    let l:newContentStart = getpos("'[")
    let l:newContentEnd = getpos("']")
    if abs(l:pos[1] - l:newContentStart[1]) < abs(l:pos[1] - l:newContentEnd[1])
        call cursor(l:newContentEnd[1], l:newContentEnd[2])
        normal! v
        call cursor(l:newContentStart[1], l:newContentStart[2])
    else
        call cursor(l:newContentStart[1], l:newContentStart[2])
        normal! v
        call cursor(l:newContentEnd[1], l:newContentEnd[2])
    endif
endfunction
