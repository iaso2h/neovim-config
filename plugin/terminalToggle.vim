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
    if &buftype != "Terminal"
        call SmartSplit("TTerminal", [], "^term.*", 1)
    else
        if l:winCount == 1
            bp
        elseif l:winCount == 2
            wincmd w | only
        else
            q
            " Switch back last window if exists
            if exists("g:smartSplitLastBufNr")
                for dict in l:winInfo
                    if winbufnr(dict['winid']) == g:smartSplitLastBufNr | execute printf("%dwincmd w", dict["winnr"]) | endif
                endfor
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

function! TerminalClose()
    let l:winInfo = getwininfo()
    for dict in l:winInfo
        if bufname(winbufnr(dict["winid"])) =~ "term:"
            execute printf("%dwincmd q", dict["winnr"])
        endif
    endfor
endfunction
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

