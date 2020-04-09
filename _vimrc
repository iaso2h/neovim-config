" Vim with all enhancements
set langmenu=en
let $LANG='en_US.utf-8'

set history=1000
set number
set ruler
set wildmenu
set scrolloff=5
set smartcase
set ignorecase
set hls
set incsearch
set backup
set lbr
set ai
set si
set shiftwidth=4
set hidden
set clipboard=unnamed


color darkblue
call plug#begin()

call plug#end()

imap jj <Esc>
rmap jj <Esc>

nmap gp "0p
nmap gP "0P

nmap <A-d> <PageDown>
nmap <A-s> <PageUp>
imap <A-d> <PageDown>
imap <A-s> <PageUp>
vmap <A-d> <PageDown>
vmap <A-s> <PageUp>

nmap <C-n> :nohls<CR>
imap <C-n> :nohls<CR>
