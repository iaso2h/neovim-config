" Description: Neovim v0.50
" Last Modified: 2021-02-22
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
Plug 'szw/vim-maximizer'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-scriptease'
Plug 'tpope/vim-eunuch'
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
" Plug 'vim-python/python-syntax'
Plug 'jmcantrell/vim-virtualenv'
Plug 'davisdude/vim-love-docs', {'branch': 'build', 'for': 'lua'}
" Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'plasticboy/vim-markdown'

Plug 'mg979/docgen.vim'
Plug 'RishabhRD/popfix'
Plug 'RishabhRD/nvim-cheat.sh'
Plug 'lambdalisue/gina.vim'
Plug 'liuchengxu/vista.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'romgrk/nvim-treesitter-context'

Plug 'dahu/VimRegexTutor'
Plug 'DanilaMihailov/vim-tips-wiki'
call plug#end()
lua require"init"
lua require"plugins"
lua require"util"
lua require"smartClose"
if has('win32')
    lua require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
endif
" }}} Plug-ins list

" Basic settings {{{
" let &path.="src/include,/usr/include/AL,"
colorscheme onedarknord
set ai
set cindent expandtab shiftround shiftwidth=4 softtabstop=4 tabstop=4
set clipboard=unnamed
set cmdheight=2
set complete=.,w,b,u,t,kspell,i,d,t
set conceallevel=2
set concealcursor=nc
set cpoptions+=q
set cursorline
set dictionary+=s:myyDict
set diffopt=context:10000,filler,closeoff,vertical,algorithm:patience
set fileignorecase
set fillchars=fold:-,vert:╎
set foldcolumn=auto:4 signcolumn=auto:4
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
set noshowcmd noshowmode
set number
set path+=**
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

let g:FiletypeCommentDelimiter = {
            \ "vim":    "\"",
            \ "python": "#",
            \ "c":      "\/\/",
            \ "cpp":    "\/\/",
            \ "json":   "\/\/",
            \ "lua":    "--",
            \ }
" Syntax {{{
" c.vim
let g:c_gnu = 1
let g:c_ansi_typedefs = 1
let g:c_ansi_constants = 1
let g:c_no_comment_fold = 1
let g:c_syntax_for_h = 1
" doxygen.vim
let g:load_doxygen_syntax= 1
let g:doxygen_enhanced_color = 1
" msql.vim
let g:msql_sql_query = 1
" }}} Syntax
" }}} Basic settings

" Function {{{
let g:enhanceFoldStartPat = {
            \ "vim":    '\s\{-}\"[^\"]\{-}{{{[^\"]*$',
            \ "python": '\s\{-}\"[^#]\{-}{{{[^#]*$',
            \ "c":      '\s\{-}//.\{-}{{{.*$',
            \ "cpp":    '\s\{-}//.\{-}{{{.*$',
            \ "lua":    '\s\{-}--.\{-}{{{.*$',
            \ }
let g:enhanceFoldEndPat = {
            \ "vim":    '\s\{-}\"[^\"]\{-}}}}[^\"]*$',
            \ "python": '\s\{-}\"[^#"]\{-}}}}[^#]*$',
            \ "c":      '\s\{-}//.\{-}}}}.*$',
            \ "cpp":    '\s\{-}//.\{-}}}}.*$',
            \ "lua":    '\s\{-}--.\{-}}}}.*$',
            \ }
function! EnhanceFoldExpr() " {{{
    let l:line = getline(v:lnum)
    if match(l:line, g:enhanceFoldStartPat[&filetype]) > -1
        return "a1"
    elseif match(l:line, g:enhanceFoldEndPat[&filetype]) > -1
        return "s1"
    else
        return "="
    endif
endfunction " }}}
function! ClearReg()
    for i in range(34,122) | silent! call setreg(nr2char(i), "") | endfor
    echohl Moremsg | echo "Register clear" | echohl None
endfunction
function! RemoveLastPathComponent() " {{{
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)
    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction " }}}
" }}} Function

" Auto commands {{{
augroup _fileType " {{{
    autocmd!
    autocmd BufEnter * set formatoptions=pj1Bml2nwc
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
    autocmd BufWritePre * lua require"util".trimWhiteSpaces(); require"util".trailingEmptyLine()
    " BUG: failed in command line mode press Ctrl-f
    autocmd FocusGained,BufEnter * if bufname() != "[Command Line]" | checktime | endif
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " C language
    autocmd CursorHold *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
    " Java
    autocmd FileType java setlocal includeexpr=substitute(v:fname,'\\.','/','g')
    " Vim & Lua
    autocmd FileType vim,lua setlocal foldmethod=expr foldexpr=EnhanceFoldExpr()
    autocmd FileType vim nmap <buffer><silent> <C-S-q> :execute 'h ' . expand('<cword>')<cr>
    autocmd FileType vim vmap <buffer><silent> <C-S-q> :<c-u>execute 'h ' . VisualSelection("string")<cr>
    autocmd bufwritepost $MYVIMRC nested source $MYVIMRC | redraw! | echom "Reload: " . $MYVIMRC
    autocmd bufwritepost *.vim if expand("%:p:h") ==# expand("$configPath" . "/plugin") |
                \ execute "source " . expand("%:p") | redraw! | echom "Reload: " . expand("%:p") |
                \ endif
    autocmd FileType lua nmap <buffer><expr>  <C-S-q> expand('<cword>') =~ '^nvim' ? ":execute 'h ' . expand('<cword>')<cr>" : ""
    autocmd bufwritepost *.lua lua RELOAD(nil)
    " Quickfix window
    autocmd FileType qf setlocal number norelativenumber
    autocmd FileType qf map <buffer> <silent> <cr> :.cc<cr>:copen<cr>
    " Terminal
    autocmd TermOpen * startinsert
    " Help
    autocmd BufEnter *.txt if &buftype == 'help' | if winwidth(0) > &columns / 2 | wincmd L | endif | endif
augroup END " }}}
" augroup highlightYank " {{{
" autocmd!
" autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false, higroup="Search", timeout=500}
" augroup END " }}}
" }}} Auto commands

" Commands {{{
command! -nargs=+ -complete=command Echo PPmsg strftime('%c') . ": " . <args>
command! -nargs=+ -complete=command  Redirc call Redir(<q-args>, "command")
command! -nargs=+ -complete=function Redirf call Redir(<q-args>, "function")
command! -nargs=0 TrimWhiteSpaces call TrimWhiteSpaces(0)
command! -nargs=0 PS terminal powershell
command! -nargs=0 O browse oldfiles
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

