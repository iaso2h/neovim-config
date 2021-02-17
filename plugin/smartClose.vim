""
" Function: SmartClose Close window or buffer without messing up Neovim layout
"
" @param type: possible string value: "window", "buffer"
""
function SmartClose(type) " {{{
    let s:curBufNr = winbufnr(0)
    let l:winCount = winnr("$")
    let l:bufListLength = len(filter(split(execute("ls"), '\n', 0), 'v:val !~# "term:"'))
    let l:bufName = bufname()
    if a:type == "window" " {{{
        if !empty(&buftype)               " Sepecial buffer
            if &buftype != "nofile"
                bdelete
            else                          " nofile, treated like a scratch file
                if bufname() == "[Command Line]"
                    q
                else
                    if l:bufListLength == 1 " 1 Buffer
                        if winCount > 1 | only | endif
                        call <SID>SaveWipe(s:curBufNr)
                    else                      " 1+ Buffers
                        if winCount > 1       " 1+ Windows
                            q
                            if !&modified && buflisted(l:bufName) | execute "bwipe! " . s:curBufNr | endif
                        else                  " 1 Window
                            call <SID>SaveWipe(s:curBufNr)
                        endif
                    endif
                endif
            endif
            " }}}
        else                              " Standard buffer
            if empty(l:bufName)           " Scratch File
                if l:bufListLength == 1 " 1 Buffer
                    if winCount > 1 | only | endif
                    call <SID>SaveWipe(s:curBufNr)
                    q
                else                      " 1+ Buffers
                    if winCount > 1       " 1+ Windows
                        q
                        if !&modified && buflisted(l:bufName) | execute "bwipe! " . s:curBufNr | endif
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
        " Delete unlisted buffer
        if !buflisted(expand("%")) | bdelete! | return 0 | endif

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
            w
            execute "bwipe " . a:bufNr
        elseif l:answer == 2
            execute "bwipe! " . a:bufNr
        endif
    else
        execute "bwipe " . a:bufNr
    endif
endfunction " }}}

