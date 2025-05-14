-- https://github.com/neovim/nvim-lspconfig

return function()
    local lspConfig = require("lspconfig")
    local u         = require("lspconfig.util")
    local icon      = require("icon")
    local serverConfigs = vim.deepcopy(require("plugins.nvim-mason-lspconfig").serverNames, true)

    local conciseQuifix = function(tbl) -- {{{
        if tbl then
            local i = tbl.items[1]
            if #tbl.items == 1 or (#tbl.items == 2 and
                                    i.filename == tbl.items[2].filename and
                                    i.lnum == tbl.items[2].lnum) then
                local currentBufNr = vim.api.nvim_get_current_buf()
                -- item.bufnr can be nil!
                local itemBufNr = vim.fn.bufnr(i.filename)
                if currentBufNr ~= itemBufNr then
                    -- local openExcmd = api.nvim_get_option_value("buflisted", {buf = i.bufnr}) and "buffer" or "edit"
                    local openExcmd = "edit"
                    vim.cmd(string.format("%s %s", openExcmd, i.filename))
                end
                require("jump.util").posCenter(function()
                    vim.cmd [[normal! m`]] -- Register current position in jumplist
                    vim.api.nvim_win_set_cursor(0, {i.lnum, i.col - 1})
                    vim.cmd [[norm! zv]]
                end, false)
            else
                vim.fn.setqflist({}, "r", {items = tbl.items, title = tbl.title})
                require("buffer.toggle")("quickfix", false)
            end
        end
    end -- }}}

    ---@param args table
    local onAttach = function(args) -- {{{
    -- Deprecated: local onAttach = function(client, bufNr)

        local bufNr = args.buf

        -- Signature
        require("plugins.nvim-lsp-signature").setup(bufNr)

        -- Mappings

        bmap(bufNr, "n", [[K]], function() vim.lsp.buf.hover {border = _G._float_win_border} end, "Documentation")
        bmap(bufNr, "n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]], {"silent"}, "LSP workspace symbols")
        bmap(bufNr, "n", [[<C-f><C-o>]], [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]], {"silent"}, "LSP workspace symbols")

        bmap(bufNr, "n", [[gd]], function()
            vim.lsp.buf.definition { on_list = conciseQuifix }
        end, "LSP definition")
        bmap(bufNr, "n", [[gD]], function()
            vim.lsp.buf.declaration { on_list = conciseQuifix }
        end, "LSP declaration")
        bmap(bufNr, "n", [[gt]], function()
            vim.lsp.buf.type_definition { on_list = conciseQuifix }
        end, "LSP type definition")
        bmap(bufNr, "n", [[gi]], function()
            vim.lsp.buf.implementation { on_list = conciseQuifix }
        end, "LSP implementation")

        bmap(bufNr, {"x", "n"}, [[ga]],  vim.lsp.buf.code_action,    "LSP code action")
        bmap(bufNr, "n", [[<leader>rn]], vim.lsp.buf.rename, "LSP rename")
        bmap(bufNr, "n", [[<F2>]],       vim.lsp.buf.rename, "LSP rename")
        bmap(bufNr, "n", [[<C-p>]],      vim.lsp.buf.signature_help, "LSP signature help")

        bmap(bufNr, "n", [[<C-q>r]], [[<CMD>lua vim.lsp.buf.references{includeDeclaration=true}<CR>]], {"silent"}, "LSP references")
        -- bmap(bufNr, "n", [=[<leader>wa]=], vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wr]=], vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wl]=], Print(vim.lsp.buf.list_workspace_folders, "LSP list workspace folder")

        -- Bring back the gqq for formatting comments and stuff
        vim.bo.formatexpr = ""
        vim.opt.formatexpr = ""
        vim.api.nvim_create_user_command("Format", function(opts)
            if opts.range == 0 then
                vim.lsp.buf.format { name = "null-ls",
                    async = true
                }
            else
                vim.lsp.buf.format {
                    name = "null-ls",
                    async = true,
                    range = {
                        ["start"] = {opts.line1, 0},
                        ["end"] = {opts.line2, 0}
                    }
                }
            end
        end, {
            desc  = "Format buffer or selected range",
            range = true
        })
    end -- }}}

    vim.api.nvim_create_autocmd('LspAttach', { callback = onAttach })


-- LSP servers override {{{
-- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
-- Python {{{
-- https://github.com/microsoft/pyright
-- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
-- serverConfigs.pyright = {
--     settings  = {
--         python = {
--             -- pythonPath = "python",
--             -- venvPath = "",
--             analysis = {
--                 -- extraPaths = "",
--             }
--         },
--         pyright = {
--             verboseOutput = true,
--             reportMissingImports = true,
--         }
--     }
-- }

serverConfigs.ruff = {
    settings  = {
    }
}
-- }}} Python
-- Lua {{{
-- https://github.com/LuaLS/lua-language-server
-- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls

--- Get lua plugins repository directory. e.g. "/home/iaso2h/.local/share/nvim/lazy/nvim-treesitter/lua"
---@param plugin string
---@return string
local luaPluginDir = function(plugin)
    return _G._plugin_root .. _G._sep .. plugin .. _G._sep .. "lua"
end
local luaLibrary = {
    vim.fn.expand("$VIMRUNTIME") .. _G._sep .. "lua",
    require("neodev.config").types(),
    luaPluginDir("nvim-treesitter"),
    luaPluginDir("telescope.nvim"),
    luaPluginDir("plenary.nvim"),
    luaPluginDir("mason-null-ls.nvim"),
    luaPluginDir("none-ls.nvim"),
    luaPluginDir("LuaSnip"),
    luaPluginDir("nvim-dap"),
}
for _, dir in ipairs(luaLibrary) do
    if not vim.loop.fs_stat(dir) then
        vim.api.nvim_echo(
            {
                {debug.traceback(), "WarningMsg"},
                {"Path doesn't exist: " .. dir}
            },
            true,
            {}
        )
    end
end
serverConfigs.lua_ls = { -- {{{
    settings = {
        Lua = {
            -- https://luals.github.io/wiki/settings/
            runtime = {
                path = {
                    -- _G._config_path .. "/lua/?/init.lua",
                    -- _G._config_path .. "/lua/?.lua",
                    "?/init.lua",
                    "?.lua",
                },
                version = "LuaJIT",
                pathStrict = false,
            },
            hint = {
                enable    = true,
                paramType = true,
                setType   = true,
                paramName = "All",
            },
            -- Use stylua to format instead. Configured in
            -- `lua/plugins/nvim-null-ls`
            format = {enable = false},
            completion = {
                callSnippet    = "Replace",
                keywordSnippet = "Replace",
            },
            diagnostics = {
                disable = {
                    "trailing-space",
                    "empty-block"
                },
                globals = { },
            },
            workspace = {
                library = luaLibrary,
                checkThirdParty = false,
                useGitIgnore    = true
            },
        },
    },
} -- }}}
-- }}} Lua
-- Fennel {{{
if _G._os_uname.sysname == "Linux" and _G._os_uname.machine ~= "aarch64" then
    -- HACK: make fennel lsp realize neovim runtime
    -- https://github.com/rydesun/fennel-language-server
    -- local fennelRuntimePath = {vim.api.nvim_eval("$VIMRUNTIME")}
    -- table.insert(fennelRuntimePath, _G._config_path)
    -- table.insert(fennelRuntimePath, string.format("%s%sfnl%sruntimestub%s%s",
    --                                     _G._config_path,
    --                                     _G._sep,
    --                                     _G._sep,
    --                                     _G._sep,
    --                                     _G._sep and "nightly" or "stable"))
    serverConfigs.fennel_language_server = {
        settings = {
            fennel = {
                workspace = {
                    library = fennelLibrary,
                },
                diagnostics = {
                    globals = {"vim"}
                }
            }
        }
    }
end
-- }}} Fennel
-- Vimscript {{{
vim.g.markdown_fenced_languages = {
    'vim',
    'help'
}
serverConfigs.vimls = {
    init_options = {
        isNeovim    = true,
        runtimepath = "",
        vimruntime  = "",
        suggest     = {
            fromRuntimepath = true,
            fromVimruntime = true
        },
    },
}
-- }}} Vimscript
-- Clangd {{{
if _G._os_uname.machine ~= "aarch64" then
    -- https://clangd.llvm.org/config
    local clangdRootDir = function(fname)
      return u.root_pattern(unpack(clangdRootFiles))(fname) or u.find_git_ancestor(fname) or vim.loop.cwd()
    end
    serverConfigs.clangd = {
        init_options = {
            -- capabilities         = {},
            clangdFileStatus     = true,
            usePlaceholders      = true,
            completeUnimported   = true,
            semanticHighlighting = true,
            fallbackFlags = {
            "-std=c99",
            "-Wall",
            "-Wextra",
            "-Wno-deprecated-declarations"
            }
        },
    }
end
-- }}} Clangd
-- marksman {{{
if _G._os_uname.sysname == "Windows_NT" then
    serverConfigs.marksman = {
        cmd = {
            [[C:\Users\Hashub\AppData\Local\nvim-data\mason\packages\marksman\marksman.exe]],
            "server"
        }
    }
end
-- }}} marksman
-- }}}

    -- Set up servers {{{
    local ok, _ = pcall(require, "cmp_nvim_lsp")
    local capabilities = ok and require("cmp_nvim_lsp").default_capabilities() or {}
    local basicConfig = { capabilities = capabilities, }

    for name, config in pairs(serverConfigs) do
        config = vim.tbl_deep_extend("force", basicConfig, config)
        if name ~= "clangd" then
            config.capabilities.offsetEncoding = {"utf-16"}
        end
        -- vim.lsp.config(name, config)
        -- vim.lsp.enable(name)
        lspConfig[name].setup(config)
    end

    if require("util").ex("omnisharp") then
        lspConfig["omnisharp"].setup{
            cmd = { "dotnet", "D:/omnisharp/OmniSharp.dll" },
            MsBuild = {
                -- If true, MSBuild project system will only load projects for files that
                -- were opened in the editor. This setting is useful for big C# codebases
                -- and allows for faster initialization of code navigation features only
                -- for projects that are relevant to code that is being edited. With this
                -- setting enabled OmniSharp may load fewer projects and may thus display
                -- incomplete reference lists for symbols.
                LoadProjectsOnDemand = nil,
            },
            RoslynExtensionsOptions = {
                -- Enables support for roslyn analyzers, code fixes and rulesets.
                EnableAnalyzersSupport = true,
                -- Enables support for showing unimported types and unimported extension
                -- methods in completion lists. When committed, the appropriate using
                -- directive will be added at the top of the current file. This option can
                -- have a negative impact on initial completion responsiveness,
                -- particularly for the first few completion sessions after opening a
                -- solution.
                EnableImportCompletion = nil,
                -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
                -- true
                AnalyzeOpenDocumentsOnly = true,
            },
        }
    end
    -- }}} Setup servers

    -- vim.diagnostic setups {{{
    vim.diagnostic.config {
        underline        = true,
        virtual_text     = true,
        update_in_insert = false,
        severity_sort    = true,
        signs = {
            severity = { min = vim.diagnostic.severity.WARN},
            text = {
                [vim.diagnostic.severity.WARN]  = icon.diagnostics.Warning,
                [vim.diagnostic.severity.INFO]  = icon.diagnostics.Information,
                [vim.diagnostic.severity.HINT]  = icon.diagnostics.Hint,
                [vim.diagnostic.severity.ERROR] = icon.diagnostics.Error,
            },
            linehl = {
                [vim.diagnostic.severity.WARN]  = 'DiagnosticSignWarnLine',
                [vim.diagnostic.severity.INFO]  = 'DiagnosticSignInfoLine',
                [vim.diagnostic.severity.HINT]  = 'DiagnosticSignHintLine',
                [vim.diagnostic.severity.ERROR] = 'DiagnosticSignErrorLine',
            },
        }
    }

    vim.cmd [[
    sign define DiagnosticSignError text= texthl=DiagnosticError linehl= numhl=DiagnosticError
    sign define DiagnosticSignWarn  text= texthl=DiagnosticWarn  linehl= numhl=DiagnosticWarn
    sign define DiagnosticSignInfo  text= texthl=DiagnosticInfo  linehl= numhl=DiagnosticInfo
    sign define DiagnosticSignHint  text= texthl=DiagnosticHint  linehl= numhl=DiagnosticHint
    ]]
    -- }}}

end
