" VSCode copy line {{{
function! VSCodeLineCopy(modeType, direction)
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
        if a:direction ==# "up"
            normal! yP
            if l:selectDirection ==# "up"
                call cursor(l:rowEnd, 0)
                normal! V
                call cursor(l:row, l:col)
            else
                normal! V
                call cursor(l:rowEnd, l:col)
            endif
        elseif a:direction ==# "down"
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
    elseif a:modeType ==# "v"
        normal! gv
        let saved_reg = @@
        let l:cursor = getpos(".")
        let l:selectStart = getpos("'<")
        let l:selectEnd = getpos("'>")
        execute printf("%d,%dyank", l:selectStart[1],l:selectEnd[1])
        if a:direction ==# "up"
            if l:cursor == l:selectStart
                put!
                call setpos(".", l:selectEnd)
                normal! v
                call setpos(".", l:selectStart)
            else
                put
                call setpos(".", l:selectStart)
                normal! v
                call setpos(".", l:selectEnd)
            endif
        else
            let l:newSelectStart = deepcopy(l:selectStart)
            let l:newSelectEnd = deepcopy(l:selectEnd)
            let l:newSelectStart[1] = l:selectStart[1] + l:selectEnd[1] - l:selectStart[1] + 1
            let l:newSelectEnd[1] = l:selectEnd[1] + l:selectEnd[1] - l:selectStart[1] + 1
            if l:cursor == l:selectStart
                put!
                call setpos(".", l:newSelectEnd)
                normal! v
                call setpos(".", l:newSelectStart)
            else
                put
                call setpos(".", l:newSelectStart)
                normal! v
                call setpos(".", l:newSelectEnd)
            endif
        endif
        let @@ = saved_reg
    elseif a:modeType == "n"
        let saved_reg = @@
        let l:col = col(".")
        let l:row = line(".")
        if a:direction ==# "up"
            normal! yyP
            call cursor(l:row, l:col)
        elseif a:direction ==# "down"
            normal! yyp
            call cursor(l:row + 1, l:col)
        endif
        let @@ = saved_reg
    endif
endfunction
" }}} VSCode copy line

" InplaceUlti {{{
function! s:InplaceInit()
    " Initiate only once
    if exists("g:InplaceInit") && g:InplaceInit | return 0 | endif

    let g:InplaceInit = 1
    let g:InplaceYankHLID = get(g:, "InplaceYankHLID", 9134)
    let g:InplacePutHLID = get(g:, "InplacePutHLID", 9135)
    let g:InplacePriority = get(g:, "InplacePriority", 50)
endfunction
call <SID>InplaceInit()
" InplaceYank {{{
function! InplaceYank(type, ...)
    let s:yankFilePath = expand("%:p")
    let l:matchAdd = 0
    if a:type ==# "char"
        normal! g`[vg`]y
    elseif a:type ==# "line"
        normal! g`[Vg`]y
    else
        normal! gvy
    endif
    normal! g`[mY
    normal! g`]my
    call cursor(s:startPos[1], s:startPos[2])
    " Create highlight {{{
    " Skip specical buffers
    if &buftype != "" | return 0 | endif
    " Clear previous HL before creating new HL
    if exists("g:InplaceHLMatchID[s:yankWinID]") && g:InplaceHLMatchID[s:yankWinID] != []
        call ClearYankHL(500)
    else
        let g:InplaceHLMatchID[s:yankWinID] = []
    endif
    try
        let l:matchID = matchadd("Search",
                    \ "\\%'Y.*\\(\\_s.*\\)*\\%'y.",
                    \ g:InplacePriority,
                    \ g:InplaceYankHLID)
        let l:matchAdd = 1
        call add(g:InplaceHLMatchID[s:yankWinID], l:matchID)
        let l:timer = timer_start(500, "ClearYankHL")
    finally
        " If failed, let VimL deside which ID to use
        " When ID added successfully, don't execute it"
        if !l:matchAdd
            let l:matchID = matchadd("Search",
                        \ "\\%'Y.*\\(\\_s.*\\)*\\%'y.",
                        \ g:InplacePriority,
                        \ )
            let g:matchAdd = l:matchID
            call add(g:InplaceHLMatchID[s:yankWinID], l:matchID)
            let l:timer = timer_start(500, "ClearYankHL")
        endif
    endtry
    " }}} Create highlight
endfunction

function! SetInplaceYank()
    if !exists("g:InplaceHLMatchID")
        let g:InplaceHLMatchID = {}
    endif
    let s:yankWinID = win_getid()
    let s:startPos = getpos('.')
    set opfunc=InplaceYank
    silent return 'g@'
endfunction
" }}} InplaceYank

function! InplacePut(typeMode, pasteCMD) "  {{{
    if !exists("g:InplaceHLMatchID")
        let g:InplaceHLMatchID = {}
    endif
    let s:putWinID = win_getid()
    let s:putFilePath = expand("%:p")
    let l:startPos = getpos('.')
    let l:curLine = getline('.')
    let l:regType = getregtype(v:register)
    let l:matchAdd = 0
    " Execute cmd {{{
    if a:typeMode ==# "n"
        if v:count
            for l:i in range(v:count)
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
        normal! g`[Vg`]=
        normal! g`[0mP
        normal! g`]g$mp
    elseif l:regType ==# "v"
        " New paste content is a single line
        let l:match = matchstr(l:curLine, '\S')
        call cursor(l:startPos[1], l:startPos[2])
        if l:match == ""
            normal! ==
            keepjumps normal! ^mP
            keepjumps normal! g_mp
        else
            normal! g`[mP
            normal! g`]mp
        endif
    else
        normal! g`[mP
        normal! g`]mp
    endif
    " }}} Formatting line long content and 'V' mode, then get position info
    " Restore position
    if a:pasteCMD ==# "P"
        if l:regType !=# "V"
            normal! g`]l
        else
            let l:putEndPos = getpos(".")
            call cursor(l:putEndPos[1] + 1, l:startPos[2])
        endif
    else
        call cursor(l:startPos[1], l:startPos[2])
    endif
    " Create highlight {{{
    " Skip specical buffers
    if &buftype != "" | return 0 | endif
    " Clear previous HL before creating new HL
    if exists("g:InplaceHLMatchID[s:putWinID]") && g:InplaceHLMatchID[s:putWinID] != []
        call ClearPutHL(500)
    else
        let g:InplaceHLMatchID[s:putWinID] = []
    endif
    try
        let l:matchID = matchadd("Search",
                    \ "\\%'P.*\\(\\_s.*\\)*\\%'p.",
                    \ g:InplacePriority,
                    \ g:InplacePutHLID)
        let l:matchAdd = 1
        call add(g:InplaceHLMatchID[s:putWinID], l:matchID)
        let l:timer = timer_start(500, "ClearPutHL")
    finally
        " If failed, let VimL deside which ID to use
        " When ID added successfully, don't execute it"
        if !l:matchAdd
            let l:matchID = matchadd("Search",
                        \ "\\%'P.*\\(\\_s.*\\)*\\%'p.",
                        \ g:InplacePriority,
                        \ )
            let g:matchAdd = l:matchID
            call add(g:InplaceHLMatchID[s:putWinID], l:matchID)
            let l:timer = timer_start(500, "ClearPutHL")
        endif
    endtry
    " }}} Create highlight
endfunction "  }}}

" YPHighlight {{{
function! ClearYankHL(timer, ...)
    let l:indexID = index(g:InplaceHLMatchID[s:yankWinID], g:InplaceYankHLID)
    if l:indexID != -1
        if CompareNeovimVersion("0.5.0", "<=")
            call matchdelete(remove(g:InplaceHLMatchID[s:yankWinID], indexID), s:yankWinID)
        else
            call matchdelete(remove(g:InplaceHLMatchID[s:yankWinID], indexID))
        endif
    endif
endfunction

function! ClearPutHL(timer, ...)
    let l:indexID = index(g:InplaceHLMatchID[s:putWinID], g:InplacePutHLID)
    if l:indexID != -1
        if CompareNeovimVersion("0.5.0", "<=")
            call matchdelete(remove(g:InplaceHLMatchID[s:putWinID], indexID), s:putWinID)
        else
            call matchdelete(remove(g:InplaceHLMatchID[s:putWinID], indexID))
        endif
    endif
endfunction

function! HighlightLastYP(cmdType)
    let l:pos = getpos('.')
    " Create jump location in jumplist
    normal! mz`z
    if a:cmdType == "yank"
        if expand("%:p") !=# s:yankFilePath
            return
        endif
        let l:Start = getpos("'Y")
        let l:End = getpos("'y")
    elseif a:cmdType == "put"
        if expand("%:p") !=# s:putFilePath
            return
        endif
        let l:Start = getpos("'P")
        let l:End = getpos("'p")
    endif
    " Check valid position
    if l:Start == l:End
        echom l:Start
        echom l:End
        echohl WarningMsg | echo "No records found" | echohl
        return 0
    endif
    " Determine select directioin
    if abs(l:pos[1] - l:Start[1]) < abs(l:pos[1] - l:End[1])
        call cursor(l:End[1], l:End[2])
        normal! v
        call cursor(l:Start[1], l:Start[2])
    else
        call cursor(l:Start[1], l:Start[2])
        normal! v
        call cursor(l:End[1], l:End[2])
    endif

    return 0 " Since visual selection will always override any highlight match,
    " there is no point to execute more code
    " Create highlight {{{
    " Skip specical buffers
    if &buftype != "" | return 0 | endif
    let l:curWinID = win_getid()
    let l:matchPat = a:cmdType == "yank" ?
                \ "\\%'Y.*\\(\\_s.*\\)*\\%'y." :
                \ "\\%'P.*\\(\\_s.*\\)*\\%'p."
    let l:matchID = a:cmdType == "yank" ?
                \ g:InplaceYankHLID :
                \ g:InplacePutHLID
    let l:clearHLHandler = a:cmdType == "yank" ?
                \ "ClearYankHL" :
                \ "ClearPutHL"
    let l:matchAdd = 0
    " Clear previous HL before creating new HL
    if exists("g:InplaceHLMatchID[l:curWinID]") && g:InplaceHLMatchID[l:curWinID] != []
        call ClearYankHL(500)
    else
        let g:InplaceHLMatchID[l:curWinID] = []
    endif
    try
        let l:matchID = matchadd("Search",
                    \ l:matchPat,
                    \ g:InplacePriority,
                    \ l:matchID)
        let l:matchAdd = 1
        call add(g:InplaceHLMatchID[l:curWinID], l:matchID)
        let l:timer = timer_start(11500, l:clearHLHandler)
    finally
        " If failed, let VimL deside which ID to use
        " When ID added successfully, don't execute it"
        if !l:matchAdd
            let l:matchID = matchadd("Search",
                        \ l:matchPat,
                        \ g:InplacePriority,
                        \ )
            let g:matchAdd = l:matchID
            call add(g:InplaceHLMatchID[l:curWinID], l:matchID)
            let l:timer = timer_start(11500, l:clearHLHandler)
        endif
    endtry
    " }}} Create highlight
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
    normal! g`[mP
    normal! g`]mP
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

function! g:ConvertPut(pasteCMD) "  {{{
    if !type(get(s:, "YPRHLIDDict", 0))
        let g:InplaceHLMatchID = {}
    endif
    let s:putFilePath = expand("%:p")
    let l:startPos = getpos(".")
    let l:regType = getregtype(v:register)
    let l:saveRegContent = getreg(v:register)
    let l:curLine = getline('.')
    let l:matchAdd = 0

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
            keepjumps normal! ^mP
            keepjumps normal! g_mp
        else
            normal! g`[mP
            normal! g`]mp
        endif
        " Restore position
        if a:pasteCMD ==# "P"
            keepjumps normal! `]l
        else
            call cursor(l:startPos[1], l:startPos[2])
        endif
    else
        normal! g`[mP
        normal! g`]mp
        " Restore position
        if a:pasteCMD ==# "P"
            let l:putEndPos = getpos(".")
            call cursor(l:putEndPos[1] + 1, l:startPos[2])
        else
            call cursor(l:startPos[1], l:startPos[2])
        endif
    endif

    " Create highlight {{{
    " Skip specical buffers
    if &buftype != "" | return 0 | endif
    " Clear previous HL before creating new HL
    if exists("g:InplaceHLMatchID[s:putWinID]") && g:InplaceHLMatchID[s:putWinID] != []
        call ClearPutHL(500)
    else
        let g:InplaceHLMatchID[s:putWinID] = []
    endif
    try
        let l:matchID = matchadd("Search",
                    \ "\\%'P.*\\(\\_s.*\\)*\\%'p.",
                    \ g:InplacePriority,
                    \ g:InplacePutHLID)
        let l:matchAdd = 1
        call add(g:InplaceHLMatchID[s:putWinID], l:matchID)
        let l:timer = timer_start(500, "ClearPutHL")
    finally
        " If failed, let VimL deside which ID to use
        " When ID added successfully, don't execute it"
        if !l:matchAdd
            let l:matchID = matchadd("Search",
                        \ "\\%'P.*\\(\\_s.*\\)*\\%'p.",
                        \ g:InplacePriority,
                        \ )
            let g:matchAdd = l:matchID
            call add(g:InplaceHLMatchID[s:putWinID], l:matchID)
            let l:timer = timer_start(500, "ClearPutHL")
        endif
    endtry
    " }}} Create highlight
    " Restore
    call setreg(v:register, getreg(v:register), l:regType)
endfunction "  }}}
