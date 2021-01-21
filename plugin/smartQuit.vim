function! s:SpanWin()
    if MultiBufInWin()
        if &filetype ==# "" || &filetype ==# "help"
            execute "normal \<C-w>v"
            execute "bp"
            execute "normal \<C-w>H"
        endif
    endif
endfunction

function! s:SaveQuit()
    let l:answer = confirm("Save modification?", ">>> &Yes\n&No\n&Cancel", 1, "Question")
    if l:answer == 1
        execute "wq" 
    elseif l:answer == 2  
        execute "q!" 
    endif
endfunction

function! s:SaveUnload()
    let l:answer = confirm("Save modification?", ">>> &Yes\n&No\n&Cancel", 1, "Question")
    if l:answer == 1 
        execute "w | bd" 
    elseif l:answer == 2 
        execute "bd!" 
    endif
endfunction

function! s:SmartQuit() 
    let l:fileBufCount = 0
    let l:winNum = winnr("$")
    let s:curBufName = bufname()
    let l:bufferInstance = 0
    " Close Help, Quickfix
    let l:specialBuf = 0
    " Command Line
    if &filetype ==# "vim" && bufname() ==# "[Command Line]"
        execute "q"
    " Newtre
    elseif &filetype ==# "netrw"
        execute "q"
    elseif &filetype ==# "help" || (&filetype != "" && s:curBufName =="")
        if l:winNum == 1
            if MultiBufInWin()
                execute("bd")
            else
                execute("q")
            endif
        else
            execute "q"
            if winnr("$") == 1
                call s:SpanWin()
            endif
        endif
    " Empty files
    elseif &filetype == "" && s:curBufName == ""
        " 1 Window
        if l:winNum == 1
            " 2+ Buffers in 1 window
            if MultiBufInWin()
                if &modified 
                    call s:SaveUnload() 
                else 
                    execute "bd"
                endif
            " 1 Buffer in 1 window
            else
                if &modified 
                    call s:SaveQuit() 
                else 
                    execute "q"
                endif
            endif
        " 2+ Windows 
        else
            if l:fileBufCount >= 1
                execute "q"
            elseif l:fileBufCount == 0
                " Check special buffer in other windows
                for l:winIndex in range(l:winNum)
                    execute "normal! \<C-w>w"
                    if l:winIndex != l:winNum - 1
                        if &filetype ==# "" && bufname() ==# ""
                            let l:specialBuf = 1
                            let l:fileBufCount += 1
                        elseif &filetype !=# "" && bufname() ==# ""
                            let l:specialBuf = 1
                        elseif &filetype !=# "" && bufname() !=# ""
                            if &filetype !=# "help"
                                let l:fileBufCount += 1
                            else
                                let l:specialBuf = 1
                            endif
                        endif
                    endif
                endfor
                " Special buffer in other windows
                if l:specialBuf
                    " Multiple buffers in current window
                    if MultiBufInWin()
                        if &modified 
                            call s:SaveUnload() 
                        else 
                            execute "bd!"
                        endif
                        if winnr("$") == 1
                            call s:SpanWin()
                        endif
                    " One buffer in current window
                    else
                        if &modified 
                            call s:SaveQuit() 
                        else 
                            execute "q"
                        endif
                    endif
                " No special buffer in other windows
                else
                    execute "q"
                endif
            endif
        endif
    " Close Buffer
    else
        " 1 Window
        if l:winNum == 1
            if &modified 
                call s:SaveUnload() 
            else 
                execute "bd!" 
            endif
        " 2+ Windows
        else
            " Check buffer instances and special buffer in other windows
            for l:winIndex in range(l:winNum)
                execute "normal! \<C-w>w"
                if l:winIndex != l:winNum - 1
                    if &filetype ==# "" && bufname() ==# ""
                        let l:specialBuf = 1
                        let l:fileBufCount += 1
                    elseif &filetype !=# "" && bufname() ==# ""
                        let l:specialBuf = 1
                    elseif &filetype !=# "" && bufname() !=# ""
                        if &filetype !=# "help"
                            let l:fileBufCount += 1
                        else
                            let l:specialBuf = 1
                        endif

                        if s:curBufName ==# bufname()
                            let l:bufferInstance = 1
                        endif
                    endif
                endif
            endfor
            if l:fileBufCount >= 1
                execute "q"
            elseif l:fileBufCount == 0
                " Close buffer
                if l:bufferInstance
                    execute "q"
                elseif !l:bufferInstance  && l:specialBuf
                    " Check if other buffers exist in current window
                    if MultiBufInWin()
                        if &modified 
                            call s:SaveUnload() 
                        else 
                            execute "bd!" 
                        endif
                        if winnr("$") == 1
                            call s:SpanWin()
                        endif
                    " Last buffer in current window
                    else
                        if &modified 
                            call s:SaveUnload() 
                        else 
                            execute "bd!" 
                        endif
                    endif
                elseif !l:bufferInstance  && !l:specialBuf
                    if &modified 
                        call s:SaveQuit() 
                    else 
                        execute "q"
                    endif
                endif
            endif
        endif
    endif
endfunction

nnoremap <silent> <Plug>smartQuit :call <SID>SmartQuit()<CR>
