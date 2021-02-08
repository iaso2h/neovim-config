" File: CIOHighlight.vim
" Author: iaso2h
" Description: Highlight specific conversion keyword in c language function
"            like printf(), scanf()
"            HL stands for highlight, CIO stands for c language I/O
"            functions
" Last Modified: 2021-02-08
" Version: 0.0.6
" TODO String:
"
" for i in range(10) | silent! execute printf("noremap z%d :set foldlevel=%d<bar>echohl Moremsg<bar>echo 'Foldlevel set to: %d'<bar>echohl None<cr>", i, i, i) | endfor
" Initiation {{{
function! s:CIOInit()
    " Initiate only once
    if exists("g:CIOInit")  && g:CIOInit | return 0 | endif

    let g:CIOInit = 1
    let s:funckeywordDict = {
                \ "c": ["printf", "scanf", "sprintf"],
                \ "vim": ["printf"],
                \}
    let s:specDict = {
                \ "printf": ["\\(%\\w\\)\\|\\(%\\.\\d\\+\\w\\?\\f\\)"],
                \ "scanf": ["%\\w"],
                \ }
    let s:skipCharacters = {
                \ "printf": ["!@#$^<>()[]{}-=+\\|/?;'\",. "],
                \ "scanf": ["!@#$^<>()[]{}-=+\\|/?;'\",. "]
                \ }
    g:FiletypeCommentDelimiter[%filetype])
    let s:varPattern = "[A-Za-z&\"'*].*\\ze\\([,\s]\\)"
    let s:varPatternLast = "[A-Za-z&\"'*].*\\ze\\()\\+;\\?$\\)"
    let g:CIOHLMatch = {}
    execute printf("%ds#%s##g", l:foldStartPos[1], s:startPat)
    let g:CIOspecHLID = 9136
    let g:CIOvarHLID = 9137
    let g:CIOHLPriority = get(g:, "CIOHLPriority", 30)
    highlight! link CIOFunctionHighlight CocHighlightText
endfunction
call <SID>CIOInit()
" }}} Initiation

function! HLCIOFunc() " {{{
    " Parse all characters
    if !<SID>ParseChar() | call <SID>RemoveHLMatch() | return 0 | endif
    if !<SID>CIOSkipChar() | call <SID>RemoveHLMatch() | return 0 | endif
    " Get highlight offset count
    if !<SID>HLOffset() | call <SID>RemoveHLMatch() | return 0 | endif

    " Store highlight ID
    if !exists("g:CIOHLMatch[s:winID]")
        " No highlight created yet
        let g:CIOHLMatch[s:winID] = []
    else
        " Remove last highlight before creating new highlight
        call <SID>RemoveHLMatch()
    endif
    " Counts of specifiers and var not equal
    if s:offsetCount > s:lastValidOffset
        " Pattern not found, clear highlight
        call <SID>RemoveHLMatch()
        return 0
    else
        " Not larger than last valid offset
        call <SID>HLSpecs()
        call <SID>HLVars()
        return 0
    endif
endfunction " }}}

function s:ParseChar() " {{{
    " TODO Multi line support
    " TODO Nested function support
    " TODO alternative comment
    let s:winID = win_getid()
    let s:curLine = getline('.')
    let s:cursorPos = getpos('.')
    let s:cursorColIndex = s:cursorPos[2] - 1
    let s:foundFuncKeywordPat = ""
    let s:specIndexList = []
    "  Skip comment for performance
    let l:commentExist = matchstr(s:curLine, '^\s*' . g:FiletypeCommentDelimiter[&filetype])
    if l:commentExist != "" | return 0 | endif

    " Parse characters {{{
    for k in s:funckeywordDict[&filetype]
        let s:funcKeywordPos = matchstrpos(s:curLine, k)
        if s:funcKeywordPos[0] != ""
            let s:foundFuncKeywordPat = deepcopy(k)

            " Count conversion specifiers
            " NOTE MatchALLStrPos is from util.vim
            let s:specIndexList = MatchALLStrPos(s:curLine, s:specDict[s:foundFuncKeywordPat][0])
            " Check specifiers found
            if s:specIndexList == [] | return 0 | endif

            " Parse symbols and variable
            let s:charList = split(s:curLine, '\zs')
            let l:openParen = 0
            let l:closeParen = 0
            let l:singleQuote = 0
            let l:doubleQuote = 0
            let l:comma = 0
            let s:delimiterColNumList = []
            let l:charColNum = 0
            " commaIndexList
            for char in s:charList
                let l:charColNum += 1
                if char == "("
                    let l:openParen += 1
                elseif char == ")"
                    let l:closeParen += 1
                    if l:closeParen == l:openParen
                        call add(s:delimiterColNumList, l:charColNum)
                    endif
                elseif char == '"'
                    let l:doubleQuote += 1
                elseif char == "'"
                    let l:singleQuote += 1
                elseif char == ","
                    if (l:doubleQuote != 0 || l:singleQuote != 0) &&
                        \ l:doubleQuote % 2 == 0 && l:singleQuote % 2 == 0
                        let l:comma += 1
                        call add(s:delimiterColNumList, l:charColNum)
                    endif
                endif
            endfor
            " Check vars found
            if s:delimiterColNumList == [] | return 0 | endif
            " Check valid syntax
            if l:openParen == 0 || l:openParen != l:closeParen
                return 0
            else
                return 1
            endif
        endif
    endfor
    " }}} Parse characters

    " No function keyword found
    if s:foundFuncKeywordPat == "" | return 0 | endif
endfunction " }}}

function! s:CIOSkipChar() abort " {{{
    " Skip range for performance
    if s:cursorPos[2] < 2 || s:cursorPos[2] + 2 - 1 > len(s:charList)
        return 0
    endif
    " Skip characters for performance
    let l:curChar = s:charList[s:cursorPos[2] - 1]
    if matchstr(s:skipCharacters[s:foundFuncKeywordPat], l:curChar) != "" | return 0 | endif
    return 1
endfunction " }}}

function! s:RemoveHLMatch() " {{{
    while exists("g:CIOHLMatch[s:winID]") && g:CIOHLMatch[s:winID] != []
        call matchdelete(remove(g:CIOHLMatch[s:winID], 0), s:winID)
    endwhile
endfunction " }}}


function! s:HLOffset() " {{{
    let l:specIndexListLength = len(s:specIndexList)
    let l:delimiterColNumListLength = len(s:delimiterColNumList)
    let s:lastValidOffset = l:specIndexListLength < l:delimiterColNumListLength - 1 ?
                \ l:specIndexListLength - 1 : l:delimiterColNumListLength - 2
    let s:offsetCount = -1

    " Get offset number in keyword list for highlighting {{{
    if s:cursorColIndex < s:delimiterColNumList[0] - 1
        " Cursor is before the first comma, then highlight specifiers
        " Specifier offset count
        for i in range(l:specIndexListLength) " {{{
            if s:cursorColIndex < s:specIndexList[0][1]
                return 0
            elseif s:cursorColIndex >= s:specIndexList[-1][1]
                let s:offsetCount = l:specIndexListLength - 1
                break
            else
                " Inside current index matchstrpos
                if s:cursorColIndex >= s:specIndexList[i][1] &&
                            \ s:cursorColIndex < s:specIndexList[i][2]
                    let s:offsetCount = i
                    break
                " Not inside current index matchstrpos
                else
                    continue
                endif
            endif
        endfor " }}}

        " Not inside all indexes matchstrpos
        if s:offsetCount == -1 | return 0 | endif
    else
        " Cursor is after the first comman, then highlight vars
        " Var offset count
        for i in range(l:delimiterColNumListLength)
            if s:cursorColIndex >= s:delimiterColNumList[-1] - 1
                return 0
            elseif s:cursorColIndex > s:delimiterColNumList[-2] - 1 &&
                        \ s:cursorColIndex < s:delimiterColNumList[-1] - 1
                let s:offsetCount = l:delimiterColNumListLength - 2
                break
            else
                if s:cursorColIndex < s:delimiterColNumList[i] - 1
                    let s:offsetCount = i - 1
                    break
                endif
            endif
        endfor
    endif
    " }}} Get offset number in keyword list for highlighting


    return 1
endfunction " }}}

function! s:HLSpecs() " {{{
    " Position possibilities
    let l:specColNumStart = s:specIndexList[s:offsetCount][1]
    let l:specLength = s:specIndexList[s:offsetCount][2] - l:specColNumStart
    let l:matchAdd = 0

    try
        let l:matchID = matchaddpos(
            \ "CIOFunctionHighlight" ,
            \ [[s:cursorPos[1], l:specColNumStart + 1, l:specLength]] ,
            \ g:CIOHLPriority, g:CIOspecHLID)
        call add(g:CIOHLMatch[s:winID], l:matchID)
        let l:matchAdd = 1
        return 0 " Failed in VimL

    finally
        " If failed, let VimL deside which ID to use
        " When ID added successfully, don't execute it"
        if !l:matchAdd
            let l:matchID = matchaddpos(
                        \ "CIOFunctionHighlight" ,
                        \ [[s:cursorPos[1], l:specColNumStart + 1, l:specLength]] ,
                        \ g:CIOHLPriority)
            let g:CIOspecHLID = l:matchID
            call add(g:CIOHLMatch[s:winID], l:matchID)
        endif
    endtry
endfunction " }}}

function! s:HLVars() " {{{
    " eg:\%>23l\%<26l[^ ]*
    let l:varColNumStart = s:delimiterColNumList[s:offsetCount]
    let l:varColNumEnd= s:delimiterColNumList[s:offsetCount + 1]
    let l:matchAdd = 0
    " Use different regex pattern based on cursor position
    if s:lastValidOffset == s:offsetCount
        let l:matchPattern = s:varPatternLast
    else
        let l:matchPattern = s:varPattern
    endif

    try
        let l:matchID = matchadd(
            \ "CIOFunctionHighlight" ,
            \ "\\%".s:cursorPos[1]."l\\%>".l:varColNumStart."c\\%<".l:varColNumEnd."c".l:matchPattern ,
            \ g:CIOHLPriority, g:CIOvarHLID)
        call add(g:CIOHLMatch[s:winID], l:matchID)
        let l:matchAdd = 1
        return 0 " Failed in VimL

    finally
        " If failed, let VimL deside which ID to use
        " When ID added successfully, don't execute it"
        if !l:matchAdd
            let l:matchID = matchadd(
                \ "CIOFunctionHighlight" ,
                \ "\\%".s:cursorPos[1]."l\\%>".l:varColNumStart."c\\%<".l:varColNumEnd."c".l:matchPattern ,
                \ g:CIOHLPriority)
            let g:CIOvarHLID = l:matchID
            call add(g:CIOHLMatch[s:winID], l:matchID)
        endif
    endtry
endfunction " }}}
