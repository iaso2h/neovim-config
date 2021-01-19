" EasyMotion {
let g:EasyMotion_off_screen_search = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyz'
highlight EasyMotionTarget guibg=white guifg=grey
highlight link EasyMotionShade  Comment
highlight EasyMotionTarget2First guibg=#ED427C guifg=white
highlight EasyMotionTarget2Second guibg=#ED427C guifg=white
augroup easyMotionGroup
    autocmd!
    autocmd User EasyMotionPromptBegin silent! CocDisable
    autocmd User EasyMotionPromptEnd   silent! CocEnable
augroup END
map <A-8> <Plug>(easymotion-prefix)
map <leader>j <Plug>(easymotion-s)
map <leader>J <Plug>(easymotion-bd-jk)
" } EasyMotion
