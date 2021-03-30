<<<<<<< HEAD
call plug#begin(stdpath('config') . '/plugged')
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'luochen1990/rainbow'
Plug 'vim-airline/vim-airline-themes'
Plug 'lukas-reineke/indent-blankline.nvim', {'branch': 'lua'}
Plug 'norcalli/nvim-colorizer.lua'
Plug 'mhinz/vim-startify'

Plug 'simnalamburt/vim-mundo', {'on': 'MundoToggle'}
Plug 'szw/vim-maximizer', {'on': 'MaximizerToggle'}
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-eunuch'
" Plug 'iaso2h/hop.nvim'
Plug 'machakann/vim-sandwich'
Plug 'tommcdo/vim-exchange', {'on': ['<Plug>(Exchange)', '<Plug>(Exchange)', '<Plug>(ExchangeClear)', '<Plug>(ExchangeLine)']}
Plug 'lag13/vim-create-variable', {'on': '<Plug>Createvariable'}
=======
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
>>>>>>> master
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
<<<<<<< HEAD
=======
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'monaqa/dial.nvim'
" Plug 'kyazdani42/nvim-tree.lua'
>>>>>>> master

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'iaso2h/vim-scriptease', {'branch': 'ftplugin'}
<<<<<<< HEAD
" python {{{
Plug 'tmhedberg/SimpylFold', {'for': 'python'}
Plug 'jmcantrell/vim-virtualenv', {'for': 'python'}
" }}} python
" lua {{{
Plug 'davisdude/vim-love-docs', {'branch': 'build', 'for': 'lua'}
Plug 'tjdevries/nlua.nvim', {'for': 'lua'}
=======
" lua {{{
Plug 'davisdude/vim-love-docs', {'branch': 'build', 'for': 'lua'}
Plug 'iaso2h/nlua.nvim', {'branch': 'iaso2h', 'for': 'lua'}
>>>>>>> master
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
<<<<<<< HEAD
Plug 'lambdalisue/gina.vim'
Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
Plug 'skywind3000/asyncrun.vim'
Plug 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension' }
=======
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
>>>>>>> master

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python', {'for': 'python'}
Plug 'theHamsta/nvim-dap-virtual-text'
<<<<<<< HEAD
Plug 'romgrk/nvim-treesitter-context'
=======
" Plug 'romgrk/nvim-treesitter-context'
Plug 'p00f/nvim-ts-rainbow'
Plug 'windwp/nvim-ts-autotag'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
>>>>>>> master

Plug 'dahu/VimRegexTutor'
Plug 'DanilaMihailov/vim-tips-wiki'
call plug#end()

<<<<<<< HEAD
lua require "init"
lua require "plugin"
lua require "temp"
if has('win32')
    lua require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
endif
" lua require('hop').setup({teasing = true, winblend = 50, keys = 'ghfjdkstyrueiwovbcnxalqozm'})
=======
>>>>>>> master

