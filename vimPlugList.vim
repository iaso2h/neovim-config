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
Plug 'iaso2h/vim-scriptease', {'branch': 'ftplugin'}
" python {{{
Plug 'tmhedberg/SimpylFold', {'for': 'python'}
Plug 'jmcantrell/vim-virtualenv', {'for': 'python'}
" }}} python
" lua {{{
Plug 'davisdude/vim-love-docs', {'branch': 'build', 'for': 'lua'}
Plug 'tjdevries/nlua.nvim', {'for': 'lua'}
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
Plug 'lambdalisue/gina.vim'
Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
Plug 'skywind3000/asyncrun.vim'
Plug 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension' }

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python', {'for': 'python'}
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'romgrk/nvim-treesitter-context'

Plug 'dahu/VimRegexTutor'
Plug 'DanilaMihailov/vim-tips-wiki'
call plug#end()

lua require "init"
lua require "plugin"
lua require "temp"
if has('win32')
    lua require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
endif
" lua require('hop').setup({teasing = true, winblend = 50, keys = 'ghfjdkstyrueiwovbcnxalqozm'})

