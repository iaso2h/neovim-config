let $configPath = expand(stdpath('config'))
" Plug-in list {{{
let &runtimepath = &runtimepath . "," . expand("$configPath/dein/repos/github.com/Shougo/dein.vim")
if has('win32')
    if dein#load_state(expand("$configPath/dein"))
        call dein#begin(expand("$configPath/dein"))
        call dein#add(&runtimepath)
        call dein#add('Shougo/deoplete.nvim')

        call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})
        call dein#add('tmhedberg/SimpylFold')

        call dein#add('joshdick/onedark.vim')
        call dein#add('arcticicestudio/nord-vim')
        call dein#add('vim-airline/vim-airline')
        call dein#add('vim-airline/vim-airline-themes')
        call dein#add('luochen1990/rainbow')
        call dein#add('norcalli/nvim-colorizer.lua')
        call dein#add('mhinz/vim-startify')
        call dein#add('jmcantrell/vim-virtualenv')
        call dein#add('lambdalisue/gina.vim')
        call dein#add('liuchengxu/vista.vim')
        call dein#add('junegunn/fzf', { 'merged': 0 })
        call dein#add('junegunn/fzf.vim')
        call dein#add('preservim/nerdtree')
        call dein#add('mbbill/undotree')
        call dein#add('Yggdroot/indentLine')

        call dein#add('jeffkreeftmeijer/vim-numbertoggle')
        call dein#add('easymotion/vim-easymotion')
        call dein#add('tpope/vim-surround')
        call dein#add('mg979/vim-visual-multi')
        call dein#add('tpope/vim-commentary')
        call dein#add('inkarkat/vim-ReplaceWithRegister')
        call dein#add('terryma/vim-expand-region')
        call dein#add('michaeljsmith/vim-indent-object')
        call dein#add('vim-utils/vim-line')

        call dein#end()
        call dein#save_state()
        filetype plugin indent on
    endif
    syntax enable
elseif has('unix')
    call plug#begin(stdpath('config') . '/plugged')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'tmhedberg/SimpylFold'

    Plug 'joshdick/onedark.vim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'luochen1990/rainbow'
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'mhinz/vim-startify'
    Plug 'jmcantrell/vim-virtualenv'
    Plug 'lambdalisue/gina.vim'
    Plug 'liuchengxu/vista.vim'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    Plug 'preservim/nerdtree'
    Plug 'mbbill/undotree'
    Plug 'Yggdroot/indentLine'

    Plug 'jeffkreeftmeijer/vim-numbertoggle'
    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-surround'
    Plug 'mg979/vim-visual-multi'
    Plug 'tpope/vim-commentary'
    Plug 'inkarkat/vim-ReplaceWithRegister'
    Plug 'terryma/vim-expand-region'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'vim-utils/vim-line'
    call plug#end()
endif
" }}} Plug-in list

" Basic settings {{{
set ai
set cindent " set C style indent
set clipboard=unnamed
set cmdheight=2 "Give more space for displaying messages
set cursorline
set expandtab " Soft tab
set gdefault
set hidden
set ignorecase " ignorecase for / and ?, work with smartcase
set inccommand=nosplit " live substitution
set langmenu=en
set lazyredraw " Make Macro faster
set mouse=a
set nobackup
set noswapfile " Diable annoying swap file notification
set nowritebackup
set number relativenumber
set scrolloff=5
set shiftround " Indent/outdent to nearest tabstop
set shiftwidth=4 " Indent/outdent by four columns
set shortmess+=c " don't give ins-completion-menu messages.
set smartcase
set softtabstop=4 " Indentation levels every four columns
set tabstop=4
set timeoutlen=500
set undofile " Combine with undotree plugin
set updatetime=300
let mapleader = "\<Space>" " First thing first

let s:configPathLength = len(expand($configPath)) + 1
let s:rcFiles = split(glob(expand("$configPath/runtimeConfig") . "/*.vim"), "\n")
for rc in s:rcFiles
    execute "runtime " . rc[s:configPathLength:]
endfor

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

" Plug-in settings {{{
" NERDTree
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
" Startify
hi StartifyHeader  ctermfg=111
hi StartifyFooter  ctermfg=111
hi StartifyBracket ctermfg=240
hi StartifyPath    ctermfg=245
hi StartifyNumber  ctermfg=215
hi StartifySlash   ctermfg=240
" Easymotion configuration
let g:EasyMotion_smartcase = 1
" Expand region configuration
call expand_region#custom_text_objects({
            \ 'a]' :1,
            \ 'ab' :1,
            \ 'ii' :0,
            \ 'aB' :1,
            \ 'ai' :0,
            \ })
" Visual-multi
let g:VM_maps = {}
let g:VM_maps["Undo"] = 'u'
let g:VM_maps["Redo"] = '<C-r>'
let g:VM_maps['Find Under']  = '<C-d>'
let g:VM_maps['Select All']  = '<M-n>'
let g:VM_maps['Visual All']  = '<M-n>'
let g:VM_maps['Skip Region'] = '<C-x>'
" Vista
let g:vista_default_executive = 'ctags'
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista#finders = ['fzf']
" }}} Plug-in settings

" Commands {{{
" Auto commands {
augroup _fileType
    autocmd!
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " Quick seperating line
    autocmd FileType javascript nnoremap <buffer> gS iconsole.log("-".reapet(65))<Esc>o
    autocmd FileType python     nnoremap <buffer> gS iprint("-"*65)<Esc>o<CR>
    " C language
    autocmd BufRead *.c,*.h	execute "1;/^{"
    " Vim
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim setlocal foldlevelstart=1
    " Help
    autocmd FileType help map <buffer> <silent> q :q<CR>
    " Quickfix window
    autocmd FileType qf setlocal number norelativenumber
    autocmd FileType qf map <buffer> <silent> <CR> :.cc<CR>:copen<CR>
    autocmd FileType qf map <buffer> <silent> q :q<CR>
    " Terminal
    autocmd TermOpen * startinsert
augroup END

nnoremap gs jO<Esc>65a-<Esc>gccj

" Clear cmd line message
function! s:emptyMessage(timer)
  if mode() ==# 'n'
    echo ''
  endif
endfunction
" augroup cmd_msg_cls
"     autocmd!
"     autocmd CmdlineLeave :  call timer_start(5000, funcref('s:empty_message'))
" augroup END
" Autoreload vimrc
function! s:myVimrcCheck(currentFile)
    let l:pathEqual = 0
    for vimrc in s:rcFiles
        if a:currentFile ==# vimrc
            let l:pathEqual = 1
            break
        endif
    endfor
    if l:pathEqual
        execut("source " . a:currentFile) | redraw! | AirlineRefresh | echom "Reload: " . a:currentFile
    endif
endfunction
augroup vimrcReload
    autocmd!
    autocmd bufwritepost $MYVIMRC nested source $MYVIMRC | redraw! | AirlineRefresh | echom "Reload: " . $MYVIMRC
    autocmd bufwritepost *.vim call <SID>myVimrcCheck(expand("%:p"))
augroup END
" } Auto commands

" Custom commands {
" Open file in oldfile list
command! -nargs=1 E :e #<<args>
" Redir command line output to clipboard
command! -nargs=* Redir :redir @* | <args> | redir END
" Custom Vim grep
" NOTE: execute "vim /<C-U>/j " . expand($VIMRUNTIME) . "/doc/*" | cw
" NOTE: VIM /\v<C-U>/j $VIMRUNTIME/doc/*
command! -nargs=* VIM :vimgrep <args> | cw
" CWD
command! -nargs=0 CD :execute "cd " . expand("%:p:h")
" PWD
command! -nargs=0 PWD :echom getcwd()
" Dein
command! -nargs=0 DEINClean :call map(dein#check_clean(), "delete(v:val, 'rf')")
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocActio('runCommand', 'editor.action.organizeImport')
" Toggle Coc Spell-checker
command! -nargs=0 Spell   :CocCommand cSpell.toggleEnableSpellChecker
" Edit Vimrc
if has('win32')
    command! -nargs=0 PS | terminal powershell
    command! -nargs=0 IDEAVimedit :vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit :vsplit $MYVIMRC
command! -nargs=0 MyVimsrc :source $MYVIMRC
" } Custom commands
" }}} Commands

" Keybindings {{{
" Plug-in Keybindings{
" NERDTree
nmap <silent> <A-1> :NERDTreeToggle<CR>
imap <silent> <A-1> <Esc><A-1>
" UndotreeToggle
nmap <silent> <C-u> :UndotreeToggle<CR>
imap <silent> <C-u> <Esc>:execute "normal! UndotreeToggle<CR>"
" Startify
nmap <silent> <C-s> :Startify<CR>
" Easymotion
nmap <leader>j <Plug>(easymotion-s)
" Region Expand/Shrink
map <C-A-a> <Plug>(expand_region_shrink)
map <A-a> <Plug>(expand_region_expand)
" Visual Multi-Cursor
nmap <C-d> <Plug>(VM-Find-Under)
nmap <C-A-k> <Plug>(VM-Add-Cursor-Up)
nmap <C-A-j> <Plug>(VM-Add-Cursor-Down)
" Tagbbar
nmap <leader>s :Vista!!<CR>
" } Plug-in Keybindings

function! s:myTerminal()
    if has('win32')
        execute "PS"
    elseif has('unix')
        execute "terminal"
    endif
endfunction
" Bring up terminal
nnoremap <silent> <C-`> :call <SID>myTerminal()<CR>
" Clear messages
nnoremap <silent> <A-`> :messages clear<CR>
" Add ; in end of line
nnoremap g; mzA;<Esc>`z
" Ctrl-BS for ins
inoremap <C-BS> <C-\><C-o>db
" Copy & Paste & Undo & Cut
nnoremap <C-z> u
xnoremap <C-z> <Esc>u
inoremap <C-z> <Esc>ua

nnoremap <C-x> dd
xnoremap <C-x> d
inoremap <C-x> <Esc>dda

nnoremap <C-c> yy
xnoremap <C-c> y
inoremap <C-c> <Esc>yya

nmap <C-v> i<C-v><Esc>
xmap <C-v> <Esc>i<C-v><Esc>
inoremap <C-v> <C-r>*
" Block visual mode
nnoremap <A-v> <C-q>
" Goto matching brackets
noremap <C-m> %
" Show registers
nnoremap <silent> Q :registers<CR>
nnoremap <silent> M :messages<CR>
" Pageup/Pagedown
noremap <A-e> <pageup>
inoremap <A-e> <pageup>
tnoremap <A-e> <pageup>
noremap <A-d> <pagedown>
inoremap <A-d> <pagedown>
tnoremap <A-d> <pagedown>
" Join line
nnoremap <C-j> mzgJ`z
" Shift-Tab to outdent
inoremap <S-Tab> <C-d>
" Buffer & Window
nnoremap <silent> <C-h> :bp<CR>
nnoremap <silent> <C-l> :bn<CR>
nnoremap <silent> <C-w>q :bd<CR>
nnoremap <silent> <C-w>c :bd<CR>
nnoremap <silent> <C-w>o :w <bar> %bd <bar> e# <bar> bd# <CR> " Close other buffers except for the current editting one
" Folding
nnoremap <silent> <Leader>F @=(foldlevel('.') ? 'za' : '\<Space>')<CR>
xnoremap <Leader>f zf
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
" Put content from registers 0
nnoremap <leader>p "0p
nnoremap <leader>P "0P
" Remain the cursor position when putting
" nnoremap p gph
" nnoremap P gPh
" Better jumping
nnoremap ; ;zz
nnoremap , ,zz
" Changelist jumping
nnoremap <A-o> g;
nnoremap <A-i> g,
" Convert \ into /
nnoremap <silent> g/ :s/\\/\//<CR>:noh<CR>
" Yank from above and below
nnoremap yk kyyp
nnoremap yj jyyP

" Commandline mode
function! s:RemoveLastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)

    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction
cnoremap <C-BS> <C-\>e(<SID>RemoveLastPathComponent())<CR>
cnoremap <A-w> <S-Right>
cnoremap <A-b> <S-Left>
cnoremap <A-h> <Left>
cnoremap <A-l> <Right>
cnoremap <A-k> <Up>
cnoremap <A-j> <Down>
cnoremap <A-s> <BS>
cnoremap <A-4> <End>
cnoremap <A-6> <Home>

" Unmap
" map <up> <nop>
" imap <up> <nop>
" map <down> <nop>
" imap <down> <nop>
" map <left> <nop>
" imap <left> <nop>
" map <right> <nop>
" imap <right> <nop>
" }}} Keybindings
