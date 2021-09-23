local fn   = vim.fn
local cmd  = vim.cmd
local M    = {}
local conf       = function(moduleString) return require(string.format("config.%s", moduleString)) end
local packerPath = fn.stdpath("data") .. "site/pack/packer/start/packer.nvim"
local packer     = require("packer")
-- VSCodeLoaded = vim.fn.exists('g:vscode') == 0
-- local nonVSCode    = function() return VSCodeLoaded end

if fn.empty(fn.glob(packerPath)) > 0 then
    fn.system{"git", "clone", "https://github.com/wbthomason/packer.nvim", packerPath}
end

cmd "packadd packer.nvim"

packer.init{
    package_root = vim.fn.stdpath("config") .. "/pack",
    compile_path = vim.fn.stdpath("config") .. "/plugin/packer_compiled.lua"
}

packer.startup(function(use, use_rocks)
    -- NOTE: https://github.com/wbthomason/packer.nvim#specifying-plugins
    -- use {
    -- 'myusername/example',        -- The plugin location string
    -- -- The following keys are all optional
    -- disable = boolean,           -- Mark a plugin as inactive
    -- as = string,                 -- Specifies an alias under which to install the plugin
    -- installer = function,        -- Specifies custom installer. See "custom installers" below.
    -- updater = function,          -- Specifies custom updater. See "custom installers" below.
    -- after = string or list,      -- Specifies plugins to load before this plugin. See "sequencing" below
    -- rtp = string,                -- Specifies a subdirectory of the plugin to add to runtimepath.
    -- opt = boolean,               -- Manually marks a plugin as optional.
    -- branch = string,             -- Specifies a git branch to use
    -- tag = string,                -- Specifies a git tag to use
    -- commit = string,             -- Specifies a git commit to use
    -- lock = boolean,              -- Skip this plugin in updates/syncs
    -- run = string, function, or table, -- Post-update/install hook. See "update/install hooks".
    -- requires = string or list,   -- Specifies plugin dependencies. See "dependencies".
    -- rocks = string or list,      -- Specifies Luarocks dependencies for the plugin
    -- config = string or function, -- Specifies code to run after this plugin is loaded.
    -- -- The setup key implies opt = true
    -- setup = string or function,  -- Specifies code to run before this plugin is loaded.
    -- -- The following keys all imply lazy-loading and imply opt = true
    -- cmd = string or list,        -- Specifies commands which load this plugin. Can be an autocmd pattern.
    -- ft = string or list,         -- Specifies filetypes which load this plugin.
    -- keys = string or list,       -- Specifies maps which load this plugin. See "Keybindings".
    -- event = string or list,      -- Specifies autocommand events which load this plugin.
    -- fn = string or list          -- Specifies functions which load this plugin.
    -- cond = string, function, or list of strings/functions,   -- Specifies a conditional test to load this plugin
    -- module = string or list      -- Specifies Lua module names for require. When requiring a string which starts
                                    -- with one of these module names, the plugin will be loaded.
    -- module_pattern = string/list -- Specifies Lua pattern of Lua module names for require. When
    -- requiring a string which matches one of these patterns, the plugin will be loaded.
    -- }
    -- BUG: Sometime the appearing sequence of "keys" and "cmd" inside use()
    -- func will take a significant effect on whether a plugin can be lazy
    -- loaded or not

    use 'wbthomason/packer.nvim'

    -- Vim enhancement {{{
    use 'inkarkat/vim-visualrepeat'
    use {
        'iaso2h/vim-repeat',
        lock = true
    }
    use {
        'tpope/vim-eunuch',
        cmd = {"Delete", "Unlink", "Remove", "Move", "Rename", "Chmod", "Mkdir", "Cfind", "Lfind", "Clocate", "Llocate", "SudoEdit", "SudoWrite", "Wall", "W"}
    }
    use {
        'skywind3000/asyncrun.vim',
        cmd    = {"AsyncRun", "AsyncStop"},
        config = conf "vim-asyncrun"
    }
    use {
        'bkad/camelcasemotion',
        setup = [[vim.g.camelcasemotion_key = ',']],
    }
    use {
        'antoinemadec/FixCursorHold.nvim',
        setup = [[vim.g.cursorhold_updatetime = 100]]
    }
    -- TODO: deprecated
    use {
        'landock/vim-expand-region',
        event    = "BufRead",
        requires = "camelcasemotion",
        config   = function()
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
            vim.g.expand_region_custom_text_objects = {
                ['i,w'] = 1,
                ['i%']  = 0,
                ['a]']  = 0,
                ['ab']  = 0,
                ['aB']  = 0,
                ['ai']  = 0
            }
            vim.fn["expand_region#custom_text_objects"](vim.g.expand_region_custom_text_objects)
            map("", [[<A-a>]], [[<Plug>(expand_region_expand)]], "Expand region")
            map("", [[<A-s>]], [[<Plug>(expand_region_shrink)]], "Shrink region")
            pcall(vim.cmd, [[unmap _]])
        end
    }
    use {
        'zatchheems/vim-camelsnek',
        cmd  = {"Camel", "Snake", "Pascal", "Snakecaps"},
        keys = {
            {"v", [[<A-c>]]},
            {"n", [[<A-c>]]},
            {"n", [[<A-S-c>]]},
        },
        config = function()
            vim.g.camelsnek_alternative_camel_commands = 1
            vim.g.camelsnek_no_fun_allowed             = 1
            vim.g.camelsnek_iskeyword_overre           = 0
            map("x", [[<A-c>]],   [[:call CaseSwitcher()<CR>]],                               {"silent"})
            map("n", [[<A-c>]],   [[:lua require("caseSwitcher").cycleCase()<CR>]],           {"silent"}, "Cycle cases")
            map("n", [[<A-S-c>]], [[:lua require("caseSwitcher").cycleDefaultCMDList()<CR>]], {"silent"}, "Cycle cases reset")
        end,
    }
    use {
        'andymass/vim-matchup',
        after  = "nvim-treesitter",
        event  = "BufRead",
        config = function()
            vim.g.matchup_mappings_enabled      = 0
            vim.g.matchup_matchparen_deferred   = 1
            vim.g.matchup_matchparen_pumvisible = 0
            vim.g.matchup_motion_cursor_end     = 0
            -- vim.g.matchup_matchparen_hi_surround_always = 1
            -- vim.g.matchup_matchparen_hi_background = 1
            -- vim.g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'OffscreenPopup'}
            -- In favor of Neovim Treesitter context display
            vim.g.matchup_matchparen_offscreen  = {}
            vim.g.matchup_matchparen_nomode     = "i"
            vim.g.matchup_delim_start_plaintext = 0
            vim.g.matchup_delim_noskips         = 2
            -- Text obeject
            map("x", [[am]],      [[<Plug>(matchup-a%)]])
            map("x", [[im]],      [[<Plug>(matchup-i%)]])
            map("o", [[am]],      [[<Plug>(matchup-a%)]])
            map("o", [[im]],      [[<Plug>(matchup-i%)]])
            -- Inclusive
            map("",  [[<C-m>]],   [[<Plug>(matchup-%)]], "Matchup forward inclusive")
            map("",  [[<C-S-m>]], [[<Plug>(matchup-g%)]], "Matchup backward inclusive")
            -- Exclusive
            map("n", [[<A-m>]],   [[<Plug>(matchup-]%)]], "Matchup forward exclusive")
            map("x", [[<A-m>]],   [[<Plug>(matchup-]%)]])
            map("n", [[<A-S-m>]], [[<Plug>(matchup-[%)]], "Matchup backward exclusive")
            map("x", [[<A-S-m>]], [[<Plug>(matchup-[%)]])
            -- Highlight
            map("n", [[<leader>m]], [[<Plug>(matchup-hi-surround)]], "Highlight Matchup")
            -- Change/Delete surrounds
            vim.g.matchup_surround_enabled = 1
            map("n", [[dsm]], [[<Plug>(matchup-ds%)]])
            map('n', [[csm]], [[<Plug>(matchup-cs%)]])
        end,
    }
    use {
        'phaazon/hop.nvim',
        keys = {
            {"n", [[<leader>f]]},
            {"v", [[<leader>f]]},
            {"n", [[<leader>F]]},
            {"v", [[<leader>F]]},
        },
        config = function()
            require('hop').setup{
                keys             = 'ghfjdkstyrueiwovbcnxalqozm',
                perm_method      = require'hop.perm'.TermSeqBias,
                case_insensitive = false
            }
            map("", [[<leader>f]], [[<cmd>lua require("hop").hint_char1()<CR>]], {"silent"}, "Hop char")
            map("", [[<leader>F]], [[<cmd>lua require("hop").hint_lines()<CR>]], {"silent"}, "Hop line")
        end
        }
    use {
        fn.stdpath("config") .. "/lua/fixScrollUp",
        keys = {"<C-e>", "<C-d>"},
        config = function()
            map("",  [[<C-e>]], [[<C-y>]], {"noremap", "novscode"}, "Scroll Up")
            map("",  [[<C-d>]], [[<C-e>]], {"noremap", "novscode"}, "Scroll Down")
        end
    }
    use {
        fn.stdpath("config") .. "/lua/compileRun",
        cmd  = {"Run", "Compile"},
        keys = {"F9", "S-F9"},
        config = function()
            vim.cmd [[
            command! -nargs=0 Compile lua require("compileRun").compileCode()
            command! -nargs=0 Run     lua require("compileRun").runCode()
            ]]

            map("n", [[<F9>]],   [[:lua require("compileRun").compileCode(true)<CR>]], {"noremap", "silent", "novscode"}, "Compile code")
            map("n", [[<S-F9>]], [[:lua require("compileRun").runCode(true)<CR>]],     {"noremap", "silent", "novscode"}, "Run code")
        end
    }
    use {
        'inkarkat/vim-ReplaceWithRegister',
        disable = true,
        config  = function()
                map("x", "R", "gr")
            end
    }
    use {
        fn.stdpath("config") .. "/lua/replace",
        disable = false,
        keys = {
            {"n", "gr"},
            {"n", "grr"},
            {"x", "R"},
        },
        config = function()
            map("n", [[<Plug>ReplaceOperator]],
                luaRHS[[luaeval("require('replace').expr()")]],
                {"silent", "expr"}
            )

            -- TODO: Test needed
            map("n", [[<Plug>ReplaceExpr]],
                [[:<C-u>let g:ReplaceExpr=getreg("=")<Bar>exec "norm!" . v:count1 . "."<CR>]],
                {"silent"}
            )

            map("n", [[<Plug>ReplaceCurLine]],
                luaRHS[[
                :lua require("replace").replaceSave();

                vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register);

                if require("replace").regType == "=" then
                    vim.g.ReplaceExpr = vim.fn.getreg("=")
                end;

                require("replace").operator{"line", "V", "<Plug>ReplaceCurLine", true}<CR>
                ]],
                {"noremap", "silent"})

            map("x", [[<Plug>ReplaceVisual]],
                luaRHS[[
                :lua require("replace").replaceSave();

                vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

                if require("replace").regType == "=" then
                    vim.g.ReplaceExpr = vim.fn.getreg("=")
                end;

                local vMotion = require("operator").vMotion(false);
                table.insert(vMotion, "<Plug>ReplaceVisual");
                require("replace").operator(vMotion)<CR>
                ]],
                {"noremap", "silent"})
            map("n", [[<Plug>ReplaceVisual]],
                luaRHS[[
                :lua require("replace").replaceSave();

                vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

                if require("replace").regType == "=" then
                    vim.g.ReplaceExpr = vim.fn.getreg("=")
                end;

                vim.cmd("norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0));

                local vMotion = require("operator").vMotion(false);
                table.insert(vMotion, "<Plug>ReplaceVisual");
                require("replace").operator(vMotion)<CR>
                ]],
                {"noremap", "silent"})

            map("n", [[gr]],  [[<Plug>ReplaceOperator]])
            map("n", [[grr]], [[<Plug>ReplaceCurLine]])
            map("x", [[R]],   [[<Plug>ReplaceVisual]])
        end
    }

    use {
        'tommcdo/vim-exchange',
        keys = {
            {"n", [[gx]]},
            {"x", [[X]]},
        },
        config = function()
            map("n", [[gx]],  [[<Plug>(Exchange)]], "Exchange operator")
            map("x", [[X]],   [[<Plug>(Exchange)]])
            map("n", [[gxc]], [[<Plug>(ExchangeClear)]], "Exchange highlight clear")
            map("n", [[gxx]], [[<Plug>(ExchangeLine)]], "Exchange current line")
        end,
    }
    use {
        'machakann/vim-sandwich',
        keys = {
            {"v", "S"},
            {"n", "gs"},
            {"n", "cs"},
            {"n", "ds"},
        },
        config = conf "vim-sandwich"
    }
    use {
        'junegunn/vim-easy-align',
        keys = {
            {"v", "A"},
            {"n", "ga"},
        },
        config = function()
            vim.g.easy_align_delimiters = {
                ["l"] = {
                    pattern       = "--",
                    left_margin   = 2,
                    right_margin  = 1,
                    stick_to_left = 0 ,
                    ignore_groups = {"String"}
                }
            }
            map("x", [[A]],  [[<Plug>(EasyAlign)]])
            map("n", [[ga]], [[<Plug>(EasyAlign)]], "Align operator")
        end
    }
    use {
        'michaeljsmith/vim-indent-object',
    }
    use {
        'monaqa/dial.nvim',
        keys = {
            {"n", [[<leader><C-a>]]},
            {"n", [[<leader><C-x>]]},
            {"v", [[<leader><C-a>]]},
            {"v", [[<leader><C-x>]]},
            {"v", [[<leader>g<C-a>]]},
            {"v", [[<leader>g<C-x>]]},
        },
        config = function()
            map("n", [[<leader><C-a>]],  [[<Plug>(dial-increment)]], "Dial up")
            map("n", [[<leader><C-x>]],  [[<Plug>(dial-decrement)]], "Dial down")
            map("x", [[<leader><C-a>]],  [[<Plug>(dial-increment)]])
            map("x", [[<leader><C-x>]],  [[<Plug>(dial-decrement)]])
            map("x", [[<leader>g<C-a>]], [[<Plug>(dial-increment-additional)]])
            map("x", [[<leader>g<C-x>]], [[<Plug>(dial-decrement-additional)]])
        end
    }
    use {
        'danymat/neogen',
        requires = {"nvim-treesitter", "nvim-cmp"},
        keys     = {{"n", "dg"}},
        config   = function()
            require("neogen").setup {
                enabled = true,
                languages = {
                    lua = {
                        template = {
                            annotation_convention = "emmylua"
                        }
                    },
                    python = {
                        template = {
                            annotation_convention = "google_docstrings"
                        }
                    }
                }
            }

            map("n", [[dg]], [[:lua require("neogen").generate()<CR>]], {"silent"})
            pcall(cmd, "xunmap dg")
        end,
    }
    use {
        'AndrewRadev/splitjoin.vim',
        keys   = {
            {"n", "gS"},
            {"n", "gJ"}
        },
        config = function()
            vim.g.splitjoin_align = 1
            vim.g.splitjoin_curly_brace_padding = 0
            map("n", [["gS"]], [[:<C-u>SplitjoinSplit<CR>]], {"silent"}, "Smart split")
            map("n", [["gJ"]], [[:<C-u>SplitjoinJoin<CR>]],  {"silent"}, "Smart join")
        end
    }
    use {
        'mg979/vim-visual-multi',
        keys   = {",j", ",k", ",m", ",a", ",d"},
        config = conf "vim-visual-multi".config()
    }
    use {
        'airblade/vim-rooter',
        event  = "BufRead",
        config = function()
            vim.g.rooter_change_directory_for_non_project_files = "current"
            vim.g.rooter_patterns = {
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
        end
    }
    -- use 'AndrewRadev/switch.vim'
    use {
        'windwp/nvim-autopairs',
        require = "nvim-treesitter",
        config  = function()
            require('nvim-autopairs').setup {
                disable_filetype          = {"TelescopePrompt"},
                ignored_next_char         = string.gsub([[[%w%%%'%[%"%.] ]],"%s+", ""),
                enable_moveright          = true,
                enable_afterquote         = true,  -- add bracket pairs after quote
                enable_check_bracket_line = true,  -- check bracket in same line
                check_ts                  = true,
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
        end
    }
    use {
        'preservim/nerdcommenter',
        keys = {
            {"v", [[<A-/>]]},
            {"n", [[<A-/>]]},
            {"n", [[g<space>o]]},
            {"n", [[g<space>O]]},

            {"n", [[g<space><space>]]},
            {"v", [[g<space><space>]]},

            {"n", [[g<space><space>]]},
            {"v", [[g<space><space>]]},
            {"n", [[g<space>n]]},
            {"v", [[g<space>n]]},

            {"n", [[g<space>i]]},
            {"v", [[g<space>i]]},

            {"n", [[g<space>s]]},
            {"v", [[g<space>s]]},

            {"n", [[g<space>y]]},
            {"v", [[g<space>y]]},

            {"n", [[g<space>$]]},
            {"n", [[g<space>A]]},
            {"n", [[g<space>I]]},

            {"v", [[<A-/>]]},
            {"n", [[<A-/>]]},

            {"n", [[g<space>n]]},
            {"v", [[g<space>n]]},
            {"n", [[g<space>b]]},
            {"v", [[g<space>b]]},

            {"n", [[g<space>u]]},
            {"v", [[g<space>u]]},
        },
        config = conf "vim-nerdcommenter".config,
    }
    use {
        'winston0410/range-highlight.nvim',
        disable  = true,
        requires = "winston0410/cmd-parser.nvim",
        config   = function()
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
        end
    }
    use {
        'lukas-reineke/indent-blankline.nvim',
        after  = "nvim-treesitter",
        config = function()
            require("indent_blankline").setup{
                char             = "▏",
                buftype_exclude  = {"terminal"},
                filetype_exclude = {"help", "startify", "NvimTree", "Trouble", "packer"},
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
        end
    }
    use {
        'szw/vim-maximizer',
        keys = {
            {"n", [[<C-w>m]]},
            {"v", [[<C-w>m]]},
            {"t", [[<C-w>m]]},
        },
        cmd    = "MaximizerToggle",
        config = function()
            map("",  [[<C-w>m]], [[:MaximizerToggle<CR>]],      {"silent"}, "Maximize window")
            map("t", [[<C-w>m]], [[<A-n>:MaximizerToggle<CR>]], {"silent"})
        end
    }
    use {
        'simnalamburt/vim-mundo',
        cmd    = "MundoToggle",
        keys   = {{"n", "<C-w>u"}},
        config = function()
            vim.g.mundo_help               = 1
            vim.g.mundo_tree_statusline    = 'Mundo'
            vim.g.mundo_preview_statusline = 'Mundo Preview'
            map("n", [[<C-W>u]], [[:<C-u>MundoToggle<CR>]], {"silent"}, "Open Mundo")
        end
    }
    -- }}} Vim enhancement
    -- UI {{{
    use {
        'kyazdani42/nvim-web-devicons',
        config = function()
            require'nvim-web-devicons'.setup { -- {{{
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
            } -- }}}
        end
    }
    use {
        'joshdick/onedark.vim',
    }
    -- TODO: deprecated
    use {
        'sindrets/galaxyline.nvim',
        event    = "BufRead",
        requires = "nvim-web-devicons",
        config   = conf "nvim-galaxyline"
    }
    use {
        -- 'romgrk/barbar.nvim',
        'akinsho/bufferline.nvim',
        event    = "BufRead",
        requires = "nvim-web-devicons",
        -- setup    = conf "nvim-barbar".setup,
        -- config   = conf "nvim-barbar".config,
        config   = conf "nvim-bufferline"
    }
    use {
    'RRethy/vim-hexokinase',
        run    = "make hexokinase",
        setup  = function()
            vim.g.Hexokinase_highlighters = {"backgroundfull"}
            vim.g.Hexokinase_optInPatterns = "full_hex,triple_hex,rgb,rgba,hsl,hsla"
        end
    }
    use {
        'folke/todo-comments.nvim',
        event    = "BufRead",
        requires = "nvim-web-devicons",
        config   = conf "nvim-todo-comments"
    }
    use {
        'kyazdani42/nvim-tree.lua',
        keys     = {{"n", "<C-w>e"}},
        requires = "nvim-web-devicons",
        config   = conf "nvim-tree".config
    }
    -- }}} UI
    -- Treesitter {{{
    use {
        'nvim-treesitter/nvim-treesitter',
        run    = ":TSUpdate",
        -- event  = "BufRead",
        config = function()
            require("nvim-treesitter.configs").setup{
                -- ensure_installed = "maintained",
                ensure_installed = {
                    "c", "cpp", "cmake", "lua", "json", "toml", "python",
                    "bash", "fish", "ruby", "regex", "css", "html", "go",
                    "javascript", "rust", "vue", "c_sharp", "typescript",
                    "comment", "query", "yaml"
                },
                highlight        = {enable = true},
                indent           = {enable = true},
                incremental_selection = {
                    enable  = true,
                    keymaps = {
                        init_selection    = "gnn",
                        node_incremental  = "grn",
                        node_decremental  = "grm",
                        scope_incremental = "grc",
                    },
                },
                matchup = {
                    enable = true,
                },
            }

            map("n", [[<A-S-a>]], [[gnn]])
            map("x", [[<A-S-a>]], [[grn]])
            map("",  [[<A-S-s>]], [[grm]])
        end
    }
    use {
        'nvim-treesitter/playground',
        requires = "nvim-treesitter",
        cmd      = "TSPlaygroundToggle",
        config   = function()
            require "nvim-treesitter.configs".setup {
                playground = {
                    enable          = true,
                    disable         = {},
                    updatetime      = 25,    -- Debounced time for highlighting nodes in the playground from source code
                    persist_queries = false, -- Whether the query persists across vim sessions
                    keybindings     = {
                        toggle_query_editor       = 'o',
                        toggle_hl_groups          = 'i',
                        toggle_injected_languages = 't',
                        toggle_anonymous_nodes    = 'a',
                        toggle_language_display   = 'I',
                        focus_language            = 'f',
                        unfocus_language          = 'F',
                        update                    = 'R',
                        goto_node                 = '<CR>',
                        show_help                 = '?',
                    },
                }
            }
        end
    }
    use {
        'romgrk/nvim-treesitter-context',
        after    = "nvim-treesitter",
        requires = "nvim-treesitter",
        config   = function()
            require("treesitter-context").setup{
                enable   = true,  -- Enable this plugin (Can be enabled/disabled later via commands)
                throttle = true,  -- Throttles plugin updates (may improve performance)
            }
        end
    }
    use {
        'p00f/nvim-ts-rainbow',
        after    = "nvim-treesitter",
        requires = "nvim-treesitter",
        config   = function()
            require("nvim-treesitter.configs").setup{
                rainbow = {
                    enable         = true,
                    extended_mode  = true,
                    max_file_lines = nil,
                    colors         = {
                        "#cc7000",
                        "#7a28a3",
                        "#3a5eca",
                        }
                },
            }
        end
    }
    use {
        'nvim-treesitter/nvim-treesitter-textobjects',
        after    = "nvim-treesitter",
        requires = "nvim-treesitter",
        config   = function()
            require("nvim-treesitter.configs").setup{
                textobjects = {
                    select = {
                        enable = true,
                        keymaps = {
                            ["nf"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<A-.>"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<A-,>"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@function.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@function.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@function.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@function.outer",
                        },
                    },
                },
            }
        end
    }
    use {
        'windwp/nvim-ts-autotag',
        after    = "nvim-treesitter",
        requires = "nvim-treesitter",
        config   = [[require"nvim-treesitter.configs".setup {autotag = {enable = true}}]]
    }
    use {
        'abecodes/tabout.nvim',
        after    = "nvim-treesitter",
        requires = "nvim-treesitter",
        config   = function()
            require('tabout').setup {
                -- key to trigger tabout, set to an empty string to disable
                tabkey           = '',
                -- key to trigger backwards tabout, set to an empty string to disable
                backwards_tabkey = '',
                -- shift content if tab out is not possible
                act_as_tab       = true,
                -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
                act_as_shift_tab = true,
                -- well ...
                enable_backwards = true,
                -- if the tabkey is used in a completion pum
                completion       = true,
                tabouts          = {
                    {open = "'",  close = "'"},
                    {open = '"',  close = '"'},
                    {open = '`',  close = '`'},
                    {open = '(',  close = ')'},
                    {open = '[',  close = ']'},
                    {open = '{',  close = '}'},
                    {open = '<',  close = '>'},
                    {open = '《', close = '》'},
                    {open = '「', close = '」'},
                    {open = '【', close = '】'},
                    {open = '“',  close = '”'},
                },
                --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
                ignore_beginning = true,
                -- tabout will ignore these filetypes
                exclude = {}
            }
        end
    }
    -- }}} Treesitter
    -- Intellisense {{{
    use {
        'neovim/nvim-lspconfig',
        event  = "BufRead",
        config = conf "nvim-lsp".config
    }
    use {
        'kabouzeid/nvim-lspinstall',
        module  = "lspinstall",
        rquires = "nvim-lspconfig",
        config  = function()
            require("config.nvim-lsp").setupServers()
            -- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
            require("lspinstall").post_install_hook = function ()
                require("config.nvim-lsp").setupServers()
                vim.cmd "bufdo e"
            end

            vim.cmd [[
            command! -nargs=0 LspInstalled lua Print(require("lspinstall").installed_servers())
            ]]
        end
    }
    -- TODO: deprecated
    use {
        'glepnir/lspsaga.nvim',
        after  = "nvim-lspconfig",
        config = function()
            require("lspsaga").init_lsp_saga {
                use_saga_diagnostic_sign = true,
                error_sign            = "",
                warn_sign             = "⚠️",
                hint_sign             = "",
                infor_sign            = "",
                dianostic_header_icon = "   ",
                code_action_icon      = " ",
                code_action_prompt    = {
                    enable        = false,
                    sign          = false,
                    sign_priority = 20,
                    virtual_text  = true,
                },
                finder_definition_icon = "  ",
                finder_reference_icon  = "  ",
                max_preview_lines      = 10,
                finder_action_keys     = {
                    open = "o", vsplit = "<C-v>",split = "<C-s>",quit = "q",scroll_down = "<A-d>", scroll_up = "<A-e>"
                },
                code_action_keys = {
                    quit = "q",exec = "<CR>"
                },
                rename_action_keys = {
                    quit = "<C-c>",exec = "<CR>"
                },
                definition_preview_icon = "  ",
                border_style            = "round",
                rename_prompt_prefix    = ">>>",
                -- server_filetype_map = {}
            }
        end
    }
    use {
        'folke/trouble.nvim',
        rquires = "nvim-lspconfig",
        -- TODO: shortcuts
        cmd     = "LspTrouble",
        config  = function()
            require("trouble").setup {
                position    = "bottom",  -- position of the list can be: bottom, top, left, right
                height      = 15,        -- height of the trouble list when position is top or bottom
                width       = 50,        -- width of the list when position is left or right
                icons       = true,      -- use devicons for filenames
                mode        = "lsp_workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
                fold_open   = "",  -- icon used for open folds
                fold_closed = "",  -- icon used for closed folds
                action_keys = {
                    -- key mappings for actions in the trouble list
                    -- map to {} to remove a mapping, for example:
                    -- close = {},
                    close          = "q",            -- close the list
                    cancel         = "<C-o>",        -- cancel the preview and get back to your last window / buffer / cursor
                    refresh        = "r",            -- manually refresh
                    jump           = {"<CR>", "o"},  -- jump to the diagnostic or open / close folds
                    open_split     = "<C-s>",        -- open buffer in new split
                    open_vsplit    = "<C-v>",        -- open buffer in new vsplit
                    open_tab       = "<C-t>",        -- open buffer in new tab
                    jump_close     = "<S-CR>",       -- jump to the diagnostic and close the list
                    toggle_mode    = "<Tab>",        -- toggle between "workspace" and "document" diagnostics mode
                    toggle_preview = "P",            -- toggle auto_preview
                    hover          = "K",            -- opens a small popup with the full multiline message
                    preview        = "p",            -- preview the diagnostic location

                    close_folds    = {"zM", "zm"},   -- close all folds
                    open_folds     = {"zR", "zr"},   -- open all folds
                    toggle_fold    = "<Leader><Space>", -- toggle fold of current file

                    previous       = "k",            -- preview item
                    next           = ""             -- next item
                },

                indent_lines = false, -- add an indent guide below the fold icons
                auto_open    = false, -- automatically open the list when you have diagnostics
                auto_close   = false, -- automatically close the list when you have no diagnostics
                auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
                auto_fold    = true,  -- automatically fold a file trouble list at creation
                signs        = {
                -- icons / text used for a diagnostic
                    error       = "",
                    warning     = "",
                    hint        = "",
                    information = "",
                    other       = "﫠"
                },
                use_lsp_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
            }
        end
    }
    -- TODO: highlight
    use {
        'folke/lsp-colors.nvim',
        rquires = "nvim-lspconfig",
        module  = "nvim-lspconfig",
        config  = function()
            require("lsp-colors").setup{
                Error       = "#db4b4b",
                Warning     = "#e0af68",
                Information = "#0db9d7",
                Hint        = "#10B981"
        }
        end
    }
    use {
        'hrsh7th/nvim-cmp',
        module   = "cmp",
        event    = "InsertEnter",
        requires = {
            "nvim-autopairs",

            {"hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp"},
            {"hrsh7th/cmp-nvim-lua", module = "cmp_nvim_lua", disable = true},
            {"hrsh7th/cmp-buffer",   module = "cmp_buffer"},
            {"hrsh7th/cmp-path",     module = "cmp_path"},
            {"hrsh7th/cmp-vsnip",    after  = "nvim-cmp"},
            {
                "tzachar/cmp-tabnine",
                disable = true,
                run    = "./install.sh",
                after  = "nvim-cmp",
                config = function()
                    require('cmp_tabnine.config'):setup{
                        max_num_results = 20;
                        max_lines       = 1000;
                        sort            = true;
                    }
                end
            },
        },
        config = conf "nvim-cmp"
    }
    use {
        'hrsh7th/vim-vsnip',
        event  = "InsertCharPre",
        after  = "nvim-cmp",
        config = function()
            vim.g.vsnip_snippet_dir   = vim.fn.stdpath("config") .. "/snippets"
            vim.g.vsnip_extra_mapping = false
            vim.g.vsnip_filetypes     = {
                txt        = {"all"},
                md         = {"all"},
                vim        = {"all"},
                lua        = {"all"},
                python     = {"all"},
                c          = {"all"},
                cpp        = {"all"},
                javascript = {"all", "typescirpt"},
                json       = {"all"},
                html       = {"all"},
                css        = {"all"},
                typescript = {"all", "javascript"},
            }
        end
    }
    use {
        'folke/lua-dev.nvim',
        commit  = "e958850",
        module  = "lua-dev",
        rquires = {
            "nvim-lspconfig",
            "nvim-cmp"
        },
    }
    use {
        'RRethy/vim-illuminate',
        module  = "illuminate",
        rquires = "nvim-lspconfig",
        setup   = function()
            vim.g.Illuminate_ftblacklist = {"nerdtree", "NvimTree"}
            vim.g.Illuminate_delay = 100
        end
    }
    -- }}} Intellisense
    -- Telescope {{{
    use {
        'nvim-lua/plenary.nvim',
        module_pattern = "plenary.*"
    }
    use {
        'nvim-telescope/telescope.nvim',
        module   = "telescope",
        -- event    = "BufRead",
        cmd      = "Telescope",
        keys     = {
            {"n", [[<C-h>l]]},     {"n", [[<C-h>e]]},
            {"n", [[<C-f>f]]},     {"n", [[<C-f>F]]},
            {"n", [[<C-h>c]]},     {"n", [[<C-h>h]]},
            {"n", [[<C-h><C-h>]]}, {"n", [[<C-h>o]]},
            {"n", [[<C-h>b]]}
        },
        requires = {
            "plenary.nvim",
            { "nvim-telescope/telescope-fzy-native.nvim",
                run = "make -C deps/fzy-lua-native",
                -- opt = true,
            },
        },
        config = conf "nvim-telescope"
    }
    use {
        'nvim-telescope/telescope-symbols.nvim',
        module   = "telescope",
        requires = "telescope.nvim"
    }
    -- }}} Telescope
    -- Debug {{{
    use {
        'bfredl/nvim-luadev',
        ft   = "lua",
    }
    use {
        'dstein64/vim-startuptime',
        cmd    = "StartupTime",
        config = [[vim.g.startuptime_tries = 20]]
    }
    use {
        'iaso2h/vim-scriptease',
        branch = 'ftplugin',
        ft     = 'vim',
        cmd    = {
            "PP", "PPmsg", "Runtime", "Disarm", "Scriptnames", "Messages",
            "Verbose", "Time", "Breakadd", "Vopen", "Vedit", "Vsplit"
        },
        keys   = {
            {"n", "zS",},
            {"n", "g>"}
        },
        config = function()
            map("n", [[g>]], [[:<C-u>Messages<CR>]], {"silent", "novscode"}, "Messages in quickfix")
            whichKeyDoc({"zS", "Show syntax highlighting groups"})
            whichKeyDoc({"g=", "Eval operator"})
            whichKeyDoc({"g==", "Eval current line"})

        end
    }
    use {
        'gaelph/logsitter.nvim',
        requires = "nvim-treesitter",
        after    = "nvim-treesitter",
        module   = "logsitter",
        cmd      = "Logsitter",
        setup    = [=[map("n", [[<leader>lg]], [[:lua require("logsitter").log(vim.bo.filetype)<CR>]=]
    }
    use {
        'bryall/contextprint.nvim',
        disable  = true,
        requires = "nvim-treesitter",
        after    = "nvim-treesitter",
        module   = "contextprint",
        config   = function()
            require('contextprint').setup{
                separator_char = "#",
                lua = {
                    separator = "#",
                    log = function(contents) return string.format([[Print("%s")]], contents) end
                }
            }
        map("n", [[<leader>L]], [[:lua require("contextprint").add_statement()<CR>]])
        end
    }
    -- use 'mfussenegger/nvim-dap'
    -- use 'theHamsta/nvim-dap-virtual-text'
    -- use 'mfussenegger/nvim-dap-python', {'for': 'python'}
    -- use 'puremourning/vimspector'
    -- use 'sakhnik/nvim-gdb', {'do': ':!./install.sh'}
    -- }}} Debug end
    -- Language support {{{
    -- Lua
    use {
        'davisdude/vim-love-docs',
        branch = "build",
        ft     = "lua"
    }
    use {
        'iaso2h/nlua.nvim',
        branch = "iaso2h",
        ft     = "lua",
        config = [[vim.g.nlua_keywordprg_map_key = "<C-S-q>"]]
    }
    use {
        'nanotee/luv-vimdocs',
        ft = "lua"
    }
    -- Markdown
    use {
        'iamcco/markdown-preview.nvim',
        run = [=[vim.fn["mkdp#util#install"]]=],
        ft  = {'markdown', 'md'}
    }
    use {
        'plasticboy/vim-markdown',
        ft     = {'markdown', 'md'},
        config = conf "vim-markdown"
    }
    -- Log
    use {
        'MTDL9/vim-log-highlighting',
        ft = "log"
    }
    -- Fish script
    use {
        'NovaDev94/vim-fish',
        ft = "fish"
    }
    -- }}} Language support
    -- Source control {{{
    use {
        'lewis6991/gitsigns.nvim',
        event  = "BufRead",
        config = conf "nvim-gitsigns"
    }
    -- TODO: highlight
    use {
        'rhysd/conflict-marker.vim',
        disable = true,
        keys    = "}x, ]x, cb, co, cn, cb",
    }
    -- use {
        -- 'sindrets/diffview.nvim',
    -- }
    -- }}} Source control
    -- Knowlege {{{
    -- TODO: highlight
    use {
        'folke/which-key.nvim',
        disable = true,
        event   = "VimEnter",
        config  = conf "nvim-which-key"
    }
    use {
        'RishabhRD/popfix',
        module_pattern = "popfix.*",
    }
    use {
        'RishabhRD/nvim-cheat.sh',
        cmd      = {"Cheat", "CheatList", "CheatListWithoutComments", "CheatWithoutComments"},
        requries = "popfix"
    }
    use {
        'dahu/VimRegexTutor',
        cmd  = "VimRegexTutor",
    }
    use {
        'DanilaMihailov/vim-tips-wiki',
    }
    -- }}} Knowlege
end)

return M

