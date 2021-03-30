if exists('g:vscode') == 1
    finish
endif
call plug#begin(stdpath('config') . '/plugged')
Plug 'glepnir/galaxyline.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'RRethy/vim-hexokinase', {'do': 'make hexokinase'}
Plug 'mhinz/vim-startify'

Plug 'lukas-reineke/indent-blankline.nvim', {'branch': 'lua'}
Plug 'simnalamburt/vim-mundo', {'on': 'MundoToggle'}
Plug 'szw/vim-maximizer', {'on': 'MaximizerToggle'}
Plug 'tpope/vim-repeat'
Plug 'inkarkat/vim-visualrepeat'
Plug 'tpope/vim-eunuch'
Plug 'iaso2h/hop.nvim'
Plug 'machakann/vim-sandwich'
Plug 'tommcdo/vim-exchange', {'on': ['<Plug>(Exchange)', '<Plug>(Exchange)', '<Plug>(ExchangeClear)', '<Plug>(ExchangeLine)']}
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
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'monaqa/dial.nvim'
" Plug 'kyazdani42/nvim-tree.lua'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'iaso2h/vim-scriptease', {'branch': 'ftplugin'}
" lua {{{
Plug 'davisdude/vim-love-docs', {'branch': 'build', 'for': 'lua'}
Plug 'iaso2h/nlua.nvim', {'branch': 'iaso2h', 'for': 'lua'}
Plug 'bfredl/nvim-luadev', {'for': 'lua'}
" }}} lua
" markdown {{{
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'plasticboy/vim-markdown', {'for': ['markdown', 'md']}
" }}} markdown
" log {{{
Plug 'MTDL9/vim-log-highlighting', {'for': 'log'}
" }}} log

Plug 'mg979/docgen.vim'
Plug 'RishabhRD/popfix'
Plug 'RishabhRD/nvim-cheat.sh', {'on': ['Cheat', 'CheatList', 'CheatListWithoutComments', 'CheatWithoutComments']}
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Plug 'lewis6991/gitsigns.nvim'
Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
Plug 'skywind3000/asyncrun.vim'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'fhill2/telescope-ultisnips.nvim'
Plug 'nvim-telescope/telescope-symbols.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-media-files.nvim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python', {'for': 'python'}
Plug 'theHamsta/nvim-dap-virtual-text'
" Plug 'romgrk/nvim-treesitter-context'
Plug 'p00f/nvim-ts-rainbow'
Plug 'windwp/nvim-ts-autotag'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

Plug 'dahu/VimRegexTutor'
Plug 'DanilaMihailov/vim-tips-wiki'
call plug#end()


