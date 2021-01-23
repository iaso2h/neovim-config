function! VSCodeLineCopy(modeType, copyDirection)
    if a:modeType ==# "V"
        execute "normal! gv"
        let saved_reg = @@
        let l:col = col(".")
        let l:row = line(".")
        let l:rowStart = line("'<") 
        let l:rowEnd = line("'>") 
        if l:row ==# l:rowStart
            let l:selectDirection = "up"
        else
            let l:selectDirection = "down"
        endif
        if a:copyDirection ==# "up"
            execute "normal! yP"
            if l:selectDirection ==# "up"
                call cursor(l:rowEnd, 0)
                execute "normal! V"
                call cursor(l:row, l:col)
            else
                execute "normal! V"
                call cursor(l:rowEnd, l:col)
            endif
        elseif a:copyDirection ==# "down"
            execute "normal! y"
            call cursor(l:rowEnd, 0)
            execute "normal! p"
            if l:selectDirection ==# "down"
                call cursor(l:rowEnd + 1, 0)
                execute "normal! V"
                call cursor(l:row + l:rowEnd - l:rowStart + 1, l:col)
            else
                call cursor(l:rowEnd + l:rowEnd - l:rowStart + 1, l:col)
                execute "normal! V"
                call cursor(l:rowEnd + 1, 0)
            endif
        endif
        let @@ = saved_reg
    elseif a:modeType ==# "n"
        let saved_reg = @@
        let l:col = col(".")
        let l:row = line(".")
        if a:copyDirection ==# "up"
            execute "normal! yyP"
            call cursor(l:row, l:col)
        elseif a:copyDirection ==# "down"
            execute "normal! yyp"
            call cursor(l:row + 1, l:col)
        endif
        let @@ = saved_reg
    endif
endfunction

