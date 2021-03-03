-- if fn.has('win32') or fn.has('win64') then
    -- noremap <silent> <leader>g :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>" "\%CD\%\*.h" "\%CD\%\*.c*" <cr>
-- else
    -- noremap <silent> <leader>g :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W>
             -- --include='*.h' --include='*.c*' '<root>' <cr>
-- end
vim.g.asyncrun_rootmarks = {'.svn', '.git', '.root', '_darcs', 'build.xml'}
vim.g.asyncrun_open = 8
vim.g.asyncrun_trim = 0
vim.g.asyncrun_save = 1

