function! OpenUrl()
    let l:url = matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
    if l:url == ""
        return
    else
        if has('win32')
            execute("!chrome " . l:url)
        elseif has('unix')
            execute("!open '" . l:url . "'")
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
