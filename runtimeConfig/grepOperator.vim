nnoremap <leader>g :set operatorfunc=<SID>GrepOperator<CR>g@
xnoremap <leader>g :<C-u>call <SID>GrepOperator(visualmode())<CR>

function! GrepOperator(type)
    let saved_reg = @@
    if a:type ==# 'v'
        execute "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute "normal! `[v`]y`"
    else
        return
    endif
    echom shellescape(@@)
    silent execute "vim /" . expand(@@) . "/j %"
    cw
    
    let @@ = saved_reg
endfunction
