local cmd = vim.cmd

-- Function {{{
vim.g.FiletypeCommentDelimiter = {
    vim    = "\"",
    python = "#",
    sh     = "#",
    zsh    = "#",
    fish   = "#",
    c      = "\\/\\/",
    cpp    = "\\/\\/",
    json   = "\\/\\/",
    conf   = "\\/\\/",
    lua    = "--",
}
if not vim.g.vscode then
    vim.g.enhanceFoldStartPat = {
        vim    = '\\s\\{-}\\"[^\\"]\\{-}{{{[^\\"]*$',
        python = '\\s\\{-}\\"[^#]\\{-}{{{[^#]*$',
        c      = '\\s\\{-}//.\\{-}{{{.*$',
        cpp    = '\\s\\{-}//.\\{-}{{{.*$',
        json   = '\\s\\{-}//.\\{-}{{{.*$',
        conf   = '\\s\\{-}//.\\{-}{{{.*$',
        lua    = '\\s\\{-}--.\\{-}{{{.*$',
        sh     = '\\s\\{-}\\"[^#]\\{-}{{{[^#]*$',
        zsh    = '\\s\\{-}\\"[^#]\\{-}{{{[^#]*$',
        fish   = '\\s\\{-}\\"[^#]\\{-}{{{[^#]*$',
    }
    vim.g.enhanceFoldEndPat = {
        vim    = '\\s\\{-}\\"[^\\"]\\{-}}}}[^\\"]*$',
        python = '\\s\\{-}\\"[^#"]\\{-}}}}[^#]*$',
        c      = '\\s\\{-}//.\\{-}}}}.*$',
        cpp    = '\\s\\{-}//.\\{-}}}}.*$',
        json   = '\\s\\{-}//.\\{-}}}}.*$',
        conf   = '\\s\\{-}//.\\{-}}}}.*$',
        lua    = '\\s\\{-}--.\\{-}}}}.*$',
        sh     = '\\s\\{-}\\"[^#"]\\{-}}}}[^#]*$',
        zsh    = '\\s\\{-}\\"[^#"]\\{-}}}}[^#]*$',
        fish   = '\\s\\{-}\\"[^#"]\\{-}}}}[^#]*$',
    }
    cmd [[
    function! EnhanceFoldExpr()
        let l:line = getline(v:lnum)
        if match(l:line, g:enhanceFoldStartPat[&filetype]) > -1
            return "a1"
        elseif match(l:line, g:enhanceFoldEndPat[&filetype]) > -1
            return "s1"
        else
            return "="
        endif
    endfunction

    function! ExitVisual()
        normal! gv
        execute "normal! \<esc>"
    endfunction
    ]]
end
-- }}} Function

-- Auto commands {{{
if not vim.g.vscode then
    -- TODO: Monitor file changed and prevent fold close
    cmd[[
    augroup fileType
    autocmd!
    autocmd VimEnter             * nested lua require("historyStartup").display()

    autocmd BufWinEnter          * lua require("cursorRecall").main()
    autocmd BufWritePre          * lua require"util".trimSpaces(); require"util".trailingEmptyLine()
  " autocmd BufEnter             * set formatoptions=pj1Bml2nwc
    autocmd BufEnter             * lua require("historyStartup").deleteBuf()
  " autocmd FocusGained,BufEnter * checktime
  " autocmd BufAdd               * lua require("consistantTab").adaptBufTab()

    autocmd BufEnter             term://* startinsert
    autocmd TermOpen             *        startinsert
    autocmd TermOpen             *        setlocal nobuflisted | setlocal nonumber

    autocmd BufEnter             *.txt,COMMIT_EDITMSG,index lua require("util").splitExist()

  " autocmd CursorHold            *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
    autocmd FileType              java setlocal includeexpr=substitute(v:fname,'\\.','/','g')
    autocmd FileType              git  setlocal nofoldenable
    autocmd FileType              json setlocal conceallevel=0 concealcursor=

    autocmd BufReadPre,BufNewFile *.jsx       setlocal filetype=jypescript
    autocmd BufReadPre,BufNewFile *.tsx       setlocal filetype=typescript
    autocmd BufReadPre,BufNewFile *.twig      setlocal filetype=twig.html
    autocmd BufReadPre,BufNewFile *.gitignore setlocal filetype=gitignore
    autocmd BufReadPre,BufNewFile config      setlocal filetype=config
    " Related work: https://github.com/RRethy/nvim-sourcerer
    autocmd BufWritePost          *.lua,*.vim lua Reload()
    augroup END
    ]]
end
-- }}} Auto commands

-- Commands {{{
cmd [[
command! -nargs=+ -complete=command  Echo PPmsg strftime('%c') . ": " . <args>
command! -nargs=+ -complete=command  Redir call luaeval('require("redir").catch(_A)', <q-args>)
command! -nargs=0 -range ExtractSelection lua require("extractSelection").main(vim.fn.visualmode())
command! -nargs=0 -range Backward setl revins | execute "norm! gvc\<C-r>\"" | setl norevins
command! -nargs=0 PS     terminal powershell
command! -nargs=0 CD     execute "cd " . expand("%:p:h")
command! -nargs=0 E      up | let g:refreshBufSavView = winsaveview() | e! | call winrestview(g:refreshBufSavView)
command! -nargs=0 O      browse oldfiles
command! -nargs=0 Dofile lua dofile(vim.fn.expand("%:p"))

command! -nargs=0 MyVimedit edit    $MYVIMRC
command! -nargs=0 MyVimsrc  luafile $MYVIMRC

command! -nargs=0 TrimSpaces              call TrimSpaces()
command! -nargs=0 TrimSpacesToggle        lua  if type(TrimSpacesChk) == "nil" then TrimSpacesChk = TrimSpacesChk or true end; TrimSpacesChk = not TrimSpacesChk; vim.api.nvim_echo({{string.format("%s",TrimSpacesChk), "Moremsg"}}, false, {})
command! -nargs=0 TrailingEmptyLineToggle lua  if type(TrailEmptyLineChk) == "nil" then TrailEmptyLineChk = TrailEmptyLineChk or true end; TrailEmptyLineChk = not TrailEmptyLineChk; vim.api.nvim_echo({{string.format("%s",TrailEmptyLineChk), "Moremsg"}}, false, {})
]]
-- }}} Commands

