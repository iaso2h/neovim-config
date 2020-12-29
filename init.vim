" Language
let $LANG = 'en_US'
set langmenu=en_US
let $lang='en_us.utf-8'
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

" Plug-in list {{
call plug#begin(stdpath('config') . './plugged')
" call plug#begin('~/.vim/plugged')
if !exists('g:vscode')
    Plug 'joshdick/onedark.vim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'vim-airline/vim-airline'
    Plug 'mhinz/vim-startify'
    Plug 'Yggdroot/indentLine'
    Plug 'easymotion/vim-easymotion'
    Plug 'luochen1990/rainbow'
    Plug 'gabebw/vim-github-link-opener'
    Plug 'jeffkreeftmeijer/vim-numbertoggle'
    Plug 'mbbill/undotree'
    Plug 'tpope/vim-commentary'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif


Plug 'tpope/vim-surround' " Vim-surround
Plug 'michaeljsmith/vim-indent-object' " Vim-indent-object
Plug 'vim-utils/vim-line' " Vim-innerline
Plug 'vim-utils/vim-all' " Vim-all
Plug 'inkarkat/vim-ReplaceWithRegister' " Replace text from register
Plug 'terryma/vim-expand-region' " Expand region
call plug#end()
" }} Plug-in list

" Plug-in settings {{
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    if (has("nvim"))
        let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    endif
    " For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    " Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " <https://github.com/neovim/neovim/wiki/Following-HEAD#20160511>
    if (has("termguicolors"))
        set termguicolors
    endif
endif

" Easymotion configuration
let g:EasyMotion_smartcase = 1

" Theme {
colorscheme nord
let g:airline_theme='nord'
let g:nord_cursor_line_number_background = 1
let g:nord_uniform_status_lines = 1
let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1

" Theme configuration
if (has("autocmd") && !has("gui_running"))
    augroup colorset
        autocmd!
        let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
        autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white })
    augroup END
endif
colorscheme onedark
" let g:airline_theme='cobalt2'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1

let g:rainbow_active = 1
let g:rainbow_conf = {
            \ 'guifgs': ['Gold', 'DarkOrchid3', 'RoyalBlue3'],
            \ 'ctermfgs': ['yellow', 'magenta', 'lightblue'],
            \}
" } Theme

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
" Expand region configuration
call expand_region#custom_text_objects({
            \ 'a]' :1,
            \ 'ab' :1,
            \ 'ii' :0,
            \ 'aB' :1,
            \ 'ai' :0,
            \ })
" }} Plug-in settings

" Basic settings {{
set ai
set autoindent " Preserve current indent on new lines
set cindent " set C style indent
set clipboard=unnamed
set cmdheight=1 "Give more space for displaying messages
set expandtab " Convert all tabs typed to spaces
set fileencoding=utf-8
set gdefault
set hidden
set ignorecase " g flag on search
set inccommand=nosplit " live substitution
set langmenu=en
set lazyredraw " Make Macro faster
set lbr
set nobackup
set noswapfile " Diable annoying swap file notification
set nowritebackup
set number relativenumber
set scrolloff=5
set shiftround " Indent/outdent to nearest tabstop
set shiftwidth=4 " Indent/outdent by four columns
set shortmess+=c " don't give ins-completion-menu messages.
set si
set smartcase
set softtabstop=4 " Indentation levels every four columns
set tabstop=4
set timeoutlen=500
set undofile " Combine with undotree plugin
set updatetime=300
let mapleader = "\<Space>" " First thing first
hi MatchParen ctermbg=blue guibg=lightblue guifg=white ctermfg=white
" }} Basic settings

" Coc-nvim settings {{
" Coc-extensions
let g:coc_global_extensions = [
            \'coc-json',
            \'coc-markdownlint',
            \'coc-marketplace',
            \'coc-nextword',
            \'coc-pairs',
            \'coc-pyright',
            \'coc-snippets',
            \'coc-spell-checker',
            \]
" Snippet
let g:coc_snippet_next= "<tab>"
" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
"  Disable coc-spell-checker first.time enter a buffer
autocmd BufEnter <silent> :CocCommand cSpell.enableForWorkspace<CR>
" Completion navigation
inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <silent><expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Trigger completion
inoremap <silent><expr> <C-space> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Navigate through dianostics list
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)
" Show all diagnostics.
nnoremap <silent> <leader>d  :<C-u>CocList diagnostics<cr>
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Show Document
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" Highlight word under cursor
nmap <leader>k call CocActionAsync("highlight")
" Symbol renaming.
nmap <leader>r <Plug>(coc-rename)
nmap <leader>R <Plug>(coc-refactor)
" Formatting selected code.
xmap <A-f> <Plug>(coc-format-selected)
nmap <A-f> <Plug>(coc-format-selected)

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected [[region]].
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ae <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>f  <Plug>(coc-fix-current)
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <A-D> coc#float#has_scroll() ? coc#float#scroll(1) : "\<A-D>"
  nnoremap <silent><nowait><expr> <A-S> coc#float#has_scroll() ? coc#float#scroll(0) : "\<A-S>"
  inoremap <silent><nowait><expr> <A-D> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <A-S> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <A-D> coc#float#has_scroll() ? coc#float#scroll(1) : "\<A-D>"
  vnoremap <silent><nowait><expr> <A-S> coc#float#has_scroll() ? coc#float#scroll(0) : "\<A-S>"
endif
" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
nmap <silent> <leader>S <Plug>(coc-range-select)
xmap <silent> <leader>S <Plug>(coc-range-select)

" Mappings for CoCList:
" Manage extensions.
nnoremap <silent><nowait> <A-c>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <A-c>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <leader>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <A-c>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <A-c>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <A-c>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <A-c>p  :<C-u>CocListResume<CR>

" Toggle Coc Spell-checker
map <silent> <leader>s :CocCommand cSpell.toggleEnableSpellChecker<CR>
" } Coc-nvim settings
" Commands {{
command! -nargs=0 Myvimesrc :source ~/.config/nvim/init.vim
command! -nargs=0 Myvimedit :e ~/.config/nvim/init.vim
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" }} Commands

" Keybindings {{
map <C-z> <NOP>

" Plug-in Keybindings{
" NERDTree
map <silent> <C-e>e :NERDTreeToggle<CR>
map <silent> <C-e>f :NERDTreeFind<CR>
" UndotreeToggle
map <silent> <C-u>e :UndotreeToggle<CR>
" Startify
map <silent> <C-s> :Startify<CR>
" Easymotion
map <Space>j <plug>(easymotion-s)
" Replace text-object with content from registers
nmap gr <plug>(operator-replace)
" Region expand/shrink
map L <plug>(expand_region_expand)
map H <plug>(expand_region_shrink)
" } Plug-in Keybindings


" Highlight json comment
autocmd FileType json syntax match Comment +\/\/.\+$+
" Pageup/Pagedown
noremap <A-e> <pageup>
noremap <A-d> <pagedown>
" Join line
nnoremap <C-j> mzgJ`z
" Shift-Tab to outdent
inoremap <S-Tab> <C-d>
" Split horizontally
noremap <silent> <C-w>h <C-w>s
" Buffer
map <silent> <C-h> :bp<CR>
map <silent> <C-l> :bn<CR>
map <silent> <Leader>f :b#<CR>
map <silent> <Leader>1 :1b<CR>
map <silent> <Leader>2 :2b<CR>
map <silent> <Leader>3 :3b<CR>
map <silent> <Leader>4 :4b<CR>
map <silent> <Leader>5 :5b<CR>
map <silent> <Leader>6 :6b<CR>
map <silent> <Leader>7 :7b<CR>
map <silent> <Leader>8 :8b<CR>
map <silent> <Leader>9 :9b<CR>
map <silent> <Leader>0 :10b<CR>
" Set working dir
nnoremap <leader>. :lcd %:p:h<CR>
" Folding
nnoremap <silent> <Leader>f @=(foldlevel('.') ? 'za' : '\<Space>')<CR>
vnoremap <Leader>f zf
" Mimic the VSCode move line up/down behavior
nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==
inoremap <silent> <A-j> <esc>:m .+1<CR>==gi
inoremap <silent> <A-k> <esc>:m .-2<CR>==gi
" Quit insert or repalce mode
inoremap jj <esc>
" Disable highlight search
noremap <silent> <Leader>h :noh<CR>
" Put content from registers 0
nnoremap gp "0p
nnoremap gP "0P
" Remain the cursor position when putting
nnoremap p mzp`z
nnoremap P mzP`z
" Better jumping
nnoremap ; ;zz
nnoremap , ,zz
" Convert \ into /
nnoremap g/ :s/\\/\//<CR>
" Yank from above and below
nnoremap yk kyyp
nnoremap yj jyyP
" Quick seperating line
nmap gs jO<Esc>65a-<Esc>gccj
" }} Keybindings
