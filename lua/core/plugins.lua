-- Bootstrap lazy.nvim {{{
local function promptOnMove(msg, func)
    local waitAu = vim.api.nvim_create_autocmd({"CursorMoved", "BufEnter"}, {
        callback = function ()
            vim.api.nvim_echo({{os.date("%Y-%m-%d %H:%M  ") .. msg, "WarningMsg"}}, false, {})
        end
    })
    if func then
        func()
        vim.api.nvim_del_autocmd(waitAu)
    end
end

local lazyPath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
    promptOnMove(os.date("%Y-%m-%d %H:%M  ") .. "Cloning lazy.nvim complete. Please restart Neovim")
    return
end
-- }}} Bootstrap lazy.nvim

-- Plug-ins configuration
local pluginArgs = { -- {{{
    -- https://github.com/folke/lazy.nvim#-plugin-spec
    -- Dependencies {{{
    "nvim-lua/plenary.nvim",
    "inkarkat/vim-visualrepeat",
    "tpope/vim-repeat",
    -- }}} Dependencies
    -- Treesitter {{{
    {
        "nvim-treesitter/nvim-treesitter",
        build = function() vim.cmd [[TSUpdate]] end,
        config = require("config.nvim-treesitter"),
    },
    {
        "nvim-treesitter/playground",
        commit = "934cb4c",
        dependencies = {"nvim-treesitter"},
        cmd    = "TSPlaygroundToggle",
        keys   = {{"gH", mode = "n"}},
        config = function()
            require "nvim-treesitter.configs".setup {
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
            map("n", [[gH]], [[<CMD>TSHighlightCapturesUnderCursor<CR>]], {"silent"}, "Show Tree sitter highlight group")
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
        config = require("config.nvim-treesitter-textobjects"),
    },
    {
        "Wansmer/sibling-swap.nvim",
        keys = {
            {[[<A-l>]],   mode = "n"},
            {[[<A-h>]],   mode = "n"},
            {[[<A-S-l>]], mode = "n"},
            {[[<A-S-h>]], mode = "n"},
        },
        dependencies = { "nvim-treesitter", },
        config = require("config.nvim-sibling-swap")
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter", },
        event  = "InsertEnter",
        ft     = {"html", "javascript", "javascriptreact", "typescriptreact", "svelte", "vue"},
        config = function() require("nvim-treesitter.configs").setup {autotag = {enable = true}} end,
    },
    -- }}} Treesitter
    -- Vim enhancement {{{
    {
        "tpope/vim-eunuch",
        cmd = {"Delete", "Unlink", "Remove", "Move", "Rename", "Chmod", "Mkdir", "Cfind", "Lfind", "Clocate", "Llocate", "SudoEdit", "SudoWrite", "Wall"}
    },
    {
        "skywind3000/asyncrun.vim",
        cmd    = {"AsyncRun", "AsyncStop"},
        config = require("config.vim-asyncrun")
    },
    {
        "inkarkat/vim-EnhancedJumps",
        dependencies = {"inkarkat/vim-ingo-library"},
        cond = true,
        init = function() vim.g.EnhancedJumps_no_mappings = 1 end,
    },
    {
        "inkarkat/vim-AdvancedSorters",
        dependencies = {"inkarkat/vim-ingo-library"},
    },
    {
        "inkarkat/vim-Concealer",
        dependencies = {"inkarkat/vim-ingo-library"},
    },
    {
        "bkad/camelcasemotion",
        event = {"BufAdd"},
        init  = function() vim.g.camelcasemotion_key = "," end
    },
    {
        "zatchheems/vim-camelsnek",
        keys = {
            {[[<A-c>]], mode = "x"},
            {[[<A-c>]], mode = "n"},
            {[[<A-S-c>]], mode = "n"},
        },
        init = function()
            vim.g.camelsnek_alternative_camel_commands = 1
            vim.g.camelsnek_no_fun_allowed             = 1
            vim.g.camelsnek_iskeyword_override         = 0
        end,
        config = function()
            map("n", [[<A-c>]],   [[<CMD>lua require("caseSwitcher").cycleCase()<CR>]],           "Cycle cases")
            map("n", [[<A-S-c>]], [[<CMD>lua require("caseSwitcher").cycleDefaultCMDList()<CR>]], "Cycle cases reset")
        end,
    },
    {
        "phaazon/hop.nvim",
        keys = {
            {[[<leader>f]], mode = "n"},
            {[[<leader>f]], mode = "x"},
            {[[<leader>F]], mode = "n"},
            {[[<leader>F]], mode = "x"},
        },
        init = function()
            map("", [[<leader>f]], [[:lua require("hop").hint_char1()<CR>]], "Hop char")
        end,
        config = function()
            require("hop").setup{
                case_insensitive = false
            }
        end
    },
    {
        "AndrewRadev/switch.vim",
        cmd  = {"Switch"},
        init = function()
            map("n", [[<leader>s]], [[<CMD>Switch<CR>]], {"silent"}, "Switch word under cursor")
            vim.g.switch_mapping = ""
        end,
        config = require("config.vim-switch")
    },
    {
        "kylechui/nvim-surround",
        keys = {
            {"gs",  mode = "n"},
            {"gss", mode = "n"},
            {"S",   mode = "x"},
            {"cs",  mode = "n"},
            {"ds",  mode = "n"},
        },
        config = require("config.nvim-surround")
    },
    {
        "junegunn/vim-easy-align",
        keys = {
            {"A", mode = "x"},
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
            map("x", [[A]],  [[<Plug>(EasyAlign)]], "Align selected")
            -- map("n", [[ga]], [[<Plug>(EasyAlign)]], "Align operator")
        end
    },
    {
        "danymat/neogen",
        dependencies = { "nvim-treesitter" },
        keys = {{"gcd", mode = "n"}},
        cmd  = {"Neogen"},
        config = function()
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
            map("n", [[gcd]], [[<CMD>lua vim.api.nvim_feedkeys(":Neogen <Tab>", "nt", true)<CR>]], "Document generation")
        end,
    },
    {
        "AndrewRadev/splitjoin.vim",
        keys = { {"gS", mode = "n"}, {"gJ", mode = "n"} },
        init = function()
            vim.g.splitjoin_align = 1
            vim.g.splitjoin_curly_brace_padding = 0
        end,
        -- TODO: split on lua ; syntax
        config = function()
            map("n", [["gS"]], [[<CMD>SplitjoinSplit<CR>]], {"silent"}, "Smart split")
            map("n", [["gJ"]], [[<CMD>SplitjoinJoin<CR>]],  {"silent"}, "Smart join")
        end
    },
    {
        "airblade/vim-rooter",
        event = {"BufAdd"},
        init  = function()
            vim.g.rooter_cd_cmd        = "lcd"
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
        config = require("config.nvim-comment")
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        dependencies = { "nvim-treesitter" },
        event  = {"BufAdd"},
        config = function()
            require("indent_blankline").setup{
                use_treesitter = true,
                char             = "▏",
                char_blankline   = "▏",
                context_char     = "▏",
                buftype_exclude  = {"terminal", "nofile"},
                filetype_exclude = require("config.nvim-galaxyline").shortLineList,
                bufname_exclude  = {"*.md"},
                char_highlight_list = {"SignColumn"},
                show_current_context           = true,
                show_trailing_blankline_indent = false,
            }
        end,
    },
    {
        "szw/vim-maximizer",
        cmd  = "MaximizerToggle",
        init = function()
            vim.g.maximizer_set_default_mapping   = 0
            vim.g.maximizer_set_mapping_with_bang = 1
            vim.g.maximizer_restore_on_winleave   = 1
            map("n", [[<C-w>m]], [[<CMD>MaximizerToggle<CR>]],      {"silent"}, "Maximize window")
            map("t", [[<C-w>m]], [[<C-\><C-o><CMD>MaximizerToggle<CR>]], {"silent"}, "Maximize window")
            map("i", [[<C-w>m]], [[<C-o><CMD>MaximizerToggle<CR>]], {"noremap", "silent"}, "Maximize window")
        end
    },
    {
        "folke/which-key.nvim",
        cmd    = "WhichKey",
        config = require("config.nvim-which-key")
    },
    -- }}} Vim enhancement
    -- Telescope {{{
    {
        "nvim-telescope/telescope.nvim",
        lazy = true,
        cmd  = "Telescope",
        keys = {
            {[[<C-f>a]],  mode = "n"}, {[[<C-f>e]],  mode = "n"}, {[[<C-f>E]], mode = "n"}, {[[<C-f>f]],  mode = "n"},
            {[[<C-f>F]],  mode = "n"}, {[[<C-f>w]],  mode = "n"}, {[[<C-f>W]], mode = "n"}, {[[<C-f>/]],  mode = "n"},
            {[[<C-f>?]],  mode = "n"}, {[[<C-f>v]],  mode = "n"}, {[[<C-f>j]], mode = "n"}, {[[<C-f>']],  mode = "n"},
            {[[<C-f>m]],  mode = "n"}, {[[<C-f>k]],  mode = "n"}, {[[<C-f>c]], mode = "n"}, {[[<C-f>C]],  mode = "n"},
            {[[<C-f>h]],  mode = "n"}, {[[<C-f>H]],  mode = "n"}, {[[<C-f>r]], mode = "n"}, {[[<C-f>gc]], mode = "n"},
            {[[<C-f>gC]], mode = "n"}, {[[<C-f>gs]], mode = "n"}, {[[<C-f>b]], mode = "n"}, {[[<C-f>d]],  mode = "n"},
            {[[<C-f>D]],  mode = "n"},
        },
        config = require("config.nvim-telescope")
    },
    {
        "nvim-telescope/telescope-symbols.nvim",
        dependencies = { "telescope.nvim" },
        lazy = true,
    },
    {
        "debugloop/telescope-undo.nvim",
        dependencies = { "telescope.nvim" },
        keys   = {[[<C-f>u]], mode = "n"},
        config = function ()
            require("telescope").load_extension("undo")
            map("n", [[<C-f>u]], [[<CMD>lua require("telescope").extensions.undo.undo()<CR>]], {"silent"}, "Undo")
        end,
    },
    -- }}} Telescope
    -- UI {{{
    {
        "kyazdani42/nvim-web-devicons",
        priority = 100,
        config = require("config.nvim-web-devicons")
    },
    {
        "yamatsum/nvim-nonicons",
        dependencies = { "nvim-web-devicons" },
        cond   = not _G._is_term,
        config = function() require("nvim-nonicons").setup() end,
    },
    {
        "glepnir/galaxyline.nvim",
        dependencies = { "nvim-web-devicons" },
        event  = {"BufAdd"},
        config = require("config.nvim-galaxyline").config,
    },
    {
        "iaso2h/nvim-cokeline",
        dependencies = { "nvim-web-devicons" },
        config = require("config.nvim-cokeline"),
    },
    {
        "NvChad/nvim-colorizer.lua",
        event  = {"BufAdd"},
        config = function()
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
        end
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-web-devicons" },
        event  = {"BufAdd"},
        config = require("config.nvim-todo-comments"),
    },
    {
        "kyazdani42/nvim-tree.lua",
        dependencies = { "nvim-web-devicons" },
        keys   = {{"<C-w>e", mode = "n"}},
        config = require("config.nvim-tree"),
    },
    {
        "stevearc/dressing.nvim",
        event  = {"BufAdd"},
        config = require("config.nvim-dressing")
    },
    -- }}} UI
    -- Intellisense {{{
    {
        "williamboman/mason.nvim",
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
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = require("config.nvim-mason-lspconfig").config,
    },
    {
        "jay-babu/mason-null-ls.nvim",
        cond  = true,
        event = {"BufAdd", "BufNewFile"},
        dependencies = {
            "jose-elias-alvarez/null-ls.nvim",
            "mason.nvim"
        },
        config = require("config.nvim-null-is"),
    },
    {
        "folke/neodev.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "plenary.nvim",
            "cmp-nvim-lsp"
        },
        config = function()
            require("neodev").setup{
                library = {
                    plugins = {
                        "nvim-dap-ui",
                        "plenary",
                        "nvim-treesitter",
                    },
                types = true },
            }
            require("config.nvim-lspconfig")()
        end,
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-lspconfig", },
        config = require("config.nvim-trouble"),
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets", },
        build  = "make install_jsregexp",
        event  = {"BufAdd"},
        config = function ()
            local mySnippets = _G._config_path .. _G._sep .. "snippets"
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load { paths = { mySnippets } }
        end,
    },
    {
        "windwp/nvim-autopairs",
        dependencies = { "nvim-treesitter" },
        event  = {"BufAdd"},
        config = function()
            require("nvim-autopairs").setup {
                disable_filetype        = vim.list_extend(
                    {"TelescopePrompt", "dap-repl"}, _G._lisp_language),
                disable_in_macro        = true,
                disable_in_visualblock  = false,
                disable_in_replace_mode = true,
                ignored_next_char         = [=[[%w%%%'%[%"%.%`%$]]=],
                enable_moveright          = true,
                enable_afterquote         = true,   -- add bracket pairs after quote
                enable_check_bracket_line = true,   -- check bracket in same line
                enable_bracket_in_quote   = false,
                enable_abbr               = false,  -- trigger abbreviation
                break_undo = true, -- switch for basic rule break undo sequence
                check_ts   = true,
                map_cr  = true,
                map_bs  = true,
                map_c_h = false,
                map_c_w = false,
                fast_wrap = {},
            }
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "nvim-autopairs",
            "nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "PaterJason/cmp-conjure",
            {
                "tzachar/cmp-tabnine",
                cond  = _G._os_uname.machine ~= "aarch64",
                build = function()
                    if _G._os_uname.sysname == "Windows_NT" then
                        vim.cmd "!powershell ./install.ps1"
                    elseif _G._os_uname.sysname == "linux" then
                        vim.cmd "!./install.sh"
                    end
                end,
            },
            {
                "saadparwaiz1/cmp_luasnip",
                build = function()
                    if _G._os_uname.sysname == "Windows_NT" then
                        vim.cmd "!powershell ./install.ps1"
                    elseif _G._os_uname.sysname == "linux" then
                        vim.cmd "!./install.sh"
                    end
                end,
                dependencies = { "LuaSnip" }
            },
        },
        config = require("config.nvim-cmp"),
    },
    {
        "Exafunction/codeium.vim",
        event  = "BufModifiedSet",
        init   = function() vim.g.codeium_disable_bindings = 1 end,
        config = function()
            map("i", "<C-f>", function() return vim.fn["codeium#Accept"]() end,             { expr = true }, "Codeium accept")
            map("i", "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true }, "Codeium previous")
            map("i", "<C-.>", function() return vim.fn["codeium#CycleCompletions"](1) end,  { expr = true }, "Codeium next")
            map("i", "<A-f>", function() return vim.fn["codeium#Clear"]() end,              { expr = true }, "Codeium clear")
        end
    },
    {
        "ray-x/lsp_signature.nvim",
        dependencies = { "nvim-lspconfig" },
        config = require("config.nvim-lsp-signature")
    },
    {
        "RRethy/vim-illuminate",
        event = {"BufAdd"},
        config = function()
            require("illuminate").configure{
                providers = {
                    "lsp",
                    "treesitter",
                },
                filetypes_denylist = require("config.nvim-galaxyline").shortLineList,
                min_count_to_highlight = 2
            }
        end
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "plenary.nvim",
            "nvim-treesitter"
        },
        keys = {
            {"gf",  mode = "x"},
            {"gfp", mode = "n"},
            {"gfv", mode = "n"},
            {"gfc", mode = "n"}
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
        dependencies = { "cmp-conjure" },
        init = function()
            vim.g["conjure#filetypes"] = {"clojure", "fennel", "janet", "hy", "julia", "racket",
             "scheme", "lua", "lisp", "rust"}
            if _G._os_uname.sysname ~= "Windows_NT" then
                table.insert(vim.g["conjure#filetypes"] , "python")
            end
            vim.g["conjure#mapping#prefix"] = " "
            vim.g["conjure#mapping#eval_comment_current_form"] = "ecc"
            vim.g["conjure#mapping#eval_replace_form"]         = "eR"
            vim.g["conjure#mapping#eval_motion"]               = "ge"
            vim.g["conjure#mapping#doc_word"]                  = "K"

            vim.g["conjure#log#wrap"]                     = true
            vim.g["conjure#log#fold#enabled"]             = true
            vim.g["conjure#log#jump_to_latest#enabled"]   = true
        end
    },
    {
        "bfredl/nvim-luadev",
        cond = true,
        ft = "lua",
        config = function()
            vim.api.nvim_create_autocmd("BufEnter",{
                pattern = "\\[nvim-lua\\]",
                command = [[lua vim.opt_local.relativenumber = true]],
                once    = true,
            })
        end
    },
    {
        "andrewferrier/debugprint.nvim",
        keys = {
            { "dp", mode = "n" },
            { "dP", mode = "n" },
            { "dv", mode = "n" },
            { "dV", mode = "n" },
        },
        cmd = {"DeleteDebugPrints"},
        config = function()
            require("debugprint").setup {
                create_keymaps = false
            }
            map("n", [[dp]], function() return require("debugprint").debugprint()
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
        cmd  = "StartupTime",
        init = function() vim.g.startuptime_tries = 20 end
    },
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>db", mode = "n" },
            { "<leader>dc", mode = "n" },
            { "<leader>dl", mode = "n" },
        },
        config = require("config.nvim-dap"),
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {"nvim-dap"},
        config = require("config.nvim-dap-ui").config,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        cmd = {
            "DapVirtualTextEnable",
            "DapVirtualTextDisable",
            "DapVirtualTextToggle",
            "DapVirtualTextForceRefresh",
        },
        dependencies = {"nvim-dap"},
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
            map("n", [[<leader>dh]], [[<CMD>DapVirtualTextToggle<CR>]], {"silent"}, "Dap virtual text toggle")
            map("n", [[<leader>dH]], [[<CMD>DapVirtualTextForceRefresh<CR>]], {"silent"}, "Dap virtual text refresh")
        end
    },
    {
        "rcarriga/cmp-dap",
        dependencies = {"nvim-dap", "nvim-cmp" },
        config = function()
            require("cmp").setup.filetype(
                { "dap-repl", "dapui_watches", "dapui_hover" },
                {
                    sources = {
                        -- HACK: Not work for lua dapter yet?
                        { name = "dap" },
                    },
                }
            )
            vim.api.nvim_create_user_command("DapCompletionSupport", function()
                local text = require("dap").session().capabilities.supportsCompletionsRequest and "true" or "false"
                vim.api.nvim_echo({{text, "MoreMsg"}}, false, {})
            end, { desc  = "Check Dap completion support", })
        end,
    },
    {
        "jbyuki/one-small-step-for-vimkind",
        ft = "lua",
        dependencies = {"nvim-dap"},
        init = function()
            vim.api.nvim_create_user_command("OSVStop", function()
                require("osv").stop()
            end, { desc  = "Stop Neovim OSV dapter", })
            vim.api.nvim_create_user_command("OSVStart", function()
                require("osv").launch { config_file = _G._config_path .. _G._sep .. "init.lua", port = 8086 }
            end, { desc  = "Launch Neovim OSV dapter"})
        end
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/neotest-plenary",
            "nvim-neotest/neotest-python",
            "antoinemadec/FixCursorHold.nvim",
            "plenary.nvim",
            "nvim-treesitter",
        },
        cmd = {
            "NeotestRun",
            "NeotestStop",
            "NeotestAttach",
        },
        config = function ()
            vim.api.nvim_create_user_command("NeotestRun", function()
                require("neotest").run.run {strategy = "integrated"}
            end, { desc  = "Neotest run integrated", })
            vim.api.nvim_create_user_command("NeotestCurrent", function()
                require("neotest").run.run(vim.fn.expand("%"))
            end, { desc  = "Neotest run current line", })
            vim.api.nvim_create_user_command("NeotestStop", function()
                require("neotest").run.stop()
            end, { desc  = "Neotest stop", })
            vim.api.nvim_create_user_command("NeotestAttach", function()
                require("neotest").run.attach()
            end, { desc  = "Neotest run attach", })

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
        cond   = _G._os_uname.sysname ~= "Windows_NT",
        build  = "bash ./install.sh",
        cmd    = {"SnipRun", "SnipReset", "SnipReplMemoryClean", "SnipTerminate", "SnipInfo", "SnipClose"},
        config = require("config.nvim-sniprun")
    },
    -- "CRAG666/code_runner.nvim"
    -- }}} Debug
    -- Language {{{
    -- TODO: support dirname/init.lua jump and variable jump
    {
        "mrjones2014/lua-gf.nvim",
        ft = "lua",
    },
    {
        "dzeban/vim-log-syntax",
        ft = "log",
    },
    -- Fennel {{{
    {
        "rktjmp/hotpot.nvim",
        config = function()
            require("hotpot").setup {
                -- allows you to call `(require :fennel)`.
                -- recommended you enable this unless you have another fennel in your path.
                -- you can always call `(require :hotpot.fennel)`.
                provide_require_fennel = true,
                -- show fennel compiler results in when editing fennel files
                enable_hotpot_diagnostics = true,
                -- compiler options are passed directly to the fennel compiler, see
                -- fennels own documentation for details.
                compiler = {
                    -- options passed to fennel.compile for modules, defaults to {}
                    modules = {
                        -- not default but recommended, align lua lines with fnl source
                        -- for more debuggable errors, but less readable lua.
                        -- correlate = true
                    },
                    -- options passed to fennel.compile for macros, defaults as shown
                    macros = {
                        env = "_COMPILER", -- MUST be set along with any other options
                        -- you may wish to disable fennels macro-compiler sandbox in some cases,
                        -- this allows access to tables like `vim` or `os` inside macro functions.
                        -- See fennels own documentation for details on these options.
                        compilerEnv = _G,
                        allowGlobals = false,
                    }
                }
            }
        end
    },
    {
        "guns/vim-sexp",
        ft = _G._lisp_language,
        init = require("config.vim-sexp")
    },
    {
        "gpanders/nvim-parinfer",
        ft = _G._lisp_language,
        init = function ()
            vim.g.parinfer_enabled = true
            vim.g.parinfer_no_maps = true
            vim.g.parinfer_mode = "smart"
        end,
        config = function ()
            -- map("n", [[<leader>L]], [[<CMD>lua vim.b.parinfer_enabled=not(vim.b.parinfer_enabled)<CR>]], "Parinfer Toggle")
            map("n", [[<leader>L]], function()
                if vim.b.parinfer_enabled == nil then
                    vim.b.parinfer_enabled = true
                end
                vim.b.parinfer_enabled = not vim.b.parinfer_enabled
                vim.api.nvim_echo({ { string.format("vim.b.parinfer_enabled: %s", vim.b.parinfer_enabled), "Moremsg" } }, false, {})
            end, "Parinfer Toggle")
        end
    },
    -- }}} Fennel
    -- }}} Language
    -- Source control {{{
    {
        "lewis6991/gitsigns.nvim",
        event  = {"BufAdd"},
        config = require("config.nvim-gitsigns")
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
        cmd    = {"DiffviewOpen", "DiffviewFileHistory"},
        dependencies = {"plenary.nvim"},
        config = require("config.nvim-diffview"),
    },
    {
        "rhysd/git-messenger.vim",
        keys = {{"<C-h>b", mode = "n"}},
        init = function()
            vim.g.git_messenger_no_default_mappings = true
            vim.g.git_messenger_floating_win_opts   = {border = "rounded"}
        end,
        config = function ()
            map("n", [[<C-h>b]], [[<Plug>(git-messenger)]], "Git Messenger")
            vim.api.nvim_create_autocmd("FileType",{
                pattern  = "gitmessengerpopup",
                desc     = "Key binding for git messenger",
                callback = function()
                    bmap(0, "n", [[<C-o>]], [[o]], "which_key_ignore")
                    bmap(0, "n", [[<C-i>]], [[O]], "which_key_ignore")
                end
            })
        end
    },
    -- }}} Source control
    -- Knowledge {{{
    {
        "RishabhRD/nvim-cheat.sh",
        cond = _G._os_uname.sysname ~= "Windows_NT",
        cmd  = {"Cheat", "CheatList", "CheatListWithoutComments", "CheatWithoutComments"},
        dependencies = {"RishabhRD/popfix"},
    },
    {
        "dahu/VimRegexTutor",
        cmd = "VimRegexTutor",
    },
    {
        "DanilaMihailov/vim-tips-wiki",
    }
    -- }}} Knowledge
} -- }}}

local opts = {
    root = _G._plugin_root,
    git  = { log = {"-30"} },
    install = {colorscheme = {"onenord"}},
    ui   = {border = "rounded"},
    concurrency = 5,
    performance = {
        cache = {
            enabled = false
        },
        reset_packpath = true,
        rtp = {reset = true}
    }
}

vim.api.nvim_create_user_command("CDLazyPlugin", function()
    vim.cmd( "cd " .. vim.fn.stdpath("data") .. "/lazy")
    vim.notify("Change directory to Lazy plug-ins path", vim.log.levels.INFO)
end, { desc  = "Change directory to lazy plug-ins path", })

vim.opt.rtp:prepend(lazyPath)
require("lazy").setup(pluginArgs, opts)
