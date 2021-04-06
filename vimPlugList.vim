if exists('g:vscode') == 1
    finish
endif
call plug#begin(stdpath('config') . '/plugged')
" UI {{{
Plug 'glepnir/galaxyline.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'RRethy/vim-hexokinase', {'do': 'make hexokinase'}
Plug 'chentau/todolist.nvim'
Plug 'mhinz/vim-startify'
Plug 'lukas-reineke/indent-blankline.nvim', {'branch': 'lua'}
Plug 'kyazdani42/nvim-tree.lua'
" }}} UI

" Vim enhancement {{{
Plug 'tpope/vim-repeat'
Plug 'inkarkat/vim-visualrepeat'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'iaso2h/vim-eunuch'
Plug 'skywind3000/asyncrun.vim'
Plug 'bkad/camelcasemotion'
Plug 'zatchheems/vim-camelsnek'
Plug 'landock/vim-expand-region'
Plug 'andymass/vim-matchup'
Plug 'iaso2h/hop.nvim'
Plug 'tommcdo/vim-exchange', {'on': ['<Plug>(Exchange)', '<Plug>(Exchange)', '<Plug>(ExchangeClear)', '<Plug>(ExchangeLine)']}
" Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'machakann/vim-sandwich'
Plug 'junegunn/vim-easy-align'
Plug 'windwp/nvim-autopairs'
Plug 'michaeljsmith/vim-indent-object'
Plug 'monaqa/dial.nvim'
Plug 'preservim/nerdcommenter'
Plug 'mg979/docgen.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'mg979/vim-visual-multi'
Plug 'szw/vim-maximizer', {'on': 'MaximizerToggle'}
Plug 'simnalamburt/vim-mundo', {'on': 'MundoToggle'}
" Plug 'dm1try/golden_size'
" }}} Vim enhancement

" Tree-sitter {{{
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'romgrk/nvim-treesitter-context'
Plug 'p00f/nvim-ts-rainbow'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
" }}} Tree-sitter

" Intellisense {{{
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'glepnir/lspsaga.nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'tzachar/compe-tabnine', { 'do': './install.sh' }
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'windwp/nvim-ts-autotag'
Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
Plug 'nvim-lua/lsp-status.nvim'
" }}} Intellisense

" Telescope {{{
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'fhill2/telescope-ultisnips.nvim'
Plug 'nvim-telescope/telescope-symbols.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-media-files.nvim'
" }}} Telescope

" Language {{{
" Python
Plug 'vim-python/python-syntax'
" Lua
Plug 'davisdude/vim-love-docs', {'branch': 'build', 'for': 'lua'}
Plug 'iaso2h/nlua.nvim', {'branch': 'iaso2h', 'for': 'lua'}
Plug 'euclidianAce/BetterLua.vim'
" Markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'plasticboy/vim-markdown', {'for': ['markdown', 'md']}
" Log
Plug 'MTDL9/vim-log-highlighting', {'for': 'log'}
" }}} Language

" Debug {{{
Plug 'kergoth/vim-hilinks'
Plug 'bfredl/nvim-luadev', {'for': 'lua'}
Plug 'iaso2h/vim-scriptease', {'branch': 'ftplugin'}
Plug 'mfussenegger/nvim-dap'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'mfussenegger/nvim-dap-python', {'for': 'python'}
" }}} Debug

" Version control {{{
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Plug 'lewis6991/gitsigns.nvim'
" }}} Version control

Plug 'RishabhRD/popfix'
Plug 'RishabhRD/nvim-cheat.sh', {'on': ['Cheat', 'CheatList', 'CheatListWithoutComments', 'CheatWithoutComments']}
Plug 'dahu/VimRegexTutor'
Plug 'DanilaMihailov/vim-tips-wiki'
call plug#end()

