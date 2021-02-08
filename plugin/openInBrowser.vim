function! OpenUrl(...)
    if a:0 == 0
        let l:url = matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
        if l:url == ""
            execute "normal! \<C-l>"
            return
        else
            if has('win32')
                execute("!chrome " . l:url)
            elseif has('unix')
                execute("!open '" . l:url . "'")
            endif
        endif
    else
        if has('win32')
            execute("!chrome " . a:1)
        elseif has('unix')
            execute("!open '" . a:1 . "'")
        endif
    endif
endfunction

function! OpenInBrowser(str)
    if has('win32')
        execute("!chrome \"? " . a:str . "\"")
    elseif has('unix')
        execute("!open '" . a:str . "'")
    endif
endfunction
