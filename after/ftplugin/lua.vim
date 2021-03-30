" lua require("after.ftplugin.lua")
setlocal formatoptions-=o
" nmap <buffer><expr> <C-S-q> expand('<cword>') =~ '^nvim' ? ":execute 'h ' . expand('<cword>')<cr>" : ""
nmap <buffer><silent> <C-S-q> :lua nlua.keyword_program()<cr>
nmap <buffer> g==        <plug>(Luadev-RunLine)
vmap <buffer> g=         <plug>(Luadev-Run)
nmap <buffer> g=iw       <plug>(Luadev-RunWord)
imap <buffer> <C-x><C-l> <plug>(Luadev-Complete)

