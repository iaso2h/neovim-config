" VSCode copy line {{{
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
" }}} VSCode copy line
function! InplacePaste(type, direction)
    let g:putFilePath = expand("%:p")
    let l:InplacePastePos = getpos('.')
    let l:startPos = getpos('.')
    if a:type ==# "n"
        if v:count
            for l:i in range(v:count - 1)
                silent execute "normal! p"
            endfor
        else
            silent execute "normal! p"
        endif
    else
        silent execute "normal! gv" . a:direction
    endif
    normal! `[mP
    normal! `]mp
    silent call cursor(l:InplacePastePos[1], l:InplacePastePos[2])
    match Search #\%'P.*\(\_s.*\)*\%'p.#
    silent call <SID>ClearYPHighlight(1)
endfunction


" InplaceCopy {{{
function! InplaceCopy(type, ...)
    let g:copyFilePath = expand("%:p")
    if a:type ==# "char"
        silent execute "normal! `[v`]y"
    elseif a:type ==# "line"
        silent execute "normal! `[V`]y"
    else
        silent execute "normal! gvy"
    endif
    normal! `[mY
    normal! `]my
    silent call cursor(g:inplaceCopyCurStart[1], g:inplaceCopyCurStart[2])
    2match Search #\%'Y.*\(\_s.*\)*\%'y.#
    silent call <SID>ClearYPHighlight(2)
endfunction

function! SetInplaceCopy()
    let g:inplaceCopyCurStart = getpos('.')
    set opfunc=InplaceCopy
    silent return 'g@'
endfunction
" }}} InplaceCopy

function! s:ClearYPHighlight(priority)
    if a:priority == 1
        let l:timer = timer_start(1000, "ClearPutHighlightHandler")
    elseif a:priority == 2
        let l:timer = timer_start(1000, "ClearYankHighlightHandler")
    endif
endfunction

function! ClearYankHighlightHandler(timer)
    2match none
endfunction

function! ClearPutHighlightHandler(timer)
    match none
endfunction

function! InplaceDisableVisual()
    normal! gv
    execute "normal! \<esc>"
endfunction

function! LastYPHighlight(key)
    let l:pos = getpos('.')
    if a:key == "yank"
        if expand("%:p") !=# g:yankFilePath
            return
        endif
        let l:Start = getpos("'Y")
        let l:End = getpos("'y")
    elseif a:key == "put"
        if expand("%:p") !=# g:putFilePath
            return
        endif
        let l:Start = getpos("'P")
        let l:End = getpos("'p")
    endif
    if abs(l:pos[1] - l:Start[1]) < abs(l:pos[1] - l:End[1])
        call cursor(l:End[1], l:End[2])
        normal! v
        call cursor(l:Start[1], l:Start[2])
    else
        call cursor(l:Start[1], l:Start[2])
        normal! v
        call cursor(l:End[1], l:End[2])
    endif
endfunction
