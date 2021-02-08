" help asyncrun-run-shell-command
" if has('win32')
    " let g:asyncrun_shell="c:/windows/system32/cmd.exe"
    " let g:asyncrun_shellflag="/C"
    " let g:asyncrun_wrapper = 'c:/windows/system32/cmd.exe /C'
    " let g:asyncrun_wrapper = &shell . '.exe ' . &shellcmdflag
" endif
if has('win32') || has('win64')
    noremap <silent> <leader>g :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>" 
            \ "\%CD\%\*.h" "\%CD\%\*.c*" <cr>
else
    noremap <silent> <leader>g :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W> 
            \ --include='*.h' --include='*.c*' '<root>' <cr>
endif
let g:asyncrun_rootmarks = ['.svn', '.git', '.root', '_darcs', 'build.xml'] 
let g:asyncrun_open = 8
let g:asyncrun_trim = 0
let g:asyncrun_save = 1

