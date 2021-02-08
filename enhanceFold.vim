" File: enhanceFold.vim
" Author: iaso2h
" Description: Enhnace origin fold feature, mainly focus on markder fold method
" Version: 0.0.4
" TODO: Better [z and [Z algorithm
" Last Modified: 2021-02-08
" Initiation {{{
function! s:EnhanceFoldInit()
    " Initiate only once
    if exists("g:enhanceFoldInit")  && g:enhanceFoldInit | return 0 | endif
    let g:enhanceFoldInit = 1
    let g:enhanceFoldStartHLID = 9138
    let g:enhanceFoldEndHLID = 9139
    let g:enhanceFoldPriority = get(g:, "enhanceFoldPriority", 30)
    let s:enhanceFoldStartPat = {
                \ "vim": "\\s\\{-}\"[^\"]\\{-}{{{[^\"]*$",
                \ "c": "\\s\\{-}/[^/]\\{-}{{{[^/]*$",
                \ }
    let s:enhanceFoldEndPat = {
                \ "vim": "\\s\\{-}\"[^\"]\\{-}}}}[^\"]*$",
                \ "c": "\\s\\{-}/[^/]\\{-}}}}[^/]*$",
                \ }
endfunction
call <SID>EnhanceFoldInit()
" }}} Initiation

function! EnhanceFoldExpr() " {{{
    let l:line = getline(v:lnum)
    if match(l:line, s:enhanceFoldStartPat[&filetype]) > -1
        return "a1"
    elseif match(l:line, s:enhanceFoldEndPat[&filetype]) > -1
        return "s1"
    else
        return "="
    endif
endfunction " }}}

function! EnhanceFold(modeType, ...) " {{{
    let l:saveCursor = getpos('.')
    if a:modeType ==# "n"
        execute "normal! A " . g:FiletypeCommentDelimiter[&filetype] . " " . a:1
    elseif a:modeType ==# "v" || a:modeType ==# "V"
        let l:selectStart = getpos("'<")
        let l:selectEnd = getpos("'>")
        if l:selectEnd[1] == l:selectStart[1]
            return 0
        else
            call cursor(l:selectStart[1], 0)
            execute "normal! g_a " . g:FiletypeCommentDelimiter[&filetype] . " {{{"
            call cursor(l:selectEnd[1], 0)
            execute "normal! g_a " . g:FiletypeCommentDelimiter[&filetype] . " }}}"
            call cursor (l:saveCursor[1], l:saveCursor[2])
            if &foldexpr == "EnhanceFoldExpr()"
                set foldexpr=EnhanceFoldExpr()
            endif
        endif
    endif
endfunction " }}}

function! EnhanceFoldJump(direction, showWarning, returnVar) " {{{
    " direction: start/end
    " showWarning: 0/1
    " returnVar: 0/1
    let l:cmd = a:direction=="start" ? "[z" : "]z"
    let l:saveView = winsaveview()
    let l:cursorPos = getpos(".")
    let l:lastFoldPos = l:cursorPos
    " Get fold position
    execute "keepjumps normal! " . l:cmd
    while 1
        let l:foldPos = getpos(".")
        let l:foldPosLine = getline('.')
        " Parsing pattern
        if a:direction == "start"
            let l:matchPos = matchstrpos(l:foldPosLine, s:enhanceFoldStartPat[&filetype])
        else
            let l:matchPos = matchstrpos(l:foldPosLine, s:enhanceFoldEndPat[&filetype])
        endif
        if l:matchPos[0] != ""
            let s:lineComment = l:matchPos[1] == 0
            let s:lineCommentIdent = l:matchPos[0][0] == " " || l:matchPos[0][0] == '\t' ? 1 : 0
            break
        endif
        " Check inside foldermarker scope
        if l:foldPos == l:lastFoldPos
            if a:showWarning == 1 | echohl WarningMsg | echo "Not inside fold scope" | echohl None | endif
            " call cursor(l:cursorPos[1], l:cursorPos[2])
            call winrestview(l:saveView)
            return [0]
        else
            let l:lastFoldPos = l:foldPos
            execute "keepjumps normal! " . l:cmd
        endif
    endwhile
    " Make jump location when a:returnVar is 0
    if !a:returnVar
        normal! mz`z
    endif

    return a:returnVar == 1 ? [1, l:foldPos, l:matchPos] : [1]
endfunction " }}}


function! EnhanceFoldHL(warningMsg, time, funcName) " {{{
    " a:warningMsg ""
    " a:time time of executing timer_start and the appending funcName
    " a:returnVar 0/1
    let l:saveView = winsaveview()
    " Fold marker info
    let l:validStartFoldPos = EnhanceFoldJump("start", 0, 1)
    " Check valid fold position
    if !l:validStartFoldPos[0]
        if a:warningMsg != "" | echohl WarningMsg | echo a:warningMsg | echohl None | endif
        return 0
    endif
    let l:foldStartPos = l:validStartFoldPos[1]
    let l:foldStartMatchPos = l:validStartFoldPos[2]
    let l:validEndFoldPos = EnhanceFoldJump("end", 0, 1)
    let l:foldEndPos= l:validEndFoldPos[1]
    let l:foldEndMatchPos = l:validEndFoldPos[2]
    let s:winID = win_getid()
    if !exists("g:enhanceFoldHLMatch")
        let g:enhanceFoldHLMatch = {}
        let g:enhanceFoldHLMatch[s:winID] = []
    else
        if !exists("g:enhanceFoldHLMatch[s:winID]")
            let g:enhanceFoldHLMatch[s:winID] = []
        else
            " Clear highligh before create highlight
            call EnhanceFoldRemoveHLMatch(a:time)
        endif
    endif
    " Create Highlight {{{
    let l:foldStartMatchAdd = 0
    let l:foldEndMatchAdd = 0
    let s:foldStartDict = {
        \ "matchID" : g:enhanceFoldStartHLID,
        \ "foldPos" : l:foldStartPos,
        \ "matchPos" : l:foldStartMatchPos,
        \ "matchAddCheck" : l:foldStartMatchAdd,
    \ }
    let s:foldEndDict = {
        \ "matchID" : g:enhanceFoldEndHLID,
        \ "foldPos" : l:foldEndPos,
        \ "matchPos" : l:foldEndMatchPos,
        \ "matchAddCheck" : l:foldEndMatchAdd,
    \ }
    for i in [s:foldStartDict, s:foldEndDict]
        try
            let l:matchID = matchaddpos(
                \ "Search" ,
                \ [[i["foldPos"][1], i["matchPos"][1] + 1, i["matchPos"][2] - i["matchPos"][1] + 1]] ,
                \ g:enhanceFoldPriority, i["matchID"])
            call add(g:enhanceFoldHLMatch[s:winID], l:matchID)
            let i["matchAddCheck"] = 1
        finally
            " If failed, let VimL deside which ID to use
            " When ID added successfully, don't execute it"
            if !i["matchAddCheck"]
                let l:matchID = matchaddpos(
                    \ "Search" ,
                    \ [[i["foldPos"][1], i["matchPos"][1] + 1, i["matchPos"][2] - i["matchPos"][1] + 1]] ,
                    \ g:enhanceFoldPriority)
                call add(g:enhanceFoldHLMatch[s:winID], l:matchID)
                let i["matchID"] = l:matchID
            endif
        endtry
        " }}} Create Highlight
    endfor

    " Restore view
    call winrestview(l:saveView)
    " Auto clear Highlight when a:time > 0
    if a:time | call timer_start(a:time, "EnhanceFoldRemoveHLMatch") | endif
    " Execute appending function
    if a:funcName != ""
        call timer_start(a:time, a:funcName)
        return 0
    endif
endfunction " }}}

function! EnhanceFoldRemoveHLMatch(...) " {{{
    while exists("g:enhanceFoldHLMatch[s:winID]") && g:enhanceFoldHLMatch[s:winID] != []
        if CompareNeovimVersion("0.5.0", "<=")
            call matchdelete(remove(g:enhanceFoldHLMatch[s:winID], 0), s:winID)
        else
            call matchdelete(remove(g:enhanceFoldHLMatch[s:winID], 0))
        endif
    endwhile
endfunction " }}}

function! EnhanceDelete(...) abort " {{{
    " Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
    " }}} Fold marker info

    if s:lineComment == 1
        " Delete fold start
        execute printf("%ds#%s##g", l:foldStartPos[1], s:enhanceFoldStartPat[&filetype])
        let l:saveUnnamedReg = @@ | d
        let l:foldEndPos[1] -= 1
        let l:saveView["lnum"] -= 1
        " Delete fold end
        execute printf("%ds#%s##g", l:foldEndPos[1], s:enhanceFoldEndPat[&filetype])
        " Delete empty line
        if s:lineComment == 1 | d | endif
    else
        execute printf("%ds#%s##g", l:foldStartPos[1], s:enhanceFoldStartPat[&filetype])
        execute printf("%ds#%s##g", l:foldEndPos[1], s:enhanceFoldEndPat[&filetype])
    endif
    " Resotre
    call winrestview(l:saveView)
    if exists("l:saveUnnamedReg") | let @@ = l:saveUnnamedReg | endif
endfunction " }}}

function! EnhanceChange(...) abort " {{{
    " Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
    " }}} Fold marker info

    echohl Moremsg
    let l:newFoldMakrerName = input("New fold marder name: ")
    if l:newFoldMakrerName == ""
        echohl WarningMsg | echo " " | echo "Cancel" | echohl None
        call winrestview(l:saveView)
        return 0
    else
        if s:lineComment == 1
            let l:newFoldStart = printf("%s %s {{{", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
            let l:newFoldEnd = printf("%s }}} %s", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
        else
            let l:newFoldStart = printf(" %s %s {{{", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
            let l:newFoldEnd = printf(" %s }}} %s", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
        endif
    endif
    echohl None
    " Clear highlight
    call EnhanceFoldRemoveHLMatch()
    " Change fold markder name
    execute printf("%ds#%s#%s#g", l:foldStartPos[1], s:enhanceFoldStartPat[&filetype], l:newFoldStart)
    execute printf("%ds#%s#%s#g", l:foldEndPos[1], s:enhanceFoldEndPat[&filetype], l:newFoldEnd)
    " Reindent new comment line
    if s:lineCommentIdent
        call cursor(l:foldStartPos[1], l:foldStartPos[2])
        normal! ==
        call cursor(l:foldEndPos[1], l:foldEndPos[2])
        normal! ==
    endif
    " Resotre
    if exists("l:saveUnnamedReg") | let @@ = l:saveUnnamedReg | endif
    call winrestview(l:saveView)
endfunction " }}}
