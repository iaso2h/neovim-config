function! VSCodeLineCopy(modeType, copyDirection)
    if a:modeType ==# "V"
        execute "normal! gv"
        let saved_reg = @@
        let l:col = col(".")
        let l:row = line(".")
        let l:rowStart = line("'<") 
        let l:rowEnd = line("'>") 
        if a:copyDirection ==# "up"
            execute "normal! yP"
            call cursor(l:row, l:col)
        elseif a:copyDirection ==# "down"
            execute "normal! y"
            call cursor(l:rowEnd, 0)
            execute "normal! p"
            call cursor(l:row + l:rowEnd - l:rowStart + 1, l:col)
        endif
        let @@ = saved_reg
    endif
endfunction
