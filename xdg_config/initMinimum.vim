" File: initMinimum.vim
" Author: iaso2h
" Description: Neovim v0.50
" Last Modified: 一月 31, 2021
let $configPath = expand(stdpath('config'))
" Basic settings {{{
filetype plugin on
let s:myDict = expand('$configPath/dev.dict')
set ai
set cindent expandtab shiftround shiftwidth=4 softtabstop=4 tabstop=4
set clipboard=unnamed
set cmdheight=2 "Give more space for displaying messages
set complete=.,w,b,u,t,kspell,i,d,t
set conceallevel=2
set concealcursor=nc
set cpoptions+=q "Failed on nvim_qt?
set cursorline
set dictionary+=s:myyDict
set diffopt=context:10000,filler,closeoff,vertical,algorithm:patience
set fileignorecase
set fillchars=fold:-,vert:╎
set foldcolumn=auto:4 signcolumn=auto:4
set formatoptions=pj1Bml2nwc
set gdefault
set guicursor=n-v-sm:block,i-c-ci-ve:ver25-Cursor,o-r-cr:hor20
set guifont=更纱黑体\ Mono\ SC\ Nerd:h13
set hidden
set ignorecase smartcase
set inccommand=nosplit
set keywordprg=:help
set listchars=tab:>-,precedes:<,extends:>,trail:-,nbsp:%
set langmenu=en
set lazyredraw
set mouse=a
set nojoinspaces
set noshowmode
set number
set scrolloff=8
set sessionoptions=buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize
set shada=!,'100,/100,:100,<100,s100,h
set shortmess=lxTI
set splitbelow splitright switchbuf=vsplit
set termguicolors
set timeoutlen=500
set undofile undodir=~/.nvimcache/undodir nobackup noswapfile nowritebackup
set updatetime=150
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite,*.bak
set wildignorecase
set wildoptions=pum
colorscheme slate
" Settings based on OS
if has('win32')
    " Python executable
    set shell=powershell
    set shellquote= shellpipe=\| shellxquote=
    set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    set shellredir=\|\ Out-File\ -Encoding\ UTF8
    let g:python3_host_prog = expand("$HOME/AppData/Local/Programs/Python/Python38/python.exe")
    if !executable(g:python3_host_prog)
        let s:pythonPath = substitute(system('python -c "import sys; print(sys.executable)"'), '\n\+$', '', 'g')
        let g:python3_host_prog = strtrans(s)
        if !executable(g:python3_host_prog) | throw "Python path not found" | endif
    endif
elseif has('unix')
    let s:pythonPath = substitute(system('which python3'), '\n\+$', '', 'g')
    let g:python3_host_prog = strtrans(s:pythonPath)
    " Linux input
    let g:input_toggle = 0
    autocmd InsertLeave * call <SID>Fcitx2en()
    autocmd InsertEnter * call <SID>Fcitx2zh()
endif
" }}} Basic settings

" Functions {{{
function! s:Fcitx2en()
    let s:input_status = system("fcitx-remote")
    if s:input_status == 2
        let g:input_toggle = 1
        let l:a = system("fcitx-remote -c")
    endif
endfunction
function! s:Fcitx2zh()
    let s:input_status = system("fcitx-remote")
    if s:input_status != 2 && g:input_toggle == 1
        let l:a = system("fcitx-remote -o")
        let g:input_toggle = 0
    endif
endfunction
function! Echo(expr)
    echom strftime('%c') . ":" a:expr
endfunction
function TrimWhiteSpaces()
    let l:saveView = winsaveview()
    keeppatterns let l:result = execute('g#\s\+$#p')
    let l:count = len(MatchAll(l:result, '\n'))
    keeppatterns let g:Result = execute('%s#\s\+$##e')
    echom l:count . " line[s] trimmed"
    call winrestview(l:saveView)
endfunction
" }}} Functions

" Auto commands {{{
augroup _fileType " {{{
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " Vim
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim vnoremap <buffer> <A-f> =
    autocmd FileType vim nmap <buffer> <A-f> <A-m>zvae=`z
    autocmd FileType vim nmap <buffer> <silent> <C-S-q> :execute 'h ' . expand('<cword>')<cr>
    autocmd FileType vim vmap <silent> <C-S-q> :<c-u>execute 'h ' . VisualSelection("string")<cr>
    " Quickfix window
    autocmd FileType qf setlocal number norelativenumber
    autocmd FileType qf map <buffer> <silent> <cr> :.cc<cr>:copen<cr>
    " Startify
    autocmd FileType startify nested setlocal buflisted
    " Terminal
    autocmd TermOpen * startinsert
    " Help
    autocmd BufEnter *.txt if &buftype == 'help' | if winwidth(0) > 116 | wincmd L | endif | endif
augroup END " }}}
" augroup highlightYank " {{{
" autocmd!
" autocmd TextYankPost * silent! lua vim.hl.on_yank {on_visual=false, higroup="Search", timeout=500}
" augroup END " }}}
augroup checkBufChanged " {{{
    autocmd!
    autocmd FocusGained,BufEnter * checktime
augroup end " }}}
augroup vimrcReload " {{{
    autocmd!
    autocmd bufwritepost $MYVIMRC nested source $MYVIMRC | redraw! | echom "Reload: " . $MYVIMRC
    autocmd bufwritepost *.vim if expand("%:p:h") ==# expand("$configPath" . "/plugin") |
                \ execute("source " . expand("%:p")) | redraw! | echom "Reload: " . expand("%:p") |
                \ endif
augroup END " }}}
" }}} Auto commands

" Commands {{{
command! -nargs=+ Echo call Echo(<args>)
command! -nargs=* O browse oldfiles
command! -nargs=* Redir redir @* | <args> | redir END
command! -nargs=* Vim vimgrep <args> | cw
command! -nargs=0 CD execute "cd " . expand("%:p:h")
command! -nargs=0 DEINClean call map(dein#check_clean(), "delete(v:val, 'rf')")
command! -nargs=0 -range Backward setl revins | exe "norm! gvc\<C-r>\"" | setl norevins
" Edit Vimrc
if has('win32')
    command! -nargs=0 IDEAVimedit vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit vsplit $MYVIMRC
command! -nargs=0 MyVimsrc source $MYVIMRC
" }}} Commands

" Key mapping {{{
let mapleader = "\<Space>" " First thing first
" Line end/start
nmap H ^
vmap H ^
nmap L $
vmap L $
omap H ^
omap L $
" Messages
nmap <silent> g< :messages<cr>
nnoremap g> g<
nmap <silent> <A-`> :messages clear <bar> echo "Message clear"<cr>
nmap <silent> <C-`> :Messages<cr>
" Bug
" Non-blank last character
noremap g$ g_
" Block visual mode
nnoremap <A-v> <C-q>
" Pageup/Pagedown
map <A-e> <pageup>
tmap <A-e> <pageup>
map <A-d> <pagedown>
tmap <A-d> <pagedown>
" Terminal
tmap <A-n> <C-\><C-n>
" Macro
nnoremap <A-q> q
" Register
function! s:ClearReg()
    for i in range(34,122) | silent! call setreg(nr2char(i), "") | endfor
endfunction
map <silent> <C-'> :reg<cr>
imap <silent> <C-'> <C-\><C-o>:reg<cr>
map <silent> <A-'> :call <SID>ClearReg()<cr>
" Buffer & Window & Tab{{{
" Smart quit
execute "source ".expand("$configPath/plugin/smartQuit.vim")
map q <Plug>smartQuit
map <silent> Q :bd!<cr>
" " Window
map <silent> <C-w><C-m> :only<cr>
" " Buffers
map <silent> <A-h> :bp<cr>
map <silent> <A-l> :bn<cr>
map <silent> <C-w>o :let g:CloseBufferSavedView = winsaveview() <bar>
            \ update <bar> %bd <bar> e# <bar> bd# <bar>
            \call winrestview(g:CloseBufferSavedView)<cr>
" Tab
map <silent> <A-S-h> :tabp<cr>
map <silent> <A-S-l> :tabn<cr>
" }}} Buffer & Window & Tab
" Folding
nnoremap <silent> <leader><Space> @=(foldlevel('.') ? 'za' : '\<Space>')<cr>
vnoremap <leader>f zf
nnoremap zo zR
nnoremap zc zM
" MS behavior {{{
" <C-z/v/s> {{{
nmap <C-z> u
vmap <C-z> <esc>u
imap <C-z> <C-\><C-o>u

nmap <C-c> Y
vmap <C-c> y
imap <C-c> <C-\><C-o>Y

nmap <C-v> i<C-v><esc>
vmap <C-v> <esc>i<C-v><esc>
imap <C-v> <C-r>*

nmap <C-s> :<c-u>w<cr>
vmap <C-s> :<c-u>w<cr>
imap <silent> <C-s> <C-\><C-o>:w<cr>
" }}} <C-z/x/v/s>
" Saveas
map <C-S-s> :<c-u>execute "" . input(getcwd() . "   >>>:", "saveas ")<cr>
imap <silent> <C-S-s> <C-\><C-o>:execute "" . input(getcwd() . "   >>>:", "saveas ")<cr>
" Delete
nmap <C-S-d> :d<cr>
vmap <C-S-d> :d<cr>
imap <silent> <C-S-d> <C-\><C-o>:d<cr>
" Put content from registers 0
nmap <leader>p "0p
nmap <leader>P "0P
" Highlight New Paste Content
execute "source ".expand("$configPath/plugin/copypasteUtil.vim")
execute "source ".expand("$configPath/plugin/util.vim")
nmap <silent> gy :call HighlightLastYP("yank")<cr>
nmap gY gy
nmap <silent> gp :call HighlightLastYP("put")<cr>
nmap gP gp
" Inplace copy
nmap Y yy
vmap Y y
nmap <silent><expr> y SetInplaceCopy()
vmap <silent><expr> y SetInplaceCopy()
omap <silent><expr> y SetInplaceCopy()
" Inplace paste
nmap <silent> p :<c-u>call InplacePaste(mode(), "p")<cr>
vmap <silent> p :<c-u>call InplacePaste(visualmode(), "p")<cr>
nmap <silent> P :<c-u>call InplacePaste(mode(), "P")<cr>
vmap <silent> P :<c-u>call InplacePaste(visualmode(), "P")<cr>
" Convert paste
nmap cP :<c-u>call ConvertPaste("P")<CR>
nmap cp :<c-u>call ConvertPaste("p")<CR>
" Mimic the VSCode move/copy line up/down behavior {{{
" Move line
nmap <silent> <A-j> :m .+1<cr>==
nmap <silent> <A-k> :m .-2<cr>==
command! -nargs=0 VSCodeLineMoveDownInsert m .+1 | execute "normal! =="
command! -nargs=0 VSCodeLineMoveUpInsert   m .-2 | execute "normal! =="
imap <A-j> <C-\><C-o>:VSCodeLineMoveDownInsert<cr>
imap <A-k> <C-\><C-o>:VSCodeLineMoveUpInsert<cr>
vmap <silent> <A-j> :m '>+1<cr>gv=gv
vmap <silent> <A-k> :m '<-2<cr>gv=gv
" Copy line
nmap <silent> <A-S-j> :call VSCodeLineCopy(mode(), "down")<cr>
nmap <silent> <A-S-k> :call VSCodeLineCopy(mode(), "up")<cr>
imap <silent> <A-S-j> <C-\><C-o>:call VSCodeLineCopy(mode(), "down")<cr>
imap <silent> <A-S-k> <C-\><C-o>:call VSCodeLineCopy(mode(), "up")<cr>
vmap <silent> <A-S-j> :<c-u>call VSCodeLineCopy(visualmode(), "down")<cr>
vmap <silent> <A-S-k> :<c-u>call VSCodeLineCopy(visualmode(), "up")<cr>
" }}} Mimic the VSCode move/copy line up/down behavior
" }}} MS bebhave
" Convert \ into /
nnoremap <silent> g/ mz:s#\\#\/<cr>:noh<cr>g`z
" Commandline & Insert {{{
imap <C-cr> <esc>o
imap <S-cr> <esc>O
imap jj <esc>
imap <C-d> <Del>
inoremap <S-Tab> <C-d>
inoremap <C-.> <C-a>
inoremap <C-S-.> <C-@>
" Navigation {{{
map! <C-a> <Home>
map! <C-e> <End>
map! <C-h> <Left>
map! <C-l> <Right>
map! <C-j> <Down>
map! <C-k> <Up>
map! <C-b> <C-Left>
map! <C-w> <C-Right>
map! <C-h> <Left>
" }}} Navigation
imap <C-BS> <C-\><C-o>db
function! s:RemoveLastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)

    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction
cmap <C-BS> <C-\>e(<SID>RemoveLastPathComponent())<cr>
cnoremap <C-S-l> <C-d>
cmap <C-d> <Del>
cmap <C-S-e> <C-\>e
cmap <C-v> <C-R>*
" }}} Commandline & Insert
" }}} Key mapping
