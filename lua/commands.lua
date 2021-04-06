local vim = vim
local api = vim.api

-- Function {{{
vim.g.FiletypeCommentDelimiter = {
    vim    = "\"",
    python = "#",
    c      = "\\/\\/",
    cpp    = "\\/\\/",
    json   = "\\/\\/",
    lua    = "--",
}
vim.g.enhanceFoldStartPat = {
    vim    = '\\s\\{-}\\"[^\\"]\\{-}{{{[^\\"]*$',
    python = '\\s\\{-}\\"[^#]\\{-}{{{[^#]*$',
    c      = '\\s\\{-}//.\\{-}{{{.*$',
    cpp    = '\\s\\{-}//.\\{-}{{{.*$',
    lua    = '\\s\\{-}--.\\{-}{{{.*$',
}
vim.g.enhanceFoldEndPat = {
    vim    = '\\s\\{-}\\"[^\\"]\\{-}}}}[^\\"]*$',
    python = '\\s\\{-}\\"[^#"]\\{-}}}}[^#]*$',
    c      = '\\s\\{-}//.\\{-}}}}.*$',
    cpp    = '\\s\\{-}//.\\{-}}}}.*$',
    lua    = '\\s\\{-}--.\\{-}}}}.*$',
}
api.nvim_exec([[
function! EnhanceFoldExpr()
    let l:line = getline(v:lnum)
    if match(l:line, g:enhanceFoldStartPat[&filetype]) > -1
        return "a1"
    elseif match(l:line, g:enhanceFoldEndPat[&filetype]) > -1
        return "s1"
    else
        return "="
    endif
endfunctio
]], false)
-- }}} Function

-- Auto commands {{{
api.nvim_exec([[
augroup fileType
autocmd!
autocmd BufReadPost          * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
autocmd BufWritePre          * lua require"util".trimWhiteSpaces(); require"util".trailingEmptyLine()
autocmd BufEnter             * set formatoptions=pj1Bml2nwc
autocmd TermOpen             * startinsert
autocmd TermOpen             * setlocal nobuflisted
autocmd FocusGained,BufEnter * checktime
" autocmd BufAdd               * lua require("consistantTab").adaptBufTab()

" autocmd CursorHold            *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
autocmd FileType              java setlocal includeexpr=substitute(v:fname,'\\.','/','g')
autocmd FileType              git  setlocal nofoldenable
autocmd FileType              json setlocal conceallevel=0 concealcursor=
autocmd FileType              qf   setlocal number norelativenumber nobuflisted
autocmd FileType              qf map <buffer> <silent> <cr> :.cc<cr>:copen<cr>
autocmd FileType              vim,lua     setlocal foldmethod=expr foldexpr=EnhanceFoldExpr()
autocmd BufEnter              term://*    startinsert
autocmd BufEnter              *.txt       lua require("util").splitExist()
autocmd BufReadPre,BufNewFile *.jsx       setlocal filetype=jypescript
autocmd BufReadPre,BufNewFile *.tsx       setlocal filetype=typescript
autocmd BufReadPre,BufNewFile *.twig      setlocal filetype=twig.html
autocmd BufReadPre,BufNewFile *.gitignore setlocal filetype=gitignore
autocmd BufReadPre,BufNewFile config      setlocal filetype=config
autocmd BufWritePost          *.lua,*.vim lua RELOAD()
augroup END
]], false)
-- }}} Auto commands

-- Commands {{{
api.nvim_exec([[
command! -nargs=+ -complete=command  Echo PPmsg strftime('%c') . ": " . <args>
command! -nargs=+ -complete=command  Redir call luaeval('require("redir").catch(_A)', <q-args>)
command! -nargs=0 -range ExtractSelection lua require("extractSelection").main(vim.fn.visualmode())
command! -nargs=0 -range Backward setl revins | execute "norm! gvc\<C-r>\"" | setl norevins
command! -nargs=0 TrimWhiteSpaces call TrimWhiteSpaces(0)
command! -nargs=0 PS terminal powershell
command! -nargs=0 CD execute "cd " . expand("%:p:h")
command! -nargs=0 E  up | let g:refreshBufSavView = winsaveview() | e! | call winrestview(g:refreshBufSavView)
" Edit Vimrc
if has('win32')
command! -nargs=0 IDEAVimedit vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit edit $MYVIMRC
command! -nargs=0 MyVimsrc source $MYVIMRC
]], false)
-- }}} Commands

