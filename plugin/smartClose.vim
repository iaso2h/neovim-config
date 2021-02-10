""
" Function: SmartClose Close window or buffer without messing up Neovim layout
"
" @param type: possible string value: "window", "buffer"
""
function SmartClose(type) " {{{
    let s:curWinID = win_getid()
    let s:curBufNr = winbufnr(0)
    let l:winCount = winnr("$")
    let l:bufList = split(execute("ls"), "\\n", 0)
    let l:bufListLength = len(l:bufList)
    let l:bufName = bufname()
    if a:type == "window"
        if !empty(&buftype)               " Sepecial buffer
            if &buftype != "nofile"
                if l:bufListLength == 0
                    bd!
                else
                    q
                endif
            else                          " nofile, treated like a scratch file
                if l:bufListLength == 1 " 1 Buffer
                    if winCount > 1 | only | endif
                    call <SID>SaveUnload(s:curBufNr)
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        q
                        execute "bd " . s:curBufNr
                    else                  " 1 Window
                        execute "bd " . s:curBufNr
                    endif
                endif
            endif
        else                              " Standard buffer
            if empty(l:bufName)           " Scratch File
                if l:bufListLength == 1 " 1 Buffer
                    if winCount > 1 | only | endif
                    call <SID>SaveUnload(s:curBufNr)
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        if &modified
                            q
                        else
                            q
                            execute "bd " . s:curBufNr
                        endif
                    else                  " 1 Window
                        call <SID>SaveUnload(s:curBufNr)
                    endif
                endif
            else                          " Standard File
                if l:bufListLength == 1 " 1 Buffer
                    if winCount > 1 | only | endif
                    call <SID>SaveUnload(s:curBufNr)
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        q
                    else                  " 1 Window
                        call <SID>SaveUnload(s:curBufNr)
                    endif
                endif
            endif
        endif
        " }}}
    elseif a:type == "buffer"
        if l:bufListLength == 1         " 1 Buffer
            if winCount > 1 | only | endif
            call <SID>SaveUnload(s:curBufNr)
        else                              " 1+ Buffers
            if l:bufListLength == 2     " 2 Buffers
                bp | only
                call <SID>SaveUnload(s:curBufNr)
            else                          " 2+ Buffers
                " Do once before while loop {{{
                execute "normal! \<C-w>w"
                if bufnr() == s:curBufNr | bp | endif
                " }}} Do once before while loop
                while win_getid() != s:curWinID " {{{
                    execute "normal! \<C-w>w"
                    if bufnr() == s:curBufNr | bp | endif
                endwhile " }}}
                " Switch another buffer for the starting buffer {{{
                bp
                " }}} Switch another buffer for the starting buffer
                call <SID>SaveUnload(s:curBufNr)
            endif
        endif
    endif
endfunction " }}}

function! s:SaveUnload(bufNr) abort
    if &modified
        echohl MoreMsg
        let l:answer = confirm("Save modification?", ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        echohl None
        if l:answer == 1
            w
            execute "bd " . a:bufNr
        elseif l:answer == 2
            execute "bd! " . a:bufNr
        endif
    else
        execute "bd " . a:bufNr
    endif
endfunction

function! s:BufWinInstance()
    bp
    if bufwinid(s:curBufNr) != s:curWinID
        bn
        return 1
    else
        bn
        return 0
    endif
endfunction

