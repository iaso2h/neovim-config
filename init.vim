" Description: Neovim v0.50
" Last Modified: 2021-02-22

let $configPath = stdpath('config')
if exists("g:vscode")
    set timeoutlen=500
    set updatetime=150
    set ignorecase smartcase
    lua require("init")
    lua require("util")
    finish
endif


let g:NERDCreateDefaultMappings = 0
let g:expand_region_use_defaults = 0
let g:VM_default_mappings = 0
let g:sandwich_no_default_key_mappings = 1
let $configPath = stdpath('config')

execute "source " . expand('$configPath/vimPlugList.vim')

" Basic settings {{{
" let &path.="src/include,/usr/include/AL,"
colorscheme onedarknord
set guicursor=n-v-sm:block,i-c-ci:ver25-Cursor,ve-o-r-cr:hor20
if exists("g:neovide")
    set guifont=更纱黑体\ Mono\ SC\ Nerd:h18
else
    set guifont=更纱黑体\ Mono\ SC\ Nerd:h13
endif
set ai
set cindent expandtab shiftround shiftwidth=4 softtabstop=4 tabstop=4
set clipboard=unnamed
set cmdheight=2
set complete=.,w,b,u,t,kspell,i,d,t
set completeopt=menu,preview,menuone
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
set hidden
set ignorecase smartcase
set inccommand=nosplit
set keywordprg=:help
set listchars=tab:>-,precedes:❮,extends:❯,trail:-,nbsp:%,eol:↴
set langmenu=en
set lazyredraw
set mouse=a
set nojoinspaces
set noshowcmd noshowmode
set number
set path+=**
set scrolloff=10
set sessionoptions=buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize
set shada=!,'100,/100,:100,<100,s100,h
set shortmess=lxTI
set showtabline=2
set showbreak=↳
set splitbelow splitright switchbuf=vsplit
set termguicolors
set timeoutlen=500
set undofile undodir=~/.nvimcache/undodir nobackup noswapfile nowritebackup
set updatetime=150
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.db,*.sqlite,*.bak
set wildignorecase
set wildoptions=pum
set winhighlight=NormalNC:WinNormalNC
" }}} Basic settings

" Function {{{
let g:FiletypeCommentDelimiter = {
            \ "vim":    "\"",
            \ "python": "#",
            \ "c":      "\/\/",
            \ "cpp":    "\/\/",
            \ "json":   "\/\/",
            \ "lua":    "--",
            \ }
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
function! EnhanceFoldExpr()
    let l:line = getline(v:lnum)
    if match(l:line, g:enhanceFoldStartPat[&filetype]) > -1
        return "a1"
    elseif match(l:line, g:enhanceFoldEndPat[&filetype]) > -1
        return "s1"
    else
        return "="
    endif
endfunction
" }}} Function

" Auto commands {{{
augroup fileType
    autocmd!
    autocmd BufReadPost          * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
    autocmd BufWritePre          * lua require"util".trimWhiteSpaces(); require"util".trailingEmptyLine()
    autocmd BufEnter             * set formatoptions=pj1Bml2nwc
    autocmd TermOpen             * startinsert
    autocmd FocusGained,BufEnter * checktime
    " autocmd BufAdd               * lua require("consistantTab").adaptBufTab()

    autocmd CursorHold            *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
    autocmd FileType              java setlocal includeexpr=substitute(v:fname,'\\.','/','g')
    autocmd FileType              git  setlocal nofoldenable
    autocmd FileType              json setlocal conceallevel=0 concealcursor=
    autocmd FileType              qf   setlocal number norelativenumber
    autocmd FileType              qf map <buffer> <silent> <cr> :.cc<cr>:copen<cr>
    autocmd FileType              vim,lua     setlocal foldmethod=expr foldexpr=EnhanceFoldExpr()
    autocmd BufEnter              *.txt       lua require("winSplit").smartSplit("help")
    autocmd BufReadPre,BufNewFile *.jsx       setlocal filetype=jypescript
    autocmd BufReadPre,BufNewFile *.tsx       setlocal filetype=typescript
    autocmd BufReadPre,BufNewFile *.twig      setlocal filetype=twig.html
    autocmd BufReadPre,BufNewFile *.gitignore setlocal filetype=gitignore
    autocmd BufReadPre,BufNewFile config      setlocal filetype=config
    autocmd BufWritePost          *.lua,*.vim lua RELOAD()
augroup END
" }}} Auto commands

" Commands {{{
command! -nargs=+ -complete=command  Echo PPmsg strftime('%c') . ": " . <args>
command! -nargs=+ -complete=command  Redirc call Redir(<q-args>, "command")
command! -nargs=+ -complete=function Redirf call Redir(<q-args>, "function")
command! -nargs=0 -range ExtractSelection lua require("extractSelection").main(vim.fn.visualmode())
command! -nargs=0 -range Backward setl revins | execute "norm! gvc\<C-r>\"" | setl norevins
command! -nargs=0 TrimWhiteSpaces call TrimWhiteSpaces(0)
command! -nargs=0 PS terminal powershell
command! -nargs=0 O  browse oldfiles
command! -nargs=0 CD execute "cd " . expand("%:p:h")
command! -nargs=0 E  up | e! | zA
" Edit Vimrc
if has('win32')
    command! -nargs=0 IDEAVimedit vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit edit $MYVIMRC
command! -nargs=0 MyVimsrc source $MYVIMRC
" }}} Commands

