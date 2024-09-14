-- Bootstrap lazy.nvim {{{
local function promptOnMove(msg, func)
    local waitAu = vim.api.nvim_create_autocmd(
        { "CursorMoved", "BufEnter" },
        { callback = function()
            vim.api.nvim_echo(
                { { os.date("%Y-%m-%d %H:%M") .. msg, "WarningMsg" } },
                false,
                {}
            )
        end }
    )
    if func then
        func()
        vim.api.nvim_del_autocmd(waitAu)
    end
end

local lazyPath = _G._plugin_root .. "/lazy.nvim"
if not vim.loop.fs_stat(lazyPath) then
    vim.o.cmdheight = 10
    if not require("util").ex("git") then
        vim.notify("Can't find git executable", vim.log.levels.WARN)
        vim.notify("Loading Plug-ins settings abort", vim.log.levels.WARN)
        return
    end
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazyPath,
    }
    promptOnMove(
        os.date("%Y-%m-%d %H:%M  ")
            .. "Cloning lazy.nvim complete. Please restart Neovim"
    )
    return
end

vim.opt.rtp:prepend(lazyPath)
-- }}} Bootstrap lazy.nvim

-- Plug-ins configuration
local icon = require("icon")
local pluginArgs = { -- {{{
    -- https://github.com/folke/lazy.nvim#-plugin-spec
    -- Dependencies {{{
    {
        "nvim-lua/plenary.nvim",
        priority = 100,
        commit = "4cd4c29"
    },
    "inkarkat/vim-visualrepeat",
    "tpope/vim-repeat",
    "nvim-neotest/nvim-nio",
    -- }}} Dependencies
    -- Treesitter {{{
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        priority = 100,
        build = function() vim.cmd([[TSUpdate]]) end,
        config = require("plugins.nvim-treesitter"),
    },
    {
        "nvim-treesitter/playground",
        -- TODO: deprecated in Neovim 0.10+
        commit = "934cb4c",
        dependencies = {"nvim-treesitter"},
        cmd    = {"TSPlaygroundToggle", "TSNodeUnderCursor" },
        keys   = {{"gH", mode = "n"}},
        config = function()
            require("nvim-treesitter.configs").setup {
                playground = {
                    enable          = true,
                    disable         = {},
                    updatetime      = 25,    -- Debounced time for highlighting nodes in the playground from source code
                    persist_queries = false, -- Whether the query persists across vim sessions
                    keybindings     = {
                        toggle_query_editor       = "o",
                        toggle_hl_groups          = "i",
                        toggle_injected_languages = "t",
                        toggle_anonymous_nodes    = "a",
                        toggle_language_display   = "I",
                        focus_language            = "f",
                        unfocus_language          = "F",
                        update                    = "R",
                        goto_node                 = "<CR>",
                        show_help                 = "?",
                    },
                }
            }
            map(
                "n",
                [[gH]],
                [[<CMD>TSHighlightCapturesUnderCursor<CR>]],
                { "silent" },
                "Show Tree sitter highlight group"
            )
        end,
    },
    {
        "romgrk/nvim-treesitter-context",
        dependencies = {"nvim-treesitter"},
        event  = {"BufAdd"},
        config = function() require("treesitter-context").setup() end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = {
            "nvim-treesitter",
            "gitsigns.nvim"
        },
        config = require("plugins.nvim-treesitter-textobjects"),
    },
    {
        "Wansmer/sibling-swap.nvim",
        keys = {
            {[[<A-l>]],   mode = "n"},
            {[[<A-h>]],   mode = "n"},
            {[[<A-S-l>]], mode = "n"},
            {[[<A-S-h>]], mode = "n"},
        },
        dependencies = { "nvim-treesitter" },
        config = require("plugins.nvim-sibling-swap"),
    },
    {
        "ckolkey/ts-node-action",
        keys = { { [[<leader>s]], mode = "n" } },
        dependencies = { "nvim-treesitter" },
        config = function()
            map("n", [[<leader>s]], require("ts-node-action").node_action, "Trigger node action" )
        end
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter" },
        event = "InsertEnter",
        ft = {
            "html",
            "javascript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
            "vue",
        },
        config = function()
            require("nvim-treesitter.configs").setup {
                autotag = { enable = true },
            }
        end,
    },
    -- }}} Treesitter
    -- Vim enhancement {{{
    {
        "lambdalisue/suda.vim",
        conda = not (_G._os_uname.sysname == "Windows_NT"),
        cmd = {
            "SudaRead",
            "SudaWrite",
        }
    },
    {
        "skywind3000/asyncrun.vim",
        cmd  = { "AsyncRun", "AsyncStop" },
        init = function()
            map("n", [[<F9>]],  [[<CMD>lua require("compileRun").compileCode(true)<CR>]], {"silent"}, "Compile code")
            map("n", [[<F10>]], [[<CMD>lua require("compileRun").runCode()<CR>]],         {"silent"}, "Run code")
        end,
        config = require("plugins.vim-asyncrun"),
    },
    {
        "inkarkat/vim-EnhancedJumps",
        enabled = false,
        lazy = true,
        dependencies = { "inkarkat/vim-ingo-library" },
        init = function() vim.g.EnhancedJumps_no_mappings = 1 end,
    },
    {
        "inkarkat/vim-AdvancedSorters",
        cmd = {
            "ReorderByHeader",
            "ReorderByMatchAndLines",
            "ReorderByMatchAndNonMatches",
            "ReorderByRangeAndLines",
            "ReorderByRangeAndNonMatches",
            "ReorderFolded",
            "ReorderOnlyByMatch",
            "ReorderOnlyByRange",
            "ReorderUnfolded",
            "ReorderVisible",
            "SortByCharLength",
            "SortByExpr",
            "SortByExprUnique",
            "SortByWidth",
            "SortEach",
            "SortRangesByHeader",
            "SortRangesByMatch",
            "SortRangesByRange",
            "SortVisible",
            "SortWORDs",
            "UniqAny",
            "UniqSubsequent",
        },
        dependencies = { "inkarkat/vim-ingo-library" },
    },
    {
        "inkarkat/vim-Concealer",
        dependencies = { "inkarkat/vim-ingo-library" },
        keys = {
            { [[<leader>xx]], mode = "n" },
            { [[<leader>xx]], mode = "x" },
            { [[<leader>xa]], mode = "n" },
            { [[<leader>xa]], mode = "x" },
            { [[<leader>xd]], mode = "n" },
            { [[<leader>xd]], mode = "x" },
        },
        config = function()
            map("n", [[<leader>xx]], [[<Plug>(ConcealerToggleLocal)]], "Conceal current word locally")
            map("x", [[<leader>xx]], [[<Plug>(ConcealerToggleLocal)]], "Reveal selected word locally")
            map("n", [[<leader>xa]], [[<Plug>(ConcealerAddGlobal)]],   "Conceal current word globally")
            map("x", [[<leader>xa]], [[<Plug>(ConcealerAddGlobal)]],   "Conceal selected words globally")
            map("n", [[<leader>xd]], [[<Plug>(ConcealerRemGlobal)]],   "Reveal current word globally")
            map("x", [[<leader>xd]], [[<Plug>(ConcealerRemGlobal)]],   "Reveal selected words globally")
        end
    },
    {
        "bkad/camelcasemotion",
        event = {"BufAdd"},
        init  = function() vim.g.camelcasemotion_key = "," end
    },
    {
        "smoka7/hop.nvim",
        keys = {
            { [[<leader>f]], mode = "n" },
            { [[<leader>f]], mode = "x" },
            { [[<leader>F]], mode = "n" },
            { [[<leader>F]], mode = "x" },
        },
        config = function()
            local create_hl_autocmd = false
            -- Overwrite the original insert_highlights function
            require('hop.highlight').insert_highlights = function() -- {{{
                -- Highlight used for the mono-sequence keys (i.e. sequence of 1).
                vim.api.nvim_set_hl(0, 'HopNextKey', { fg = '#ff007c', bold = true, ctermfg = 198, cterm = { bold = true } , default = not create_hl_autocmd})

                -- Highlight used for the first key in a sequence.
                vim.api.nvim_set_hl(0, 'HopNextKey1', { fg = '#00dfff', bold = true, ctermfg = 45, cterm = { bold = true } , default = not create_hl_autocmd})

                -- Highlight used for the second and remaining keys in a sequence.
                vim.api.nvim_set_hl(0, 'HopNextKey2', { fg = '#2b8db3', ctermfg = 33, default = not create_hl_autocmd })

                -- Highlight used for the unmatched part of the buffer.
                vim.api.nvim_set_hl(0, 'HopUnmatched', { fg = '#666666', sp = '#666666', ctermfg = 242, default = not create_hl_autocmd })

                -- Highlight used for the fake cursor visible when hopping.
                vim.api.nvim_set_hl(0, 'HopCursor', { link = 'Cursor', default = not create_hl_autocmd })

                -- Highlight used for preview pattern
                vim.api.nvim_set_hl(0, 'HopPreview', { link = 'IncSearch', default = not create_hl_autocmd })
            end -- }}}

            require("hop").setup {
                case_insensitive = false,
                create_hl_autocmd = create_hl_autocmd
            }
            map("", [[<leader>f]], require("hop").hint_char1, "Hop char")
            map("", [[<leader>F]], require("hop").hint_nodes, "Hop char")
        end
    },
    -- TODO: skip asking for input when performing a dot-repeat
    {
        "kylechui/nvim-surround",
        keys = {
            {"gs",  mode = "n"},
            {"gss", mode = "n"},
            {"S",   mode = "x"},
            {"cs",  mode = "n"},
            {"ds",  mode = "n"},
        },
        config = require("plugins.nvim-surround"),
    },
    {
        "junegunn/vim-easy-align",
        keys = {
            { "A", mode = "x" },
            -- {"ga", mode = "n"},
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
            map("x", [[A]], [[<Plug>(EasyAlign)]], "Align selected")
            -- map("n", [[ga]], [[<Plug>(EasyAlign)]], "Align operator")
        end,
    },
    {
        "danymat/neogen",
        dependencies = { "nvim-treesitter" },
        keys = {{"gcd", mode = "n"}},
        cmd  = {"Neogen"},
        config = require("plugins.nvim-neogen")
    },
    {
        "airblade/vim-rooter",
        event = {"BufAdd"},
        init  = function()
            vim.g.rooter_cd_cmd        = "cd"
            vim.g.rooter_silent_chdir  = 1
            vim.g.rooter_resolve_links = 1
            vim.g.rooter_change_directory_for_non_project_files = "current"
            vim.g.rooter_patterns = {
                ".git",
                ".hg",
                "*.lsn",
                ".svn",
                "package.json",
                "makefile",
                ".vscode",
            }
        end,
    },
    {
        "numToStr/Comment.nvim",
        keys = {
            {[[gc]],  mode = "n"},
            {[[gcc]], mode = "n"},
            {[[C]],   mode = "x"},

            {[[gcy]], mode = "n"},
            {[[gcy]], mode = "x"},

            {[[gco]], mode = "n"},
            {[[gcO]], mode = "n"},
            {[[gcA]], mode = "n"},

            {[[gci]], mode = "n"},
            {[[gci]], mode = "x"},
        },
        config = require("plugins.nvim-comment"),
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        dependencies = { "nvim-treesitter" },
        event = { "BufAdd" },
        -- TODO: support dapui_watches filetype
        config = function()
            local ftExclude = vim.deepcopy(_G._short_line_list)
            ftExclude[#ftExclude + 1] = "help"
            ftExclude[#ftExclude + 1] = ""

            require("ibl").overwrite {
                indent = {
                    char = require("icon").ui.LineLeft,
                    tab_char = ""
                },
                exclude = {
                    buftypes  = {"terminal", "prompt"},
                    filetypes = ftExclude,
                },
                scope = {
                    show_start = true,
                    show_end = true,
                }
            }
        end,
    },
    {
        "andymass/vim-matchup",
        init   = require("plugins.vim-matchup").setup,
        config = require("plugins.vim-matchup").config,
    },
    {
        "utilyre/sentiment.nvim",
        event  = {"BufAdd"},
        config = function()
            -- local excludedFiletypes = _G._short_line_list
            require("sentiment").setup {
                excluded_filetypes = _G._short_line_list,
                delay = 250,
            }
        end
    },
    {
        "szw/vim-maximizer",
        cmd  = "MaximizerToggle",
        init = function()
            vim.g.maximizer_set_default_mapping   = 0
            vim.g.maximizer_set_mapping_with_bang = 0
            vim.g.maximizer_restore_on_winleave   = 1
            map("n", [[<C-w>m]], [[<CMD>MaximizerToggle<CR>]],           {"silent"},            "Maximize window")
            map("t", [[<C-w>m]], [[<C-\><C-o><CMD>MaximizerToggle<CR>]], {"noremap", "silent"}, "Maximize window")
            map("i", [[<C-w>m]], [[<C-\><C-o><CMD>MaximizerToggle<CR>]], {"noremap", "silent"}, "Maximize window")
        end
    },
    {
        "folke/which-key.nvim",
        cmd    = "WhichKey",
        config = require("plugins.nvim-which-key")
    },
    {
        "shortcuts/no-neck-pain.nvim",
        keys   = { { [[<leader>z]],  mode = "n" } },
        config = require("plugins.nvim-no-neck-pain")
    },
    {
        "chrisbra/unicode.vim",
        cmd = {
            "UnicodeSearch",
            "UnicodeName",
            "UnicodeCache",
            "UnicodeTable",
            "Digraphs",
            "DownloadUnicode",
        },
    },
    -- }}} Vim enhancement
    -- Telescope {{{
    {
        "nvim-telescope/telescope.nvim",
        lazy = true,
        cmd = "Telescope",
        keys = {
            { [[<C-f>a]],  mode = "n" },
            { [[<C-f>e]],  mode = "n" },
            { [[<C-f>E]],  mode = "n" },
            { [[<C-f>f]],  mode = "n" },
            { [[<C-f>F]],  mode = "n" },
            { [[<C-f>w]],  mode = "n" },
            { [[<C-f>W]],  mode = "n" },
            { [[<C-f>/]],  mode = "n" },
            { [[<C-f>?]],  mode = "n" },
            { [[<C-f>c]],  mode = "n" },
            { [[<C-f>:]],  mode = "n" },
            { [[<C-f>v]],  mode = "n" },
            { [[<C-f>j]],  mode = "n" },
            { [[<C-f>m]],  mode = "n" },
            { [[<C-f>k]],  mode = "n" },
            { [[<C-f>h]],  mode = "n" },
            { [[<C-f>H]],  mode = "n" },
            { [[<C-f>r]],  mode = "n" },
            { [[<C-f>gc]], mode = "n" },
            { [[<C-f>gC]], mode = "n" },
            { [[<C-f>gs]], mode = "n" },
            { [[<C-f>b]],  mode = "n" },
            { [[<C-f>d]],  mode = "n" },
            { [[<C-f>D]],  mode = "n" },
        },
        config = require("plugins.nvim-telescope")
    },
    {
        "nvim-telescope/telescope-symbols.nvim",
        dependencies = { "telescope.nvim" },
        lazy = true,
    },
    {
        "2KAbhishek/nerdy.nvim",
        cmd = "Nerdy",
        dependencies = {
            "dressing.nvim",
            "telescope.nvim"
        },
    },
    {
        "debugloop/telescope-undo.nvim",
        dependencies = { "telescope.nvim" },
        keys   = {[[<C-f>u]], mode = "n"},
        config = function ()
            require("telescope").load_extension("undo")
            map(
                "n",
                [[<C-f>u]],
                [[<CMD>lua require("telescope").extensions.undo.undo()<CR>]],
                { "silent" },
                "Undo history"
            )
        end,
    },
    {
        "prochri/telescope-all-recent.nvim",
        cond = not (_G._os_uname.sysname == "Windows_NT"),
        dependencies = { "telescope.nvim", "kkharji/sqlite.lua" },
        config = function() require("telescope-all-recent").setup {} end,
    },
    {
        "LinArcX/telescope-env.nvim",
        dependencies = { "telescope.nvim" },
        config = function() require("telescope").load_extension("env") end,
    },
    {
        "LinArcX/telescope-changes.nvim",
        dependencies = { "telescope.nvim" },
        keys = { [[<C-f>J]], mode = "n" },
        config = function()
            require("telescope").load_extension("changes")
            map(
                "n",
                [[<C-f>J]],
                [[<CMD>Telescope changes<CR>]],
                { "silent" },
                "Changes history"
            )
        end,
    },
    {
        "benshuailyu/online-thesaurus-vim",
        cmd = { "ThesaurusCurrent", "Thesaurus", },
        init = function() vim.g.use_default_key_map = 0 end,
        config = function()
            vim.api.nvim_create_user_command("ThesaurusCurrent",
                [[:call thesaurusPy2Vim#Thesaurus_LookCurrentWord()]], {})
            vim.api.nvim_create_user_command("Thesaurus",
                [[:call thesaurusPy2Vim#Thesaurus_LookWord(<q-args>)]],
                { nargs = 1 }
            )
        end,
    },
    -- }}} Telescope
    -- UI {{{
    {
        "kyazdani42/nvim-web-devicons",
        priority = 100,
        config = require("plugins.nvim-web-devicons"),
    },
    {
        "yamatsum/nvim-nonicons",
        dependencies = { "nvim-web-devicons" },
        cond   = not _G._is_term,
        config = function() require("nvim-nonicons").setup() end,
    },
    {
        "freddiehaddad/feline.nvim",
        dependencies = { "nvim-web-devicons" },
        config = require("plugins.nvim-feline")
    },
    {
        "willothy/nvim-cokeline",
        dependencies = { "nvim-web-devicons" },
        config = require("plugins.nvim-cokeline"),
    },
    {
        "NvChad/nvim-colorizer.lua",
        event = { "BufAdd" },
        config = require("plugins.nvim-colorizer"),
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-web-devicons" },
        event = { "BufAdd" },
        config = require("plugins.nvim-todo-comments"),
    },
    {
        "kyazdani42/nvim-tree.lua",
        dependencies = { "nvim-web-devicons" },
        keys = { { "<C-w>e", mode = "n" } },
        config = require("plugins.nvim-tree"),
    },
    {
        "stevearc/dressing.nvim",
        event = { "BufAdd" },
        config = require("plugins.nvim-dressing"),
    },
    -- }}} UI
    -- Intellisense {{{
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup {
                icons = {
                    package_installed   = icon.ui.Circle,
                    package_pending     = icon.ui.Target,
                    package_uninstalled = icon.kind.Event
                },
                ui = {
                    border = "rounded",
                    keymaps = {
                        toggle_package_expand   = "<CR>",
                        install_package         = "i",
                        update_package          = "u",
                        update_all_packages     = "U",
                        check_package_version   = "c",
                        check_outdated_packages = "C",
                        uninstall_package       = "x",
                        cancel_installation     = "<C-c>",
                        apply_language_filter   = "f",
                    }
                }
            }
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = require("plugins.nvim-mason-lspconfig").config,
    },
    {
        "jay-babu/mason-null-ls.nvim",
        cond  = true,
        event = {"BufAdd", "BufNewFile"},
        dependencies = {
            "davidmh/cspell.nvim",
            "nvimtools/none-ls.nvim",
            "mason.nvim",
            "davidmh/cspell.nvim",
        },
        config = require("plugins.nvim-null-ls"),
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-lspconfig.nvim",
            "folke/neodev.nvim",
        },
        config = require("plugins.nvim-lspconfig"),
    },
    {
        "p00f/clangd_extensions.nvim",
        dependencies = {"nvim-lspconfig"},
        config = require("plugins.nvim-clangd-extensions")
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        dependencies = { "nvim-lspconfig" },
        config = require("plugins.nvim-trouble"),
    },
    {
        "L3MON4D3/LuaSnip",
        pin = true,
        dependencies = { "rafamadriz/friendly-snippets", },
        build  = "make install_jsregexp",
        event  = {"BufAdd"},
        config = require("plugins.nvim-luasnip")
    },
    {
        "windwp/nvim-autopairs",
        dependencies = { "nvim-treesitter" },
        event  = {"BufAdd"},
        config = require("plugins.nvim-autopairs")
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "nvim-autopairs",
            "nvim-lspconfig",
            {
                "hrsh7th/cmp-nvim-lsp",
                dependencies = { "nvim-lspconfig" }
            },
            "hrsh7th/cmp-buffer",
            "FelipeLema/cmp-async-path",
            {
                "tzachar/cmp-tabnine",
                cond = _G._os_uname.machine ~= "aarch64",
                build = function()
                    if _G._os_uname.sysname == "Windows_NT" then
                        vim.cmd("!powershell ./install.ps1")
                    elseif _G._os_uname.sysname == "Linux" then
                        vim.cmd("!./install.sh")
                    end
                end,
            },
            {
                "saadparwaiz1/cmp_luasnip",
                build = function()
                    if _G._os_uname.sysname == "Windows_NT" then
                        vim.cmd("!powershell ./install.ps1")
                    elseif _G._os_uname.sysname == "Linux" then
                        vim.cmd("!./install.sh")
                    end
                end,
                dependencies = { "LuaSnip" },
            },
        },
        config = require("plugins.nvim-cmp"),
    },
    {
        "Exafunction/codeium.nvim",
        enabled = false,
        dependencies = {
            "plenary.nvim",
            "nvim-cmp"
        },
        config = function()
            require("codeium").setup {
                detect_proxy = true
            }
        end
    },
    {
        "ray-x/lsp_signature.nvim",
        dependencies = { "nvim-lspconfig" },
        config = require("plugins.nvim-lsp-signature"),
    },
    {
        "kosayoda/nvim-lightbulb",
        config = require("plugins.nvim-lightbulb")
    },
    {
        "aznhe21/actions-preview.nvim",
        keys = { { "<leader>a", mode = "n" } },
        -- BUG:
        enabled = false,
        config = function()
            map("n", "<leader>a", require("actions-preview").code_actions, "Lsp code action")

            require("actions-preview").setup {
                -- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
                diff = {
                    algorithm         = "histogram",
                    ignore_whitespace = true,
                    ctxlen            = 3,
                    filler            = true
                },
                -- priority list of preferred backend
                backend = { "telescope"},
                telescope = require("telescope.themes").get_dropdown(),
                highlight_command = {
                    require("actions-preview.highlight").delta("path/to/delta --option1 --option2"),
                }
            }
        end,
    },
    {
        "RRethy/vim-illuminate",
        config = function()
            require("illuminate").configure {
                providers = {
                    "lsp",
                    "treesitter",
                },
                filetypes_denylist = _G._short_line_list,
                filetype_overrides = {
                    autohotkey = {
                        providers = { "regex" }
                    }
                },
                min_count_to_highlight = 2,
            }
        end,
    },
    {
        "m-demare/hlargs.nvim",
        dependencies = {
            "nvim-lspconfig",
            "nvim-treesitter",
        },
        config = function()
            require("hlargs").setup {
                color = require("onenord.pallette").orange,
                highlight = {},
                excluded_filetypes = {},
                paint_arg_declarations = true,
                paint_arg_usages = true,
                paint_catch_blocks = {
                    declarations = false,
                    usages = false,
                },
                extras = {
                    named_parameters = false,
                },
                hl_priority = 10000,
                excluded_argnames = {
                    declarations = {},
                    usages = {
                        python = { "self", "cls" },
                        lua = { "self" },
                    },
                },
            }
        end,
    },
    {
        "simrat39/symbols-outline.nvim",
        cmd = {
            "SymbolsOutline",
            "SymbolsOutlineOpen",
            "SymbolsOutlineClose",
        },
        config = require("plugins.nvim-symbols-outline"),
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "plenary.nvim",
            "nvim-treesitter",
        },
        keys = {
            { "gf", mode = "x" },
            { "gfp", mode = "n" },
            { "gfv", mode = "n" },
            { "gfc", mode = "n" },
        },
        config = function()
            require("refactoring").setup{}
            map("x", [[gf]],  [[<CMD>lua require("refactoring").select_refactor()<CR>]],              {"silent"}, "Extract selected")
            map("n", [[gfp]], [[<CMD>lua require("refactoring").debug.print_var{normal = true}<CR>]], {"silent"}, "Debug print variable under cursor")
            map("n", [[gfv]], [[<CMD>lua require("refactoring").debug.printf{below = false}<CR>]],    {"silent"}, "Debug printf")
            map("n", [[gfc]], [[<CMD>lua require("refactoring").debug.cleanup()<CR>]],                {"silent"}, "Debug clean up")
        end,
    },
    -- }}} Intellisense
    -- Debug {{{
    {
        "Olical/conjure",
        cond = not (_G._os_uname.sysname == "Windows_NT"),
        dependencies = {
            {
                "PaterJason/cmp-conjure",
                dependencies = { "nvim-cmp" },
            },
        },
        init = require("plugins.nvim-conjure"),
    },
    {
        "bfredl/nvim-luadev",
        cond = true,
        ft = "lua",
        config = function()
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "\\[nvim-lua\\]",
                command = [[lua vim.opt_local.relativenumber = true]],
                once = true,
            })
        end,
    },
    {
        "andrewferrier/debugprint.nvim",
        keys = {
            { "dp", mode = "n" },
            { "dP", mode = "n" },
            { "dv", mode = "n" },
            { "dV", mode = "n" },
        },
        cmd = {
            "ToggleCommentDebugPrints",
            "DeleteDebugPrints",
        },
        config = function()
            require("debugprint").setup {
                create_keymaps = false,
            }
            -- TODO: prehook buffer-wise
            map("n", [[dp]], function()
                if vim.wo.diff then
                    vim.api.nvim_feedkeys("dp", "n", false)
                else
                    return require("debugprint").debugprint()
                end
                end, {"expr"}, "Debug print below")
            map("n", [[dP]], function() return require("debugprint").debugprint { above = true}
                end, {"expr"}, "Debug print above")
            map("n", [[dv]], function() return require("debugprint").debugprint { variable = true }
                end, {"expr"}, "Debug print value below")
            map("n", [[dV]], function() return require("debugprint").debugprint { variable = true, above = true}
                end, {"expr"}, "Debug print value above")
        end
    },
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        init = function() vim.g.startuptime_tries = 20 end,
    },
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>db", mode = "n" },
            { "<leader>dc", mode = "n" },
            { "<leader>dl", mode = "n" },
        },
        config = require("plugins.nvim-dap"),
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "nvim-dap",
            "nvim-nio"
        },
        config = require("plugins.nvim-dap-ui").config,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        lazy = true,
        dependencies = { "nvim-dap" },
        cmd = {
            "DapVirtualTextEnable",
            "DapVirtualTextDisable",
            "DapVirtualTextToggle",
            "DapVirtualTextForceRefresh",
        },
        config = function()
            require("nvim-dap-virtual-text").setup {
                enabled = true,
                enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,             -- prefix virtual text with comment string
                only_first_definition = true,  -- only show virtual text at first definition (if there are multiple)
                all_references = false,        -- show virtual text on all all references of the variable (not only definitions)
                -- experimental features:
                virt_text_pos = "eol",   -- position of virtual text, see `:h nvim_buf_set_extmark()`
                all_frames = false,      -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                virt_lines = false,      -- show virtual lines instead of virtual text (will flicker!)
                virt_text_win_col = nil  -- position the virtual text at a fixed window column (starting from the first text column) , e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
            }
            map("n", [[<leader>dh]], [[<CMD>DapVirtualTextToggle<CR>]],       {"silent"}, "Dap virtual text toggle")
            map("n", [[<leader>dH]], [[<CMD>DapVirtualTextForceRefresh<CR>]], {"silent"}, "Dap virtual text refresh")
        end
    },
    {
        "rcarriga/cmp-dap",
        dependencies = { "nvim-dap", "nvim-cmp" },
        config = function()
            require("cmp").setup.filetype(
                { "dap-repl", "dapui_watches", "dapui_hover" },
                {
                    sources = {
                        -- HACK: Not working for lua dapter yet?
                        { name = "dap" },
                    },
                }
            )
            vim.api.nvim_create_user_command(
                "DapCompletionSupport",
                function()
                    local text = require("dap").session().capabilities.supportsCompletionsRequest
                            and "true" or "false"

                    vim.api.nvim_echo({ { text, "MoreMsg" } }, false, {})
                end,
                { desc = "Check Dap completion support" }
            )
        end,
    },
    {
        "jbyuki/one-small-step-for-vimkind",
        ft = "lua",
        dependencies = { "nvim-dap" },
        init = function()
            vim.api.nvim_create_user_command(
                "OSVStop",
                function() require("osv").stop() end,
                { desc = "Stop Neovim OSV dapter" }
            )
            vim.api.nvim_create_user_command(
                "OSVStart",
                function()
                    require("osv").launch {
                        config_file = _G._config_path
                            .. _G._sep
                            .. "init.lua",
                        port = 8086,
                    }
                end,
                { desc = "Launch Neovim OSV dapter" }
            )
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/neotest-plenary",
            "nvim-neotest/neotest-python",
            "antoinemadec/FixCursorHold.nvim",
            "plenary.nvim",
            "nvim-nio",
            "nvim-treesitter",
        },
        cmd = {
            "NeotestRun",
            "NeotestStop",
            "NeotestAttach",
        },
        config = function()
            vim.api.nvim_create_user_command(
                "NeotestRun",
                function()
                    require("neotest").run.run { strategy = "integrated" }
                end,
                { desc = "Neotest run integrated" }
            )
            vim.api.nvim_create_user_command(
                "NeotestCurrent",
                function() require("neotest").run.run(vim.fn.expand("%")) end,
                { desc = "Neotest run current line" }
            )
            vim.api.nvim_create_user_command(
                "NeotestStop",
                function() require("neotest").run.stop() end,
                { desc = "Neotest stop" }
            )
            vim.api.nvim_create_user_command(
                "NeotestAttach",
                function() require("neotest").run.attach() end,
                { desc = "Neotest run attach" }
            )

            require("neotest").setup {
                adapters = {
                    require("neotest-python") {
                        dap = { justMyCode = false },
                    },
                    require("neotest-plenary"),
                },
            }
        end,
    },
    {
        "vim-test/vim-test",
        cmd = {
            "TestNearest",
            "TestFile",
            "TestSuite",
            "TestLast",
            "TestVisit",
        },
        init = function()
            vim.g["test#strategy"] = {
                nearest = "neovim",
                file    = "dispatch",
                suite   = "basic",
            }
        end,
    },
    {
        "michaelb/sniprun",
        cond  = _G._os_uname.sysname ~= "Windows_NT",
        build = "bash ./install.sh",
        cmd   = {
            "SnipRun",
            "SnipReset",
            "SnipReplMemoryClean",
            "SnipTerminate",
            "SnipInfo",
            "SnipClose",
        },
        config = require("plugins.nvim-sniprun"),
    },
    -- "CRAG666/code_runner.nvim"
    -- }}} Debug
    -- Language {{{
    {
        "mrjones2014/lua-gf.nvim",
        keys = { { [[gF]], mode = "n" } },
        config = function()
            map("n", [[gF]], [[<CMD>lua require("plugins.nvim-lua-gf")()<CR>]], {"silent"}, "Go to file")
        end
    },
    {
        "dzeban/vim-log-syntax",
        ft = "log",
    },
    {
        "HakonHarnes/img-clip.nvim",
        ft = {
            "log",
            "md",
            "tex",
            "typst",
            "rst",
            "asciidoc",
            "org",
        },
        cmd = { "PasteImage"}
    },
    -- Fennel {{{
    {
        "rktjmp/hotpot.nvim",
        config = require("plugins.nvim-hotpot"),
    },
    {
        "guns/vim-sexp",
        ft = _G._lisp_language,
        init = require("plugins.vim-sexp"),
    },
    {
        "gpanders/nvim-parinfer",
        ft = _G._lisp_language,
        init = function()
            vim.g.parinfer_enabled = false
            vim.g.parinfer_no_maps = true
            vim.g.parinfer_mode = "smart"
        end,
        config = function()
            vim.api.nvim_create_user_command(
                "ToggleParinfer",
                function()
                    if vim.b.parinfer_enabled == nil then
                        vim.b.parinfer_enabled = true
                    end
                    vim.b.parinfer_enabled = not vim.b.parinfer_enabled
                    vim.api.nvim_echo({
                        {
                            string.format(
                                "vim.b.parinfer_enabled: %s",
                                vim.b.parinfer_enabled
                            ),
                            "Moremsg",
                        },
                    }, false, {})
                end,
                { desc = "Parinfer toggle" }
            )
        end,
    },
    -- }}} Fennel
    -- }}} Language
    -- Source control {{{
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufAdd" },
        config = require("plugins.nvim-gitsigns"),
    },
    {
        "rhysd/conflict-marker.vim",
        cond   = not require("util").ex("lazygit"),
        init   = function() vim.g.conflict_marker_enable_mappings = 0; vim.g.conflict_marker_enable_highlight = 1 end,
        config = function()
            map("x", "]x", [[<Plug>(conflict-marker-next-hunk)]], "Next conflict marker")
            map("x", "[x", [[<Plug>(conflict-marker-prev-hunk)]], "Previous conflict marker")
        end
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        dependencies = { "plenary.nvim" },
        config = require("plugins.nvim-diffview"),
    },
    -- }}} Source control
    -- Knowledge {{{
    {
        "Bryley/neoai.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        cmd = {
            "NeoAI",
            "NeoAIOpen",
            "NeoAIClose",
            "NeoAIToggle",
            "NeoAIContext",
            "NeoAIContextOpen",
            "NeoAIContextClose",
            "NeoAIInject",
            "NeoAIInjectCode",
            "NeoAIInjectContext",
            "NeoAIInjectContextCode",
        },
        keys = {
            { "gas", desc = "summarize text" },
            { "gag", desc = "generate git message" },
        },
        config = require("plugins.nvim-neoai"),
    },
    {
        "RishabhRD/nvim-cheat.sh",
        cond = _G._os_uname.sysname ~= "Windows_NT",
        cmd = {
            "Cheat",
            "CheatList",
            "CheatListWithoutComments",
            "CheatWithoutComments",
        },
        dependencies = { "RishabhRD/popfix" },
    },
    {
        "dahu/VimRegexTutor",
        cmd = "VimRegexTutor",
    },
    {
        "DanilaMihailov/vim-tips-wiki",
    },
    {
        "vim-scripts/autolisp-help",
    },
    -- }}} Knowledge
} -- }}}

local trailingSpaces = " "
local lazyOpts = { -- {{{
    root = _G._plugin_root,
    git  = { log = {"-30"} },
    install = {colorscheme = {"onenord"}},
    ui   = {
        border = "rounded",
        icons = {
            cmd        = icon.ui.Terminal .. trailingSpaces,
            config     = icon.ui.Tweak .. trailingSpaces,
            event      = icon.kind.Event .. trailingSpaces,
            ft         = icon.ui.FindFile .. trailingSpaces,
            init       = icon.ui.Tweak .. trailingSpaces,
            import     = icon.kind.Reference .. trailingSpaces,
            keys       = " ",
            lazy       = icon.kind.Event .. trailingSpaces,
            loaded     = icon.ui.Circle .. trailingSpaces,
            not_loaded = icon.ui.CircleDotted .. trailingSpaces,
            plugin     = icon.ui.Package .. trailingSpaces,
            runtime    = icon.ui.Vim .. trailingSpaces,
            source     = icon.debug.RunLast .. trailingSpaces,
            start      = icon.debug.Play .. trailingSpaces,
            task       = icon.ui.BoxChecked .. trailingSpaces,
            list       = {
                icon.ui.Circle,
                icon.ui.BoldArrowRight,
                icon.ui.Dot,
                "‒",
            },
        },
    },
    concurrency = 5,
    performance = {
        cache = {
            enabled = false,
        },
        reset_packpath = true,
        rtp = { reset = true },
    },
} -- }}}

vim.api.nvim_create_user_command("CDPlugin", function()
    vim.cmd("cd " .. _G._plugin_root)
    vim.notify("Change directory to Lazy plug-ins path", vim.log.levels.INFO)
end, { desc = "Change directory to lazy plug-ins path" })

require("lazy").setup(pluginArgs, lazyOpts)
