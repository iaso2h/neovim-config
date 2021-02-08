function! CompileRunC() abort
    let l:srcPath = expand('%:p')
    let l:srcNoExt = expand('%:p:r')
    " The building flags
    let l:flags = '-Wall -std=c99'
    if executable('clang')
        let l:prog = 'clang'
    elseif executable('gcc')
        let l:prog = 'gcc'
    else
        echoerr 'No compiler found!'
    endif
    " call <SID>create_term_buf('v', 80)
    let l:compileCMD = l:prog." ".l:flags." ".l:srcPath." -o ".l:srcNoExt.".exe"
    let g:asyncrun_status = 0
    execute "AsyncRun " . l:compileCMD
    echom g:asyncrun_status
    " execute printf('term %s.exe', l:srcNoExt)
    " call system(l:srcNoExt.".exe")
endfunction

function! s:create_term_buf(_type, size) abort
    if a:_type ==# 'v' | vnew | else | new | endif
    execute 'resize ' . a:size
endfunction
nnoremap <silent> <F9> :call CompileRunC()<cr>
nnoremap <silent> <S-F9> :!%:r.exe<cr>

