" File: enhanceFold.vim
" Author: iaso2h
" Description: Enhnace origin fold feature, mainly focus on markder fold method
" Version: 0.0.6
" TODO: Better [z and [Z algorithm
" Last Modified: 2021-02-09
" Initiation {{{
let g:enhanceFoldInit = 1
let g:enhanceFoldStartHLID = 9138
let g:enhanceFoldEndHLID = 9139
let g:enhanceFoldPriority = get(g:, "enhanceFoldPriority", 30)
" }}} Initiation

""
" Function: EnhanceFold
"
" @param modeType: n/v/V standards for normal mode, visual characterwise mode,
" visual linewise mode
" @param ...:      When in normal mode, character need provided to be appended at the end of line, but other mode doesn't
" Returns: 0
""
function! HighlightComment()
    let l:delimiterPosList = MatchAll(getline("."), '"')
endfunction

function! EnhanceFold(modeType, ...) " {{{
    let l:saveCursor = getpos('.')
    let l:curLine = getline(".")
    if a:modeType ==# "n"
        if &filetype == "vim"
            let l:delimiterPosList = MatchAll(getline("."), '"')
            if len(l:delimiterPosList) % 2 != 0
                execute "normal! A " . a:1
            else
                execute "normal! A " . "\" " . a:1
            endif
        else
            execute "normal! A " . g:FiletypeCommentDelimiter[&filetype] . " " . a:1
        endif
    elseif a:modeType ==# "v" || a:modeType ==# "V"
        let l:selectStart = getpos("'<")
        let l:selectEnd = getpos("'>")
        if l:selectEnd[1] == l:selectStart[1]
            return 0
        else
            if &filetype == "vim"
                let l:delimiterPosList = MatchAll(getline("."), '"')
                if len(l:delimiterPosList) % 2 != 0
                    call cursor(l:selectStart[1], 0)
                    execute "normal! g_a " . "{{{"
                    call cursor(l:selectEnd[1], 0)
                    execute "normal! g_a " . "}}}"
                    call cursor (l:saveCursor[1], l:saveCursor[2])
                else
                    call cursor(l:selectStart[1], 0)
                    execute "normal! g_a " . "\" {{{"
                    call cursor(l:selectEnd[1], 0)
                    execute "normal! g_a " . "\" }}}"
                    call cursor (l:saveCursor[1], l:saveCursor[2])
                endif
            else
                call cursor(l:selectStart[1], 0)
                execute "normal! g_a " . g:FiletypeCommentDelimiter[&filetype] . " {{{"
                call cursor(l:selectEnd[1], 0)
                execute "normal! g_a " . g:FiletypeCommentDelimiter[&filetype] . " }}}"
                call cursor (l:saveCursor[1], l:saveCursor[2])
            endif
        endif
    endif
endfunction " }}}

""
" Function: EnhanceFoldJump: Jump to previous/next fold location inclusively
"
" @param direction:   Possible value "previous", "next"
" @param showWarning: Possible value 0, 1. Whether to show warnning message
" when not inside fold scope
" @param returnVar:   Possbile value 0, 1. Whether to return verbose list when execute successfully
" Returns: return [1, l:foldPos, l:matchPos] when a:returnVar is set to 1, otherwise return [1] when succeeded, return [0] when failed
""
function! EnhanceFoldJump(direction, showWarning, returnVar) " {{{
    if a:direction == "previous"
        let l:cmd = "[z"
    elseif a:direction == "next"
        let l:cmd = "]z"
    endif
    let l:saveView = winsaveview()
    let l:cursorPos = getpos(".")
    let l:lastFoldPos = l:cursorPos
    " Get fold position
    execute "keepjumps normal! " . l:cmd
    while 1
        let l:foldPos = getpos(".")
        let l:foldPosLine = getline('.')
        " Parsing pattern
        if a:direction == "previous"
            let l:matchPos = matchstrpos(l:foldPosLine, g:enhanceFoldStartPat[&filetype])
        elseif a:direction == "next"
            let l:matchPos = matchstrpos(l:foldPosLine, g:enhanceFoldEndPat[&filetype])
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


""
" Function: EnhanceFoldHL Enhence Fold Highlight Light, highlight
" previous/next fold when cursor within the fold scope
"
" @param warningMsg: string value to show when fold scope not found, provided
" empty string wont't show message when fold scope not found
" @param time:       milisecond to start the EnhanceFoldRemoveHLMatch() and
" the appending function
" @param funcName:   function name in a string value, this function will be
" invoke with the EnhanceFoldRemoveHLMatch() function when reaching a:time if
" provide
" Returns: 0
""
function! EnhanceFoldHL(warningMsg, time, funcName) " {{{
    let l:saveView = winsaveview()
    " Fold marker info
    let l:validStartFoldPos = EnhanceFoldJump("previous", 0, 1)
    " Check valid fold position
    if !l:validStartFoldPos[0]
        if a:warningMsg != "" | echohl WarningMsg | echo a:warningMsg | echohl None | endif
        return 0
    endif
    let l:foldStartPos = l:validStartFoldPos[1]
    let l:foldStartMatchPos = l:validStartFoldPos[2]
    let l:validEndFoldPos = EnhanceFoldJump("next", 0, 1)
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
        execute printf("%ds#%s##g", l:foldStartPos[1], g:enhanceFoldStartPat[&filetype])
        let l:saveUnnamedReg = @@ | d
        let l:foldEndPos[1] -= 1
        let l:saveView["lnum"] -= 1
        " Delete fold end
        execute printf("%ds#%s##g", l:foldEndPos[1], g:enhanceFoldEndPat[&filetype])
        " Delete empty line
        if s:lineComment == 1 | d | endif
    else
        execute printf("%ds#%s##g", l:foldStartPos[1], g:enhanceFoldStartPat[&filetype])
        execute printf("%ds#%s##g", l:foldEndPos[1], g:enhanceFoldEndPat[&filetype])
    endif
    " Resotre
    call winrestview(l:saveView)
    if exists("l:saveUnnamedReg") | let @@ = l:saveUnnamedReg | endif
endfunction " }}}

function! EnhanceChange(...) abort " {{{
    "TODO : " Mode - Commandline " Commandline & Insert {{{ Insert {{{
    " Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
    " }}} Fold marker info

    echohl Moremsg
    let l:newFoldMakrerName = input("New fold marder name: ")
    if empty(l:newFoldMakrerName)
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
    execute printf("%ds#%s#%s#g", l:foldStartPos[1], g:enhanceFoldStartPat[&filetype], l:newFoldStart)
    execute printf("%ds#%s#%s#g", l:foldEndPos[1], g:enhanceFoldEndPat[&filetype], l:newFoldEnd)
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

