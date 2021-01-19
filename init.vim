let $configPath = expand(stdpath('config'))

" Plug-ins list {{{
let &runtimepath = &runtimepath . "," . expand('$configPath/dein/dein.vim')
if has('unix')
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
"         call dein#add('norcalli/nvim-colorizer.lua')
"         call dein#add('mhinz/vim-startify')

"         call dein#add('mbbill/undotree')
"         call dein#add('easymotion/vim-easymotion')
"         call dein#add('tpope/vim-surround')
"         call dein#add('mg979/vim-visual-multi')
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
" "         call dein#add('junegunn/fzf', { 'build': 'powershell.exe ./install.ps1', 'merged': 0 })
" "         call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
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
    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-surround'
    Plug 'mg979/vim-visual-multi'
    Plug 'tpope/vim-commentary'
    Plug 'inkarkat/vim-ReplaceWithRegister'
    Plug 'terryma/vim-expand-region'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'andymass/vim-matchup'
         
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'tmhedberg/SimpylFold'
    Plug 'jmcantrell/vim-virtualenv'

    Plug 'lambdalisue/gina.vim'
    Plug 'othree/eregex.vim'
    Plug 'coot/CRDispatcher'
    Plug 'coot/EnchantedVim'
    Plug 'liuchengxu/vista.vim'
    " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    " Plug 'junegunn/fzf.vim'
    Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

    Plug 'dahu/VimRegexTutor'
    call plug#end()
endif
" }}} Plug-ins list
" Basic settings {{{
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
set ai
set cindent " set C style indent
set clipboard=unnamed
set cursorline
set cmdheight=2 "Give more space for displaying messages
set expandtab " Soft tab
set gdefault
" set guicursor=n-v:block-NordMain,c-i-ci-ve:ver25,r-cr-o:hor25,a:blinkwait300-blinkoff150-blinkon200-NordMain,sm:block-blinkwait175-blinkoff150-blinkon175
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
function! EchoTime(expr)
    echom strftime('%c') . ":" a:expr
endfunction
" }}}

" Auto commands {{{
augroup mySession
    autocmd VimLeave * nested++ MakeSession
augroup END
" fileType {
augroup _fileType
    autocmd!
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " Quick seperating line
    autocmd FileType javascript nnoremap <buffer> gS iconsole.log("-".reapet(65))<Esc>o
    autocmd FileType python     nnoremap <buffer> gS iprint("-"*65)<Esc>o<CR>
    nnoremap gs jO<Esc>65a-<Esc>gccj
    " C language
    autocmd BufRead *.c,*.h	execute "1;/^{"
    " Vim
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim setlocal foldlevelstart=1
    " Quickfix window
    autocmd FileType qf setlocal number norelativenumber
    autocmd FileType qf map <buffer> <silent> <CR> :.cc<CR>:copen<CR>
    autocmd TermOpen * startinsert
    " Terminal
    autocmd TermEnter * map <buffer> <A-S-q> <C-\><C-n>
    " Help
    autocmd FileType help if winnr('$') > 2 | wincmd J | else | wincmd L | endif
augroup END
" } fileType
" Clear cmd line message {
function! s:emptyMessage(timer)
    if mode() ==# 'n'
        echo ''
    endif
endfunction
" augroup cmd_msg_cls
"     autocmd!
"     autocmd CmdlineLeave :  call timer_start(5000, funcref('s:empty_message'))
" augroup END
" } Clear cmd line message


" Autoreload vimrc {
augroup vimrcReload
    autocmd!
    autocmd bufwritepost $MYVIMRC nested source $MYVIMRC | redraw! | echom "Reload: " . $MYVIMRC
    autocmd bufwritepost *.vim if expand("%:p:h") ==# expand("$configPath" . "/runtimeConfig") | 
                \ execute("source " . expand("%:p")) | redraw! | echom "Reload: " . expand("%:p") |
                \ endif
augroup END
" } Autoreload vimrc
" }}} Auto commands

" Commands {{{
" Echo with time
command! -nargs=+ EchoTime :call EchoTime(<args>)
" Custom old files
" TODO filter duplicate items
command! -nargs=* O :browse oldfiles
" Redir command line output to clipboard
command! -nargs=* Redir :redir @* | <args> | redir END
" Custom Vim grep
command! -nargs=* VIM :vimgrep <args> | cw
" CWD
command! -nargs=0 CD :execute "cd " . expand("%:p:h")
" PWD
command! -nargs=0 PWD :echom getcwd()
" Dein
command! -nargs=0 DEINClean :call map(dein#check_clean(), "delete(v:val, 'rf')")
" Edit Vimrc
if has('win32')
    command! -nargs=0 PS | terminal powershell
    command! -nargs=0 IDEAVimedit :vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit :vsplit $MYVIMRC
command! -nargs=0 MyVimsrc :source $MYVIMRC
" }}} Commands

" Key mapping {{{
let mapleader = "\<Space>" " First thing first
" Vim query under cursor
nmap <silent> <A-q> :execute 'h ' . expand('<cword>')<CR>
" Bring up terminal
if has('win32') | exe "map <silent> <C-`> :PS<CR>" |
            \elseif has('unix') | exe "map <silent> <C-`> :te<CR>" | endif
" Trailing semicolon
nmap <silent> g; <Plug>trailingSemicolon
" Clear messages
nnoremap <silent> <A-`> :messages clear<CR>
" Non-blank last character
nnoremap g$ g_
" Ctrl-BS for ins
inoremap <C-BS> <C-\><C-o>db
" <C-z/x/v/s> {{{
nnoremap <C-z> u
xnoremap <C-z> <Esc>u
inoremap <C-z> <Esc>ua

xnoremap <C-x> d
inoremap <C-x> <Esc>dda

nnoremap <C-c> yy
xnoremap <C-c> y
inoremap <C-c> <Esc>yya

nmap <C-v> i<C-v><Esc>
xmap <C-v> <Esc>i<C-v><Esc>
inoremap <C-v> <C-r>*

map <C-s> :<c-u>w<CR>
imap <C-s> <Esc><C-s>
" }}} <C-z/x/v/s>
" Block visual mode
nnoremap <A-v> <C-q>
" Show messages
nnoremap <silent> <leader>m :messages<CR>
" Pageup/Pagedown
noremap <A-e> <pageup>
inoremap <A-e> <pageup>
tnoremap <A-e> <pageup>
noremap <A-d> <pagedown>
inoremap <A-d> <pagedown>
tnoremap <A-d> <pagedown>
" Macro
nnoremap Q q
" Buffer & Window {{{
" Smart quit
map q <Plug>smartQuit
" Cycle buffers
nnoremap <silent> <C-h> :bp<CR>
nnoremap <silent> <C-l> :bn<CR>
" nnoremap <silent> <C-w>V <C-w>v
" nnoremap <silent> <C-w>S <C-w>v
" }}} Buffer & Window

nnoremap <silent> <C-w>o :w <bar> %bd <bar> e# <bar> bd# <CR> " Close other buffers except for the current editting one
" Folding
nnoremap <silent> <Leader><Space> @=(foldlevel('.') ? 'za' : '\<Space>')<CR>
xnoremap <Leader>f zf
nnoremap zo zR
nnoremap zc zM
" Mimic the VSCode move line up/down behavior
nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==
xnoremap <silent> <A-j> :m '>+1<CR>gv=gv
xnoremap <silent> <A-k> :m '<-2<CR>gv=gv
imap <silent> <A-j> <Esc><A-j>
imap <silent> <A-k> <Esc><A-k>
nnoremap <A-S-k> mz"*yygp`z
nnoremap <A-S-j> mz"*yygP`z
" Quit insert
inoremap jj <esc>
" Disable highlight search
nnoremap <silent> <Leader>h :noh<CR>
xnoremap <silent> <Leader>h :<c-u><Esc>
" Put content from registers 0
nnoremap <leader>p "0p
nnoremap <leader>P "0P
" Changelist jumping
nnoremap <A-o> g;
nnoremap <A-i> g,
" Convert \ into /
nnoremap <silent> g/ :s/\\/\//<CR>:noh<CR>
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
cnoremap <C-BS> <C-\>e(<SID>RemoveLastPathComponent())<CR>
cnoremap <C-V> <C-R>*
cnoremap <A-h> <Left>
cnoremap <A-l> <Right>
cnoremap <A-w> <S-Right>
cnoremap <A-b> <S-Left>
cnoremap <A-k> <Up>
cnoremap <A-j> <Down>
cnoremap <A-d> <Del>
cnoremap <A-e> <End>
cnoremap <A-a> <Home>

cnoremap <C-e> <C-\>e
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
runtime! runtimeConfig/*.vim
runtime! utility/*.vim

" execute "luafile " . expand("$configPath/lua/plug-colorizer.lua")
" Eregx
nnoremap <leader>/ :call eregex#toggle()<CR>
" Enchanted Vim
let g:VeryMagic = 0
" let g:VeryMagicSubstitute = 1  " (default is 0)
" let g:VeryMagicGlobal = 1  " (default is 0)
" let g:VeryMagicVimGrep = 1  " (default is 0)
" let g:VeryMagicSearchArg = 1  " (default is 0, :edit +/{pattern}))
" let g:VeryMagicFunction = 1  " (default is 0, :fun /{pattern})
" let g:VeryMagicHelpgrep = 1  " (default is 0)
" let g:VeryMagicRange = 1  " (default is 0, search patterns in command ranges)
" let g:VeryMagicEscapeBackslashesInSearchArg = 1  " (default is 0, :edit +/{pattern}))
" let g:SortEditArgs = 1  " (default is 0, see below)
" Search visual selected
xnoremap * :<C-u>execute "/" . VisualSelection()<CR>
xnoremap # :<C-u>execute "?" . VisualSelection()<CR>
" Matchup {{{
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
" Mark
nnoremap gm m
nmap <silent> <A-m> <plug>(matchup-hi-surround)
" Inclusive
map <C-m> <Plug>(matchup-%)
map <C-A-m> <Plug>(matchup-g%)
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
" }}} Matchup

" Expand region {{{
call expand_region#custom_text_objects({
        \ "\/\\n\\n\<CR>": 0,
        \ 'a]' :1,
        \ 'ab' :1,
        \ 'aB' :1,
        \ 'ii' :1,
        \ 'ai' :1,
        \ 'i%' :1,
        \ 'a%' :1,
        \ })
" call expand_region#custom_text_objects('ruby', {
"         \ 'im' :0,
"         \ 'am' :0,
"         \ })
map H <Plug>(expand_region_shrink)
map L <Plug>(expand_region_expand)
" }}} Expand region

" Vista {{{
let g:vista_default_executive = 'ctags'
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista#finders = ['fzf']
" Base on Sarasa Nerd Mono SC
let g:vista#renderer#icons = {
            \   "variable": "\uF194",
            \   }
" Vista
nmap <leader>s :Vista!!<CR>
" }}} Vista
" UndotreeToggle
nmap <silent> <C-u> :UndotreeToggle<CR>
" }}} Plug-ins settings

