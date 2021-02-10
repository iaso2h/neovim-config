""
" Function: Redir Redir command output to a new split window
"
" @param CMD: string value contain ex command
""
function! Redir(CMD) abort
    redir => s:output
    silent PP execute(a:CMD)
    redir END
    if empty(s:output)
        echohl WarningMsg | echo "No output" | echohl None
    else
        call SmartSplit("RedirBuffer", [])
        execute "1,2delete"
    endif
endfunction

function! RedirBuffer()
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=s:output
endfunction

