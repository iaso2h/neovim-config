let $configPath = expand(stdpath('config'))

" Plug-ins list {{{
let &runtimepath = &runtimepath . "," . expand('$configPath/dein/dein.vim')
if 1
    "     if !isdirectory(expand('$configPath/dein'))
    "         execute "autocmd VimEnter * !git clone https://github.com/Shougo/dein.vim " . expand('$configPath/dein/dein.vim')
    "         execute "autocmd VimEnter * !echo Require restarting Neovim"
    "         finish
    "     endif
    "     if !isdirectory(expand('$configPath/dein/repos'))
    "         echom "call dein#install()"
    "         execute "messages"
    "         finish
    "     endif
    "     if dein#load_state(expand('$configPath/dein'))
    "         call dein#begin(expand('$configPath/dein'))
    "         call dein#add('$configPath/dein/dein.vim')
    "         call dein#add('Shougo/deoplete.nvim')

    "         call dein#add('joshdick/onedark.vim')
    "         call dein#add('arcticicestudio/nord-vim')
    "         call dein#add('vim-airline/vim-airline')
    "         call dein#add('vim-airline/vim-airline-themes')
    "         call dein#add('luochen1990/rainbow')
    "         call dein#add('Yggdroot/indentLine')
    " call dein#add('bkad/camelcasemotion')
    "         call dein#add('norcalli/nvim-colorizer.lua')
    "         call dein#add('mhinz/vim-startify')

    " call dein#add('mbbill/undotree')
    " call dein#add('xolox/vim-session')
    " call dein#add('xolox/vim-misc')
    " call dein#add('szw/vim-maximizer')
    " call dein#add('tpope/vim-repeat')
    "         call dein#add('easymotion/vim-easymotion')
    "         call dein#add('tpope/vim-surround')
    "         call dein#add('mg979/vim-visual-multi')
    "         call dein#add('junegunn/vim-easy-align')
    "         call dein#add('AndrewRadev/splitjoin.vim')
    "         call dein#add('tpope/vim-commentary')
    "         call dein#add('inkarkat/vim-ReplaceWithRegister')
    "         call dein#add('terryma/vim-expand-region')
    " call dein#add('michaeljsmith/vim-indent-object')
    " call dein#add('andymass/vim-matchup')

    "         call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})
    "         call dein#add('tmhedberg/SimpylFold')
    "         call dein#add('jmcantrell/vim-virtualenv')

    " call dein#add('lambdalisue/gina.vim')
    " call dein#add('othree/eregex.vim')
    " call dein#add('puremourning/vimspector')
    " call dein#add('mfussenegger/nvim-dap')
    " call dein#add('mfussenegger/nvim-dap-python')
    " call dein#add('nvim-treesitter/nvim-treesitter')
    " call dein#add('theHamsta/nvim-dap-virtual-text')
    " call dein#add('liuchengxu/vista.vim')
    " call dein#add('Yggdroot/LeaderF', { 'build': './install.bat' })

    " call dein#add('dahu/VimRegexTutor')
    "         call dein#end()
    "         call dein#save_state()
    "         filetype plugin indent on
    "     endif
    "     syntax enable
    " elseif has('unix')
    call plug#begin(stdpath('config') . '/plugged')
    Plug 'joshdick/onedark.vim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'luochen1990/rainbow'
    Plug 'Yggdroot/indentLine'
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'mhinz/vim-startify'

    Plug 'mbbill/undotree'
    Plug 'xolox/vim-session'
    Plug 'xolox/vim-misc'
    Plug 'szw/vim-maximizer'
    Plug 'tpope/vim-repeat'
    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-surround'
    Plug 'mg979/vim-visual-multi'
    Plug 'junegunn/vim-easy-align'
    Plug 'AndrewRadev/splitjoin.vim'
    Plug 'tpope/vim-commentary'
    Plug 'inkarkat/vim-ReplaceWithRegister'
    Plug 'terryma/vim-expand-region'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'bkad/camelcasemotion'
    Plug 'andymass/vim-matchup'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'tmhedberg/SimpylFold'
    Plug 'jmcantrell/vim-virtualenv'

    Plug 'lambdalisue/gina.vim'
    Plug 'liuchengxu/vista.vim'
    Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
    " Plug 'othree/eregex.vim'
    " Plug 'puremourning/vimspector'
    Plug 'mfussenegger/nvim-dap'
    Plug 'mfussenegger/nvim-dap-python'
    Plug 'theHamsta/nvim-dap-virtual-text'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    Plug 'dahu/VimRegexTutor'
    call plug#end()
endif
" }}} Plug-ins list
" Basic settings {{{
set ai
set cindent " set C style indent
set clipboard=unnamed
set cursorline
set cmdheight=2 "Give more space for displaying messages
set expandtab " Soft tab
set fillchars=fold:-,vert:╎ "Sarasa Nerd Mono SC
set gdefault
set guicursor=n-v-sm:block,i-c-ci-ve:ver25-Cursor,o-r-cr:hor20
set hidden
set ignorecase " ignorecase for / and ?, work with smartcase
set inccommand=nosplit " live substitution
set langmenu=en
set lazyredraw " Make Macro faster
set mouse=a
set nobackup
set noswapfile
set nostartofline
set nowritebackup
set number
set scrolloff=5
set sessionoptions=buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize
set shiftround " Indent/outdent to nearest tabstop
set shiftwidth=4 " Indent/outdent by four columns
set shortmess=lxTI
set smartcase
set softtabstop=4 " Indentation levels every four columns
set splitbelow
set splitright
set switchbuf=vsplit
set tabstop=4
set timeoutlen=500
set undofile " Combine with undotree plugin
set updatetime=150
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite,*.bak

" Settings based on OS
if has('win32')
    " Python executable
    let s = substitute(system('python -c "import sys; print(sys.executable)"'), '\n\+$', '', 'g')
    let g:python3_host_prog = strtrans(s)
elseif has('unix')
    " Python executable
    let s = substitute(system('which python3'), '\n\+$', '', 'g')
    let g:python3_host_prog = strtrans(s)
    " Linux input
    let g:input_toggle = 0
    function! Fcitx2en()
        let s:input_status = system("fcitx-remote")
        if s:input_status == 2
            let g:input_toggle = 1
            let l:a = system("fcitx-remote -c")
        endif
    endfunction

    function! Fcitx2zh()
        let s:input_status = system("fcitx-remote")
        if s:input_status != 2 && g:input_toggle == 1
            let l:a = system("fcitx-remote -o")
            let g:input_toggle = 0
        endif
    endfunction

    autocmd InsertLeave * call Fcitx2en()
    autocmd InsertEnter * call Fcitx2zh()
endif
" }}} Basic settings

" Functions {{{
function! Echom(expr)
    echom strftime('%c') . ":" a:expr
endfunction
" }}}

" Auto commands {{{
augroup mySession
    autocmd VimLeave * call MakeSession()
augroup END
" fileType {
augroup _fileType
    autocmd!
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " Quick seperating line
    " autocmd FileType javascript nnoremap <buffer> gS iconsole.log("-".reapet(65))<esc>o
    " autocmd FileType python     nnoremap <buffer> gS iprint("-"*65)<esc>o<cr>
    nnoremap gs jO<esc>65a-<esc>gccj
    " C language
    autocmd BufRead *.c,*.h	execute "1;/^{"
    " Vim
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim xnoremap <buffer> <A-f> =
    autocmd FileType vim nmap <buffer> <A-f> <C-m>zvae=`z
<<<<<<< HEAD
    autocmd FileType vim nmap <buffer> <silent> <A-S-q> :execute 'h ' . expand('<cword>')<cr>
    autocmd FileType vim xmap <silent> <A-S-q> :<c-u>execute 'h ' . VisualSelection("string")<cr>
=======
>>>>>>> a3b35b323e6e2f680dd1507fd654fb3278a65ddd
    " autocmd FileType vim setlocal foldlevelstart=1
    " Quickfix window
    autocmd FileType qf setlocal number norelativenumber
    autocmd FileType qf map <buffer> <silent> <cr> :.cc<cr>:copen<cr>
    " Terminal
    autocmd TermOpen * startinsert
    autocmd TermEnter * map <buffer> <A-S-q> <C-\><C-n>
    " Help
    autocmd FileType help if winnr('$') > 2 | wincmd J | else | wincmd L | endif
augroup END
" } fileType
" Clear cmd line message {
function! EmptyMessage()
    if mode() ==# 'n'
        echo ''
    endif
endfunction
" augroup cmd_msg_cls
"     autocmd!
"     autocmd CmdlineLeave :  call timer_start(5000, funcref('Empty_message'))
" augroup END
" } Clear cmd line message


" Autoreload vimrc {
augroup vimrcReload
    autocmd!
    autocmd bufwritepost $MYVIMRC nested source $MYVIMRC | redraw! | echom "Reload: " . $MYVIMRC
    autocmd bufwritepost *.vim if expand("%:p:h") ==# expand("$configPath" . "/plugin") | 
                \ execute("source " . expand("%:p")) | redraw! | echom "Reload: " . expand("%:p") |
                \ endif
augroup END
" } Autoreload vimrc
" }}} Auto commands

" Commands {{{
" Echo with time
command! -nargs=+ Echom call Echom(<args>)
" Custom old files
" TODO filter duplicate items
command! -nargs=* O browse oldfiles
" Redir command line output to clipboard
command! -nargs=* Redir redir @* | <args> | redir END
" Custom Vim grep
command! -nargs=* Vim vimgrep <args> | cw
" CWD
command! -nargs=0 CD execute "cd " . expand("%:p:h")
" Debug mode
command! -nargs=0 Debug echom getcwd()
" Dein
command! -nargs=0 DEINClean call map(dein#check_clean(), "delete(v:val, 'rf')")
" Edit Vimrc
if has('win32')
    command! -nargs=0 PS | terminal powershell
    command! -nargs=0 IDEAVimedit vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit vsplit $MYVIMRC
command! -nargs=0 MyVimsrc source $MYVIMRC
" }}} Commands

" Key mapping {{{
let mapleader = "\<Space>" " First thing first
<<<<<<< HEAD
" Paragraph & Block navigation
noremap { {j
noremap } }k
noremap [ [[
noremap ] ]]
noremap <A-]> []
noremap <A-[> ][
" Line end/start
noremap H ^
noremap L $
" Force enter a linebreak for LSP popup
=======
" Force enter a linebreak for LSP
>>>>>>> a3b35b323e6e2f680dd1507fd654fb3278a65ddd
imap <C-cr> <esc>o
" Regex very magic
noremap / /\v
noremap ? ?\v
<<<<<<< HEAD
" Trailing symbol
nmap <silent> g; :call TrailingSemicolon()<cr>
nmap <silent> g<cr> :call TrailingLinebreak()<cr>
=======
" Vim query under cursor
nmap <silent> <A-q> :execute 'h ' . expand('<cword>')<cr>
xmap <silent> <A-q> :<c-u>execute 'h ' . VisualSelection("string")<cr>
" Trailing semicolon
nmap <silent> g; <Plug>trailingSemicolon
>>>>>>> a3b35b323e6e2f680dd1507fd654fb3278a65ddd
" Messages
nnoremap <silent> <A-`> :messages clear<cr>:call EmptyMessage()<cr>
nnoremap <silent> <C-`> :messages<cr>
" Non-blank last character
nnoremap g$ g_
" Ctrl-BS for ins
imap <C-BS> <C-\><C-o>db
" <C-z/x/v/s> {{{
nnoremap <C-z> u
xnoremap <C-z> <esc>u
inoremap <C-z> <esc>ua

xnoremap <C-x> d
inoremap <C-x> <esc>dda

nnoremap <C-c> yy
xnoremap <C-c> y
inoremap <C-c> <esc>yya

nmap <C-v> i<C-v><esc>
xmap <C-v> <esc>i<C-v><esc>
inoremap <C-v> <C-r>*

map <C-s> :<c-u>w<cr>
imap <C-s> <esc><C-s>
" }}} <C-z/x/v/s>
" Block visual mode
nnoremap <A-v> <C-q>
" Pageup/Pagedown
noremap <A-e> <pageup>
tnoremap <A-e> <pageup>
noremap <A-d> <pagedown>
tnoremap <A-d> <pagedown>
" Macro
<<<<<<< HEAD
nnoremap <C-q> q
=======
nnoremap gq q
>>>>>>> a3b35b323e6e2f680dd1507fd654fb3278a65ddd
" Buffer & Window {{{
" Smart quit
map q <Plug>smartQuit
map <silent> Q :bd!<cr>
" Cycle buffers
noremap <silent> <C-h> :bp<cr>
noremap <silent> <C-l> :bn<cr>
nnoremap <silent> <C-w>o :w <bar> %bd <bar> e# <bar> bd# <cr> " Close other buffers except for the current editting one
" nnoremap <silent> <C-w>V <C-w>v
" nnoremap <silent> <C-w>S <C-w>v
" }}} Buffer & Window
" VisualSelection
xnoremap * :<c-u>execute "/" . VisualSelection("string")<cr>
xnoremap # :<c-u>execute "?" . VisualSelection("string")<cr>
xmap / *
xmap ? #
" Folding
nnoremap <silent> <leader><Space> @=(foldlevel('.') ? 'za' : '\<Space>')<cr>
xnoremap <leader>f zf
nnoremap zo zR
nnoremap zc zM
" Inplace copy
xmap <silent> y :<c-u>call InplaceCopy(visualmode())<cr>
" Disable highlight search
nmap <silent> <leader>h :noh<cr>
xmap <silent> <leader>h :<c-u>call InplaceDisableVisual(visualmode())<cr>
" Mimic the VSCode move line up/down behavior
nnoremap <silent> <A-j> :m .+1<cr>==
nnoremap <silent> <A-k> :m .-2<cr>==
xnoremap <silent> <A-j> :m '>+1<cr>gv=gv
xnoremap <silent> <A-k> :m '<-2<cr>gv=gv
imap <silent> <A-j> <esc><A-j>
imap <silent> <A-k> <esc><A-k>
nnoremap <silent> <A-S-j> :call VSCodeLineCopy(mode(), "down")<cr>
nnoremap <silent> <A-S-k> :call VSCodeLineCopy(mode(), "up")<cr>
xnoremap <silent> <A-S-j> :<c-u>call VSCodeLineCopy(visualmode(), "down")<cr>
xnoremap <silent> <A-S-k> :<c-u>call VSCodeLineCopy(visualmode(), "up")<cr>
" Quit insert
inoremap jj <esc>
" Put content from registers 0
nnoremap gp "0p
nnoremap gP "0P
" Changelist jumping
nnoremap <A-o> g;zz
nnoremap <A-i> g,zz
" Convert \ into /
nnoremap <silent> g/ :s/\\/\//<cr>:noh<cr>
" Yank from above and below
nnoremap yk kyyp
nnoremap yj jyyP
" Commandline {{{
function! s:RemoveLastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)

    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction
cmap <C-BS> <C-\>e(<SID>RemoveLastPathComponent())<cr>
cmap <C-e> <C-\>e
cmap <C-v> <C-R>*
cmap <A-h> <Left>
cmap <A-l> <Right>
cmap <A-w> <S-Right>
cmap <A-b> <S-Left>
cmap <A-k> <Up>
cmap <A-j> <Down>
cmap <A-d> <Del>
cmap <A-e> <End>
cmap <A-a> <Home>

" }}}Commandline
" Shift-Tab to outdent for insert mode
inoremap <S-Tab> <C-d>
" Unmap
map <up> <nop>
imap <up> <nop>
map <down> <nop>
imap <down> <nop>
map <left> <nop>
imap <left> <nop>
map <right> <nop>
imap <right> <nop>
"  }}} Key mapping

" Plug-ins settings  {{{
runtime! plugin/*.vim
execute "luafile " . expand("$configPath/lua/plug-colorizer.lua")
if has('win32')
    lua require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
endif
" tpope/vim-surround {{{
xmap S< S>
" }}}
" junegunn/vim-easy-align {{{
xmap A <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}} junegunn/vim-easy-align
" szw/vim-maximizer {{{
map <C-w>m <f3>
" }}} szw/vim-maximizer
" vim-xolox/vim-session {{{
let g:session_directory = expand("$HOME/.nvimcache")
let g:session_autosave = 'yes'
let g:session_autosave_periodic = 15
let g:session_autosave_silent = 1
let g:session_command_aliases = 1 " TODO
" }}} vim-xolox/vim-session
" bkad/camelcasemotion {{{
call camelcasemotion#CreateMotionMappings(',')
" }}} bkad/camelcasemotion
" andymass/vim-matchup {{{
" let g:matchup_matchparen_deferred = 1
" let g:matchup_matchparen_hi_surround_always = 1
" let g:matchup_matchparen_hi_background = 1
let g:matchup_matchparen_offscreen
            \ = {'method': 'popup', 'highlight': 'OffscreenPopup'}
" BUG do not highlight mathup word agian after being selected in visual modes
let g:matchup_matchparen_nomode = "i"
" let g:matchup_matchparen_nomode = "ivV\<c-v>"
let g:matchup_surround_enabled = 1
let g:matchup_delim_noskips = 0
" function! VimHotfix()
"     " customization
" endfunction
" let g:matchup_hotfix['vim'] = 'VimHotfix'
" Origin mark
nnoremap <c-m> m
nmap <silent> <leader>m <plug>(matchup-hi-surround)
" Inclusive
map <A-m> <Plug>(matchup-%)
map <A-S-m> <Plug>(matchup-g%)
" Exclusive 
map m <Plug>(matchup-]%)
map M <Plug>(matchup-[%)
" Text obeject
xmap am <Plug>(matchup-a%)
xmap im <Plug>(matchup-i%)
nmap dim di%
nmap dam da%
nmap cim ci%
nmap cam ca%
nmap dsm ds%
nmap csm cs%
" }}} andymass/vim-matchup
" terryma/vim-expand-region {{{
call expand_region#custom_text_objects({
            \ "\/\\n\\n\<cr>": 0,
            \ 'a]' :1,
            \ 'ab' :1,
            \ 'aB' :1,
            \ 'ii' :1,
            \ 'ai' :1,
            \ })
" call expand_region#custom_text_objects('ruby', {
"         \ 'im' :0,
"         \ 'am' :0,
"         \ })
map <A-a> <Plug>(expand_region_expand)
map <A-s> <Plug>(expand_region_shrink)
" }}} terryma/vim-expand-region
" liuchengxu/vista.vim {{{
let g:vista_default_executive = 'ctags'
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista#finders = ['fzf']
" Base on Sarasa Nerd Mono SC
let g:vista#renderer#icons = {
            \   "variable": "\uF194",
            \   }
nmap <leader>s :Vista!!<cr>
" }}} liuchengxu/vista.vim
" mbbill/undotree {{{
nmap <silent> <c-u> :UndotreeToggle<cr>
" }}} mbbill/undotree
" tpope/vim-repeat {{{
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)
" }}} tpope/vim-repeat
" }}} Plug-ins settings

