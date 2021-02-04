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

" InplaceUlti {{{
" InplaceCopy {{{
function! InplaceCopy(type, ...)
    let s:yankFilePath = expand("%:p")
    if a:type ==# "char"
        normal! `[v`]y
    elseif a:type ==# "line"
        normal! `[V`]y
    else
        normal! gvy
    endif
    normal! `[mY
    normal! `]my
    call cursor(s:startPos[1], s:startPos[2])
    " Create highlight {{{
    " Clear previous HL before creating new HL
    if get(s:YPRHLIDDict, s:yankWinID, 0)
        call ClearPutHL(500)
    endif
    let s:YPRHLIDDict[s:yankWinID] = 9135
    call matchadd("Search", "\\%'Y.*\\(\\_s.*\\)*\\%'y.", 50, 9135)
    let l:timer = timer_start(500, "ClearYankHL")
    " }}} Create highlight
endfunction

function! SetInplaceCopy()
    if !type(get(s:, "YPRHLIDDict", 0))
        let s:YPRHLIDDict = {}
    endif
    let s:yankWinID = win_getid()
    let s:startPos = getpos('.')
    set opfunc=InplaceCopy
    silent return 'g@'
endfunction
" }}} InplaceCopy

function! InplacePaste(typeMode, pasteCMD) "  {{{
    if !type(get(s:, "YPRHLIDDict", 0))
        let s:YPRHLIDDict = {}
    endif
    let s:putWinID = win_getid()
    let s:putFilePath = expand("%:p")
    let l:startPos = getpos('.')
    let l:curLine = getline('.')
    let l:regType = getregtype(v:register)
    " Execute cmd {{{
    if a:typeMode ==# "n"
        if v:count
            for l:i in range(v:count - 1)
                execute "normal! \"" . v:register . a:pasteCMD
            endfor
        else
            execute "normal! \"" . v:register . a:pasteCMD
        endif
    else
        execute "normal! gv\"" . v:register . a:pasteCMD
    endif
    " }}} Execute cmd
    " Formatting 1 line long content and 'V' mode, then get position info {{{
    if l:regType ==# "V"
        normal! `[V`]=
        normal! `[0mP
        normal! `]g$mp
    elseif l:regType ==# "v"
        " New paste content is a single line
        let l:match = matchstr(l:curLine, '\S')
        call cursor(l:startPos[1], l:startPos[2])
        if l:match == ""
            normal! ==
            normal! ^mP
            normal! g_mp
        else
            normal! `[mP
            normal! `]mp
        endif
    else
        normal! `[mP
        normal! `]mp
    endif
    " }}} Formatting line long content and 'V' mode, then get position info
    " Restore position
    if a:pasteCMD ==# "P"
        if l:regType !=# "V"
            keepjumps normal! `]l
        else
            let l:putEndPos = getpos(".")
            call cursor(l:putEndPos[1] + 1, l:startPos[2])
        endif
    else
        call cursor(l:startPos[1], l:startPos[2])
    endif
    " Create highlight {{{
    " Clear previous HL before creating new HL
    if get(s:YPRHLIDDict, s:putWinID, 0)
        call ClearPutHL(500)
    endif
    let s:YPRHLIDDict[s:putWinID] = 9134
    call matchadd("Search", "\\%'P.*\\(\\_s.*\\)*\\%'p.", 50, 9134)
    let l:timer = timer_start(500, "ClearPutHL")
    " }}} Create highlight
endfunction "  }}}

" YPHighlight {{{
function! ClearYankHL(timer, ...)
    if get(s:YPRHLIDDict, s:yankWinID, 0)
        if has("win32")
            call matchdelete(s:YPRHLIDDict[s:yankWinID], s:yankWinID)
        else
            call matchdelete(s:YPRHLIDDict[s:yankWinID])
        endif
        let s:YPRHLIDDict[s:yankWinID] = 0
    endif
endfunction

function! ClearPutHL(timer, ...)
    if get(s:YPRHLIDDict, s:putWinID, 0)
        if has("win32")
            call matchdelete(s:YPRHLIDDict[s:putWinID], s:putWinID)
        else
            call matchdelete(s:YPRHLIDDict[s:putWinID])
        endif
        let s:YPRHLIDDict[s:putWinID] = 0
    endif
endfunction

function! LastYPHL(key)
    let l:pos = getpos('.')
    normal! mz`z
    if a:key == "yank"
        if expand("%:p") !=# s:yankFilePath
            return
        endif
        let l:Start = getpos("'Y")
        let l:End = getpos("'y")
    elseif a:key == "put"
        if expand("%:p") !=# s:putFilePath
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
    normal! gv
    execute "normal! \<esc>"
endfunction " }}}

" InplaceReplace {{{
" TODO need fix load after ReplaceWithRegister plugin
" if !exists('g:loaded_ReplaceWithRegister')
    " finish
" endif

function! InplaceReplace(type, ...)
    let s:yankFilePath = expand("%:p")
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
    call <SID>ClearYPHL(1)
endfunction

function! SetInplaceReplace()
    let l:InplacePasteStart = getpos('.')
    set opfunc=InplaceReplace
    silent return 'g@'
endfunction
" }}} InplaceReplace
" }}} InplaceUlti

function! g:ConvertPaste(pasteCMD) "  {{{
    if !type(get(s:, "YPRHLIDDict", 0))
        let s:YPRHLIDDict = {}
    endif
    let s:putFilePath = expand("%:p")
    let l:startPos = getpos(".")
    let l:regType = getregtype(v:register)
    let l:saveRegContent = getreg(v:register)
    let l:curLine = getline('.')

    if l:regType ==# "v" || l:regType ==# "c"
        call setreg(v:register, l:saveRegContent, "V")
    elseif l:regType ==# "V" || l:regType ==# "l"
        let l:formatRegContent = substitute(l:saveRegContent, "\\n\\|\\(\\s\\{2,}\\(\\S.*\\S\\)\\@=\\)", "", "ge")
        call setreg(v:register, l:formatRegContent, "v")
    else
        return
    endif
    if v:count
        for l:i in range(v:count - 1)
            execute "normal \"" . v:register . a:pasteCMD
        endfor
    else
        execute "normal \"". v:register . a:pasteCMD
    endif
    if l:regType ==# "V"
        " New paste content is a single line
        let l:match = matchstr(l:curLine, '\S')
        if l:match == ""
            " Formatting 1 line long content
            normal! ==
            normal! ^mP
            normal! g_mp
        else
            normal! `[mP
            normal! `]mp
        endif
        " Restore position
        if a:pasteCMD ==# "P"
            keepjumps normal! `]l
        else
            call cursor(l:startPos[1], l:startPos[2])
        endif
    else
        normal! `[mP
        normal! `]mp
        " Restore position
        if a:pasteCMD ==# "P"
            let l:putEndPos = getpos(".")
            call cursor(l:putEndPos[1] + 1, l:startPos[2])
        else
            call cursor(l:startPos[1], l:startPos[2])
        endif
    endif

    " Create highlight {{{
    " Clear previous HL before creating new HL
    if get(s:YPRHLIDDict, s:putWinID, 0)
        call ClearPutHL(500)
    endif
    let s:YPRHLIDDict[s:putWinID] = 9134
    call matchadd("Search", "\\%'P.*\\(\\_s.*\\)*\\%'p.", 50, 9134)
    let l:timer = timer_start(500, "ClearPutHL")
    " }}} Create highlight
    " Restore
    call setreg(v:register, getreg(v:register), l:regType)
endfunction "  }}}
