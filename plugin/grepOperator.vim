nnoremap <leader>g :set operatorfunc=<SID>GrepOperator<CR>g@
xnoremap <leader>g :<C-u>call <SID>GrepOperator(visualmode())<CR>

function! s:GrepOperator(type)
    let saved_reg = @@
    if a:type ==# 'v'
        execute "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute "normal! `[v`]y`"
    else
        return
    endif
    echom "Grep " . shellescape(@@)
    let l:askPath = input("Specify the path: ")
    
    " silent execute "vim /" . expand(@@) . "/j %"
    silent execute "vim /" . expand(@@) . "/j " . l:askPath
    cw
    
    let @@ = saved_reg
endfunction
