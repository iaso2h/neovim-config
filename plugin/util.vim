function! CompareNeovimVersion(compareVersion, operator) " {{{
    if type(a:compareVersion) != 1 || type(a:operator) != 1
        echoerr("Arguments must be string")
        return -1
    endif
    if !exists("g:runningVersion") | let g:runningVersion = matchstr(execute('version'), '\d\.\d\.\d') | endif
    if g:runningVersion == "" | throw "Neovim version not found" | endif
    let l:compareVersion = matchstr(a:compareVersion, '\d\.\d\.\d')
    if l:compareVersion == "" || l:compareVersion != a:compareVersion | echoerr "format of version for comparision is not correct" | return -1 | endif
    " eg: l:compareVersion < l:runningVersion
    if a:operator == '<'
        if l:compareVersion[0] < g:runningVersion[0] &&
                    \ l:compareVersion[2] < g:runningVersion[2] &&
                    \ l:compareVersion[4] < g:runningVersion[4]
            return 1
        else
            return 0
        endif
    elseif a:operator == '>'
        if l:compareVersion[0] > g:runningVersion[0] &&
                    \ l:compareVersion[2] > g:runningVersion[2] &&
                    \ l:compareVersion[4] > g:runningVersion[4]
            return 1
        else
            return 0
        endif
    elseif a:operator == '<='
        if l:compareVersion[0] <= g:runningVersion[0] &&
                    \ l:compareVersion[2] <= g:runningVersion[2] &&
                    \ l:compareVersion[4] <= g:runningVersion[4]
            return 1
        else
            return 0
        endif
    elseif a:operator == '>='
        if l:compareVersion[0] >= g:runningVersion[0] &&
                    \ l:compareVersion[2] >= g:runningVersion[2] &&
                    \ l:compareVersion[4] >= g:runningVersion[4]
            return 1
        else
            return 0
        endif
    else
        echoerr "Unkown operator"
    endif
endfunction " }}}

function! VisualSelection(returnType) " {{{
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    endif

    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
                    \   [line_end, column_end, line_start, column_start]
    endif
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ['']
    endif
    if &selection ==# "exclusive"
        let column_end -= 1 "Needed to remove the last character to make it match the visual selction
    endif
    if visualmode() ==# "\<C-V>"
        for idx in range(len(lines))
            let lines[idx] = lines[idx][: column_end - 1]
            let lines[idx] = lines[idx][column_start - 1:]
        endfor
    else
        let lines[-1] = lines[-1][: column_end - 1]
        let lines[ 0] = lines[ 0][column_start - 1:]
    endif

    if a:returnType == "list"
        return lines
    elseif a:returnType == "string"
        return join(lines, "\n")
    endif
endfunction " }}}

" Match all item based on regex {{{
function! MatchAll(expr, pat)
    " Based on VimL match(), Always return a list
    let l:list = []
    let l:index = -1
    while 1
        let l:index = match(a:expr, a:pat, l:index + 1)
        if l:index == -1 | return l:list | endif
        call add(l:list, l:index)
    endwhile
endfunction

function! MatchALLStrPos(expr, pat)
    " Based on VimL matchstrpos(), Always return a list
    let l:list = []
    while 1
        if !exists("l:posList")
            let l:posList = matchstrpos(a:expr, a:pat, 0)
        else
            let l:posList = matchstrpos(a:expr, a:pat, l:posList[2])
        endif
        if l:posList[0] == "" | return l:list | endif
        call add(l:list, l:posList)
    endwhile
endfunction
" }}} Match all item based on regex

""
" Smart split {{{
" Function: SmartSplit Create a new split window based on the current window
" layout
"
" @param funcName:    string value of function name
" @param funcArgList: function argument list, can be empty
" @param bufnamePat:  Switch to window contain the buffer that match the
" pattern if that buffer is displayed in window
" @param noFileCheck: Set this value for the new window buffer setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
" Returns: 0
""
function SmartSplit(funcName, funcArgList, bufnamePat, noFileCheck)
    let s:width2height = 0.3678
    let s:height2width = 2.7188
    let s:screenWidth = &columns
    let s:screenHeight = &lines
    let l:winInfo = getwininfo()
    let s:curWinID = win_getid()
    let l:winCount = winnr("$")

    " Switch to window contain the buffer that match the
    " pattern if that buffer is displayed in window
    if !empty(a:bufnamePat) " {{{
        for dict in l:winInfo
            if bufname(winbufnr(dict["winid"])) =~ a:bufnamePat
                execute printf("%dwincmd w", dict["winnr"])
                startinsert
                return 0
            endif
        endfor
    endif " }}}

    let g:smartSplitLastBufNr = bufnr()
    if l:winCount == 1 " {{{
        if winwidth(0) <= winheight(0) * s:height2width
            call <SID>ToggleOnBelow(a:funcName, a:funcArgList, a:noFileCheck)
        else
            call <SID>ToggleOnRight(a:funcName, a:funcArgList, a:noFileCheck)
        endif " }}}
    elseif l:winCount == 2 " {{{
        if winheight(0) + 6 > s:screenHeight
            wincmd w
            call <SID>ToggleOnBelow(a:funcName, a:funcArgList, a:noFileCheck)
        else
            wincmd w
            call <SID>ToggleOnRight(a:funcName, a:funcArgList, a:noFileCheck)
        endif " }}}
    elseif l:winCount == 3 " {{{
        for dict in l:winInfo
            if dict['height'] + 6 > s:screenHeight || dict['width'] + 6 > s:screenWidth
                execute printf("%dwincmd w", dict["winnr"])
                break
            endif
        endfor

        if winheight(0) + 6 > s:screenHeight
            call <SID>ToggleOnBelow(a:funcName, a:funcArgList, a:noFileCheck)
        else
            call <SID>ToggleOnRight(a:funcName, a:funcArgList, a:noFileCheck)
        endif " }}}
    else
        only
        call <SID>ToggleOnRight(a:funcName, a:funcArgList, a:noFileCheck)
    endif
endfunction

function s:ToggleOnRight(funcName, funcArgList, noFileCheck)
    vnew
    if a:noFileCheck
        setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    endif
    execute "vertical resize " . (s:screenWidth - float2nr(winheight(0) * 0.618 * s:height2width))
    let l:Func = function(a:funcName, a:funcArgList)
    call l:Func()
endfunction

function s:ToggleOnBelow(funcName, funcArgList, noFileCheck)
    new
    if a:noFileCheck
        setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    endif
    execute "resize " . (s:screenHeight - float2nr(winwidth(0) * 0.618 * s:width2height))
    let l:Func = function(a:funcName, a:funcArgList)
    call l:Func()
endfunction
" }}} Smart split

