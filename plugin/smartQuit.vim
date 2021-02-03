function! s:SpanWin()
    if MultiBufInWin()
        if &buftype == "help"
            if winwidth(0) <= 116 
                wincmd s | bp | wincmd K
            else
                wincmd v | bp | wincmd H
            endif
        endif
    endif
endfunction

function! s:SaveQuit() abort
    let l:answer = confirm("Save modification?", ">>> &Save\n&Discard\n&Cancel", 3, "Question")
    if l:answer == 1
        wq 
    elseif l:answer == 2  
        q!
    else
    endif
endfunction

function! s:SaveUnload() abort
    let l:answer = confirm("Save modification?", ">>> &Save\n&Discard\n&Cancel", 3, "Question")
    if l:answer == 1 
        w | bd
    elseif l:answer == 2 
        bd!
    else
    endif
endfunction

function! s:SmartQuit()  abort
    let l:fileBufCount = 0
    let l:winNum = winnr("$")
    let s:curBufName = bufname()
    let l:bufferInstance = 0
    let l:specialBuf = 0
    " Special buffer
    if &buftype != "" && &buftype !=# "acwrite"
        if l:winNum == 1
            if MultiBufInWin() | bd | else | q | endif
        else
            execute "q"
            if winnr("$") == 1 | call s:SpanWin() | endif
        endif
    " Close Buffer
    else
        " 1 Window
        if l:winNum == 1 | if &modified | call s:SaveUnload() | else | bd!| endif
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
                q
            elseif l:fileBufCount == 0
                " Close buffer
                if l:bufferInstance
                    q
                elseif !l:bufferInstance  && l:specialBuf
                    " Check if other buffers exist in current window
                    if MultiBufInWin()
                        if &modified 
                            call s:SaveUnload() 
                        else 
                            bd!
                        endif
                        if winnr("$") == 1
                            call s:SpanWin()
                        endif
                    " Last buffer in current window
                    else
                        if &modified 
                            call s:SaveUnload() 
                        else 
                            bd!
                        endif
                    endif
                elseif !l:bufferInstance  && !l:specialBuf
                    if &modified 
                        call s:SaveQuit() 
                    else 
                        q
                    endif
                endif
            endif
        endif
    endif
endfunction

nnoremap <silent> <Plug>smartQuit :call <SID>SmartQuit()<CR>
