local M   = {servers = {}}


M.formatCode = function(vimMode) -- {{{
    local fn  = vim.fn
    local cmd = vim.cmd
    if not vim.bo.modified then return end

    local fileType = vim.bo.filetype

    cmd "up"

    if vimMode == "n" then
        if fileType == "lua" then
            if not ex("lua-format") then return end
            local saveView = fn.winsaveview()
            local flags
            flags = vim.b.luaFormatflags or [[--indent-width=4 --tab-width=4 --continuation-indent-width=4]]
            cmd([[silent %!lua-format % ]] .. flags)
            fn.winrestview(saveView)
        elseif fileType == "json" then
            if not ex("js-beautify") then return end
            cmd [[silent %!js-beautify %]]
        else
            local saveView = fn.winsaveview()
            cmd [[normal vae=]]
            fn.winrestview(saveView)
        end
    else
        local saveView = fn.winsaveview()
        cmd [[normal! gv=]]
        fn.winrestview(saveView)
    end
end -- }}}


----
-- Function: M.config: Find and setup configuration for each LSP, including keymaps
----
M.config = function() -- {{{
    local lspConfig = require("lspconfig")
    local path = require("plenary.path")
    local lsp = vim.lsp
    local fn  = vim.fn
    local cmd = vim.cmd
    local M   = require("config.nvim-lsp")
    ----
    -- Function: onAttach :Mappings or commands need to be loaded when specific LSP is attach
    --
    -- @param client: language-server client
    -- @param bufNr: buffer number
    ----

    local onAttach = function(client, bufNr) -- {{{
        require("illuminate").on_attach(client)

        bmap(bufNr, "n", [[<A-n>]],   [[:lua require("util").addJump(require("illuminate").next_reference, false, {wrap = true})<CR>]],                 {"silent"})
        bmap(bufNr, "n", [[<A-S-n>]], [[:lua require("util").addJump(require("illuminate").next_reference, false, {reverse = true, wrap = true})<CR>]], {"silent"})
        -- Mappings
        -- bmap(bufNr, "n", [[gd]], require('telescope.builtin').lsp_definitions, "Telescope LSP definition")
        -- bmap(bufNr, "n", [[gD]], require('telescope.builtin').lsp_type_definitions, "Telescope LSP definition")
        -- bmap(bufNr, "n", [[gR]], require('telescope.builtin').lsp_references, "Telescope LSP references")
        -- bmap(bufNr, "n", [[gi]], require('telescope.builtin').lsp_implementations, "Telescope LSP implementation)
        bmap(bufNr, "n", [[<C-f>a]],    require('telescope.builtin').lsp_code_actions,          "Telescope LSP code action")
        bmap(bufNr, "n", [[<C-f>o]],    require('telescope.builtin').lsp_document_symbols,      "Telescope LSP document symbols")
        bmap(bufNr, "n", [[<C-f>O]],    require('telescope.builtin').lsp_workspace_symbols,     "Telescope LSP workspace symbols")
        bmap(bufNr, "n", [[<leader>e]], require('telescope.builtin').lsp_document_diagnostics,  "Telescope LSP document diagnostics")
        bmap(bufNr, "n", [[<leader>E]], require('telescope.builtin').lsp_workspace_diagnostics, "Telescope LSP workspace diagnostics")

        bmap(bufNr, "n", [=[gD]=],        vim.lsp.buf.declaration,     "LSP documentation")
        bmap(bufNr, "n", [=[gd]=],        vim.lsp.buf.definition,      "LSP definition")
        bmap(bufNr, "n", [=[<leader>D]=], vim.lsp.buf.type_definition, "LSP type definition")
        bmap(bufNr, "n", [=[gi]=],        vim.lsp.buf.implementation,  "LSP implementation")
        bmap(bufNr, "n", [=[gR]=], luaRHS[[:lua
    do
        QuickfixSwitchWin = true;
        vim.lsp.buf.references{includeDeclaration = false}
    end<CR>
]], "LSP references")
        bmap(bufNr, "n", [[K]],         vim.lsp.buf.hover,          "LSP hover")
        bmap(bufNr, "n", [[<C-p>]],     vim.lsp.buf.signature_help, "LSP signature help")
        bmap(bufNr, "n", [[<leader>rn]], vim.lsp.buf.rename,         "LSP rename")
        -- bmap(bufNr, "n", [=[<leader>wa]=], vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wr]=], vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wl]=], Print(vim.lsp.buf.list_workspace_folders, "LSP list workspace folder")
        bmap(bufNr, "n", [[<C-q>e]], vim.diagnostic.setqflist, "LSP add workspace folder")
        bmap(bufNr, "n", [[[e]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}};vim.cmd("norm! zz")<CR>]], {"silent"})
        bmap(bufNr, "n", [[]e]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}};vim.cmd("norm! zz")<CR>]], {"silent"})
        bmap(bufNr, "n", [[[E]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}, severity = "Error"};vim.cmd("norm! zz")<CR>]], {"silent"})
        bmap(bufNr, "n", [[]E]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}, severity = "Error"};vim.cmd("norm! zz")<CR>]], {"silent"})
        -- Override existing mapping if lsp support
        if client.resolved_capabilities.document_formatting then
            bmap(bufNr, "n", [=[<A-f>]=], [[:lua vim.lsp.buf.formatting()<CR>]],       {"silent"})
        elseif client.resolved_capabilities.document_range_formatting then
            bmap(bufNr, "n", [=[<A-f]=],  [[:lua vim.lsp.buf.range_formatting()<CR>]], {"silent"})
        end
    end -- }}}

    -- LSP config override {{{
    -- Setup() function: https://github.com/neovim/nvim-lspconfig#setup-function
    -- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
    -- Python {{{
    -- https://github.com/microsoft/pyright
    -- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
    -- https://github.com/microsoft/pyright/blob/96871bec5a427048fead499ab151be87b7baf023/packages/vscode-pyright/package.json

    M.servers.pyright = {
        settings  = {
            python = {
                pythonPath = "python",
                venvPath = "",
                analysis = {
                    diagnosticMode = "openFileOnly",
                    extraPaths = "",
                    typeCheckingMode = "basic",
                    useLibraryCodeForTypes = false,
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
    -- https://github.com/sumneko/lua-language-server
    -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua
    local runtimePath     = vim.split(package.path, ";")
    table.insert(runtimePath, "lua/?.lua")
    table.insert(runtimePath, "lua/?/init.lua")

    M.servers.sumneko_lua = {
        settings = {
            Lua = {
                runtime = {
                -- For neovim
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtimePath
                },
                completion = {
                    callSnippet    = "Replace",
                    keywordSnippet = "Replace"
                },
                diagnostics = {
                    globals = {'vim'},
                },

                workspace = {
                    maxPreload      = 10000,
                    preloadFileSize = 10000,
                    ignoreDir       = {".vscode", ".git"}
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
    M.servers.vimls = {
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
        M.servers.clangd = {
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
    M.servers.jsonls = nil
    M.servers.html = nil
    M.servers.tsserver = nil
    M.servers.yamlls = nil
    M.servers.cssls = nil
    M.servers.bashls = nil
    -- }}} LSP config override

    -- vim.lsp and vim.diagnostic setups {{{
    vim.diagnostic.config {
        underline        = true,
        virtual_text     = true,
        signs            = true,
        update_in_insert = false,
        severity_sort    = true,
    }

    cmd [[
    sign define DiagnosticSignError text= texthl=DiagnosticError linehl= numhl=DiagnosticError
    sign define DiagnosticSignWarn  text= texthl=DiagnosticWarn  linehl= numhl=DiagnosticWarn
    sign define DiagnosticSignInfo  text= texthl=DiagnosticInfo  linehl= numhl=DiagnosticInfo
    sign define DiagnosticSignHint  text= texthl=DiagnosticHint  linehl= numhl=DiagnosticHint
    ]]
    lsp.handlers["textDocument/hover"]         = lsp.with(lsp.handlers.hover,          {border = "rounded"})
    lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {border = "rounded"})
    -- }}} vim.lsp and vim.diagnostic setups

    -- Format mapping {{{
    cmd [[command! -nargs=0 Format lua require("config.nvim-lsp").formatCode("n")]]
    map("n", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("n")<CR>]], {"silent"})
    map("x", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("v")<CR>]], {"silent"})
    -- }}} Format mapping

    -- Setup servers {{{
    local lsp_installer_servers = require("nvim-lsp-installer.servers")
    local snippetCapabilities   = vim.lsp.protocol.make_client_capabilities()
    snippetCapabilities.textDocument.completion.completionItem.snippetSupport = true

    local basicConfig = {
        -- enable snippet support
        capabilities = require("cmp_nvim_lsp").update_capabilities(snippetCapabilities),
        -- map buffer local keybindings when the language server attaches
        on_attach    = onAttach
    }

    for _, server in pairs(vim.tbl_keys(M.servers)) do
        local server_available, requested_server = lsp_installer_servers.get_server(server)
        if server_available then
            requested_server:on_ready(function ()
                local config = {}
                if server == "lua" then
                    config = require("lua-dev").setup{
                        -- lspconfig = M.servers[server]
                    }
                    config = vim.tbl_deep_extend("force", basicConfig, config)
                else
                    config = vim.tbl_deep_extend("force", basicConfig, M.servers[server])
                end
                requested_server:setup(config)
            end)
            if not requested_server:is_installed() then
                -- Queue the server to be installed
                requested_server:install()
            end
        end
    end
    -- }}} Setup servers

end -- }}}


return M

