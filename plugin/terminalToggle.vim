" File: terminalToggle.vim
" Author: iaso2h
" Description: Toggle terminal like VS Code
" Last Modified: 2021-02-10
" Version: 0.0.2
""
" Function: TerminalToggle Toggle terminal on split windows, support Winodows
" and linux only
" Return: 0
""

function! TerminalToggle() " {{{
    let l:winCount = winnr("$")
    let l:winInfo = getwininfo()
    let l:curWinID = win_getid()
    if &buftype != "Terminal"
        let s:lastWinID = l:curWinID
        call SmartSplit("TTerminal", [], 1)
    else
        if l:winCount == 1
            bp
        elseif l:winCount == 2
            execute "normal! \<C-w>w"
            only
        else
            q
            " Switch back to last window id if exist
            let l:dictIndex = -1
            let l:lastWinIndex = 0
            for dict in l:winInfo
                let l:dictIndex += 1
                if dict['winid'] == s:lastWinID | let l:lastWinIndex = l:dictIndex | endif
                if dict['winid'] == l:curWinID | let l:curWinIndex = l:dictIndex | endif
            endfor
            if l:lastWinIndex
                let l:offset = l:lastWinIndex - l:curWinIndex
                if l:offset > 0
                    execute printf("normal! %d\<C-w>w", abs(l:offset) + 1)
                else
                    execute printf("normal! %d\<C-w>W", abs(l:offset) + 1)
                endif
            else
                return 0
            endif
        endif
    endif
endfunction " }}}


""
" Function: TTmerminal Run terminal in a smart way
" Return: if no terminal found, run a new instance. If one or multiple terminal is
" found, the smallest buffer number, which is determined by bufnr(), will be
" invoke
""
function! TTerminal() " {{{
    let l:termBuf = execute("ls R")
    let l:termBufNr = l:termBuf == "" ? 0 : str2nr(matchstr(split(l:termBuf, "\\n", 0)[0], "\\d\\+"))
    if l:termBufNr
        execute "b " . l:termBufNr | startinsert
    else
        if has("win32")
            execute "terminal powershell"
        elseif has("unix")
            execute "terminal"
        endif
    endif
endfunction " }}}

" let l:winInfo =
" [{'botline': 91,
" 'bufnr': 10,
" 'height': 44,
" 'loclist': 0,
" 'quickfix': 0,
" 'tabnr': 1,
" 'terminal': 0,
" 'topline': 47,
" 'variables':
" 'width': 143,
" 'winbar': 0,
" 'wincol': 1,
" 'winid': 1000,
" 'winnr': 1,
" 'winrow': 2},

" {'botline': 53,
" 'bufnr': 10,
" 'height': 29,
" 'loclist': 0,
" 'quickfix': 0,
" 'tabnr': 1,
" 'terminal': 0,
" 'topline': 2,
" 'variables':
" 'width': 88,
" 'winbar': 0,
" 'wincol': 145,
" 'winid': 1430,
" 'winnr': 2,
" 'winrow': 2},

" {'botline': 48,
" 'bufnr': 10,
" 'height': 14,
" 'loclist': 0,
" 'quickfix': 0,
" 'tabnr': 1,
" 'terminal': 0,
" 'topline': 11,
" 'variables':
" 'width': 88,
" 'winbar': 0,
" 'wincol': 145,
" 'winid': 1431,
" 'winnr': 3,
" 'winrow': 32}]

