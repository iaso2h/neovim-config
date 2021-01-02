" Plug-in list {{
if has('win32')
    set runtimepath+=~/AppData/Local/nvim/dein/repos/github.com/Shougo/dein.vim
    if dein#load_state('~/AppData/Local/nvim/dein')
        call dein#begin('~/AppData/Local\nvim\dein')
        call dein#add('~/AppData/Local/nvim/dein/repos/github.com/Shougo/dein.vim')
        call dein#add('Shougo/deoplete.nvim')
        call dein#add('roxma/nvim-yarp')
        call dein#add('roxma/vim-hug-neovim-rpc')

        call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})

        call dein#add('joshdick/onedark.vim')
        call dein#add('arcticicestudio/nord-vim')
        call dein#add('vim-airline/vim-airline')
        call dein#add('vim-airline/vim-airline-themes')
        call dein#add('mhinz/vim-startify')
        call dein#add('preservim/nerdtree')
        call dein#add('mbbill/undotree')
        call dein#add('Yggdroot/indentLine')
        call dein#add('luochen1990/rainbow')

        call dein#add('jeffkreeftmeijer/vim-numbertoggle')
        call dein#add('easymotion/vim-easymotion')
        call dein#add('tpope/vim-surround')
        call dein#add('lfv89/vim-interestingwords')
        call dein#add('tpope/vim-commentary')
        call dein#add('inkarkat/vim-ReplaceWithRegister')
        call dein#add('terryma/vim-expand-region')

        call dein#add('michaeljsmith/vim-indent-object')
        call dein#add('vim-utils/vim-line')
        call dein#add('vim-utils/vim-all')
        call dein#end()
        call dein#save_state()
    endif
    filetype plugin indent on
    syntax enable
elseif has('unix')
    call plug#begin(stdpath('config') . './plugged')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    Plug 'joshdick/onedark.vim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'mhinz/vim-startify'
    Plug 'preservim/nerdtree'
    Plug 'mbbill/undotree'
    Plug 'Yggdroot/indentLine'
    Plug 'luochen1990/rainbow'

    Plug 'jeffkreeftmeijer/vim-numbertoggle'
    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-surround'
    Plug 'lfv89/vim-interestingwords'
    Plug 'tpope/vim-commentary'
    Plug 'inkarkat/vim-ReplaceWithRegister'
    Plug 'terryma/vim-expand-region'

    Plug 'michaeljsmith/vim-indent-object'
    Plug 'vim-utils/vim-line'
    Plug 'vim-utils/vim-all'
    call plug#end()
endif

" }} Plug-in list

" Basic settings {{
set ai
set cindent " set C style indent
set clipboard=unnamed
set cmdheight=2 "Give more space for displaying messages
set cursorline " Highlight line in which cursor is located
set expandtab " Convert all tabs typed to spaces
set gdefault
set hidden
set ignorecase
set inccommand=nosplit " live substitution
set langmenu=en
set lazyredraw " Make Macro faster
set lbr
set mouse=a
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

" Settings based on OS
if has('win32')
    " GUI settings
    source ~/AppData/Local/nvim/gui.vim
    " Python executable
    let s = substitute(system('python -c "import sys; print(sys.executable)"'), '\n\+$', '', 'g')
    let g:python3_host_prog = strtrans(s)
elseif has('unix')
    " GUI settings
    source ~/.config/nvim/gui.vim
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
" }} Basic settings

" Plug-in settings {{

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
" Interesting words
let g:interestingWordsGUIColors = ['#8CCBEA', '#A4E57E', '#FFDB72', '#FF7272', '#FFB3FF', '#9999FF']

" }} Plug-in settings

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
nmap <silent> gR <Plug>(coc-references)
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
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<CR>" : "\<Left>"
xnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
xnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
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
nnoremap <silent><nowait> <leader>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <A-c>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <A-c>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <A-c>p  :<C-u>CocListResume<CR>
" }} Coc-nvim settings

" Commands {{
augroup bufferenter
    autocmd!
    " autocmd BufEnter <silent> :sleep 20ms<CR>
    " autocmd BufEnter <silent> :CocCommand cSpell.disableForWorkspace<CR>
    autocmd BufEnter <silent> :lcd %:p:h<CR> " Autocwd
    autocmd BufNewFile,BufReadPost *.md <silent> setfiletype markdown
    " To always start editing C files at the first function:
    " Highlight json comment
augroup END 

augroup fileextension
    autocmd!
    autocmd FileType json syntax match Comment +\/\/.\+$+
    " Quick seperating line
    autocmd FileType javascript nnoremap <buffer> gS iconsole.log("-".reapet(65))<Esc>o
    autocmd FileType python     nnoremap <buffer> gS iprint("-"*65)<Esc>o<CR>
    autocmd BufRead *.c,*.h	1;/^{
augroup END
nnoremap gs jO<Esc>65a-<Esc>gccj

" Clear cmd line message
function! s:empty_message(timer)
  if mode() ==# 'n'
    echo ''
  endif
endfunction

augroup cmd_msg_cls
    autocmd!
    autocmd CmdlineLeave :  call timer_start(5000, funcref('s:empty_message'))
augroup END

augroup vimrc
    autocmd!
    autocmd bufwritepost $MYVIMRC nested source $MYVIMRC | redraw! | AirlineRefresh | echo "Reload " . $MYVIMRC
augroup END

" Vimrc
command! -nargs=0 Myvimesrc :source $MYVIMRC
command! -nargs=0 Myvimedit :vsplit $MYVIMRC
command! -nargs=0 IDEAvimedit :vsplit ~/.ideavimrc
" Dein
command! -nargs=+ DEINClean :call map(dein#check_clean(), "delete(v:val, 'rf')")
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')
" Toggle Coc Spell-checker
command! -nargs=0 Spell   :CocCommand cSpell.toggleEnableSpellChecker
" }} Commands

" Keybindings {{

" Plug-in Keybindings{
" NERDTree
nmap <silent> <C-e>e :NERDTreeToggle<CR>
imap <silent> <C-e>e <Esc>:execute "normal! NERDTreeToggle<CR>"
nmap <silent> <C-e>f :NERDTreeFind<CR>
imap <silent> <C-e>f <Esc>:execute "normal! NERDTreeFind<CR>"
" UndotreeToggle
nmap <silent> <C-u> :UndotreeToggle<CR>
imap <silent> <C-u> <Esc>:execute "normal! UndotreeToggle<CR>"
" Startify
nmap <silent> <C-s> :Startify<CR>
" Easymotion
nmap <leader>j <plug>(easymotion-s)
" Region expand/shrink
nmap L <plug>(expand_region_expand)
nmap H <plug>(expand_region_shrink)
" } Plug-in Keybindings

" Show registers
nnoremap <silent> Q :registers<CR>
nnoremap <silent> M :messages<CR>
" Pageup/Pagedown
nnoremap <A-e> <pageup>
inoremap <A-e> <pageup>
xnoremap <A-e> <pageup>
nnoremap <A-d> <pagedown>
inoremap <A-d> <pagedown>
xnoremap <A-d> <pagedown>
" Join line
nnoremap <C-j> mzgJ`z
" Shift-Tab to outdent
inoremap <S-Tab> <C-d>
" Buffer
nnoremap <silent> <C-h> :bp<CR>
nnoremap <silent> <C-l> :bn<CR>
nnoremap <silent> <C-w>o :w <bar> %bd <bar> e# <bar> bd# <CR> " Close other buffers except for the current editting one
" Folding
nnoremap <silent> <Leader>F @=(foldlevel('.') ? 'za' : '\<Space>')<CR>
xnoremap <Leader>f zf
" Mimic the VSCode move line up/down behavior
nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==
xnoremap <silent> <A-j> :m '>+1<CR>gv=gv
xnoremap <silent> <A-k> :m '<-2<CR>gv=gv
inoremap <silent> <A-j> <esc>:m .+1<CR>==gi
inoremap <silent> <A-k> <esc>:m .-2<CR>==gi
" Quit insert or repalce mode
inoremap jj <esc>
" Disable highlight search
nnoremap <silent> <Leader>h :noh<CR>
" Put content from registers 0
nnoremap gp "0p
nnoremap gP "0P
" Remain the cursor position when putting
nnoremap p mzp`z
nnoremap P mzP`z
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
cnoremap <A-w> <S-Right>
cnoremap <A-b> <S-Left>
cnoremap <A-h> <Left>
cnoremap <A-l> <Right>
cnoremap <A-k> <Up>
cnoremap <A-j> <Down>
cnoremap <A-d> <BS>
cnoremap <A-4> <End>
cnoremap <A-6> <Home>
" cnoremap <C-t> <C-R>=expand("%:p:h") . "/" <CR>

" Unmap
nmap <C-z> <Nop>
imap <C-z> <Nop>
xmap <C-z> <Nop>
map <up> <nop>
xmap <up> <nop>
imap <up> <nop>
map <down> <nop>
xmap <down> <nop>
imap <down> <nop>
map <left> <nop>
xmap <left> <nop>
imap <left> <nop>
map <right> <nop>
xmap <right> <nop>
imap <right> <nop>
" }} Keybindings
