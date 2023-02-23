local fn   = vim.fn
local packerPath = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(packerPath)) > 0 then
    vim.notify("Fetching packer.nvim from github.com", vim.log.levels.WARN)
    fn.system{"git", "clone", "https://github.com/wbthomason/packer.nvim", packerPath}
    return vim.notify("Please restart neovim", vim.log.levels.WARN)
end

local packer = require("packer")
local conf   = function(moduleString) return require(string.format("config.%s", moduleString)) end


packer.init{
    package_root = vim.fn.stdpath("config") .. "/pack",
    compile_path = vim.fn.stdpath("config") .. "/lua/packer_compiled.lua"
}

packer.startup{function(use, use_rocks)
    use 'wbthomason/packer.nvim'
    -- use_rocks 'icecream'

    -- disable = boolean,           -- Mark a plugin as inactive
    -- as = string,                 -- Specifies an alias under which to install the plugin
    -- installer = function,        -- Specifies custom installer. See |packer-custom-installers|
    -- updater = function,          -- Specifies custom updater. See |packer-custom-installers|
    -- after = string or list,      -- Specifies plugins to load before this plugin.
    -- rtp = string,                -- Specifies a subdirectory of the plugin to add to runtimepath.
    -- opt = boolean,               -- Manually marks a plugin as optional.
    -- bufread = boolean,           -- Manually specifying if a plugin needs BufRead after being loaded
    -- branch = string,             -- Specifies a git branch to use
    -- tag = string,                -- Specifies a git tag to use. Supports '*' for "latest tag"
    -- commit = string,             -- Specifies a git commit to use
    -- lock = boolean,              -- Skip updating this plugin in updates/syncs. Still cleans.
    -- run = string, function, or table  -- Post-update/install hook. See |packer-plugin-hooks|
    -- requires = string or list    -- Specifies plugin dependencies. See |packer-plugin-dependencies|
    -- config = string or function, -- Specifies code to run after this plugin is loaded.
    -- rocks = string or list,      -- Specifies Luarocks dependencies for the plugin
    -- -- The following keys all imply lazy-loading
    -- cmd = string or list,        -- Specifies commands which load this plugin.  Can be an autocmd pattern.
    -- ft = string or list,         -- Specifies filetypes which load this plugin.
    -- keys = string or list,       -- Specifies maps which load this plugin. See |packer-plugin-keybindings|
    -- event = string or list,      -- Specifies autocommand events which load this plugin.
    -- fn = string or list          -- Specifies functions which load this plugin.
    -- cond = string, function, or list of strings/functions,   -- Specifies a conditional test to load this plugin
    -- setup = string or function,  -- Specifies code to run before this plugin is loaded. The code is ran even if
                                -- -- the plugin is waiting for other conditions (ft, cond...) to be met.
    -- module = string or list      -- Specifies Lua module names for require. When requiring a string which starts
                                -- -- with one of these module names, the plugin will be loaded.
    -- module_pattern = string/list -- Specifies Lua pattern of Lua module names for require. When requiring a string
                                -- -- which matches one of these patterns, the plugin will be loaded.



    -- Dependencies {{{
    use {
        'nvim-lua/plenary.nvim',
        module_pattern = "plenary.*"
    }
    -- }}} Dependencies
-- Treesitter {{{
use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
        require('nvim-treesitter.install').update({with_sync = true})
        ---@diagnostic disable-next-line: undefined-global
        ts_update()
    end,
    config = conf "nvim-treesitter"
}
use {
    'nvim-treesitter/playground',
    requires = "nvim-treesitter",
    cmd      = "TSPlaygroundToggle",
    keys     = {{"n", "gH"}},
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
    config   = [[require("treesitter-context").setup()]]
}
use {
    'p00f/nvim-ts-rainbow',
    -- TODO:
    -- 'HiPhish/nvim-ts-rainbow2',
    event    = "BufAdd",
    requires = "nvim-treesitter",
    after    = "nvim-treesitter",
    config   = function()
        require("nvim-treesitter.configs").setup{
            rainbow = {
                enable         = true,
                extended_mode  = true,
                max_file_lines = 3000,
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
    'lewis6991/gitsigns.nvim',
    config = conf "nvim-gitsigns"
}
use {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event    = "BufAdd",
    requires = {
        "nvim-treesitter",
        "gitsigns.nvim"
    },
    config = conf "nvim-treesitter-textobjects"
}
use {
    'windwp/nvim-ts-autotag',
    event    = "InsertEnter",
    requires = "nvim-treesitter",
    ft       = {"html", "javascript", "javascriptreact", "typescriptreact", "svelte", "vue"},
    config   = [[require("nvim-treesitter.configs").setup {autotag = {enable = true}}]]
}

-- }}} Treesitter
    -- Vim enhancement {{{
    use {
        'inkarkat/vim-visualrepeat',
        event = "BufModifiedSet"
    }
    use {
        'tpope/vim-repeat',
        event = "BufModifiedSet"
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
        event = "BufAdd",
        setup = [[vim.g.camelcasemotion_key = ',']],
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
            -- TODO: support in visual mode
            -- map("x", [[<A-c>]],   [[:call CaseSwitcher()<CR>]],    {"silent"}, "Change case for selected")
            map("n", [[<A-c>]],   [[<CMD>lua require("caseSwitcher").cycleCase()<CR>]],           "Cycle cases")
            map("n", [[<A-S-c>]], [[<CMD>lua require("caseSwitcher").cycleDefaultCMDList()<CR>]], "Cycle cases reset")
        end,
    }
    use {
        'andymass/vim-matchup',
        event   = "BufAdd",
        require = "nvim-treesitter",
        setup   = conf "vim-matchup".setup,
        config  = conf "vim-matchup".config
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
        keys = {"F9", "<S-F9>"},
        config = function()
            vim.cmd [[
            command! -nargs=0 Compile lua require("compileRun").compileCode()
            command! -nargs=0 Run     lua require("compileRun").runCode()
            ]]

            map("n", [[<F9>]],   [[<CMD>lua require("compileRun").compileCode(true)<CR>]], {"noremap", "silent"}, "Compile code")
            map("n", [[<S-F9>]], [[<CMD>lua require("compileRun").runCode(true)<CR>]],     {"noremap", "silent"}, "Run code")
        end
    }
    use {
        'tommcdo/vim-exchange',
        keys = {
            {"n", [[gx]]},
            {"x", [[X]]},
        },
        config = function()
            map("n", [[gx]],  [[<Plug>(Exchange)]],      "Exchange operator")
            map("x", [[X]],   [[<Plug>(Exchange)]],      "Exchange selected")
            map("n", [[gxc]], [[<Plug>(ExchangeClear)]], "Exchange highlight clear")
            map("n", [[gxx]], [[<Plug>(ExchangeLine)]],  "Exchange current line")
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
            -- {"n", "ga"},
        },
        config = function()
            vim.g.easy_align_delimiters = {
                -- Align to lua comment
                ["l"] = {
                    pattern       = "--",
                    left_margin   = 2,
                    right_margin  = 1,
                    stick_to_left = 0 ,
                    ignore_groups = {"String"}
                }
            }
            map("x", [[A]],  [[<Plug>(EasyAlign)]], "Align selected")
            -- map("n", [[ga]], [[<Plug>(EasyAlign)]], "Align operator")
        end
    }
    use {
        'michaeljsmith/vim-indent-object',
        event = "BufAdd"
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
        requires = "nvim-treesitter",
        keys     = {{"n", "gcd"}},
        config   = function()
            require("neogen").setup {
                enabled             = true,
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
                    c = {
                        template = {
                            annotation_convention = "doxygen"
                        }
                    },
                    csharp = {
                        template = {
                            annotation_convention = "xmldoc"
                        }
                    },
                    rust = {
                        template = {
                            annotation_convention = "rustdoc"
                        }
                    },
                    typescript = {
                        template = {
                            annotation_convention = "jsdoc"
                        }
                    },
                    typescriptreact = {
                        template = {
                            annotation_convention = "jsdoc"
                        }
                    },
                }
            }

            map("n", [[gcd]], [[<CMD>lua require("neogen").generate()<CR>]], {"silent"}, "Document generation")
        end,
    }
    use {
        'AndrewRadev/splitjoin.vim',
        keys   = {
            {"n", "gS"},
            {"n", "gJ"}
        },
        setup = function()
            vim.g.splitjoin_align = 1
            vim.g.splitjoin_curly_brace_padding = 0
        end,
        config = function()
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
        event  = "BufAdd",
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
    -- BUG:
    use {
        'windwp/nvim-autopairs',
        disable = true,
        require = "nvim-treesitter",
        config  = function()
            require('nvim-autopairs').setup {
                disable_filetype        = {"TelescopePrompt", "dap-repl"},
                disable_in_macro        = true,
                disable_in_visualblock  = false,
                disable_in_replace_mode = true,
                ignored_next_char         = [=[[%w%%%'%[%"%.%`%$]]=],
                enable_moverighR          = true,
                enable_afterquote         = true,   -- add bracket pairs after quote
                enable_check_bracket_line = true,  -- check bracket in same line
                enable_bracket_in_quote   = true,
                enable_abbr               = true, -- trigger abbreviation
                break_undo = true, -- switch for basic rule break undo sequence
                check_ts   = false,
                map_cr  = true,
                map_bs  = true,
                map_c_h = false,
                map_c_w = false,
                fast_wrap = {
                    map            = '<M-e>',
                    chars          = {'{', '[', '(', '"', "'"},
                    pattern        = [=[[%'%"%>%]%)%}%,]]=],
                    end_key        = '$',
                    keys           = 'qwertyuiopzxcvbnmasdfghjkl',
                    check_comma    = true,
                    highlight      = 'Search',
                    highlight_grey = 'Comment'
                },
            }
        end
    }
    use {
        'preservim/nerdcommenter',
        event = "BufAdd",
        keys  = {
            {"x", [[<A-/>]]},
            {"n", [[<A-/>]]},
            {"n", [[gco]]},
            {"n", [[gcO]]},

            {"n", [[gcc]]},
            {"x", [[C]]},

            {"n", [[gcc]]},
            {"x", [[gcc]]},
            {"n", [[gcn]]},
            {"x", [[gcn]]},

            {"n", [[gci]]},
            {"x", [[gci]]},

            {"n", [[gcs]]},
            {"x", [[gcs]]},

            {"n", [[gcy]]},
            {"x", [[gcy]]},

            {"n", [[gc$]]},
            {"n", [[gcA]]},
            {"n", [[gcI]]},

            {"x", [[<A-/>]]},
            {"n", [[<A-/>]]},

            {"n", [[gcn]]},
            {"x", [[gcn]]},
            {"n", [[gcb]]},
            {"x", [[gcb]]},

            {"n", [[gcu]]},
            {"x", [[gcu]]},
        },
        setup  = [[vim.api.nvim_set_var("NERDCreateDefaultMappings", 0)]],
        config = conf("vim-nerdcommenter").config,
    }
    use {
        'lukas-reineke/indent-blankline.nvim',
        require = "nvim-treesitter",
        event   = "BufAdd",
        config  = function()
            require("indent_blankline").setup{
                use_treesitter = true,
                char             = "▏",
                char_blankline   = "▏",
                context_char     = "▏",
                buftype_exclude  = {"terminal"},
                filetype_exclude = {"help", "startify", "NvimTree", "Trouble", "packer"},
                bufname_exclude  = {"*.md"},
                char_highlight_list = {"SignColumn"},
                show_current_context           = true,
                show_trailing_blankline_indent = false,
                -- TODO:
                -- show_foldtext                  = true,
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
    use {
        'folke/which-key.nvim',
        cmd    = "WhichKey",
        config = conf "nvim-which-key"
    }
    -- }}} Vim enhancement
    -- Telescope {{{
    use {
        'nvim-telescope/telescope.nvim',
        module_pattern = "telescope.*",
        cmd      = "Telescope",
        keys     = {
            {"n", [[<C-f>l]]},  {"n", [[<C-f>E]]},  {"n", [[<C-f>e]]},    {"n", [[<C-f>f]]},
            {"n", [[<C-f>F]]},  {"n", [[<C-f>w]]},  {"n", [[<C-f>W]]},    {"n", [[<A-C-j>]]},
            {"n", [[<A-C-k>]]}, {"n", [[<C-h>/]]},  {"n", [[<C-h>v]]},    {"n", [[<C-h>o]]},
            {"n", [[<C-h>i]]},  {"n", [[<C-h>q]]},  {"n", [[<C-h>m]]},    {"n", [[<C-h>k]]},
            {"n", [[<C-h>c]]},  {"n", [[<C-h>h]]},  {"n", [[<C-h>H]]},    {"n", [[<C-h>l]]},
            {"n", [[<C-f>gc]]}, {"n", [[<C-f>gC]]}, {"n", [[<C-f>gs]]},   {"n", [[<leader>b]]},

            {"n", [[<C-f>o]]},  {"n", [[<C-f>O]]},  {"n", [[<leader>e]]}, {"n", [[<leader>E]]},
        },
        requires = {
            "plenary.nvim",
        },
        config = conf "nvim-telescope"
    }
    use {
        'nvim-telescope/telescope-symbols.nvim',
        module   = "telescope",
        requires = "telescope.nvim"
    }
    -- }}} Telescope
    -- UI {{{
    use {
        'kyazdani42/nvim-web-devicons',
        config = conf "nvim-web-devicons"
    }
    use {
        disable = true,
        'yamatsum/nvim-nonicons',
        requires = "nvim-web-devicons",
        config = [[require("nvim-nonicons").setup()]]
    }
    use {
        'joshdick/onedark.vim',
        disable = true
    }
    use {
        -- TODO: use the main brach
        'NTBBloodbath/galaxyline.nvim',
        event    = "BufAdd",
        requires = "nvim-web-devicons",
        config   = conf "nvim-galaxyline"
    }

    use {
        'akinsho/bufferline.nvim',
        event    = "BufAdd",
        requires = "nvim-web-devicons",
        config   = conf "nvim-bufferline".config
    }
    use {
        'NvChad/nvim-colorizer.lua',
        event = "BufAdd",
        config = function() -- {{{
            require("colorizer").setup {
                filetypes = { "*" },
                user_default_options = {
                    RGB      = true,  -- #RGB hex codes
                    RRGGBB   = true,  -- #RRGGBB hex codes
                    names    = true,  -- "Name" codes like Blue or blue
                    RRGGBBAA = true,  -- #RRGGBBAA hex codes
                    AARRGGBB = true,  -- 0xAARRGGBB hex codes
                    rgb_fn   = true,  -- CSS rgb() and rgba() functions
                    hsl_fn   = true,  -- CSS hsl() and hsla() functions
                    css      = true,  -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                    css_fn   = true,  -- Enable all CSS *functions*: rgb_fn, hsl_fn
                    -- Available modes for `mode`: foreground, background,  virtualtext
                    mode = "background", -- Set the display mode.
                    -- Available methods are false / true / "normal" / "lsp" / "both"
                    -- True is same as normal
                    tailwind = false, -- Enable tailwind colors
                    -- parsers can contain values used in |user_default_options|
                    sass = {enable = true, parsers = {"css"},}, -- Enable sass colors
                    virtualtext = "■",
                },
                -- all the sub-options of filetypes apply to buftypes
                buftypes = {},
            }
        end -- }}}
    }
    use {
        'folke/todo-comments.nvim',
        event    = "BufAdd",
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
        'stevearc/dressing.nvim',
        event = "BufAdd",
        config = conf "nvim-dressing"
    }
    -- }}} UI
    -- Intellisense {{{
    use {
        'williamboman/mason.nvim',
        config = function()
            require("mason").setup {
                ui = {
                    border = "rounded",
                    keymaps = {
                        toggle_package_expand   = "<CR>",
                        install_package         = "i",
                        update_package          = "u",
                        update_all_packages     = "U",
                        check_package_version   = "c",
                        check_outdated_packages = "C",
                        uninstall_package       = "d",
                        cancel_installation     = "<C-c>",
                        apply_language_filter   = "f",
                    }
                }
            }
            vim.cmd[[
            command! -nargs=0 MasonInstalled lua Print(require("mason-registry").get_installed_package_names())
            command! -nargs=0 MasonAvailable lua Print(require("mason-registry").get_all_package_names())
            ]]
        end
    }
    use {
        'williamboman/mason-lspconfig.nvim',
        requires = {
            "mason.nvim",
        },
        config = conf("nvim-mason-lspconfig").config
    }
    use {
        'neovim/nvim-lspconfig',
        event  = "BufAdd",
        requires = {
            "plenary.nvim",
            {
                "hrsh7th/cmp-nvim-lsp",
                event  = "BufAdd",
            }
        },
    }
    use {
        'folke/neodev.nvim',
        ft     = "lua",
        config = [[ require("neodev").setup(); require("config.nvim-lspconfig")() ]]
    }
    use 'rafamadriz/friendly-snippets'
    use {
        "L3MON4D3/LuaSnip",
        run      = "make install_jsregexp",
        config = function ()
            local sep = jit.os == "Windows" and "\\" or "/"
            local mySnippets = vim.fn.stdpath("config") .. sep .. "snippets"
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load{paths = {mySnippets}}
        end
    }
    use {
        'hrsh7th/nvim-cmp',
        requires = "LuaSnip",
        config = conf "nvim-cmp"
    }
    use {
        'hrsh7th/cmp-nvim-lsp',
        requires = "nvim-cmp"
    }
    use {
        "tzachar/cmp-tabnine",
        event = "InsertEnter",
        requires = "nvim-cmp",
        run = function()
            if jit.os == "Windows" then
                vim.cmd "!powershell ./install.ps1'"
            elseif jit.os == "linux" then
                vim.cmd "!./install.sh"
            end
        end,
    }
    use {
        "saadparwaiz1/cmp_luasnip",
        event = "InsertEnter",
        requires = "nvim-cmp",
        run = function()
            if jit.os == "Windows" then
                vim.cmd "!powershell ./install.ps1'"
            elseif jit.os == "linux" then
                vim.cmd "!./install.sh"
            end
        end,
    }
    use {
        "hrsh7th/cmp-buffer",
        event = "InsertEnter",
        requires = "nvim-cmp",
    }
    use {
        "hrsh7th/cmp-path",
        event = "InsertEnter",
        requires = "nvim-cmp",
    }
    use {
        "hrsh7th/cmp-cmdline",
        event = "InsertEnter",
        requires = "nvim-cmp",
    }
    use {
        'folke/trouble.nvim',
        rquires = "nvim-lspconfig",
        cmd     = "Trouble",
        config  = function()
            require("trouble").setup {
                position    = "bottom",  -- position of the list can be: bottom, top, left, right
                height      = 15,        -- height of the trouble list when position is top or bottom
                width       = 50,        -- width of the list when position is left or right
                icons       = true,      -- use devicons for filenames
                mode        = "workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
                fold_open   = "",  -- icon used for open folds
                fold_closed = "",  -- icon used for closed folds
                group = true,       -- group results by file
                padding = false,    -- add an extra new line on top of the list
                action_keys = {
                    -- key mappings for actions in the trouble list
                    -- map to {} to remove a mapping, for example:
                    -- close = {},
                    close          = "q",                 -- close the list
                    cancel         = {"<esc>", "<C-o>"},  -- cancel the preview and get back to your last window / buffer / cursor
                    refresh        = "r",                 -- manually refresh
                    jump           = {"<CR>", "o"},       -- jump to the diagnostic or open / close folds
                    open_split     = "<C-s>",             -- open buffer in new split
                    open_vsplit    = "<C-v>",             -- open buffer in new vsplit
                    open_tab       = "<C-t>",             -- open buffer in new tab
                    jump_close     = "O",                 -- jump to the diagnostic and close the list
                    toggle_mode    = "<Tab>",             -- toggle between "workspace" and "document" diagnostics mode
                    toggle_preview = "P",                 -- toggle auto_preview
                    hover          = "K",                 -- opens a small popup with the full multiline message
                    preview        = "p",                 -- preview the diagnostic location

                    close_folds    = {"zM", "zm"},        -- close all folds
                    open_folds     = {"zR", "zr"},        -- open all folds
                    toggle_fold    = "<Leader><Space>",   -- toggle fold of current file

                    previous       = "k",                 -- preview item
                    next           = "j"                  -- next item
                },

                indent_lines = true, -- add an indent guide below the fold icons
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
                use_lsp_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
            }
        end
    }
    use {
        'ray-x/lsp_signature.nvim',
        event  = "InsertEnter",
        config = function()
            require("lsp_signature").setup{
                hint_enable    = false,
                always_trigger = true,
                doc_lines      = 12
            }
        end
    }
    use {
        'RRethy/vim-illuminate',
        event = "BufAdd",
        config = function()
            require("illuminate").configure{
                providers = {
                    "lsp",
                    "treesitter",
                },
                filetypes_denylist = {
                    "fugitive",
                    "dap"
                },
                min_count_to_highlight = 2
            }
        end
    }
    use {
        'ThePrimeagen/refactoring.nvim',
        event    = "BufAdd",
        requires = {
            "plenary.nvim",
            "nvim-treesitter"
        },
        keys = {
            {"x", "<Leader>rf"},
            {"n", "<Leader>rp"},
            {"n", "<Leader>rv"},
            {"n", "<Leader>rc"}
        },
        config = function()
            require("refactoring").setup{}

            map("x", [[<Leader>rf]], [[<CMD>lua require("refactoring").select_refactor()<CR>]],              {"silent"}, "Extract selected")
            map("n", [[<Leader>rv]], [[<CMD>lua require("refactoring").debug.print_var{normal = true}<CR>]], {"silent"}, "Debug print vairiable under cursor")
            map("n", [[<Leader>rp]], [[<CMD>lua require("refactoring").debug.printf{below = false}<CR>]],    {"silent"}, "Debug printf")
            map("n", [[<Leader>rc]], [[<CMD>lua require("refactoring").debug.cleanup()<CR>]],                {"silent"}, "Debug clean up")
        end
    }
    -- }}} Intellisense
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
    -- use 'lewis6991/impatient.nvim'
    use {
        'iaso2h/vim-scriptease',
        branch = 'ftplugin',
        ft     = 'vim',
        cmd    = {
            "PP", "Runtime", "Disarm", "Scriptnames", "Messages",
            "Verbose", "Time", "Breakadd", "Vopen", "Vedit", "Vsplit"
        },
        keys   = {{"n", "<C-q>,"}, {"n", "<C-q>."}},
        config = conf("vim-scriptease").config
    }
    -- use {
        -- 'mfussenegger/nvim-dap',
            -- disable = true,
        -- module = "dap",
        -- setup  = conf("nvim-dap").setup,
        -- config = conf("nvim-dap").config
    -- }
    use {
        'rcarriga/nvim-dap-ui',
            disable = true,
        after  = "nvim-dap",
        config = conf "nvim-dap-ui"
    }
    use {
        -- TODO: hlGroup
        'theHamsta/nvim-dap-virtual-text',
        disable = true,
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
        run    = 'vim.fn["mkdp#util#install"]()',
        -- cmd    = {"MarkdownPreview", "MarkdownPreviewStop"},
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
        'rhysd/conflict-marker.vim',
        disable = ex("lazygit"),
        setup = [[vim.g.conflict_marker_enable_mappings = 0; vim.g.conflict_marker_enable_highlight = 1]],
        config = function ()
            map("x", "]x", [[<Plug>(conflict-marker-next-hunk)]])
            map("x", "[x", [[<Plug>(conflict-marker-prev-hunk)]])
        end
        -- disable = true,
        -- keys    = "}x, ]x, ct, co, cn, cb",
    }
    use {
        'sindrets/diffview.nvim',
        config = conf "nvim-diffview",
        cmd = "DiffviewOpen"
    }
    -- }}} Source control
    -- Knowlege {{{
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
