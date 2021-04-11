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
if not vim.g.vscode then
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
end
-- }}} Function

-- Auto commands {{{
if not vim.g.vscode then
    api.nvim_exec([[
    augroup fileType
    autocmd!
    autocmd BufWinEnter          * lua require("cursorRecall").main()
    autocmd BufWritePre          * lua require"util".trimWhiteSpaces(); require"util".trailingEmptyLine()
    autocmd BufEnter             * set formatoptions=pj1Bml2nwc
    autocmd FocusGained,BufEnter * checktime
  " autocmd BufAdd               * lua require("consistantTab").adaptBufTab()

    autocmd BufEnter             *.txt              lua require("util").splitExist()
    autocmd BufEnter             fugitive,gitcommit lua require("util").splitExist()
    autocmd BufEnter             term://*           startinsert
    autocmd TermOpen             *                  startinsert
    autocmd TermOpen             *                  setlocal nobuflisted | setlocal nonumber

  " autocmd CursorHold            *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
    autocmd FileType              java setlocal includeexpr=substitute(v:fname,'\\.','/','g')
    autocmd FileType              git  setlocal nofoldenable
    autocmd FileType              json setlocal conceallevel=0 concealcursor=

    autocmd BufReadPre,BufNewFile *.jsx       setlocal filetype=jypescript
    autocmd BufReadPre,BufNewFile *.tsx       setlocal filetype=typescript
    autocmd BufReadPre,BufNewFile *.twig      setlocal filetype=twig.html
    autocmd BufReadPre,BufNewFile *.gitignore setlocal filetype=gitignore
    autocmd BufReadPre,BufNewFile config      setlocal filetype=config
    autocmd BufWritePost          *.lua,*.vim lua RELOAD()
    augroup END
    ]], false)
end
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
command! -nargs=0 MyVimedit edit    $MYVIMRC
command! -nargs=0 MyVimsrc  luafile $MYVIMRC
]], false)
-- }}} Commands

