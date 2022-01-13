local fn   = vim.fn
local cmd  = vim.cmd
local M    = {}
local conf       = function(moduleString) return require(string.format("config.%s", moduleString)) end
local packerPath = fn.stdpath("data") .. "site/pack/packer/start/packer.nvim"
local packer     = require("packer")

if fn.empty(fn.glob(packerPath)) > 0 then
    fn.system{"git", "clone", "https://github.com/wbthomason/packer.nvim", packerPath}
end

cmd "packadd packer.nvim"

packer.init{
    package_root = vim.fn.stdpath("config") .. "/pack",
    compile_path = vim.fn.stdpath("config") .. "/lua/packer_compiled.lua"
}

packer.startup{
    function(use, use_rocks)
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
    -- cond = string, function, or list of strings/functions,   -- Specifies a conditional test to load this plugin
    -- fn = string or list          -- Specifies functions which load this plugin.
    -- module = string or list      -- Specifies Lua module names for require. When requiring a string which starts
                                    -- with one of these module names, the plugin will be loaded.
    -- module_pattern = string/list -- Specifies Lua pattern of Lua module names for require. When
    -- requiring a string which matches one of these patterns, the plugin will be loaded.
    -- }
    -- func will take a significant effect on whether a plugin can be lazy
    -- loaded or not

    use 'wbthomason/packer.nvim'

    -- use_rocks 'icecream'

    -- Vim enhancement {{{
    use 'nathom/filetype.nvim'
    use 'inkarkat/vim-visualrepeat'
    use 'tpope/vim-repeat'
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
    use {
        'zatchheems/vim-camelsnek',
        keys = {
            {"x", [[<A-c>]]},
            {"n", [[<A-c>]]},
            {"n", [[<A-S-c>]]},
        },
        setup = function()
            vim.g.camelsnek_alternative_camel_commands = 1
            vim.g.camelsnek_no_fun_allowed             = 1
            vim.g.camelsnek_iskeyword_override         = 0
        end,
        config = function()
            map("x", [[<A-c>]],   [[:call CaseSwitcher()<CR>]],    {"silent"}, "Change case for selected")
            map("n", [[<A-c>]],   require("caseSwitcher").cycleCase,           "Cycle cases")
            map("n", [[<A-S-c>]], require("caseSwitcher").cycleDefaultCMDList, "Cycle cases reset")
        end,
    }
    use {
        'andymass/vim-matchup',
        require = "nvim-treesitter",
        event   = {"CursorHold", "CursorHoldI"},
        config  = function()
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
            vim.g.matchup_surround_enabled      = 0
            -- Text obeject
            map("x", [[am]],      [[<Plug>(matchup-a%)]], "Matchup a% text object")
            map("x", [[im]],      [[<Plug>(matchup-i%)]], "Matchup i% text object")
            map("o", [[am]],      [[<Plug>(matchup-a%)]], "Matchup a% text object")
            map("o", [[im]],      [[<Plug>(matchup-i%)]], "Matchup i% text object")
            -- Inclusive
            map({"n", "x", "o"},  [[<C-m>]],   [[<Plug>(matchup-%)]], "Matchup forward inclusive")
            map({"n", "x", "o"},  [[<C-S-m>]], [[<Plug>(matchup-g%)]], "Matchup backward inclusive")
            -- Exclusive
            map("n", [[<A-m>]],   [[<Plug>(matchup-]%)]], "Matchup forward exclusive")
            map("x", [[<A-m>]],   [[<Plug>(matchup-]%)]], "Matchup forward exclusive")
            map("n", [[<A-S-m>]], [[<Plug>(matchup-[%)]], "Matchup backward exclusive")
            map("x", [[<A-S-m>]], [[<Plug>(matchup-[%)]], "Matchup backward exclusive")
            -- Highlight
            map("n", [[<leader>m]], [[<Plug>(matchup-hi-surround)]], "Highlight Matchup")
        end,
    }
    use {
        'phaazon/hop.nvim',
        keys = {
            {"n", [[<leader>f]]},
            {"x", [[<leader>f]]},
            {"n", [[<leader>F]]},
            {"x", [[<leader>F]]},
        },
        config = function()
            require('hop').setup{
                case_insensitive = false
            }
            map({"n", "x"}, [[<leader>f]], require("hop").hint_char1, "Hop char")
            map({"n", "x"}, [[<leader>F]], require("hop").hint_lines, "Hop line")
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

            map("n", [[<F9>]],   [[:lua require("compileRun").compileCode(true)<CR>]], {"noremap", "silent"}, "Compile code")
            map("n", [[<S-F9>]], [[:lua require("compileRun").runCode(true)<CR>]],     {"noremap", "silent"}, "Run code")
        end
    }
    use {
        'inkarkat/vim-ReplaceWithRegister',
        disable = true,
        config  = 'map("x", "R", "gr", "Replace operator)'
    }
    use {
        fn.stdpath("config") .. "/lua/replace",
        disable = false,
        keys = {
            {"n", "gr"},
            {"n", "grr"},
            {"n", "grn"},
            {"n", "grN"},
            {"x", "R"},
        },
        config = function()
            map("n", [[<Plug>ReplaceOperator]],
                luaRHS[[luaeval("require('replace').expr()")]],
                {"silent", "expr"}, "Replace operator"
            )

            -- TODO: Test needed
            map("n", [[<Plug>ReplaceExpr]],
                [[:<C-u>let g:ReplaceExpr=getreg("=")<Bar>exec "norm!" . v:count1 . "."<CR>]],
                {"silent"}, "Replace expression"
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
                {"noremap", "silent"}, "Replace current line")
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
                {"noremap", "silent"}, "Replace selected")
            map("n", [[<Plug>ReplaceVisual]],
                luaRHS[[
                :lua require("replace").replaceSave();

                vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

                if require("replace").regType == "=" then
                    vim.g.ReplaceExpr = vim.fn.getreg("=")
                end;

                vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0));

                local vMotion = require("operator").vMotion(false);
                table.insert(vMotion, "<Plug>ReplaceVisual");
                require("replace").operator(vMotion)<CR>
                ]],
                {"noremap", "silent"}, "Visual-repeat for replaced selected")

            map("n", [[gr]],  [[<Plug>ReplaceOperator]], "Replace operator")
            map("n", [[grr]], [[<Plug>ReplaceCurLine]], "Replace current line")
            map("n", [[grn]], [[*``griw]], {"noremap"}, "Replace word under cursor, then highlight forward")
            map("n", [[grN]], [[#``griw]], {"noremap"}, "Replace word under cursor, then highlight backward")
            map("x", [[R]],   [[<Plug>ReplaceVisual]], "Replace selected")
        end
    }
    use {
        fn.stdpath("config") .. "/lua/logsitter",
        requires = "nvim-treesitter",
        module   = "logsitter",
        keys     = {{"n", "<leader>lg"}},
        config   = function()
            map("n", [[<leader>lg]], require("logsitter").log, "Log under cursor")
            require("logsitter").setup{
                logFunc = {
                    lua = "Print",
                }
            }
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
            map("x", [[X]],   [[<Plug>(Exchange)]], "Exchange selected")
            map("n", [[gxc]], [[<Plug>(ExchangeClear)]], "Exchange highlight clear")
            map("n", [[gxx]], [[<Plug>(ExchangeLine)]], "Exchange current line")
        end,
    }
    use {
        'machakann/vim-sandwich',
        keys = {
            {"x", "S"},
            {"n", "gs"},
            {"n", "cs"},
            {"n", "ds"},
        },
        setup  = conf "vim-sandwich".setup,
        config = conf "vim-sandwich".config
    }
    use {
        'junegunn/vim-easy-align',
        keys = {
            {"x", "A"},
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
            map("x", [[A]],  [[<Plug>(EasyAlign)]], "Align selected")
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
            {"x", [[<leader><C-a>]]},
            {"x", [[<leader><C-x>]]},
            {"x", [[<leader>g<C-a>]]},
            {"x", [[<leader>g<C-x>]]},
        },
        config = function()
            map("n", [[<leader><C-a>]],  [[<Plug>(dial-increment)]],            "Dial up")
            map("n", [[<leader><C-x>]],  [[<Plug>(dial-decrement)]],            "Dial down")
            map("x", [[<leader><C-a>]],  [[<Plug>(dial-increment)]],            "Dial up for selected")
            map("x", [[<leader><C-x>]],  [[<Plug>(dial-decrement)]],            "Dial down for selected")
            map("x", [[<leader>g<C-a>]], [[<Plug>(dial-increment-additional)]], "Dial up additional for selected")
            map("x", [[<leader>g<C-x>]], [[<Plug>(dial-decrement-additional)]], "Dial down additional for selected")
        end
    }
    use {
        'danymat/neogen',
        requires = {"nvim-treesitter", "nvim-cmp"},
        keys     = {{"n", "g<Space>d"}},
        config   = function()
            require("neogen").setup {
                enabled             = false,
                input_after_comment = true,
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
                    },
                    php = {
                        template = {
                            annotation_convention = "phpdoc"
                        }
                    },
                    rust = {
                        template = {
                            annotation_convention = "rustdoc"
                        }
                    },
                    c = {
                        template = {
                            annotation_convention = "doxygen"
                        }
                    },
                    cpp = {
                        template = {
                            annotation_convention = "doxygen"
                        }
                    },
                    csharp = {
                        template = {
                            annotation_convention = "xmldoc"
                        }
                    },
                    java = {
                        template = {
                            annotation_convention = "javadoc"
                        }
                    },
                    javascript = {
                        template = {
                            annotation_convention = "jsdoc"
                        }
                    },
                    typescript = {
                        template = {
                            annotation_convention = "jsdoc"
                        }
                    },
                }
            }

            map("n", [[g<Space>d]], require("neogen").generate, "Comment function description")
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
            map("n", [["gS"]], [[<CMD>SplitjoinSplit<CR>]], {"silent"}, "Smart split")
            map("n", [["gJ"]], [[<CMD>SplitjoinJoin<CR>]],  {"silent"}, "Smart join")
        end
    }
    use {
        'mg979/vim-visual-multi',
        keys = {
                {"n", ",j"},
                {"n", ",k"},
                {"n", ",m"},
                {"n", ",a"},
                {"n", ",d"}
            },
        setup  = conf("vim-visual-multi").setup,
        config = conf("vim-visual-multi").config
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
    use {
        'AndrewRadev/switch.vim',
        cmd   = "Switch",
        setup = 'map("n", [[gt]], [[<CMD>Switch<CR>]], {"silent"}, "Switch word under cursor")'
    }
    use {
        'AndrewRadev/linediff.vim',
        cmd = {"Linediff", "LinediffReset"},
    }
    -- TODO: reimplement in lua way and support treesitter
    use {
        'AndrewRadev/deleft.vim',
        disable = true,
        cmd = {"Linediff", "LinediffReset"},
    }
    use {
        'AndrewRadev/sideways.vim',
        disable = true,
        -- cmd  = {"SidewaysJumpLeft", "SidewaysJumpRight"},
        -- keys = {
            -- {"n", "gx<"},
            -- {"n", "gx>"},
        -- },
        -- config = function()
            -- map("n", [[gx<]], [[<CMD>SidewaysLeft<CR>]],  {"silent"})
            -- map("n", [[gx>]], [[<CMD>SidewaysRight<CR>]], {"silent"})
        -- end
    }
    use {
        'windwp/nvim-autopairs',
        require = "nvim-treesitter",
        config  = function()
            require('nvim-autopairs').setup {
                disable_filetype          = {"TelescopePrompt", "dap-repl"},
                disable_in_macro          = true,
                ignored_next_char         = string.gsub([[[%w%%%'%[%"%.] ]],"%s+", ""),
                enable_moveright          = true,
                enable_afterquote         = true,   -- add bracket pairs after quote
                enable_check_bracket_line = false,  -- check bracket in same line
                check_ts                  = true,
                map_bs                    = true,
                map_c_h                   = false,
                map_c_w                   = false,
                fast_wrap = {
                    map         = '<A-p>',
                    chars       = {'{', '[', '(', '"', "'"},
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
            {"x", [[<A-/>]]},
            {"n", [[<A-/>]]},
            {"n", [[g<space>o]]},
            {"n", [[g<space>O]]},

            {"n", [[g<space><space>]]},
            {"x", [[g<space><space>]]},

            {"n", [[g<space><space>]]},
            {"x", [[g<space><space>]]},
            {"n", [[g<space>n]]},
            {"x", [[g<space>n]]},

            {"n", [[g<space>i]]},
            {"x", [[g<space>i]]},

            {"n", [[g<space>s]]},
            {"x", [[g<space>s]]},

            {"n", [[g<space>y]]},
            {"x", [[g<space>y]]},

            {"n", [[g<space>$]]},
            {"n", [[g<space>A]]},
            {"n", [[g<space>I]]},

            {"x", [[<A-/>]]},
            {"n", [[<A-/>]]},

            {"n", [[g<space>n]]},
            {"x", [[g<space>n]]},
            {"n", [[g<space>b]]},
            {"x", [[g<space>b]]},

            {"n", [[g<space>u]]},
            {"x", [[g<space>u]]},
        },
        setup  = [[vim.api.nvim_set_var("NERDCreateDefaultMappings", 0)]],
        config = conf("vim-nerdcommenter").config,
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
        require = "nvim-treesitter",
        event   = "BufRead",
        config  = function()
            require("indent_blankline").setup{
                char             = "▏",
                context_char     = "▏",
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
            {"x", [[<C-w>m]]},
            {"t", [[<C-w>m]]},
        },
        cmd    = "MaximizerToggle",
        config = function()
            map({"n", "x"},  [[<C-w>m]], [[<CMD>MaximizerToggle<CR>]],  {"silent"}, "Maximize window")
            map("t",         [[<C-w>m]], [[<A-n>:MaximizerToggle<CR>]], {"silent"}, "Maximize window")
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
            map("n", [[<C-W>u]], [[<CMD>MundoToggle<CR>]], {"silent"}, "Open Mundo")
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
        disable = true
    }
    use {
        'NTBBloodbath/galaxyline.nvim',
        event    = "BufRead",
        requires = "nvim-web-devicons",
        config   = conf "nvim-galaxyline"
    }
    use {
        'akinsho/bufferline.nvim',
        event    = "BufRead",
        requires = "nvim-web-devicons",
        config   = conf "nvim-bufferline".config
    }
    use {
    'RRethy/vim-hexokinase',
        event = "BufRead",
        run   = "make hexokinase",
        setup = function()
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
        config   = conf "nvim-tree"
    }
    use {
        'MunifTanjim/nui.nvim',
        disable = true
    }
    -- }}} UI
    -- Treesitter {{{
    use {
        'nvim-treesitter/nvim-treesitter',
        run    = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup{
                -- ensure_installed = "maintained",
                ensure_installed = {
                    "c", "cpp", "cmake", "lua", "json", "toml",
                    "python", "bash", "fish", "ruby", "regex", "css", "html",
                    "go", "javascript", "rust", "vue", "c_sharp", "typescript",
                    "comment", "query", "yaml"
                },
                highlight        = {
                    enable = true,
                    custom_captures = {
                    },
                    additional_vim_regex_highlighting = false
                },
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

            map("n",        [[<A-S-a>]], [[gnn]], "Expand selection")
            map("x",        [[<A-S-a>]], [[grc]], "Expand selection")
            map({"n", "x"}, [[<A-S-s>]], [[grm]], "Shirnk selection")
        end
    }
    use {
        'nvim-treesitter/playground',
        requires = "nvim-treesitter",
        cmd      = "TSPlaygroundToggle",
        keys     = {
                {"n", "gH"}
            },
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

            map("n", [[gH]], [[<CMD>TSHighlightCapturesUnderCursor<CR>]], {"silent"}, "Show Tree sitter highlight group")
        end
    }
    use {
        'romgrk/nvim-treesitter-context',
        requires = "nvim-treesitter",
        event    = {"CursorHold", "CursorHoldI"},
        config   = function()
            require("treesitter-context").setup{
                enable   = true,  -- Enable this plugin (Can be enabled/disabled later via commands)
                throttle = true,  -- Throttles plugin updates (may improve performance)
                patterns = {      -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
                    -- For all filetypes
                    -- Note that setting an entry here replaces all other patterns for this entry.
                    -- By setting the 'default' entry below, you can control which nodes you want to
                    -- appear in the context window.
                    default = {
                        'class',
                        'function',
                        'method',
                        'for',
                        'while',
                        'if',
                        'switch',
                        'case',
                    },
                }
            }
        end
    }
    use {
        'p00f/nvim-ts-rainbow',
        requires = "nvim-treesitter",
        after    = "nvim-treesitter",
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
        requires = "nvim-treesitter",
        config   = function()
            require("nvim-treesitter.configs").setup{
                textobjects = {
                    select = {
                        enable = true,
                        keymaps = {
                            -- ["nf"] = "@function.outer",
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
        requires = "nvim-treesitter",
        ft       = {"html", "javascript", "javascriptreact", "typescriptreact", "svelte", "vue"},
        config   = [[require("nvim-treesitter.configs").setup {autotag = {enable = true}}]]
    }
    use {
        'abecodes/tabout.nvim',
        disable = true,
        event    = "InsertEnter",
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
        config = conf("nvim-lsp").config
    }
    use {
        'williamboman/nvim-lsp-installer',
        module  = "nvim-lsp-installer",
        rquires = "nvim-lspconfig",
    }
    use {
        'kosayoda/nvim-lightbulb',
        require = "nvim-lspconfig",
        event   = {"CursorHold", "CursorHoldI"},
        config  = function()
            vim.cmd [[
            augroup lightBulb
            autocmd!
            autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb{sign={enabled=false,},virtual_text={enabled=true, text = "💡"}}
            augroup END
            ]]
            -- require('nvim-lightbulb').update_lightbulb({
                -- sign = {
                    -- enabled = true,
                    -- },
                -- virtual_text = {
                    -- enabled = true, text = "💡"
                -- }
            -- })
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
    use {
        'hrsh7th/vim-vsnip',
        event  = "InsertEnter",
        config = conf "vim-vsnip"
    }
    use {
        'hrsh7th/nvim-cmp',
        module   = "cmp",
        event    = "InsertEnter",
        requires = {
            "nvim-autopairs",

            {"hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp"},
            {"hrsh7th/cmp-nvim-lua", module = "cmp_nvim_lua",  disable = true},
            {"hrsh7th/cmp-buffer",   module = "cmp_buffer"},
            {"hrsh7th/cmp-path",     module = "cmp_path"},
            {"hrsh7th/cmp-vsnip",    after = "nvim-cmp",},
            {"lukas-reineke/cmp-under-comparator", module = "cmp-under-comparator",},
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
            vim.g.Illuminate_ftblacklist = {"nerdtree", "NvimTree", "qf", "packer"}
            vim.g.Illuminate_delay = 100
        end
    }
    use {
        'ThePrimeagen/refactoring.nvim',
        disable = true,
        requires = {
            "plenary.nvim",
            "nvim-treesitter"
        },
        config = function()
            local refactor = require("refactoring")
            refactor.setup{}

            -- -- telescope refactoring helper
            -- local function refactor(prompt_bufnr)
                -- local content = require("telescope.actions.state").get_selected_entry(
                    -- prompt_bufnr
                -- )
                -- require("telescope.actions").close(prompt_bufnr)
                -- require("refactoring").refactor(content.value)
            -- end
            map("x", [[<leader>re]], [[:lua require("refactoring").refactor("Extract Function")<CR>]],         {"silent"}, "Extract function")
            map("x", [[<leader>rf]], [[:lua require("refactoring").refactor("Extract Function To File")<CR>]], {"silent"}, "Extract function to file")
            map("v", [[<Leader>rv]], [[:lua require('refactoring').refactor('Extract Variable')<CR>]], {"silent"}, "extract varibale")
            map("v", [[<Leader>ri]], [[:lua require('refactoring').refactor('Inline Variable')<CR>]], {"silent"}, "extract inline varibale")
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
        cmd      = "Telescope",
        keys     = {
            {"n", [[<C-f>l]]},  {"n", [[<C-f>E]]},    {"n", [[<C-f>e]]},  {"n", [[<C-f>f]]},
            {"n", [[<C-f>F]]},  {"n", [[<C-f>w]]},    {"n", [[<C-f>W]]},  {"n", [[<A-C-j>]]},
            {"n", [[<A-C-k>]]}, {"n", [[<C-h>/]]},    {"n", [[<C-h>v]]},  {"n", [[<C-h>o]]},
            {"n", [[<C-h>i]]},  {"n", [[<C-h>q]]},    {"n", [[<C-h>m]]},  {"n", [[<C-h>k]]},
            {"n", [[<C-h>c]]},  {"n", [[<C-h>h]]},    {"n", [[<C-h>H]]},  {"n", [[<C-h>l]]},
            {"n", [[<C-f>o]]},  {"n", [[<C-f>O]]},    {"n", [[<C-f>gc]]}, {"n", [[<C-f>gC]]},
            {"n", [[<C-f>gs]]}, {"n", [[<leader>b]]},

            {"n", [[<C-f>a]]},    {"n", [[<C-f>o]]}, {"n", [[<C-f>O]]}, {"n", [[<leader>e]]},
            {"n", [[<leader>E]]},
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
        config = [[vim.g.startuptime_tries = 50]]
    }
    use 'lewis6991/impatient.nvim'
    use {
        'iaso2h/vim-scriptease',
        branch = 'ftplugin',
        ft     = 'vim',
        cmd    = {
            "PP", "Runtime", "Disarm", "Scriptnames", "Messages",
            "Verbose", "Time", "Breakadd", "Vopen", "Vedit", "Vsplit"
        },
        keys   = {
            {"n", "g>"}
        },
        config = conf("vim-scriptease").config
    }
    use {
        'mfussenegger/nvim-dap',
        module = "dap",
        setup  = conf "nvim-dap".setup,
        config = conf "nvim-dap".config
    }
    use {
        'rcarriga/nvim-dap-ui',
        after  = "nvim-dap",
        config = conf "nvim-dap-ui"
    }
    use {
        -- TODO: hlGroup
        'theHamsta/nvim-dap-virtual-text',
        after  = "nvim-dap",
        config = function()
            require("nvim-dap-virtual-text").setup {
                enabled = true,                      -- enable this plugin (the default)
                enabled_commands = true,             -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                highlight_changed_variables = true,  -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
                highlight_new_as_changed = false,    -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
                show_stop_reason = true,             -- show stop reason when stopped for exceptions
                commented = false,                   -- prefix virtual text with comment string

                -- experimental features:
                virt_text_pos = 'eol',               -- position of virtual text, see `:h nvim_buf_set_extmark()`
                all_frames = false,                  -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                virt_lines = false,                  -- show virtual lines instead of virtual text (will flicker!)
                virt_text_win_col = nil              -- position the virtual text at a fixed window column (starting from the first text column) ,
                                                     -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
            }
        end
    }
    use {
        'jbyuki/one-small-step-for-vimkind',
        module = "osv",
        cmd    = {"OSVStart", "OSVStop"},
        config = function()
            vim.cmd [[command! -nargs=0 OSVStop  lua require("osv").stop()]]
            vim.cmd [[command! -nargs=0 OSVStart lua require("osv").launch()]]
        end
    }
    use {
        'michaelb/sniprun',
        run = 'bash ./install.sh',
        cmd = {"SnipRun", "SnipReset", "SnipReplMemoryClean", "SnipTerminate", "SnipInfo", "SnipClose"},
        config = function ()
            require'sniprun'.setup{
                selected_interpreters = {},     --# use those instead of the default for the current filetype
                repl_enable = {},               --# enable REPL-like behavior for the given interpreters
                repl_disable = {},              --# disable REPL-like behavior for the given interpreters

                interpreter_options = {},       --# intepreter-specific options, consult docs / :SnipInfo <name>

                --# you can combo different display modes as desired
                display = {
                    "Classic",                    --# display results in the command-line  area
                    "VirtualTextOk",              --# display ok results as virtual text (multiline is shortened)

                    -- "VirtualTextErr",          --# display error results as virtual text
                    -- "TempFloatingWindow",      --# display results in a floating window
                    -- "LongTempFloatingWindow",  --# same as above, but only long results. To use with VirtualText__
                    -- "Terminal",                --# display results in a vertical split
                    -- "NvimNotify",              --# display with the nvim-notify plugin
                    -- "Api"                      --# return output to a programming interface
                },

                --# You can use the same keys to customize whether a sniprun producing
                --# no output should display nothing or '(no output)'
                show_no_output = {
                    "Classic",
                    "TempFloatingWindow",      --# implies LongTempFloatingWindow, which has no effect on its own
                },

                -- --# customize highlight groups (setting this overrides colorscheme)
                -- snipruncolors = {
                    -- SniprunVirtualTextOk  = {bg="#66eeff",fg="#000000"},
                    -- SniprunFloatingWinOk  = {fg="#66eeff"},
                    -- SniprunVirtualTextErr = {bg="#881515",fg="#000000"},
                    -- SniprunFloatingWinErr = {fg="#881515"},
                -- },

                --# miscellaneous compatibility/adjustement settings
                inline_messages = 0,             --# inline_message (0/1) is a one-line way to display messages
                                --# to workaround sniprun not being able to display anything

                borders = 'single'               --# display borders around floating windows
                                                --# possible values are 'none', 'single', 'double', or 'shadow'
            }
        end,
    }
    -- use 'sakhnik/nvim-gdb', {'do': ':!./install.sh'}
    -- }}} Debug
    -- Language support {{{
    -- Lua
    use {
        'davisdude/vim-love-docs',
        disable = true,
        branch  = "build",
        ft      = "lua"
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
        run = [=[vim.fn["mkdp#util#install"] ]=],
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
    use {
        'rhysd/conflict-marker.vim',
        disable = true,
        keys    = "}x, ]x, cb, co, cn, cb",
    }
    use {
        'sindrets/diffview.nvim',
        config = conf "nvim-diffview",
        cmd = "DiffviewOpen"
    }
    -- }}} Source control
    -- Knowlege {{{
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
        "AndrewRadev/exercism.vim",
        cmd = "Exercism"
    }
    use {
        'dahu/VimRegexTutor',
        cmd  = "VimRegexTutor",
    }
    use {
        'DanilaMihailov/vim-tips-wiki',
        disable = true
    }
    -- }}} Knowlege
    end,

    config = {
        display = {
            prompt_border = 'rounded',
            open_fn       = function()
                return require("packer.util").float{border = "single"}
            end
        },
        luarocks = {
            python_cmd = 'python' -- Set the python command to use for running hererocks
        }
    }
}

return M

