function! InclusivePragraph(direction)
    let l:currentLineNum = getpos(".")[1]
    if a:direction ==# "up"
        if getline(".") ==# ""
            execute "normal! {j"
        else
            if getline(l:currentLineNum - 1) ==# ""
                execute "normal! k{j"
            else
                execute "normal! {j"
            endif
        endif
    elseif a:direction ==# "down"
        if getline(".") ==# ""
            execute "normal! }k"
        else
            let l:currentLineNum = getpos(".")[1]
            if getline(l:currentLineNum + 1) ==# ""
                execute "normal! j}k"
            else
                execute "normal! }k"
            endif
        endif
    endif
endfunction
