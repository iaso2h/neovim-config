" File: init.vim
" Author: iaso2h
" Description: Neovim v0.50
" Last Modified: 一月 31, 2021
let $configPath = expand(stdpath('config'))
let g:NERDCreateDefaultMappings = 0
let g:expand_region_use_defaults = 0
let g:VM_default_mappings = 0
let g:sandwich_no_default_key_mappings = 1
" Plug-ins list {{{
let &runtimepath = &runtimepath . "," . expand('$configPath/dein/dein.vim')
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
Plug 'tpope/vim-scriptease'
Plug 'easymotion/vim-easymotion'
Plug 'machakann/vim-sandwich'
Plug 'tommcdo/vim-exchange'
Plug 'lag13/vim-create-variable'
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
Plug 'dm1try/golden_size'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'tmhedberg/SimpylFold'
Plug 'vim-python/python-syntax'
Plug 'jmcantrell/vim-virtualenv'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'plasticboy/vim-markdown'

Plug 'lambdalisue/gina.vim'
Plug 'liuchengxu/vista.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'dahu/VimRegexTutor'
Plug 'DanilaMihailov/vim-tips-wiki'
call plug#end()

execute "luafile " . expand("$configPath/lua/plug-colorizer.lua")
if has('win32')
    lua require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
endif
" }}} Plug-ins list
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
set guicursor=n-v-sm:block,i-c-ci:ver25-Cursor,ve-o-r-cr:hor20
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
colorscheme onedarknord
" Settings based on OS
if has('win32')
    " Python executable
    " set shell=powershell
    " set shellquote= shellpipe=\| shellxquote=
    " set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    " set shellredir=\|\ Out-File\ -Encoding\ UTF8
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
function TrimWhiteSpaces(silent)
    let l:saveView = winsaveview()
    if a:silent
        keeppatterns let g:Result = execute('%s#\s\+$##e')
    else
        keeppatterns let l:result = execute('g#\s\+$#p')
        let l:count = len(MatchAll(l:result, '\n'))
        keeppatterns let g:Result = execute('%s#\s\+$##e')
        echohl Moremsg | echom l:count . " line[s] trimmed" | echohl None
    call winrestview(l:saveView)
    endif
endfunction
" }}} Functions

" Auto commands {{{
augroup _fileType " {{{
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
    autocmd BufWritePre * call TrimWhiteSpaces(1)
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " C language
    autocmd CursorHold *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
    " Vim
    " autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim setlocal foldmethod=expr foldexpr=EnhanceFoldExpr()
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
" autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false, higroup="Search", timeout=500}
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
command! -nargs=0 TrimWhiteSpaces call TrimWhiteSpaces(0)
command! -nargs=+ Echo echom strftime('%c') . ": " . <args>
command! -nargs=* O browse oldfiles
command! -nargs=* Redir redir @* | <args> | redir END
command! -nargs=* Vim vimgrep <args> | cw
command! -nargs=0 CD execute "cd " . expand("%:p:h")
command! -nargs=0 DEINClean call map(dein#check_clean(), "delete(v:val, 'rf')")
command! -nargs=0 -range ExtractSelection call ExtractSelection(visualmode())
command! -nargs=0 -range Backward setl revins | execute "norm! gvc\<C-r>\"" | setl norevins
" Edit Vimrc
if has('win32')
    command! -nargs=0 IDEAVimedit vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit vsplit $MYVIMRC
command! -nargs=0 MyVimsrc source $MYVIMRC
" }}} Commands

" Key mapping {{{
let mapleader = "\<Space>" " First thing first
" Motion
map [Z zk
map ]Z zj
" Add jump in jumplist for motions {{{
" Changelist jumping {{{
nnoremap <expr><silent> <A-o> &diff? "mz`z[czz" : "mz`zg;zz"
nnoremap <expr><silent> <A-i> &diff? "mz`z]czz" : "mz`zg,zz"
" }}} Changelist jumping
" Count specified j/k {{{
nmap <silent> j :<c-u>call AddJumpMotion(1, "j")<cr>
nmap <silent> k :<c-u>call AddJumpMotion(1, "k")<cr>
" }}} Count specified j/k
" Search & Jumping {{{
vnoremap <silent> * mz`z:<c-u>execute "/" . VisualSelection("string")<cr>
vnoremap <silent> # mz`z:<c-u>execute "?" . VisualSelection("string")<cr>
vmap <silent> / *
vmap <silent> ? #
" Regex very magic
nnoremap / /\v
nnoremap ? ?\v
" Disable highlight search
nmap <silent> <leader>h :noh<cr>
vmap <silent> <leader>h :<c-u>call InplaceDisableVisual()<cr>
nmap <silent> go gvo<esc>
" }}} Search & Jumping
" }}} Add jump in jumplist for motions
" Scratch file
nmap <silent> <C-n> :new<cr>
" Open/Search in browser
nmap <silent> <C-l> :call OpenUrl()<cr>
xmap <silent> <C-l> :<c-u>call OpenInBrowser(VisualSelection("string"))<cr>
" Interrupt
nnoremap <C-A-c> call interrupt()<cr>
" Paragraph & Block navigation
noremap <silent> { :call InclusiveParagraph("up")<cr>
noremap <silent> } :call InclusiveParagraph("down")<cr>
" Line end/start
nmap H ^
vmap H ^
nmap L $
vmap L $
omap H ^
omap L $
" Trailing character {{{
nmap <silent> g, :call TrailingChar(",")<cr>
nmap <silent> g; :call TrailingChar(";")<cr>
nmap <silent> g: :call TrailingChar(":")<cr>:
nmap <silent> g" :call TrailingChar("\"")<cr>
nmap <silent> g' :call TrailingChar("'")<cr>
nmap <silent> g) :call TrailingChar(")")<cr>
nmap <silent> g( :call TrailingChar("(")<cr>
nmap <silent> g<C-cr> :call TrailingLinebreak("down")<cr>
nmap <silent> g<S-cr> :call TrailingLinebreak("up")<cr>
" }}} Trailing character
" Messages
nmap <silent> g< :messages<cr>
nmap <silent> g> :Messages<cr>
nmap <A-,> :execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>
nmap <A-.> :execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>
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
if has('win32') | nmap <silent> <C-`> :te powershell<cr> | endif
" Macro
nnoremap <A-q> q
" Register
function! s:ClearReg()
    for i in range(34,122) | silent! call setreg(nr2char(i), "") | endfor
    echohl Moremsg | echo "Register clear" | echohl None
endfunction
map <silent> <C-'> :reg<cr>
imap <silent> <C-'> <C-\><C-o>:reg<cr>
map <silent> <A-'> :call <SID>ClearReg()<cr>
" Buffer & Window & Tab{{{
" Smart quit
map q <Plug>smartQuit
map <silent> Q :execute "bdelete! " . bufnr()<cr>
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
" Folding {{{
noremap <silent> [z :call EnhanceFoldJump("start", 1, 0)<cr>
noremap <silent> ]z :call EnhanceFoldJump("end", 1, 0)<cr>
noremap <silent> g[z [z
noremap <silent> g]z ]z
map <silent> <leader>z :call EnhanceFoldHL("No fold marker found", 500, "")<cr>
map <silent> zd :call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>
map <silent> zc :call EnhanceFoldHL("", 0, "EnhanceChange")<cr>
nmap g{ :<c-u>call EnhanceFold(mode(), "{{{")<cr>
nmap g} :<c-u>call EnhanceFold(mode(), "}}}")<cr>
vmap g{ <A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z
vmap g} <A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z
noremap <silent> <leader><Space> @=(foldlevel('.') ? 'za' : '\<Space>')<cr>
noremap <silent> <S-Space> @=(foldlevel('.') ? 'zA' : 'zC')<cr>
for i in range(10) | silent! execute printf("noremap z%d :set foldlevel=%d<bar>echohl Moremsg<bar>echo 'Foldlevel set to: %d'<bar>echohl None<cr>", i, i, i) | endfor
" }}} Folding
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
command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<cr>
map <C-S-s> :Saveas<cr>
imap <silent> <C-S-s> <C-\><C-o>:Saveas<cr>
" Delete
nmap <C-S-d> :d<cr>
vmap <C-S-d> :d<cr>
imap <silent> <C-S-d> <C-\><C-o>:d<cr>
" Put content from registers 0
nmap <leader>p "0p
nmap <leader>P "0P
" Highlight New Paste Content
nmap <silent> gy :call HighlightLastYP("yank")<cr>
nmap gY gy
nmap <silent> gp :call HighlightLastYP("put")<cr>
nmap gP gp
" Inplace yank
nmap Y yy
vmap Y y
nmap <silent><expr> y SetInplaceYank()
vmap <silent><expr> y SetInplaceYank()
omap <silent><expr> y SetInplaceYank()
" Inplace put
nmap <silent> p :<c-u>call InplacePut(mode(), "p")<cr>
vmap <silent> p :<c-u>call InplacePut(visualmode(), "p")<cr>
nmap <silent> P :<c-u>call InplacePut(mode(), "P")<cr>
vmap <silent> P :<c-u>call InplacePut(visualmode(), "P")<cr>
" Convert paste
nmap cP :<c-u>call ConvertPut("P")<CR>
nmap cp :<c-u>call ConvertPut("p")<CR>
" Mimic the VSCode move/copy line up/down behavior {{{
" Move line {{{
nmap <silent> <A-j> :m .+1<cr>==
nmap <silent> <A-k> :m .-2<cr>==
command! -nargs=0 VSCodeLineMoveDownInsert m .+1 | execute "normal! =="
command! -nargs=0 VSCodeLineMoveUpInsert   m .-2 | execute "normal! =="
imap <A-j> <C-\><C-o>:VSCodeLineMoveDownInsert<cr>
imap <A-k> <C-\><C-o>:VSCodeLineMoveUpInsert<cr>
vmap <silent> <A-j> :m '>+1<cr>gv=gv
vmap <silent> <A-k> :m '<-2<cr>gv=gv
" }}} Move line
" Copy line {{{
nmap <silent> <A-S-j> :call VSCodeLineYank(mode(), "down")<cr>
nmap <silent> <A-S-k> :call VSCodeLineYank(mode(), "up")<cr>
imap <silent> <A-S-j> <C-\><C-o>:call VSCodeLineYank(mode(), "down")<cr>
imap <silent> <A-S-k> <C-\><C-o>:call VSCodeLineYank(mode(), "up")<cr>
vmap <silent> <A-S-j> :<c-u>call VSCodeLineYank(visualmode(), "down")<cr>
vmap <silent> <A-S-k> :<c-u>call VSCodeLineYank(visualmode(), "up")<cr>
" }}} Copy line
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
function! s:RemoveLastPathComponent() " {{{
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)

    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction " }}}
cmap <C-BS> <C-\>e(<SID>RemoveLastPathComponent())<cr>
cnoremap <C-S-l> <C-d>
cmap <C-d> <Del>
cmap <C-S-e> <C-\>e
cmap <C-v> <C-R>*
" }}} Commandline & Insert
" }}} Key mapping

" Plug-ins settings  {{{
" AndrewRadev/splitjoin.vim {{{
let g:splitjoin_join_mapping = ""
let g:splitjoin_split_mapping = ""
nmap <silent> gj :SplitjoinJoin<cr>
nmap <silent> gs :SplitjoinSplit<cr>
map gJ <nop>
" }}} AndrewRadev/splitjoin.vim
" inkarkat/vim-ReplaceWithRegister {{{
vmap R gr
" }}} inkarkat/vim-ReplaceWithRegister
" Syntax enhance {{{
" vim-python/python-syntax {{{
let g:python_highlight_all = 1
let g:python_highlight_file_headers_as_comments = 1
" }}} vim-python/python-syntax
" bfrg/vim-cpp-modern{{{
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1
" }}} bfrg/vim-cpp-modern
" }}} Syntax enhance
" lag13/vim-create-variable {{{
vmap C <Plug>Createvariable
" }}} lag13/vim-create-variable
" SirVer/ultisnips {{{
" Disable UltiSnips keymapping in favour of coc-snippets
let g:UltiSnipsExpandTrigger = ""
let g:UltiSnipsListSnippets = ""
let g:UltiSnipsJumpForwardTrigger = ""
let g:UltiSnipsJumpBackwardTrigger = ""
" }}} SirVer/ultisnips
" preservim/nerdcommenter {{{
let g:FiletypeCommentDelimiter = {
            \ "vim": "\"",
            \ "python": "#",
            \ "c": "\/\/",
            \ "cpp": "\/\/",
            \ "json": "\/\/"
            \ }
let g:NERDAltDelims_c = 1
let g:NERDAltDelims_cpp = 1
let g:NERDAltDelims_javascript = 1
function! CommentJump(keystroke) " {{{
    if getline(".") != ""
        if a:keystroke ==# "o"
            let l:saveReg = @@
            execute "normal! yypcc" . g:FiletypeCommentDelimiter[&filetype] . " "
            let @@ = l:saveReg
            startinsert!
        elseif a:keystroke ==# "O"
            let l:saveReg = @@
            execute "normal! yyPcc" . g:FiletypeCommentDelimiter[&filetype] . " "
            let @@ = l:saveReg
            startinsert!
        endif
    endif
endfunction " }}}
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

vmap <A-/> <plug>NERDCommenterAltDelims
nmap <A-/> <plug>NERDCommenterAltDelims

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
vmap <silent> <A-c> :call CaseSwitcher()<cr>
nmap <silent> <A-c> :call CaseSwitcher()<cr>
nmap <silent> <A-S-c> :call CaseSwitcherDefaultCMDListOrder()<cr>
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
" Inclusive
map <C-m> <Plug>(matchup-%)
map <C-S-m> <Plug>(matchup-g%)
" Exclusive
map m <Plug>(matchup-]%)
map M <Plug>(matchup-[%)
" Origin mark
noremap <A-m> m
" Highlight
nmap <silent> <leader>m <plug>(matchup-hi-surround)
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
nmap <silent><expr> <c-u> &buftype? ":UndotreeToggle\<cr>" : ":UndotreeToggle\<bar>UndotreeFocus\<cr>"
" }}} mbbill/undotree
" tpope/vim-repeat {{{
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)
" }}} tpope/vim-repeat
" Exchange {{{
nmap gx <Plug>(Exchange)
xmap X <Plug>(Exchange)
nmap gxc <Plug>(ExchangeClear)
nmap gxx <Plug>(ExchangeLine)
" }}} Exchange
" }}} Plug-ins settings
