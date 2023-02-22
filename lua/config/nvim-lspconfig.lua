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

    local onAttach = function(client, bufNr) -- {{{
        -- TODO:
        -- bmap(bufNr, "n", [[<A-n>]],   [[<CMD>lua require("util").addJump(require("illuminate").next_reference, false, {wrap = true})<CR>]],                 {"silent"})
        -- bmap(bufNr, "n", [[<A-S-n>]], [[<CMD>lua require("util").addJump(require("illuminate").next_reference, false, {reverse = true, wrap = true})<CR>]], {"silent"})

        -- Mappings
        -- bmap(bufNr, "n", [[gd]], require('telescope.builtin').lsp_definitions, "Telescope LSP definition")
        -- bmap(bufNr, "n", [[gD]], require('telescope.builtin').lsp_type_definitions, "Telescope LSP definition")
        -- bmap(bufNr, "n", [[gR]], require('telescope.builtin').lsp_references, "Telescope LSP references")
        -- bmap(bufNr, "n", [[gi]], require('telescope.builtin').lsp_implementations, "Telescope LSP implementation)
        bmap(bufNr, "n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]],  {"silent"}, "Telescope LSP document symbols")
        bmap(bufNr, "n", [[<C-f>O]], [[<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]], {"silent"}, "Telescope LSP workspace symbols")

        bmap(bufNr, "n", [=[ga]=],        [[<CMD>lua vim.lsp.buf.code_action()<CR>]],     {"silent"}, "LSP code action")
        bmap(bufNr, "n", [=[gd]=],        [[<CMD>lua vim.lsp.buf.definition()<CR>]],      {"silent"}, "LSP definition")
        bmap(bufNr, "n", [=[gD]=],        [[<CMD>lua vim.lsp.buf.type_definition()<CR>]], {"silent"}, "LSP type definition")
        bmap(bufNr, "n", [=[gi]=],        [[<CMD>lua vim.lsp.buf.implementation()<CR>]],  {"silent"}, "LSP implementation")
        bmap(bufNr, "n", [=[<leader>D]=], [[<CMD>lua vim.lsp.buf.declaration()<CR>]],     {"silent"}, "LSP documentation")
        bmap(bufNr, "n", [=[<leader>R]=], function()
            QuickfixSwitchWin = true
            vim.lsp.buf.references{includeDeclaration = false}
        end, "LSP references")
        bmap(bufNr, "n", "<leader>rn", [[<CMD>lua vim.lsp.buf.rename()<CR>]],           {"silent"}, "LSP rename")
        bmap(bufNr, "n", [[K]],        [[<CMD>lua vim.lsp.buf.hover()<CR>]],            {"silent"}, "LSP hover")
        bmap(bufNr, "n", [[<C-p>]],    [[<CMD>lua vim.lsp.buf.signature_help()<CR>]],   {"silent"}, "LSP signature help")
        bmap(bufNr, "n", [[<A-f>]],    [[<CMD>lua vim.lsp.buf.format{async=true}<CR>]], {"silent"}, "LSP format")
        -- bmap(bufNr, "n", [=[<leader>wa]=], vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wr]=], vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wl]=], Print(vim.lsp.buf.list_workspace_folders, "LSP list workspace folder")
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
                    version = 'LuaJIT',
                },
                hint = {
                    enable = true
                },
                completion = {
                    callSnippet    = "Replace",
                    keywordSnippet = "Replace",
                    displayContext = 1,
                },
                diagnostics = {
                    globals = {'vim'},
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    maxPreload      = 2000,
                    preloadFileSize = 1000,
                    ignoreDir       = {".vscode", ".git"},
                    useGitIgnore    = true
                },
            },
        }
    }
    -- }}} Lua
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
    local findClangd = function() -- {{{
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
        local binaryExt       = {macOS = "", Linux = "", Windows = ".exe"}
        local sep             = jit.os == "Windows" and "\\" or "/"
        local dataPath   = path:new(fn.stdpath("data"))
        local clangdGenericPath = dataPath:joinpath("lsp_servers/clangd")
        local clangdPathStr     = fn.glob(clangdGenericPath.filename .. sep .. "clangd_*")
        if clangdPathStr == "" then
            return {}
        else
            local clangdBinPath = path:new(clangdPathStr):joinpath("bin", "clangd")
            local clangdBinStr  = clangdBinPath.filename .. binaryExt[jit.os]
            table.insert(cmdStr, 1, clangdBinStr)
            return cmdStr
        end

    end -- }}}

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

    -- TODO:
    -- Move to core/mapping.lua
    -- Diagnostic mapping
    map("n", [[<C-q>e]], [[<CMD>lua vim.diagnostic.setqflist()<CR>]], {"silent"}, "LSP add workspace folder")
    map("n", [[[e]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to previous diagnostic symbol")
    map("n", [[]e]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to next diagnostic symbol")
    map("n", [[[E]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}, severity = "Error"};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to previous error")
    map("n", [[]E]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}, severity = "Error"};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to next error")
    if TelescopeGlobalState then
        map("n", [[<leader>e]], [[<CMD>lua require('telescope.builtin').diagnostics{bufnr=0}<CR>]],
            {"silent"}, "Telescope LSP document diagnostics")
        map("n", [[<leader>E]], [[<CMD>lua require('telescope.builtin').diagnostics{bufnr=nil}<CR>]],
        {"silent"}, "Telescope LSP workspace diagnostics")
    else
        map("n", [[<leader>e]], [[<CMD>lua vim.diagnostic.open_float()<CR>]], {"silent"}, "LSP diagnostics")
    end

    -- Setup servers {{{
    local basicConfig = {
        -- enable snippet support
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
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

