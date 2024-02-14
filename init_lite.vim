let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
colorscheme slate
" colorscheme desert
" colorscheme habamax
set autoindent
set autoread
set backspace=indent,eol,start
set belloff=all
set comments+=fb:-
set nocompatible
set complete-=i
set copyindent
set cindent
set clipboard=unnamedplus
set cmdheight=2
set cursorline
hi! CursorLine guibg=#303642 cterm=NONE term=NONE
hi! CursorLineNr guifg=White cterm=NONE term=NONE
set display=lastline
set hidden
set history=10000
set hlsearch
set incsearch
" set jumpoptions=stack
set nojoinspaces
set langnoremap
set nolangremap
set laststatus=2
set lazyredraw
set mouse=nvi
set number
set ruler
set showmode
set showcmd
set sidescroll=1
set startofline
set splitbelow
set splitright
set splitkeep=screen
set switchbuf=uselast
set ttyfast
set termguicolors
set viminfo+=!
set wrap
set wildignorecase
set wildmenu

set ignorecase
set smartcase
set smartindent

set expandtab
set shiftround
set shiftwidth=4
set sts=4
set tabstop=4

" 按键设置
" First thing first
let g:mapleader = "\<space>"
" Search current word under cursor
nnoremap K :h <cr>
" Press <leader>h to disable search highlight or return back to Normal mode in Visual mode
nnoremap <silent> <leader>h <cmd>noh<cr>
xnoremap <leader>h <esc>
" Buffer switch
noremap <A-,> <cmd>bprevious<cr>
noremap <A-.> <cmd>bnext<cr>
" Navigation
nnoremap <expr><silent> <A-o> &diff? "mz`z[c" : "mz`zg;"
nnoremap <expr><silent> <A-i> &diff? "mz`z]c" : "mz`zg,"
noremap H ^
noremap L $
noremap <A-e> <PageUp>
noremap <A-d> <PageDown>
tnoremap <A-e> <C-\><C-n><pageup>
tnoremap <A-d> <C-\><C-n><pagedown>
" Remapping q
map q <Nop>
nnoremap <A-q> q
nnoremap <A-v> <C-q>
" Mimic VS Code's move line command
nnoremap <silent> <A-j> :m .+1<cr>==
nnoremap <silent> <A-k> :m .-2<cr>==
command! -nargs=0 VSCodeLineMoveDownInsert m .+1 | execute "normal! =="
command! -nargs=0 VSCodeLineMoveUpInsert   m .-2 | execute "normal! =="
inoremap <A-j> <C-\><C-o>:VSCodeLineMoveDownInsert<cr>
inoremap <A-k> <C-\><C-o>:VSCodeLineMoveUpInsert<cr>
vnoremap <silent> <A-j> :m '>+1<cr>gv=gv
vnoremap <silent> <A-k> :m '<-2<cr>gv=gv
" Y to copy
nnoremap Y yy
xnoremap Y y
" Emacs-like mapping in Insert mode and Command mode
map! <C-a> <Home>
map! <C-e> <End>
map! <C-h> <Left>
map! <C-l> <Right>
map! <C-j> <Down>
map! <C-k> <Up>
map! <C-p> <Down>
map! <C-n> <Up>
map! <C-b> <C-Left>
map! <C-f> <C-Right>
map! <C-d> <Del>
" 命令
command! -narg=0 O browse oldfiles
augroup AutoReloadThisFile " {{{
    autocmd!
    autocmd bufwritepost init_lite.vim nested echom expand("%:p") | redraw! | echom "Reload: " . expand("%:p")
augroup END  }}}
