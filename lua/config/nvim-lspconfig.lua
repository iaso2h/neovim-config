-- https://github.com/neovim/nvim-lspconfig
return function()
    local lsp       = vim.lsp
    local fn        = vim.fn
    local lspConfig = require("lspconfig")
    local lspUtil   = require("lspconfig.util")
    local path      = require("plenary.path")
    local servers   = require("config.nvim-mason-lspconfig").servers
    ----
    -- Function: onAttach :Mappings or commands need to be loaded when specific LSP is attach
    --
    -- @param client: language-server client
    -- @param bufNr: buffer number
    ----
    local conciseQuifix = function(tbl)
        local api = vim.api
        if tbl then
            local i = tbl.items[1]
            if #tbl.items == 1 or (#tbl.items == 2 and
                                    i.filename == tbl.items[2].filename and
                                    i.lnum == tbl.items[2].lnum) then
                local currentBufNr = api.nvim_get_current_buf()
                -- item.bufnr can be nil!
                local itemBufNr = fn.bufnr(i.filename)
                if currentBufNr ~= itemBufNr then
                    -- local openExcmd = api.nvim_buf_get_option(i.bufnr, "buflisted") and "buffer" or "edit"
                    local openExcmd = "edit"
                    vim.cmd(string.format("%s %s", openExcmd, i.filename))
                end
                vim.cmd [[normal! m`]] -- Register current position in jumplist
                api.nvim_win_set_cursor(0, {i.lnum, i.col - 1})
                vim.cmd [[norm! zv]]
            else
                fn.setqflist({}, "r", {items = tbl.items, title = tbl.title})
                require("quickfix.toggle")(false)
            end
        end
    end


    local onAttach = function(client, bufNr) -- {{{
        -- Mappings
        bmap(bufNr, "n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]],  {"silent"}, "LSP document symbols")
        bmap(bufNr, "n", [[<C-f>O]], [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]], {"silent"}, "LSP workspace symbols")

        bmap(bufNr, "n", [[gd]], function()
            vim.lsp.buf.definition { on_list = conciseQuifix }
        end, { "silent" }, "LSP definition")
        bmap(bufNr, "n", [[gD]], function()
            vim.lsp.buf.declaration { on_list = conciseQuifix }
        end, { "silent" }, "LSP declaration")
        bmap(bufNr, "n", [[gt]], function()
            vim.lsp.buf.type_definition { on_list = conciseQuifix }
        end, { "silent" }, "LSP type definition")
        bmap(bufNr, "n", [[gi]], function()
            vim.lsp.buf.implementation { on_list = conciseQuifix }
        end, { "silent" }, "LSP implementation")

        bmap(bufNr, "n", [[<leader>a]],
            [[<CMD>lua vim.lsp.buf.code_action()<CR>]],    {"silent"}, "LSP code action")
        bmap(bufNr, "n", "<leader>rn",
            [[<CMD>lua vim.lsp.buf.rename()<CR>]],         {"silent"}, "LSP rename")
        bmap(bufNr, "n", [[K]],
            [[<CMD>lua vim.lsp.buf.hover()<CR>]],          {"silent"}, "LSP hover")
        bmap(bufNr, "n", [[<C-p>]],
            [[<CMD>lua vim.lsp.buf.signature_help()<CR>]], {"silent"}, "LSP signature help")

        bmap(bufNr, "n", [[<C-q>r]], [[<CMD>lua vim.lsp.buf.references{includeDeclaration=true}<CR>]], {"silent"}, "LSP references")
        -- bmap(bufNr, "n", [=[<leader>wa]=], vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wr]=], vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wl]=], Print(vim.lsp.buf.list_workspace_folders, "LSP list workspace folder")

        -- Bring back the gqq for formatting comments and stuff, use <A-f> to
        vim.opt.formatexpr = ""
    end -- }}}

    -- LSP config override {{{
    -- Setup() function: https://github.com/neovim/nvim-lspconfig#setup-function
    -- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
    -- Python {{{
    -- https://github.com/microsoft/pyright
    -- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
    -- https://github.com/microsoft/pyright/blob/96871bec5a427048fead499ab151be87b7baf023/packages/vscode-pyright/package.json
    local pyRootFiles = {
        'pyproject.toml',
        'setup.py',
        'main.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        }

    servers.pyright = {
        settings  = {
            root_dir = lspUtil.root_pattern(unpack(pyRootFiles)),
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
    servers.lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                hint = {
                    enable = true
                },
                completion = {
                    callSnippet    = "Both",
                    keywordSnippet = "Both",
                    displayContext = 1,
                },
                diagnostics = {
                    disable = {
                        "trailing-space",
                        "empty-block"
                    },
                    globals = {
                        "vim",
                        "map",
                        "bmap",
                        "luaRHS",
                        "t",
                        "Print",
                        "ex",
                        "tbl_idx",
                        "tbl_replace",
                        "nvim_buf_get_name",
                    },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                    maxPreload      = 2000,
                    preloadFileSize = 1000,
                    ignoreDir       = {".vscode", ".git"},
                    useGitIgnore    = true
                },
            },
        }
    }
    -- }}} Lua
    -- Fennel {{{
    if _G._os_uname.sysname ~= "Windows_NT" then
        -- HACK:
        local fennelRuntimePath = {vim.api.nvim_eval("$VIMRUNTIME")}
        table.insert(fennelRuntimePath, _G._config_path)
        table.insert(fennelRuntimePath, string.format("%s%sfnl%sruntimestub%s%s",
                                            _G._config_path,
                                            _G._sep,
                                            _G._sep,
                                            _G._sep,
                                            _G._sep and "nightly" or "stable"))
        servers.fennel_language_server = {
            settings = {
                fennel = {
                    workspace = {
                        library = fennelRuntimePath,
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
    -- npm install -g vim-language-server
    vim.g.markdown_fenced_languages = {
        'vim',
        'help'
    }
    servers.vimls = {
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
    -- https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd
    local findClangd = function()
        local cmdStr = {
            "--all-scopes-completion",
            "--background-index",
            "--clang-tidy",
            "--clang-tidy-checks=google-*,llvm-*,clang-analyzer-*, cert-*,performance-*,misc-,modernize-*,-modernize-use-trailing-return-type,concurrency-*,bugprone-*,readability-*,-readability-magic-numbers",
            "--completion-parse=auto",
            "--completion-style=detailed",
            "--cross-file-rename",
            "--header-insertion=iwyu",
            "--j=4",
            "--pretty",
            "--suggest-missing-includes",
            "--fallback-style=google"
        }
        -- TODO: breaking change in clangd path
        local binaryExt       = {macOS = "", Linux = "", Windows_NT = ".exe"}
        local sep             = _G._os_uname.sysname == "Windows_NT" and "\\" or "/"
        local dataPath   = path:new(fn.stdpath("data"))
        local clangdGenericPath = dataPath:joinpath("lsp_servers/clangd")
        local clangdPathStr     = fn.glob(clangdGenericPath.filename .. sep .. "clangd_*")
        if clangdPathStr == "" then
            return {}
        else
            local clangdBinPath = path:new(clangdPathStr):joinpath("bin", "clangd")
            local clangdBinStr  = clangdBinPath.filename .. binaryExt[_G._os_uname.sysname]
            table.insert(cmdStr, 1, clangdBinStr)
            return cmdStr
        end

    end

    local clangdCMD = findClangd()
    if clangdCMD ~= "" then
        servers.clangd = {
            cmd = clangdCMD,
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
            root_dir = lspConfig.util.root_pattern(".git", "compile_commands.json", "compile_flags.txt", "build", "README.md", "makefile"),
        }
    end
    -- }}} Clangd

    if _G._os_uname.sysname == "Windows_NT" then
        servers.marksman = {
            cmd = {
                [[C:\Users\Hashub\AppData\Local\nvim-data\mason\packages\marksman\marksman.exe]],
                "server"
            }

        }
    end
    -- }}} LSP config override

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
    lsp.handlers["textDocument/hover"]         = lsp.with(lsp.handlers.hover,          {border = "rounded"})
    lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {border = "rounded"})
    -- }}} vim.lsp and vim.diagnostic setups

    -- Setup servers {{{
    local ok, _ = pcall(require, "cmp_nvim_lsp")
    local capabilities = ok and require("cmp_nvim_lsp").default_capabilities() or {}
    local basicConfig = {
        -- enable snippet support
        capabilities = capabilities,
        -- map buffer local keybindings when the language server attaches
        on_attach    = onAttach
    }

    local config
    for _, server in pairs(vim.tbl_keys(servers)) do
        config = vim.tbl_deep_extend("force", basicConfig, servers[server])
        lspConfig[server].setup(config)
    end
    -- }}} Setup servers

end
