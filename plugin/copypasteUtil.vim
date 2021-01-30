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

" InplacePaste {{{
function! InplacePaste(type, direction)
    let g:putFilePath = expand("%:p")
    let l:InplacePasteStart = getpos('.')
    let l:startPos = getpos('.')
    if a:type ==# "n"
        if v:count
            for l:i in range(v:count - 1)
                execute "normal! \"" . v:register . a:direction
            endfor
        else
            execute "normal! \"" . v:register . a:direction
        endif
    else
        execute "normal! gv\"" . v:register . a:direction
    endif
    normal! `[mP
    normal! `]mp
    " Formatting 1 line long content
    if getpos("'P")[1] == getpos("'p")[1] && a:type ==# "V"
        normal! ==
        normal! ^mP
        normal! g_mp
    endif
    call cursor(l:InplacePasteStart[1], l:InplacePasteStart[2])
    match Search #\%'P.*\(\_s.*\)*\%'p.#
    call <SID>ClearYPHighlight(1)
endfunction
" }}} InplacePaste

" InplaceCopy {{{
function! InplaceCopy(type, ...)
    let g:yankFilePath = expand("%:p")
    if a:type ==# "char"
        normal! `[v`]y
    elseif a:type ==# "line"
        normal! `[V`]y
    else
        normal! gvy
    endif
    normal! `[mY
    normal! `]my
    call cursor(g:inplaceCopyCurStart[1], g:inplaceCopyCurStart[2])
    2match Search #\%'Y.*\(\_s.*\)*\%'y.#
    call <SID>ClearYPHighlight(2)
endfunction

function! SetInplaceCopy()
    let g:inplaceCopyCurStart = getpos('.')
    set opfunc=InplaceCopy
    silent return 'g@'
endfunction
" }}} InplaceCopy

" YPHighlight {{{
function! s:ClearYPHighlight(priority)
    if a:priority == 1
        let l:timer = timer_start(500, "ClearPutHighlightHandler")
    elseif a:priority == 2
        let l:timer = timer_start(500, "ClearYankHighlightHandler")
    endif
endfunction

function! ClearYankHighlightHandler(timer)
    let l:currentWin = nvim_get_current_win()
    windo 2match none
    if l:currentWin != nvim_get_current_win()
        call nvim_set_current_win(l:currentWin)
    endif
endfunction

function! ClearPutHighlightHandler(timer)
    let l:currentWin = nvim_get_current_win()
    windo match none
    if l:currentWin != nvim_get_current_win()
        call nvim_set_current_win(l:currentWin)
    endif
endfunction

function! LastYPHighlight(key)
    let l:pos = getpos('.')
    normal! mz`z
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
" }}} YPHighlight

function! InplaceDisableVisual() " {{{
    execute "normal! \<esc>"
endfunction " }}}


" InplaceReplace {{{
if !exists('g:loaded_ReplaceWithRegister')
    finish
endif
function! InplaceReplace(type, ...)
    let g:yankFilePath = expand("%:p")
    if a:type ==# "char"
        call ReplaceWithRegister#OperatorExpression()
    else
        <C-u>call setline('.', getline('.'))<Bar>
        \execute 'silent! call repeat#setreg("\<lt>Plug>ReplaceWithRegisterVisual", v:register)'<Bar>
        \call ReplaceWithRegister#SetRegister()<Bar>
        \if ReplaceWithRegister#IsExprReg()<Bar>
        \    let g:ReplaceWithRegister#expr = getreg('=')<Bar>
        \endif<Bar>
        \call ReplaceWithRegister#Operator('visual', "\<lt>Plug>ReplaceWithRegisterVisual")<CR>    endif
    endif
    normal! `[mP
    normal! `]mP
    call cursor(g:InplacePasteStart[1], g:InplacePasteStart[2])
    match Search #\%'P.*\(\_s.*\)*\%'p.#
    call <SID>ClearYPHighlight(1)
endfunction

function! SetInplaceReplace()
    let l:InplacePasteStart = getpos('.')
    set opfunc=InplaceReplace
    silent return 'g@'
endfunction
" }}} InplaceReplace

