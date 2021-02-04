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

function! MultiBufInWin() " {{{
    let l:curBufName = bufname()
    execute "bp"
    if bufname() !=# l:curBufName
        execute "normal! \<C-o>"
        return 1
    else
        return 0
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
