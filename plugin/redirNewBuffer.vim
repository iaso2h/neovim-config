"
" @param CMD: string value contain ex command
""
function! Redir(input, type) abort
    if a:type == "command"
        redir => s:output
        silent PP execute(a:input)
        redir END
    elseif a:type == "function"
        let l:Func = function(a:input)
        redir => s:output
        silent PP l:Func()
        redir END
    endif
    if empty(s:output)
        echohl WarningMsg | echo "No output" | echohl None
    else
        call SmartSplit("RedirBuffer", [], "", 0)
    endif
endfunction

function! RedirBuffer()
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified filetype=vim
    silent put=s:output
    execute "1,2delete"
endfunction











