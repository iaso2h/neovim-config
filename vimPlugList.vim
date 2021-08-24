if has("unix")
    if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
        execute "silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    endif
elseif has("win32")
    if empty(glob(stdpath("data") . "/site/autoload/plug.vim"))
        execute 'silent !iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force'
    endif
endif

call plug#begin(stdpath('config') . '/plugged')
" Vim enhancement {{{
Plug 'inkarkat/vim-visualrepeat'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-eunuch'
Plug 'skywind3000/asyncrun.vim'
Plug 'bkad/camelcasemotion'
Plug 'zatchheems/vim-camelsnek'
Plug 'landock/vim-expand-region'
Plug 'andymass/vim-matchup'
Plug 'phaazon/hop.nvim'
Plug 'tommcdo/vim-exchange', {'on': ['<Plug>(Exchange)', '<Plug>(Exchange)', '<Plug>(ExchangeClear)', '<Plug>(ExchangeLine)']}
" Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'machakann/vim-sandwich'
Plug 'junegunn/vim-easy-align'
Plug 'windwp/nvim-autopairs'
Plug 'michaeljsmith/vim-indent-object'
Plug 'monaqa/dial.nvim'
if !exists('g:vscode')
    Plug 'preservim/nerdcommenter'
    Plug 'winston0410/cmd-parser.nvim'
    Plug 'winston0410/range-highlight.nvim'
endif
Plug 'mg979/docgen.vim', {'on': 'DocGen'}
Plug 'AndrewRadev/splitjoin.vim'
Plug 'mg979/vim-visual-multi'
Plug 'airblade/vim-rooter'
" Plug 'AndrewRadev/switch.vim'
" }}} Vim enhancement
if !exists('g:vscode')
    " UI {{{
    Plug 'joshdick/onedark.vim'
    Plug 'glepnir/galaxyline.nvim'
    Plug 'romgrk/barbar.nvim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'RRethy/vim-hexokinase', {'do': 'make hexokinase'}
    Plug 'folke/todo-comments.nvim'
    Plug 'mhinz/vim-startify'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'szw/vim-maximizer', {'on': 'MaximizerToggle'}
    Plug 'simnalamburt/vim-mundo', {'on': 'MundoToggle'}
    if exists("neovide")
        " Plug 'dm1try/golden_size'
    endif
    " }}} UI

    " Tree-sitter {{{
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    " Plug 'romgrk/nvim-treesitter-context'
    Plug 'p00f/nvim-ts-rainbow'
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'windwp/nvim-ts-autotag'
    " }}} Tree-sitter

    " Intellisense {{{
    " Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'neovim/nvim-lspconfig'
    Plug 'kabouzeid/nvim-lspinstall'
    Plug 'glepnir/lspsaga.nvim'
    Plug 'hrsh7th/nvim-compe'
    Plug 'tzachar/compe-tabnine', {'do': './install.sh'}
    Plug 'hrsh7th/vim-vsnip'
    Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
    Plug 'nvim-lua/lsp-status.nvim'
    " }}} Intellisense

    " Telescope {{{
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-symbols.nvim'
    Plug 'nvim-telescope/telescope-fzy-native.nvim'
    " }}} Telescope

    " Language {{{
    " Python
    Plug 'vim-python/python-syntax', {'for': ['python', 'py']}
    " Lua
    Plug 'davisdude/vim-love-docs',    {'branch': 'build',  'for': 'lua'}
    Plug 'iaso2h/nlua.nvim',           {'branch': 'iaso2h', 'for': 'lua'}
    Plug 'nanotee/luv-vimdocs',        {'for': 'lua'}
    " Markdown
    Plug 'iamcco/markdown-preview.nvim', {'do': { -> mkdp#util#install() }, 'for': ['markdown', 'md']}
    Plug 'plasticboy/vim-markdown',      {'for': ['markdown', 'md']}
    " Log
    Plug 'MTDL9/vim-log-highlighting', {'for': 'log'}
    " Fish script
    Plug 'NovaDev94/vim-fish', {'for': 'fish'}
    " }}} Language

    " Debug {{{
    Plug 'bfredl/nvim-luadev',       {'for': 'lua'}
    Plug 'rafcamlet/nvim-luapad',    {'on': ['Luapad', 'LuaRun', 'Lua']}
    Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}
    Plug 'iaso2h/vim-scriptease',    {'branch': 'ftplugin'}
    " Plug 'mfussenegger/nvim-dap'
    " Plug 'theHamsta/nvim-dap-virtual-text'
    " Plug 'mfussenegger/nvim-dap-python', {'for': 'python'}
    " Plug 'puremourning/vimspector'
    Plug 'sakhnik/nvim-gdb', {'do': ':!./install.sh'}
    " }}} Debug

    " Version control {{{
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    " Plug 'lewis6991/gitsigns.nvim'
    Plug 'rhysd/git-messenger.vim', {'on': ['GitMessenger', '<Plug>(git-messenger)']}
    " Plug 'sindrets/diffview.nvim',
    " }}} Version control

    " Misc {{{
    Plug 'antoinemadec/FixCursorHold.nvim'
    Plug 'RishabhRD/popfix'
    Plug 'RishabhRD/nvim-cheat.sh', {'on': ['Cheat', 'CheatList', 'CheatListWithoutComments', 'CheatWithoutComments']}
    Plug 'dahu/VimRegexTutor'
    Plug 'DanilaMihailov/vim-tips-wiki'
    " }}} Misc
endif
call plug#end()

