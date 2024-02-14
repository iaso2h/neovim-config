let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
colorscheme slate
" colorscheme desert
" colorscheme habamax
set ci
set cin
set clipboard=unnamedplus
set cmdheight=2
set cursorline
set lazyredraw
set nu
set showmode
set ignorecase
set smartcase
set smartindent
set wrap

set expandtab
set shiftwidth=4
set sts=4
set tabstop=4

" 按键设置
let g:mapleader = "\<space>"
nnoremap <silent> <leader>h <cmd>noh<cr>
xnoremap <leader>h <esc>
noremap <M-o> g;
noremap <M-i> g,
noremap <silent> <M-,> <cmd>bp<cr>
noremap <silent> <M-.> <cmd>bn<cr>

" 命令
command! -narg=0 O browse oldfiles
