" Description: Neovim v0.50 settings for VSCode
" Last Modified: 2021-02-22
let $configPath = stdpath('config')

" execute "source " . expand('$configPath/vimPlugList.vim')

" Basic settings {{{
set clipboard=unnamed
set ignorecase smartcase
set lazyredraw
set nojoinspaces
set splitbelow splitright switchbuf=vsplit
set timeoutlen=500
set updatetime=150
" }}} Basic settings

" Auto commands {{{
augroup fileType
    autocmd!
    autocmd BufWritePost          *.lua,*.vim lua RELOAD()
augroup END
" }}} Auto commands

" Commands {{{
command! -nargs=0 -range ExtractSelection lua require("extractSelection").main(vim.fn.visualmode())
command! -nargs=0 -range Backward setl revins | execute "norm! gvc\<C-r>\"" | setl norevins
command! -nargs=0 TrimWhiteSpaces call TrimWhiteSpaces(0)
command! -nargs=0 O  browse oldfiles
command! -nargs=0 CD execute "cd " . expand("%:p:h")
" Edit Vimrc
if has('win32')
    command! -nargs=0 IDEAVimedit vsplit ~/.ideavimrc
endif
command! -nargs=0 MyVimedit edit $MYVIMRC
command! -nargs=0 MyVimsrc source $MYVIMRC
" }}} Commands

"  Key mapping {{{

"  Don't truncate the name
"  Search & Jumping {{{
"  Changelist jumping
nnoremap <A-o> &diff? "mz`z[czz" : "mz`zg;zz"
nnoremap <A-i> &diff? "mz`z]czz" : "mz`zg,zz"
nmap     <C-o> <C-o>zz
nmap     <C-i> <C-i>zz
nmap     j     :lua require("util").addJumpMotion("j", true)<cr>
nmap     k     :lua require("util").addJumpMotion("k", true)<cr>
nmap     k     :lua require("util").addJumpMotion("k", true)<cr>
vnoremap *     mz`z:<c-u>execute "/" . VisualSelection("string")<cr>
vnoremap #     mz`z:<c-u>execute "?" . VisualSelection("string")<cr>
vmap     /     *
vmap     ?     #
"  Regex very magic
nnoremap  / /\v
nnoremap  ? ?\v
"  Disable highlight search & Exit visual mode

"  ExitVisual() {{{
function! s:exitVisual()
    normal! gv
    execute "normal! \<esc>"
endfunction
"  }}} ExitVisual()
nmap <leader>h :<c-u>noh<cr>
vmap <leader>h :<c-u>call <SID>exitVisual()<cr>
"  Visual selection
lua << EOF
function OppoSelection()
    local curPos         = vim.api.nvim_win_get_cursor(0)
    local startSelectPos = vim.api.nvim_buf_get_mark(0, "<")
    local endSelectPos   = vim.api.nvim_buf_get_mark(0, ">")
    local closerToStart  = require("util").posDist(startSelectPos, curPos) < require("util").posDist(endSelectPos, curPos) and true or false
    if closerToStart then api.nvim_win_set_cursor(0, endSelectPos) else api.nvim_win_set_cursor(0, startSelectPos) end
    end
EOF
nmap go :lua OppoSelection()<cr>
nnoremap  <A-v> <C-q>
"  }}} Search & Jumping
"  Scratch file
nmap <C-n> :<c-u>new<cr>
"  Open/Search in browser
"  TODO:
vmap <C-l> :lua require("openBrowser").openInBrowser(require("util").visualSelection("string"))<cr>
vmap <C-l> :lua require("openBrowser").openInBrowser(require("util").visualSelection("string"))<cr>
"  Interrupt
" nnoremap  <C-A-c> :<c-u>call interrupt()<cr>
"  Paragraph & Block navigation
noremap { :lua require("inclusiveParagraph").main("up")<cr>
noremap } :lua require("inclusiveParagraph").main("down")<cr>
"  Line end/start
"  https://github.com/ryanoasis/nerd-fonts)
map  H ^
map  L $
"  Non-blank last character
noremap  g$ g_
"  Trailing character {{{
nmap g, :lua require("trailingUtil").trailingChar(",")<cr>
nmap g; :lua require("trailingUtil").trailingChar(";")<cr>
nmap g: :lua require("trailingUtil").trailingChar(":")<cr>
nmap g" :lua require("trailingUtil").trailingChar("\"")<cr>
nmap g' :lua require("trailingUtil").trailingChar("'")<cr>
nmap g) :lua require("trailingUtil").trailingChar(")")<cr>
nmap g( :lua require("trailingUtil").trailingChar("(")<cr>
nmap g<C-cr> :lua require("trailingUtil").trailingChar("o")<cr>
nmap g<S-cr> :lua require("trailingUtil").trailingChar("O")<cr>
"  }}} Trailing character
"  Messages
nmap g< :<c-u>messages<cr>
" nmap g> :<c-u>Messages<cr>
nmap  <A-,> :<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>
nmap  <A-.> :<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>
"  Pageup/Pagedown
" map  <A-e> <pageup>
" tmap  <A-e> <C-\><C-n><pageup>
" map  <A-d> <pagedown>
" tmap  <A-d> <C-\><C-n><pagedown>
"  Macro
"  <C-q> has been mapped to COC showDoc
nnoremap  <A-q> q
"  Register
"  ClearReg() {{{






"  }}} ClearReg()
map <C-'> :<c-u>reg<cr>
imap <C-'> <C-\><C-o>:reg<cr>
map <A-'> :<c-u>call ClearReg()<cr>
"  Buffer & Window & Tab{{{
"  Smart quit
nmap q :lua require"smartClose".main("window")<cr>
nmap Q :lua require"smartClose".main("buffer")<cr>
"  Window

" map <C-w>h :lua require("init").winFocus("wincmd h")<cr>
" map <C-w>l :lua require("init").winFocus("wincmd l")<cr>
" map <C-w>j :lua require("init").winFocus("wincmd j")<cr>
" map <C-w>k :lua require("init").winFocus("wincmd k")<cr>
map <C-w>v :lua require("consistantTab").splitCopy("wincmd v")<cr>
map <C-w>s :lua require("consistantTab").splitCopy("wincmd s")<cr>
map <C-w>V :only<cr><C-w>v
map <C-w>S :only<cr><C-w>s
"  Buffers




" map <A-h> :lua require("init").bufSwitcher("bp")<cr>
" map <A-l> :lua require("init").bufSwitcher("bn")<cr>
" map <C-w>O :lua require("closeOtherBuffer").main()<cr>
"  Tab
" map <A-S-h> :tabp<cr>
" map <A-S-l> :tabn<cr>
"  }}} Buffer & Window & Tab
"  Folding {{{
map  [Z zk
map  ]Z zj
" noremap [z :<c-u>call EnhanceFoldJump("previous", 1, 0)<cr>
" noremap ]z :<c-u>call EnhanceFoldJump("next",     1, 0)<cr>
" noremap g[z [z
" noremap g]z ]z
" map <leader>z :<c-u>call EnhanceFoldHL("No fold marker found", 500, "")<cr>
" nmap dz :<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>
" nmap zd :<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>
" nmap cz :<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>
" nmap  g{ :<c-u>call EnhanceFold(mode(), "{{{")<cr>
" nmap  g} :<c-u>call EnhanceFold(mode(), "}}}")<cr>
" vmap  g{ <A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z
" vmap  g} <A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z
noremap <leader><Space> @=(foldlevel('.') ? 'za' : '\<Space>')<cr>
noremap <S-Space> @=(foldlevel('.') ? 'zA' : '\<Space>')<cr>

"  }}} Folding
"  MS behavior {{{
"  <C-z/v/s> {{{
nmap  <C-z> u
vmap  <C-z> <esc>u
" imap  <C-z> <C-\><C-o>u

nmap  <C-c> Y
vmap  <C-c> y
"  map("i", [[<C-c>]], [[<C-\><C-o>Y]])

nnoremap  <C-v> p
vmap  <C-v> <esc>i<C-v><esc>
" imap  <C-v> <C-r>*

nmap  <C-s> :<c-u>w<cr>
vmap  <C-s> :<c-u>w<cr>
" imap  <C-s> <C-\><C-o>:w<cr>
"  }}} <C-z/x/v/s>
"  Saveas

map <C-S-s> :<c-u>Saveas<cr>
" imap <C-S-s> <C-\><C-o>:Saveas<cr>
"  Delete
nmap <C-S-d> :<c-u>d<cr>
vmap <C-S-d> :d<cr>
" imap <C-S-d> <C-\><C-o>:d<cr>
"  Highlight New Paste Content
nmap gy :lua require("yankPut").lastYankPut("yank")<cr>
nmap  gY gy
nmap gp :lua require("yankPut").lastYankPut("put")<cr>
nmap  gP gp
"  Put content from registers 0
nmap  <leader>p "0p
nmap  <leader>P "0P
"  Inplace yank
nmap  Y yy
map y luaeval("require('operator').main(require('yankPut').inplaceYank)")
"  Inplace put
nmap p :lua require("yankPut").inplacePut("n", "p")<cr>
vmap p :lua require("yankPut").inplacePut("v", "p")<cr>
nmap P :lua require("yankPut").inplacePut("n", "P")<cr>
vmap P :lua require("yankPut").inplacePut("v", "P")<cr>
"  Convert paste
nmap  cP :lua require("yankPut").convertPut("P")<CR>
nmap  cp :lua require("yankPut").convertPut("p")<CR>
"  Mimic the VSCode move/copy line up/down behavior {{{
"  Move line


" imap  <A-j> <C-\><C-o>:VSCodeLineMoveDownInsert<cr>
" imap  <A-k> <C-\><C-o>:VSCodeLineMoveUpInsert<cr>
" nmap <A-j> :<c-u>m .+1<cr>==
" nmap <A-k> :<c-u>m .-2<cr>==
" vmap <A-j> :m '>+1<cr>gv=gv
" vmap <A-k> :m '<-2<cr>gv=gv
"  Copy line
" imap <A-S-j> <C-\><C-o>:lua require("yankPut").VSCodeLineYank("n",       "down")<cr>
" imap <A-S-k> <C-\><C-o>:lua require("yankPut").VSCodeLineYank("n",       "up")<cr>
" nmap <A-S-j> :lua require("yankPut").VSCodeLineYank("n",                 "down")<cr>
" nmap <A-S-k> :lua require("yankPut").VSCodeLineYank("n",                 "up")<cr>
" vmap <A-S-j> :lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<cr>
" vmap <A-S-k> :lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<cr>
"  }}} Mimic the VSCode move/copy line up/down behavior
"  }}} MS bebhave
"  Convert \ into /
nnoremap g/ mz:s#\\#\/#e<cr>:noh<cr>g`z
nnoremap g\ mz:s#\\#\\\\#e<cr>:noh<cr>g`z
"  Mode: Terminal {{{
" tmap  <A-n> <C-\><C-n>
" nmap <C-`> :<c-u>call TerminalToggle()<cr>
" tmap <C-`> <A-n>:call TerminalToggle()<cr>
" nmap <A-`> <A-n>:call TerminalClose()<cr>
" tmap <A-`> <A-n>:call TerminalClose()<cr>
" tmap  <A-h> <A-n><A-h>
" tmap  <A-l> <A-n><A-l>
" tmap  <A-S-h> <A-n><A-S-h>
" tmap  <A-S-l> <A-n><A-S-l>
" tnoremap  <C-BS> <C-w>
" tmap <C-r> '\<A-n>"' . nr2char(getchar()) . 'pi'
" tmap  <C-w>k <A-n><C-w>k
" tmap  <C-w>j <A-n><C-w>j
" tmap  <C-w>h <A-n><C-w>h
" tmap  <C-w>l <A-n><C-w>l
" tmap  <C-w>w <A-n><C-w>w
" tmap  <C-w><C-w> <A-n><C-w><C-w>
" tmap  <C-w>W <A-n><C-w>W
" tmap  <C-w>H <A-n><C-w>H
" tmap  <C-w>L <A-n><C-w>L
" tmap  <C-w>J <A-n><C-w>J
" tmap  <C-w>K <A-n><C-w>K
"  }}} Mode: Terminal
"  Mode: Commandline & Insert {{{
" imap  <C-cr> <esc>o
" imap  <S-cr> <esc>O
" imap  jj <esc>`^
" imap  <C-d> <Del>
" inoremap  <S-Tab> <C-d>
" inoremap  <C-.> <C-a>
" inoremap  <C-S-.> <C-@>
" inoremap  <C-BS> <C-w>
"  Navigation {{{
" map!  <C-a> <Home>
" map!  <C-e> <End>
" map!  <C-h> <Left>
" map!  <C-l> <Right>
" map!  <C-j> <Down>
" map!  <C-k> <Up>
" map!  <C-b> <C-Left>
" map!  <C-w> <C-Right>
" map!  <C-h> <Left>
"  }}} Navigation
"  RemoveLastPathComponent() {{{










"  }}} RemoveLastPathComponent()
" cmap  <C-BS> <C-\>e(RemoveLastPathComponent())<cr>
" cnoremap  <C-S-l> <C-d>
" cmap  <C-d> <Del>
" cmap  <C-S-e> <C-\>e
" cmap  <C-v> <C-R>*
"  }}} Mode: Commandline & Insert
"  }}} Key mapping

" "  Plug-ins settings  {{{
" "  Build-in plugin {{{
" "  Netrow


" "  }}} Build-in plugin
" "  inkarkat/vim-ReplaceWithRegister {{{
" nmap grr <Plug>ReplaceWithRegisterLine==
" vmap  R <Plug>ReplaceWithRegisterVisual`<v`>=
" "  }}} inkarkat/vim-ReplaceWithRegister
" "  RishabhRD/nvim-cheat.sh {{{
" nmap <C-S-l> :<c-u>Cheat<cr>
" "  }}} RishabhRD/nvim-cheat.sh
" "  mg979/docgen.vim {{{
" nmap ,d :<c-u>DocGen<cr>
" "  }}} mg979/docgen.vim
" "  AndrewRadev/splitjoin.vim {{{


" nmap "gS" :<c-u>SplitjoinSplit<cr>
" nmap "gJ" :<c-u>SplitjoinJoin<cr>
" "  }}} AndrewRadev/splitjoin.vim
" "  lag13/vim-create-variable {{{
" vmap  C <Plug>Createvariable
" "  }}} lag13/vim-create-variable
" "  SirVer/ultisnips {{{
" "  Disable UltiSnips keymapping in favour of coc-snippets




" "  }}} SirVer/ultisnips
" "  preservim/nerdcommenter {{{
















" nmap gco :lua require("init").commentJump("o")<cr>
" nmap gcO :lua require("init").commentJump("O")<cr>

" nmap  gc<space> <plug>NERDCommenterToggle
" vmap  gc<space> <plug>NERDCommenterToggle
" "  map("n", [[gcn]], [[<plug>NERDCommenterNested]])
" "  map("v", [[gcn]], [[<plug>NERDCommenterNested]])
" nmap  gci <plug>NERDCommenterInvert
" vmap  gci <plug>NERDCommenterInvert

" nmap  gcs <plug>NERDCommenterSexy
" vmap  gcs <plug>NERDCommenterSexy

" nmap  gcy <plug>NERDCommenterYank
" vmap  gcy <plug>NERDCommenterYank

" nmap  gc$ <plug>NERDCommenterToEOL
" nmap  gcA <plug>NERDCommenterAppend
" nmap  gcI <plug>NERDCommenterInsert

" vmap  <A-/> <plug>NERDCommenterAltDelims
" nmap  <A-/> <plug>NERDCommenterAltDelims

" nmap  gcn <plug>NERDCommenterAlignLeft
" vmap  gcn <plug>NERDCommenterAlignLeft
" nmap  gcb <plug>NERDCommenterAlignBoth
" vmap  gcb <plug>NERDCommenterAlignBoth

" nmap  gcu <plug>NERDCommenterUncomment
" vmap  gcu <plug>NERDCommenterUncomment








" "  }}} preservim/nerdcommenter
" "  junegunn/vim-easy-align {{{

" "  Lua comment








" vmap  A <Plug>(EasyAlign)
" nmap  ga <Plug>(EasyAlign)
" "  }}} junegunn/vim-easy-align
" "  szw/vim-maximizer {{{
" map <C-w>m :MaximizerToggle<cr>
" "  }}} szw/vim-maximizer
" "  zatchheems/vim-camelsnek {{{



" vmap <A-c> :call CaseSwitcher()<cr>
" nmap <A-c> :<c-u>call CaseSwitcher()<cr>
" nmap <A-S-c> :<c-u>call CaseSwitcherDefaultCMDListOrder()<cr>
" "  }}} zatchheems/vim-vimsnek
" "  bkad/camelcasemotion {{{

" "  }}} bkad/camelcasemotion
" "  andymass/vim-matchup {{{
" "  vim.g.matchup_matchparen_deferred = 1
" "  vim.g.matchup_matchparen_hi_surround_always = 1
" "  vim.g.matchup_matchparen_hi_background = 1



" "  Text obeject
" xmap  am <Plug>(matchup-a%)
" xmap  im <Plug>(matchup-i%)
" omap  am <Plug>(matchup-a%)
" omap  im <Plug>(matchup-i%)
" "  Inclusive
" map  <C-m> <Plug>(matchup-%)
" map  <C-S-m> <Plug>(matchup-g%)
" "  Exclusive
" map  m <Plug>(matchup-]%)
" map  M <Plug>(matchup-[%)
" "  Highlight
" nmap  <leader>m <plug>(matchup-hi-surround)
" "  Origin mark
" noremap  <A-m> m
" "  }}} andymass/vim-matchup
" "  landock/vim-expand-region {{{














" map  <A-a> <Plug>(expand_region_expand)
" map  <A-s> <Plug>(expand_region_shrink)
" "  }}} landock/vim-expand-region
" "  liuchengxu/vista.vim {{{



" "  Base on Sarasa Nerd Mono SC

" nmap <leader>s :Vista!!<cr>
" "  }}} liuchengxu/vista.vim
" "  simnalamburt/vim-mundo {{{



" nmap <c-u> :<c-u>MundoToggle<cr>
" "  }}} simnalamburt/vim-mundo
" "  tommcdo/vim-exchange {{{
" nmap  gx <Plug>(Exchange)
" xmap  X <Plug>(Exchange)
" nmap  gxc <Plug>(ExchangeClear)
" nmap  gxx <Plug>(ExchangeLine)
" "  }}} tommcdo/vim-exchange
" "  phaazon/hop.nvim {{{
" map <leader>f :lua require("hop").hint_char1()<cr>
" map <leader>F :lua require("hop").hint_lines()<cr>
" "  }}} phaazon/hop.nvim
" "  michaeljsmith/vim-indent-object {{{






" "  }}} michaeljsmith/vim-indent-object
" "  Startify {{{





















" "  }}} Startify
" "  tpope/vim-repeat {{{

" "  }}} tpope/vim-repeat
" "  iaso2h/nlua {{{

" "  }}} iaso2h/nlua
" "  }}} Plug-ins settings


