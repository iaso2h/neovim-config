-- https://github.com/neovim/nvim-lspconfig
return function()
    local lspConfig   = require("lspconfig")
    local u           = require("lspconfig.util")
    local serverNames = require("plugins.nvim-mason-lspconfig").serverNames

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
                    -- local openExcmd = api.nvim_buf_get_option(i.bufnr, "buflisted") and "buffer" or "edit"
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

    ---@param client table
    ---@param bufNr integer
    local onAttach = function(client, bufNr) -- {{{
        -- Mappings
       bmap(bufNr, "n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]],  {"silent"}, "LSP document symbols")
          bmap(bufNr, "n", [[<C-f>O]], [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]], {"silent"}, "LSP workspace symbols")

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

        -- bmap(bufNr, {"x", "n"}, [[<leader>a]],  vim.lsp.buf.code_action,    "LSP code action")
        bmap(bufNr, "n", [[<leader>rn]], vim.lsp.buf.rename,         "LSP rename")
        bmap(bufNr, "n", [[K]],          vim.lsp.buf.hover,          "LSP hover")
        bmap(bufNr, "n", [[<C-p>]],      vim.lsp.buf.signature_help, "LSP signature help")

        bmap(bufNr, "n", [[<C-q>r]], [[<CMD>lua vim.lsp.buf.references{includeDeclaration=true}<CR>]], {"silent"}, "LSP references")
        -- bmap(bufNr, "n", [=[<leader>wa]=], vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wr]=], vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wl]=], Print(vim.lsp.buf.list_workspace_folders, "LSP list workspace folder")

        -- Bring back the gqq for formatting comments and stuff
        --  HACK: vim.lsp.formatexpr() is always set in:
        -- https://github.com/neovim/neovim/blob/f1b415b3abbcccb8b0d2aa1a41a45dd52de1a5ff/runtime/lua/vim/lsp.lua#L1130
        vim.bo.formatexpr = ""
        vim.opt.formatexpr = ""
        bmap(bufNr, "n", [[gqq]], function()
            if vim.bo.formatexpr ~= "" then
                vim.bo.formatexpr = ""
            end
            vim.cmd [[norm! gqq]]
        end, "which_key_ignore")
        bmap(bufNr, "n", [[gq]], function()
            if vim.bo.formatexpr ~= "" then
                vim.bo.formatexpr = ""
            end
            vim.cmd [[norm! gq]]
        end, "which_key_ignore")
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

-- LSP servers override {{{
-- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
-- Python {{{
-- https://github.com/microsoft/pyright
-- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
serverNames.pyright = {
    settings  = {
        python = {
            pythonPath = "python",
            venvPath = "",
            analysis = {
                -- autoSearchPaths = true,
                diagnosticMode = "workspace",
                -- diagnosticMode = "openFileOnly",
                -- extraPaths = "",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
            }
        },
        pyright = {
            verboseOutput = true,
            reportMissingImports = true,
        }
    }
}
-- }}} Python
-- Lua {{{
-- https://github.com/LuaLS/lua-language-server
-- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls

--- Get lua plugins repository directory. e.g. "/home/iaso2h/.local/share/nvim/lazy/nvim-treesitter/lua"
---@param plugin string
---@return string
local luaGetPluginRepoDir = function(plugin, suffix)
    return suffix and
        _G._plugin_root .. _G._sep .. plugin .. _G._sep .. "lua" or
        _G._plugin_root .. _G._sep .. plugin .. _G._sep
end
local luaLibrary = {
    vim.fn.expand("$VIMRUNTIME") .. _G._sep .. "lua",
    require("neodev.config").types(),
    luaGetPluginRepoDir("nvim-treesitter", true),
    luaGetPluginRepoDir("telescope.nvim", true),      -- HACK: failed to parse the lib
    luaGetPluginRepoDir("plenary.nvim", true),
    luaGetPluginRepoDir("mason-null-ls.nvim", true),  -- HACK: failed to parse the lib
    luaGetPluginRepoDir("null-ls.nvim", true),        -- HACK: failed to parse the lib
    luaGetPluginRepoDir("LuaSnip", true),             -- HACK: failed to parse the lib
    luaGetPluginRepoDir("nvim-dap", true),
}
local fennelLibrary = {
    vim.fn.expand("$VIMRUNTIME") .. _G._sep,
    require("neodev.config").types(),
    luaGetPluginRepoDir("nvim-treesitter", false),
    luaGetPluginRepoDir("telescope.nvim", false),
    luaGetPluginRepoDir("plenary.nvim", false),
    luaGetPluginRepoDir("mason-null-ls.nvim", false),
    luaGetPluginRepoDir("null-ls.nvim", false),
    luaGetPluginRepoDir("LuaSnip", false),
    luaGetPluginRepoDir("nvim-dap", false),
}
for _, dir in ipairs(luaLibrary) do
    if not vim.loop.fs_stat(dir) then
        vim.notify(debug.traceback(), vim.log.levels.WARN)
        vim.notify("Path doesn't exist: " .. dir)
    end
end
serverNames.lua_ls = { -- {{{
    settings = {
        Lua = {
            -- https://github.com/LuaLS/lua-language-server/blob/076dd3e5c4e03f9cef0c5757dfa09a010c0ec6bf/locale/en-us/setting.lua#L5-L13
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
            codeLens = {enable = true},
            completion = {
                callSnippet    = "Replace",
                keywordSnippet = "Replace",
                workspaceWord  = true,
                displayContext = true,
                showWord = "Fallback",
                showParams = true,
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
            telemetry = {enable = false}
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
    serverNames.fennel_language_server = {
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
serverNames.vimls = {
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
    local clangdRootFiles = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac', -- AutoTools
    'makefile',
    'build',
    }
    local clangdRootDir = function(fname)
      return u.root_pattern(unpack(clangdRootFiles))(fname) or u.find_git_ancestor(fname) or vim.loop.cwd()
    end
    serverNames.clangd = {
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
        root_dir = clangdRootDir
    }
end
-- }}} Clangd
-- marksman {{{
if _G._os_uname.sysname == "Windows_NT" then
    serverNames.marksman = {
        cmd = {
            [[C:\Users\Hashub\AppData\Local\nvim-data\mason\packages\marksman\marksman.exe]],
            "server"
        }
    }
end
-- }}} marksman
-- }}}

    -- Setup servers {{{
    local ok, _ = pcall(require, "cmp_nvim_lsp")
    local capabilities = ok and require("cmp_nvim_lsp").default_capabilities() or {}
    local basicConfig = {
        -- enable snippet support
        capabilities = capabilities,
        -- map buffer local keybindings when the language server attaches
        on_attach    = onAttach
    }

    for _, serverName in pairs(vim.tbl_keys(serverNames)) do
        serverNames[serverName] = vim.tbl_deep_extend("force", basicConfig, serverNames[serverName])
        if serverName ~= "clangd" then
            lspConfig[serverName].setup(serverNames[serverName])
        else
            serverNames[serverName].capabilities.offsetEncoding = {"utf-16"}
        end
    end
    -- }}} Setup servers

-- vim.lsp and vim.diagnostic setups {{{
vim.diagnostic.config {
    underline        = true,
    virtual_text     = true,
    signs            = true,
    update_in_insert = false,
    severity_sort    = true,
}

vim.cmd [[
sign define DiagnosticSignError text= texthl=DiagnosticError linehl= numhl=DiagnosticError
sign define DiagnosticSignWarn  text= texthl=DiagnosticWarn  linehl= numhl=DiagnosticWarn
sign define DiagnosticSignInfo  text= texthl=DiagnosticInfo  linehl= numhl=DiagnosticInfo
sign define DiagnosticSignHint  text= texthl=DiagnosticHint  linehl= numhl=DiagnosticHint
]]
vim.lsp.handlers["textDocument/hover"]         = vim.lsp.with(vim.lsp.handlers.hover,          {border = "rounded"})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})
-- }}} vim.lsp and vim.diagnostic setups

end
