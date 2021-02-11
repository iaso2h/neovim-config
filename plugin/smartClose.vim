""
" Function: SmartClose Close window or buffer without messing up Neovim layout
"
" @param type: possible string value: "window", "buffer"
""
function SmartClose(type) " {{{
    let s:curBufNr = winbufnr(0)
    let l:winCount = winnr("$")
    let l:bufListLength = len(split(execute("ls"), "\\n", 0))
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
                    call <SID>SaveWipe(s:curBufNr)
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        q
                        if !&modified | silent execute "bwipe! " . s:curBufNr | endif
                    else                  " 1 Window
                        call <SID>SaveWipe(s:curBufNr)
                    endif
                endif
            endif
        else                              " Standard buffer
            if empty(l:bufName)           " Scratch File
                if l:bufListLength == 1 " 1 Buffer
                    if winCount > 1 | only | endif
                    call <SID>SaveWipe(s:curBufNr)
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        q
                        if !&modified | execute "bwipe! " . s:curBufNr | endif
                    else                  " 1 Window
                        call <SID>SaveWipe(s:curBufNr)
                    endif
                endif
            else                          " Standard File
                if l:bufListLength == 1 " 1 Buffer
                    if winCount > 1 | only | endif
                    call <SID>SaveWipe(s:curBufNr)
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        q
                    else                  " 1 Window
                        call <SID>SaveWipe(s:curBufNr)
                    endif
                endif
            endif
        endif
        " }}}
    elseif a:type == "buffer"
        if l:bufListLength == 1         " 1 Buffer
            if winCount > 1 | only | endif
            call <SID>SaveWipe(s:curBufNr)
        else                              " 1+ Buffers
            if l:bufListLength == 2     " 2 Buffers
                execute bufnr("#") > 0 && buflisted(bufnr("#")) ? "buffer #" : "bprevious"
                only
                call <SID>SaveWipe(s:curBufNr)
            else                          " 2+ Buffers
                for i in range(l:winCount)
                    wincmd w
                    if bufnr() == s:curBufNr
                        execute bufnr("#") > 0 && buflisted(bufnr("#")) ? "buffer #" : "bprevious"
                    endif
                endfor
                call <SID>SaveWipe(s:curBufNr)
            endif
        endif
    endif
endfunction " }}}

function! s:SaveWipe(bufNr) abort " {{{
    if getbufvar(a:bufNr, "&mod")
        echohl MoreMsg
        let l:answer = confirm("Save modification?", ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        echohl None
        if l:answer == 1
            w | execute "bw " . a:bufNr
        elseif l:answer == 2
            execute "bw! " . a:bufNr
        endif
    else
        execute "bw " . a:bufNr
    endif
endfunction " }}}

