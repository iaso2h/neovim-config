local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local map  = require("util").map
local vmap = require("util").vmap
local M    = {}

-- Module configuration {{{
-- General module {{{
require "config.vim-visual-multi"
require "config.vim-asyncrun"
-- }}} General module

-- Neovim cilent module {{{
if not vim.g.vscode then
    require "config.vim-markdown"
    -- require "config.nvim-golden_size"
    require "config.nvim-telescope"
    require "config.nvim-treesitter"
    require "config.nvim-tree"
    -- require "config.nvim-dap"
    -- require "config.nvim-gitsigns"
    require "config.nvim-barbar"
    require "config.nvim-galaxyline"
    -- require "config.nvim-coc"
    require "config.nvim-lsp"
    require "config.nvim-comp"
    -- require "config.nvim-gdb"
    require "config.nvim-todo-comments"
end
-- }}} Neovim cilent module
-- }}} Module configuration

-- Configuration {{{
-- General {{{
-- lukas-reineke/indent-blankline.nvim {{{
require("indent_blankline").setup{
    char             = "▏",
    buftype_exclude  = {"terminal"},
    filetype_exclude = {"help", "startify", "NvimTree"},
    bufname_exclude  = {"*.md"},
    char_highlight   = "SignColumn",
    use_treesitter                 = true,
    show_current_context           = true,
    show_first_indent_level        = true,
    show_trailing_blankline_indent = true,
    show_end_of_line               = true,
    show_foldtext                  = true,
    strict_tabs                    = true
}
-- }}} lukas-reineke/indent-blankline.nvim
-- tommcdo/vim-exchange {{{
map("n", [[gx]],  [[<Plug>(Exchange)]])
map("x", [[X]],   [[<Plug>(Exchange)]])
map("n", [[gxc]], [[<Plug>(ExchangeClear)]])
map("n", [[gxx]], [[<Plug>(ExchangeLine)]])
-- }}} tommcdo/vim-exchange
-- zatchheems/vim-camelsnek {{{
vim.g.camelsnek_alternative_camel_commands = 1
vim.g.camelsnek_no_fun_allowed             = 1
vim.g.camelsnek_iskeyword_overre           = 0
map("v", [[<A-c>]],   [[:call CaseSwitcher()<cr>]],                               {"silent"})
map("n", [[<A-c>]],   [[:lua require("caseSwitcher").cycleCase()<cr>]],           {"silent"})
map("n", [[<A-S-c>]], [[:lua require("caseSwitcher").cycleDefaultCMDList()<cr>]], {"silent"})
-- }}} zatchheems/vim-vimsnek
-- bkad/camelcasemotion {{{
vim.g.camelcasemotion_key = ','
-- }}} bkad/camelcasemotion
-- andymass/vim-matchup {{{
-- vim.g.matchup_matchparen_deferred = 1
-- vim.g.matchup_matchparen_hi_surround_always = 1
-- vim.g.matchup_matchparen_hi_background = 1
vim.g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'OffscreenPopup'}
vim.g.matchup_matchparen_nomode = "i"
-- Set to 0 to match within strings and comments,
vim.g.matchup_delim_noskips = 0
-- Text obeject
map("x", [[am]],      [[<Plug>(matchup-a%)]])
map("x", [[im]],      [[<Plug>(matchup-i%)]])
map("o", [[am]],      [[<Plug>(matchup-a%)]])
map("o", [[im]],      [[<Plug>(matchup-i%)]])
-- Inclusive
map("",  [[<C-m>]],   [[<Plug>(matchup-%)]])
map("",  [[<C-S-m>]], [[<Plug>(matchup-g%)]])
-- Exclusive
map("n", [[<A-m>]],   [[<Plug>(matchup-]%)]])
map("x", [[<A-m>]],   [[<Plug>(matchup-]%)]])
map("n", [[<A-S-m>]], [[<Plug>(matchup-[%)]])
map("x", [[<A-S-m>]], [[<Plug>(matchup-[%)]])
-- Highlight
map("n", [[<leader>m]], [[<Plug>(matchup-hi-surround)]])
-- Change/Delete surrounds
vim.g.matchup_surround_enabled = 1
map("n", [[dsm]], [[<Plug>(matchup-ds%)]])
map('n', [[csm]], [[<Plug>(matchup-cs%)]])
-- }}} andymass/vim-matchup
-- landock/vim-expand-region {{{
vim.g.expand_region_text_objects = {
    ['iw'] = 0,
    ['iW'] = 0,
    ['i"'] = 0,
    ["i'"] = 0,
    ['i]'] = 1,
    ['ib'] = 1,
    ['iB'] = 1,
    ['il'] = 0,
    ['ii'] = 0,
    ['ip'] = 1,
    ['ie'] = 0,
}
local expand_region_custom_text_objects = {
    ['i,w'] = 1,
    ['i%']  = 0,
    ['a]']  = 0,
    ['ab']  = 0,
    ['aB']  = 0,
    ['ai']  = 0
}
fn["expand_region#custom_text_objects"](expand_region_custom_text_objects)
map("", [[<A-a>]], [[<Plug>(expand_region_expand)]])
map("", [[<A-s>]], [[<Plug>(expand_region_shrink)]])
-- }}} landock/vim-expand-region
-- monaqa/dial.nvim {{{
map("n", [[<leader><C-a>]],  [[<Plug>(dial-increment)]])
map("n", [[<leader><C-x>]],  [[<Plug>(dial-decrement)]])
map("v", [[<leader><C-a>]],  [[<Plug>(dial-increment)]])
map("v", [[<leader><C-x>]],  [[<Plug>(dial-decrement)]])
map("v", [[<leader>g<C-a>]], [[<Plug>(dial-increment-additional)]])
map("v", [[<leader>g<C-x>]], [[<Plug>(dial-decrement-additional)]])
-- }}} monaqa/dial.nvim
-- preservim/nerdcommenter {{{
vim.g.NERDAltDelims_c          = 1
vim.g.NERDAltDelims_cpp        = 1
vim.g.NERDAltDelims_javascript = 1
vim.g.NERDAltDelims_lua        = 0
vim.g.NERDAltDelims_conf       = 0
function M.commentJump(keystroke) -- {{{
    if api.nvim_get_current_line() ~= '' then
        local saveReg = fn.getreg('"')
        if keystroke == "o" then
            cmd("normal! YpS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
            elseif keystroke == "O" then
            cmd("normal! YPS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
        end
        fn.setreg('"', saveReg)
        cmd [[startinsert!]]
    end
end -- }}}
map("n", [[g<space>o]], [[:lua require("core.plugins").commentJump("o")<cr>]], {"silent"})
map("n", [[g<space>O]], [[:lua require("core.plugins").commentJump("O")<cr>]], {"silent"})

vmap("n", [[g<space><space>]], [[<c-u>:call VSCodeCall("editor.action.commentLine")<cr>]])
vmap("v", [[g<space><space>]], [[:call VSCodeCall("editor.action.commentLine")<cr>]])

map("n", [[g<space><space>]], [[<plug>NERDCommenterToggle]], {"novscode"})
map("v", [[g<space><space>]], [[<plug>NERDCommenterToggle]], {"novscode"})
-- map("n", [[g<space>n]], [[<plug>NERDCommenterNested]], {"novscode"})
-- map("v", [[g<space>n]], [[<plug>NERDCommenterNested]], {"novscode"})

map("n", [[g<space>i]], [[<plug>NERDCommenterInvert]], {"novscode"})
map("v", [[g<space>i]], [[<plug>NERDCommenterInvert]], {"novscode"})

map("n", [[g<space>s]], [[<plug>NERDCommenterSexy]], {"novscode"})
map("v", [[g<space>s]], [[<plug>NERDCommenterSexy]], {"novscode"})

map("n", [[g<space>y]], [[<plug>NERDCommenterYank]], {"novscode"})
map("v", [[g<space>y]], [[<plug>NERDCommenterYank]], {"novscode"})

map("n", [[g<space>$]], [[<plug>NERDCommenterToEOL]], {"novscode"})
map("n", [[g<space>A]], [[<plug>NERDCommenterAppend]], {"novscode"})
map("n", [[g<space>I]], [[<plug>NERDCommenterInsert]], {"novscode"})

map("v", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], {"novscode"})
map("n", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], {"novscode"})

map("n", [[g<space>n]], [[<plug>NERDCommenterAlignLeft]], {"novscode"})
map("v", [[g<space>n]], [[<plug>NERDCommenterAlignLeft]], {"novscode"})
map("n", [[g<space>b]], [[<plug>NERDCommenterAlignBoth]], {"novscode"})
map("v", [[g<space>b]], [[<plug>NERDCommenterAlignBoth]], {"novscode"})

map("n", [[g<space>u]], [[<plug>NERDCommenterUncomment]], {"novscode"})
map("v", [[g<space>u]], [[<plug>NERDCommenterUncomment]], {"novscode"})

vim.g.NERDSpaceDelims              = 1
vim.g.NERDRemoveExtraSpaces        = 1
vim.g.NERDCommentWholeLinesInVMode = 1
vim.g.NERDLPlace                   = "{{{"
vim.g.NERDRPlace                   = "}}}"
vim.g.NERDCompactSexyComs          = 1
vim.g.NERDToggleCheckAllLines      = 1
-- }}} preservim/nerdcommenter
-- junegunn/vim-easy-align {{{
vim.g.easy_align_delimiters = { ["l"] = {
    pattern       = '--',
    left_margin   = 2,
    right_margin  = 1,
    stick_to_left = 0 ,
    ignore_groups = {'String'}
}
}
map("v", [[A]],  [[<Plug>(EasyAlign)]])
map("n", [[ga]], [[<Plug>(EasyAlign)]])
-- }}} junegunn/vim-easy-align
-- mg979/docgen.vim {{{
map("n", [[,d]], [[:<c-u>DocGen<cr>]], {"silent"})
-- }}} mg979/docgen.vim
-- AndrewRadev/splitjoin.vim {{{
vim.g.splitjoin_align = 1
vim.g.splitjoin_curly_brace_padding = 0
map("n", [["gS"]], [[:<c-u>SplitjoinSplit<cr>]], {"silent"})
map("n", [["gJ"]], [[:<c-u>SplitjoinJoin<cr>]],  {"silent"})
-- }}} AndrewRadev/splitjoin.vim
-- windwp/nvim-autopairs {{{
local npairs = require('nvim-autopairs')
npairs.setup {
    disable_filetype          = {"TelescopePrompt"},
    ignored_next_char         = string.gsub([[[%w%%%'%[%"%.] ]],"%s+", ""),
    enable_moveright          = true,
    enable_afterquote         = true,  -- add bracket pairs after quote
    enable_check_bracket_line = true,  -- check bracket in same line
    check_ts                  = false,
    fast_wrap = {
        map         = '<A-p>',
        chars       = { '{', '[', '(', '"', "'" },
        pattern     = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
        end_key     = 'p',
        keys        = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        hightlight  = 'Search'
    },
}
require('nvim-autopairs.completion.compe').setup {
    map_cr       = false,  -- map <CR> on insert mode, this was implemented by nvim-comp instead
    map_complete = true,   -- it will auto insert `(` after select function or method item
    auto_select  = false,  -- auto select first (item)
}
-- }}} windwp/nvim-autopairs
-- airblade/vim-rooter {{{
vim.g.rooter_change_directory_for_non_project_files = "current"
vim.g.rooter_patterns      = {
    ".git",
    "makefile",
    "*.sln",
    "build/env.sh",
    ".vscode",
    "^config",
    "^local",
    }
vim.g.rooter_cd_cmd        = "lcd"
vim.g.rooter_silent_chdir  = 1
vim.g.rooter_resolve_links = 1
-- }}} airblade/vim-rooter
-- winston0410/range-highlight.nvim {{{
require("range-highlight").setup {
    highlight = "Visual",
    highlight_with_out_range = {
        d          = true,
        delete     = true,
        m          = true,
        move       = true,
        y          = true,
        yank       = true,
        c          = true,
        change     = true,
        j          = true,
        join       = true,
        ["<"]      = true,
        [">"]      = true,
        s          = true,
        subsititue = true,
        sno        = true,
        snomagic   = true,
        sm         = true,
        smagic     = true,
        ret        = true,
        retab      = true,
        t          = true,
        co         = true,
        copy       = true,
        ce         = true,
        center     = true,
        ri         = true,
        right      = true,
        le         = true,
        left       = true,
        sor        = true,
        sort       = true
    }
}
-- }}} winston0410/range-highlight.nvim
-- }}} General

-- Neovim client {{{
if not vim.g.vscode then
    -- RRethy/vim-hexokinase {{{
    -- NOTE: Go language compiler is required
    vim.g.Hexokinase_highlighters = {'backgroundfull'}
    vim.g.Hexokinase_optInPatterns = 'full_hex,triple_hex,rgb,rgba,hsl,hsla,colour_names'
    -- RRethy/vim-hexokinase }}}
    -- vim-python/python-syntax {{{
    vim.g.python_highlight_all = 1
    -- }}} vim-python/python-syntax
    -- hrsh7th/vim-vsnip {{{
    vim.g.vsnip_snippet_dir   = fn.expand('$configPath/snippets')
    vim.g.vsnip_extra_mapping = false
    vim.g.vsnip_filetypes     = {
        txt        = {"all"},
        md         = {"all"},
        vim        = {"all"},
        lua        = {"all"},
        python     = {"all"},
        c          = {"all"},
        cpp        = {"all"},
        javascript = {"all"},
        json       = {"all"},
        html       = {"all"},
        css        = {"all"},
        typescript = {"all"},
    }
    -- }}} hrsh7th/vim-vsnip
    -- RishabhRD/nvim-cheat.sh {{{
    -- map("n", [[<C-S-l>]], [[:<c-u>Cheat<cr>]], {"silent"})
    -- }}} RishabhRD/nvim-cheat.sh
    -- szw/vim-maximizer {{{
    map("",  [[<C-w>m]], [[:MaximizerToggle<cr>]],      {"silent"})
    map("t", [[<C-w>m]], [[<A-n>:MaximizerToggle<cr>]], {"silent"})
    -- }}} szw/vim-maximizer
    -- simnalamburt/vim-mundo {{{
    vim.g.mundo_help               = 1
    vim.g.mundo_tree_statusline    = 'Mundo'
    vim.g.mundo_preview_statusline = 'Mundo Preview'
    map("n", [[<C-W>u]], [[:<c-u>MundoToggle<cr>]], {"silent"})
    -- }}} simnalamburt/vim-mundo
    -- iaso2h/hop.nvim {{{
    require('hop').setup{
        keys             = 'ghfjdkstyrueiwovbcnxalqozm',
        perm_method      = require'hop.perm'.TermSeqBias,
        case_insensitive = false
    }
    map("", [[<leader>f]], [[:lua require("hop").hint_char1()<cr>]], {"silent"})
    map("", [[<leader>F]], [[:lua require("hop").hint_lines()<cr>]], {"silent"})
    -- }}} iaso2h/hop.nvim
    -- Startify {{{
    map("n", [[<C-s>]], [[:<c-u>Startify<cr>]], {"silent", "novscode"})
    map("v", [[<C-s>]], [[:<c-u>Startify<cr>]], {"silent", "novscode"})
    vim.g.startify_session_dir  = os.getenv("HOME") .. '/.nvimcache/session'
    vim.g.startify_padding_left = 20
    vim.g.startify_lists = {
        {type = 'files',     header = {string.rep(" ", vim.g.startify_padding_left) .. 'MRU'}            },
        {type = 'dir',       header = {string.rep(" ", vim.g.startify_padding_left) .. 'MRU ' .. fn.getcwd()}},
        {type = 'sessions',  header = {string.rep(" ", vim.g.startify_padding_left) .. 'Sessions'}       },
        {type = 'bookmarks', header = {string.rep(" ", vim.g.startify_padding_left) .. 'Bookmarks'}      },
    }
    vim.g.startify_update_oldfiles        = 1
    vim.g.startify_session_autoload       = 1
    vim.g.startify_bookmarks              = {{v = fn.expand("$MYVIMRC")}}
    vim.g.startify_session_before_save    = {'echo "Cleaning up before saving.."' }
    vim.g.startify_session_persistence    = 1
    vim.g.startify_session_delete_buffers = 1
    vim.g.startify_change_to_vcs_root     = 1
    vim.g.startify_fortune_use_unicode    = 1
    vim.g.startify_relative_path          = 1
    vim.g.startify_use_env                = 1
    -- }}} Startify
    -- iaso2h/nlua {{{
    vim.g.nlua_keywordprg_map_key = "<C-S-q>"
    -- }}} iaso2h/nlua
    -- liuchengxu/vista.vim {{{
    vim.g.vista_default_executive = 'ctags'
    vim.g.vista_icon_indent = {"╰─▸ ", "├─▸ "}
    vim.g["vista#finders"] = {'fzf'}
    -- Base on Sarasa Nerd Mono SC
    vim.g["vista#renderer#icons"] = {variable = "\\uF194"}
    map("n", [[<leader>t]], [[:Vista!!<cr>]], {"silent"})
    -- }}} liuchengxu/vista.vim
    -- airblade/vim-gitgutter {{{
    -- if fn.has('win32') == 1 then vim.g.gitgutter_git_executable = "D:/Git/bin/git.exe" end
    vim.g.gitgutter_map_keys = 0
    vim.g.gitgutter_sign_priority = 10
    vim.g.gitgutter_preview_win_floating = 1
    map("n", [[]h]], [[<Plug>(GitGutterNextHunk)]])
    map("n", [[[h]], [[<Plug>(GitGutterPrevHunk)]])
    map("o", [[ih]], [[<Plug>(GitGutterTextObjectInnerPending)]])
    map("o", [[ah]], [[<Plug>(GitGutterTextObjectOuterPending)]])
    map("x", [[ih]], [[<Plug>(GitGutterTextObjectInnerVisual)]])
    map("x", [[ah]], [[<Plug>(GitGutterTextObjectOuterVisual)]])
    -- }}} airblade/vim-gitgutter
    -- rafcamlet/nvim-luapad {{{
    -- BUG: Cannot find nvim-luapad???
    -- require("luapad").config{
        -- count_limit     = 150000,
        -- error_indicator = true,
        -- eval_on_move    = true,
        -- error_highlight = 'WarningMsg',
        -- on_init         = function()
            -- print 'Hello from Luapad!'
        -- end,
        -- context = {
            -- the_answer = 42,
            -- shout = function(str) return(string.upper(str) .. '!') end
        -- }
    -- }
    -- }}} rafcamlet/nvim-luapad
    -- rhysd/git-messenger.vim {{{
    vim.g.git_messenger_date_format = "%Y-%m-%d %X"
    map("n", [[<C-w>g]], [[:lua vim.cmd"GitMessenger"]], {"silent", "nowait"})
    -- }}} rhysd/git-messenger.vim
    -- nvim-web-devicons {{{
    require'nvim-web-devicons'.setup {
        override = {
            html = {
                icon = "",
                color = "#DE8C92",
                name = "html"
            },
            css = {
                icon = "",
                color = "#61afef",
                name = "css"
            },
            js = {
                icon = "",
                color = "#EBCB8B",
                name = "js"
            },
            png = {
                icon = " ",
                color = "#BD77DC",
                name = "png"
            },
            jpg = {
                icon = " ",
                color = "#BD77DC",
                name = "jpg"
            },
            jpeg = {
                icon = " ",
                color = "#BD77DC",
                name = "jpeg"
            },
            mp3 = {
                icon = "",
                color = "#C8CCD4",
                name = "mp3"
            },
            mp4 = {
                icon = "",
                color = "#C8CCD4",
                name = "mp4"
            },
            out = {
                icon = "",
                color = "#C8CCD4",
                name = "out"
            },
            toml = {
                icon = "",
                color = "#61afef",
                name = "toml"
            },
            lock = {
                icon = "",
                color = "#DE6B74",
                name = "lock"
            },
            webpack = {
                icon = "",
                color = "#519aba",
                name = "Webpack",
            },
            svg = {
                icon = "",
                color = "#FFB13B",
                name = "Svg",
            },
            [".babelrc"] = {
                icon = "",
                color = "#cbcb41",
                name = "Babelrc"
            },
            ["_vimrc"] = {
                icon = "",
                color = "#019833",
                name = "Vimrc",
            },
            [".vimrc"] = {
                icon = "",
                color = "#019833",
                name = "Vimrc"
            },
            ["_gvimrc"] = {
                icon = "",
                color = "#019833",
                name = "Vimrc"
            },
            ["vim"] = {
                icon = "",
                color = "#019833",
                name = "Vim"
            },
            [".exe"] = {
                icon = "",
                color = "#6d8086",
                name = "Executable"
            },
        },
        default = true
        }
    -- }}} nvim-web-devicons
end
-- }}} Neovim client
-- }}} Configuration

return M

