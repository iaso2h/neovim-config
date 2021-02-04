function! s:compile_run_cpp() abort
    let l:srcPath = expand('%:p')
    let l:srcNoExt = expand('%:p:r')
    " The building flags
    let l:flag = '-Wall -Wextra -std=c99'
    if executable('clang')
        let l:prog = 'clang'
    elseif executable('gcc')
        let l:prog = 'gcc'
    else
        echoerr 'No compiler found!'
    endif
    call <SID>create_term_buf('v', 80)
    execute printf('term %s %s %s -o %s', l:prog, l:flag, l:srcPath, l:srcNoExt)
    startinsert
endfunction

function s:create_term_buf(_type, size) abort
    set splitbelow
    set splitright
    if a:_type ==# 'v' | vnew | else | new | endif
    execute 'resize ' . a:size
endfunction

nnoremap <silent> <buffer> <F9> :call <SID>compile_run_cpp()<CR>
