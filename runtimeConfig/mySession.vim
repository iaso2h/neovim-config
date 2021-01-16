function! s:MakeSession()
    let l:sessionDir = getcwd() . "/.vim"
    if (filewritable(l:sessionDir) != 2)
        if has('win32')
            execute 'silent !mkdir ' . l:sessionDir
        elseif has('unix')
            execute 'silent !mkdir -p ' . l:sessionDir
        endif
        redraw!
    endif
    let l:fileName = l:sessionDir . '/Session.vim'
    execute "mksession! " . l:fileName
endfunction

function! s:LoadSession()
    " let l:sessionDir = getcwd() . "/.vim"
    let l:sessionDir = "C:/Users/Hashub/AppData/Local/nvim" . "/.vim"
    let l:fileName = l:sessionDir . '/Session.vim'
    if (filereadable(l:fileName))
        execute 'source ' . l:fileName
        echom "Load: " . l:fileName
    else
        echom "No session loaded"
    endif
endfunction

command! -nargs=0 MakeSession :call <SID>MakeSession()
command! -nargs=0 LoadSession :call <SID>LoadSession()
