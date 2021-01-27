let $configPath = expand(stdpath('config'))
let g:NERDCreateDefaultMappings = 0
let g:expand_region_use_defaults = 0
let g:VM_default_mappings = 0
let g:sandwich_no_default_key_mappings = 1

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
    " call dein#add('zatchheems/vim-camelsnek')
    "         call dein#add('norcalli/nvim-colorizer.lua')
    "         call dein#add('mhinz/vim-startify')

    " call dein#add('mbbill/undotree')
    " call dein#add('xolox/vim-session')
    " call dein#add('xolox/vim-misc')
    " call dein#add('szw/vim-maximizer')
    " call dein#add('tpope/vim-repeat')
    " call dein#add('vim-scripts/pp.vim')
    "         call dein#add('easymotion/vim-easymotion')
    "         call dein#add('machakann/vim-sandwich')
    "         call dein#add('tommcdo/vim-exchange')
    "         call dein#add('mg979/vim-visual-multi')
    "         call dein#add('junegunn/vim-easy-align')
    "         call dein#add('AndrewRadev/splitjoin.vim')
    "         call dein#add('preservim/nerdcommenter')
    "         call dein#add('inkarkat/vim-ReplaceWithRegister')
    "         call dein#add('landock/vim-expand-region')
    " call dein#add('michaeljsmith/vim-indent-object')
    " call dein#add('andymass/vim-matchup')

    "         call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})
    "         call dein#add('tmhedberg/SimpylFold')
    "         call dein#add('jmcantrell/vim-virtualenv')

    " call dein#add('lambdalisue/gina.vim')
    " call dein#add('othree/eregex.vim')
    " call dein#add('skywind3000/asyncrun.vim')
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
    Plug 'vim-scripts/pp.vim'
    Plug 'easymotion/vim-easymotion'
    Plug 'machakann/vim-sandwich'
    Plug 'tommcdo/vim-exchange'
    Plug 'mg979/vim-visual-multi'
    Plug 'junegunn/vim-easy-align'
    Plug 'AndrewRadev/splitjoin.vim'
    Plug 'preservim/nerdcommenter'
    Plug 'inkarkat/vim-ReplaceWithRegister'
    Plug 'landock/vim-expand-region'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'bkad/camelcasemotion'
    Plug 'zatchheems/vim-camelsnek'
    Plug 'andymass/vim-matchup'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'tmhedberg/SimpylFold'
    Plug 'jmcantrell/vim-virtualenv'

    Plug 'lambdalisue/gina.vim'
    Plug 'liuchengxu/vista.vim'
    Plug 'skywind3000/asyncrun.vim'
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
let mydict = expand('$configPath/dev.dict')
set ai
set cindent " set C style indent
set clipboard=unnamed
set cursorline
set cmdheight=2 "Give more space for displaying messages
set dictionary+=mydict
set expandtab " Soft tab
set fillchars=fold:-,vert:╎ "Sarasa Nerd Mono SC
set formatoptions=pj1Bml2nwc
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
set termguicolors
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
    autocmd FileType vim vnoremap <buffer> <A-f> =
    autocmd FileType vim nmap <buffer> <A-f> <A-m>zvae=`z
    autocmd FileType vim nmap <buffer> <silent> <C-S-q> :execute 'h ' . expand('<cword>')<cr>
    autocmd FileType vim vmap <silent> <C-S-q> :<c-u>execute 'h ' . VisualSelection("string")<cr>
    " autocmd FileType vim setlocal foldlevelstart=1
    " Quickfix window
    autocmd FileType qf setlocal number norelativenumber
    autocmd FileType qf map <buffer> <silent> <cr> :.cc<cr>:copen<cr>
    " Terminal
    autocmd TermOpen * startinsert
    " Help
    " autocmd FileType help if winnr('$') > 2 | wincmd J | else | wincmd L | endif
    autocmd FileType help if winwidth(0) > 128 | wincmd L | endif
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
" Backward
command! -nargs=0 -range Backward setl revins | exe "norm! gvc\<C-r>\"" | setl norevins
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
" Remap for origin ,/;
noremap ,, ,
" noremap ;; ;
" Paragraph & Block navigation
noremap <silent> { :call InclusivePragraph("up")<cr>
noremap <silent> } :call InclusivePragraph("down")<cr>
" Line end/start
nmap H ^
vmap H ^
nmap L $
vmap L $
omap H ^
omap L $
" Trailing Char
nnoremap g; :call TrailingChar(";")<cr>
nnoremap <silent> g<C-cr> :call TrailingLinebreak("down")<cr>
nnoremap <silent> g<S-cr> :call TrailingLinebreak("up")<cr>
" Messages
nmap <silent> <A-`> :messages clear<cr>:call EmptyMessage()<cr>
nmap <silent> <C-`> :messages<cr>
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
nmap <silent> <C-'> :reg<cr>
nmap <silent> <C-S-'> :call <SID>ClearReg()<cr>
" " Buffer & Window & Tab{{{
" Smart quit
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
" Search & Jumping {{{
vmap * :<c-u>execute "/" . VisualSelection("string")<cr>
vmap # :<c-u>execute "?" . VisualSelection("string")<cr>
vmap / *
vmap ? #
" Regex very magic
noremap / /\v
noremap ? ?\v
" Disable highlight search
nmap <silent> <leader>h :noh<cr>
vmap <silent> <leader>h :<c-u>call InplaceDisableVisual()<cr>
" }}} Search & Jumping
" Folding
nnoremap <silent> <leader><Space> @=(foldlevel('.') ? 'za' : '\<Space>')<cr>
vnoremap <leader>f zf
nnoremap zo zR
nnoremap zc zM
" Copy && Paste {{{
" <C-z/x/v/s> {{{
nmap <C-z> u
vmap <C-z> <esc>u
imap <C-z> <esc>ua

vmap <C-x> d
" imap <C-x> <esc>dda

nmap <C-c> Y
vmap <C-c> y
imap <C-c> <esc>Ya

nmap <C-v> i<C-v><esc>
vmap <C-v> <esc>i<C-v><esc>
imap <C-v> <C-r>*

map <C-s> :<c-u>w<cr>
imap <C-s> <esc><C-s>
" }}} <C-z/x/v/s>
" Put content from registers 0
nmap <leader>p "0p
nmap <leader>P "0P
" Highlight New Paste Content
nmap <silent> gy :call LastYPHighlight("yank")<cr>
nmap <silent> gp :call LastYPHighlight("put")<cr>
" Inplace copy
nmap Y yy
nmap <silent><expr> y SetInplaceCopy()
vmap <silent><expr> y SetInplaceCopy()
omap <silent><expr> y SetInplaceCopy()
" Inplace paste
nmap <silent> p :<c-u>call InplacePaste(mode(), "p")<cr>
vmap <silent> p :<c-u>call InplacePaste(visualmode(), "p")<cr>
nmap <silent> P :<c-u>call InplacePaste(mode(), "P")<cr>
vmap <silent> P :<c-u>call InplacePaste(visualmode(), "P")<cr>

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
" }}} Copy && Paste
" Changelist jumping
nnoremap <A-o> g;zz
nnoremap <A-i> g,zz
" Convert \ into /
nmap <silent> g/ :s#\\#\/<cr>:noh<cr>
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

" Plug-ins settings  {{{
runtime! plugin/*.vim
execute "luafile " . expand("$configPath/lua/plug-colorizer.lua")
if has('win32')
    lua require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
endif
" Exchange {{{
nmap gx <Plug>(Exchange)
xmap X <Plug>(Exchange)
nmap gxc <Plug>(ExchangeClear)
nmap gxx <Plug>(ExchangeLine)
" }}} Exchange
" NOTE: anything mapping to the <C-n> must be sourced after Visual-Multi plug-in
vmap <silent> <C-n> :ExtractSelection<cr>
nmap <silent> <C-n> :new<cr>
" preservim/nerdcommenter {{{
let g:FiletypeCommentDelimiter = {
    \ "vim": "\"",
    \ "python": "#",
    \ "c": "\\",
    \ "json": "\\"
  \ }

function! CommentJump(keystroke)
    if getline(".") != ""
        execute "normal! Y"
        if a:keystroke ==# "o"
            execute "normal! Pcca<C-\><C-o>:execute 'gc\<space>'\<cr>\<bs>"
        elseif a:keystroke ==# "O"
            execute "normal! pcca<C-\><C-o>:execute 'gc\<space>'\<cr>\<bs>"
        endif
    endif
endfunction
nmap gco :call CommentJump("o")<cr>
nmap gcO :call CommentJump("O")<cr>

nmap gc<space> <plug>NERDCommenterToggle
vmap gc<space> <plug>NERDCommenterToggle
" nmap gcn <plug>NERDCommenterNested
" vmap gcn <plug>NERDCommenterNested
nmap gci <plug>NERDCommenterInvert
vmap gci <plug>NERDCommenterInvert

nmap gcs <plug>NERDCommenterSexy
vmap gcs <plug>NERDCommenterSexy

nmap gcy <plug>NERDCommenterYank
vmap gcy <plug>NERDCommenterYank

nmap gc$ <plug>NERDCommenterToEOL
nmap gcA <plug>NERDCommenterAppend
nmap gcI <plug>NERDCommenterInsert

vmap gca <plug>NERDCommenterAltDelims
nmap gca <plug>NERDCommenterAltDelims

nmap gcn <plug>NERDCommenterAlignLeft
vmap gcn <plug>NERDCommenterAlignLeft
nmap gcb <plug>NERDCommenterAlignBoth
vmap gcb <plug>NERDCommenterAlignBoth

nmap gcu <plug>NERDCommenterUncomment
vmap gcu <plug>NERDCommenterUncomment

let g:NERDSpaceDelims              = 1
let g:NERDRemoveExtraSpaces        = 1
let g:NERDCommentWholeLinesInVMode = 1
let g:NERDLPlace="{{{"
let g:NERDRPlace="}}}"
let g:NERDCompactSexyComs = 1
let g:NERDToggleCheckAllLines = 1
" }}} preservim/nerdcommenter
" junegunn/vim-easy-align {{{
vmap A <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}} junegunn/vim-easy-align
" szw/vim-maximizer {{{
map <C-w>m <f3>
" }}} szw/vim-maximizer
" vim-xolox/vim-session {{{
let g:session_directory         = expand("$HOME/.nvimcache")
let g:session_autosave          = 'yes'
let g:session_autosave_periodic = 15
let g:session_autosave_silent   = 1
let g:session_command_aliases   = 1 " TODO
let g:session_persist_font = 0
let g:session_persist_colors = 0
" }}} vim-xolox/vim-session
" zatchheems/vim-camelsnek {{{
let g:camelsnek_alternative_camel_commands = 1
let g:camelsnek_no_fun_allowed             = 1
let g:camelsnek_iskeyword_overre           = 0
vmap <silent> <A-c> :Camel<cr>
nmap <silent> <A-c> :Camel<cr>
vmap <silent> <A-S-c> :Snake<cr>
nmap <silent> <A-S-c> :Snake<cr>
" }}} zatchheems/vim-vimsnek
" bkad/camelcasemotion {{{
call camelcasemotion#CreateMotionMappings(',')
" }}} bkad/camelcasemotion
" andymass/vim-matchup {{{
" let g:matchup_matchparen_deferred = 1
" let g:matchup_matchparen_hi_surround_always = 1
" let g:matchup_matchparen_hi_background = 1
let g:matchup_matchparen_offscreen
            \ = {'method': 'popup', 'highlight': 'OffscreenPopup'}
let g:matchup_matchparen_nomode = "i"
let g:matchup_delim_noskips = 0
" function! VimHotfix()
"     " customization
" endfunction
" let g:matchup_hotfix['vim'] = 'VimHotfix'
" Text obeject
xmap am <Plug>(matchup-a%)
xmap im <Plug>(matchup-i%)
omap am <Plug>(matchup-a%)
omap im <Plug>(matchup-i%)
" vmap vim vi%
" vmap vim vi%
" Enter Fix
noremap <cr> <cr>
" Origin mark
nnoremap <A-m> m
" Highlight
nmap <silent> <leader>m <plug>(matchup-hi-surround)
" Inclusive
map <C-m> <Plug>(matchup-%)
map <C-S-m> <Plug>(matchup-g%)
" Exclusive 
map m <Plug>(matchup-]%)
map M <Plug>(matchup-[%)
" }}} andymass/vim-matchup
" landock/vim-expand-region {{{
let g:expand_region_text_objects = {
        \ 'iw':  0,
        \ 'iW':  0,
        \ 'i"':  0,
        \ 'i''': 0,
        \ 'i]':  1,
        \ 'ib':  1,
        \ 'iB':  1,
        \ 'il':  0,
        \ 'ii':  0,
        \ 'ip':  1,
        \ 'ie':  0,
        \ }
call expand_region#custom_text_objects({
        \ "\/\\n\\n\<CR>": 0,
        \ 'i,w'  :1,
        \ 'i%'  :0,
        \ 'a]' :0,
        \ 'ab' :0,
        \ 'aB' :0,
        \ 'ai' :0,
        \ })
map <A-a> <Plug>(expand_region_expand)
map <A-s> <Plug>(expand_region_shrink)
" }}} landock/vim-expand-region
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
