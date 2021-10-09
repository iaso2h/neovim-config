local M = {servers = {}}

M.formatCode = function(vimMode)
    if not vim.bo.modified then return end

    local cmd      = vim.cmd
    local fn       = vim.fn
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
end

M.setupServers = function() -- {{{
    local lspInstall = require("lspinstall")
    local M          = require("config.nvim-lsp")

    lspInstall.setup()
    -- Get all installed servers
    local servers = lspInstall.installed_servers()

    local snippetCapabilities = vim.lsp.protocol.make_client_capabilities()
    snippetCapabilities.textDocument.completion.completionItem.snippetSupport = true
    local basicConfig = {
        -- enable snippet support
        capabilities = require("cmp_nvim_lsp").update_capabilities(snippetCapabilities),
        -- map buffer local keybindings when the language server attaches
        on_attach    = M.onAttach
    }

    local config
    for _, server in pairs(servers) do
        if vim.tbl_contains(vim.tbl_keys(M.servers), server) then

            if server == "lua" then
                config = require("lua-dev").setup{
                    -- lspconfig = M.servers[server]
                }
                config = vim.tbl_deep_extend("force", basicConfig, config)
            else
                config = vim.tbl_deep_extend("force", basicConfig, M.servers[server])
            end

            require("lspconfig")[server].setup(config)
        end
    end
end -- }}}

----
-- Function: onAttach :Mappings or commands need to be loaded when specific LSP is attach
--
-- @param client: language-server client
-- @param bufNr: buffer number
----
M.onAttach = function(client, bufNr) -- {{{
    require("illuminate").on_attach(client)
    bmap(bufNr, "n", [[<A-n>]],   [[:lua require("util").addJump(require("illuminate").next_reference, false, {wrap = true})<CR>]],                 {"silent"})
    bmap(bufNr, "n", [[<A-S-n>]], [[:lua require("util").addJump(require("illuminate").next_reference, false, {reverse = true, wrap = true})<CR>]], {"silent"})
    -- Mappings
    -- bmap(bufNr, "n", [[gd]],        [[:lua require('telescope.builtin').lsp_definitions()<CR>]],           {"silent"})
    -- bmap(bufNr, "n", [[gD]],        [[:lua require('telescope.builtin').lsp_type_definitions()<CR>]],      {"silent"})
    -- bmap(bufNr, "n", [[gR]],        [[:lua require('telescope.builtin').lsp_references()<CR>]],            {"silent"})
    -- bmap(bufNr, "n", [[gi]],        [[:lua require('telescope.builtin').lsp_implementations()<CR>]],       {"silent"})
    bmap(bufNr, "n", [[<C-f>a]],    [[:lua require('telescope.builtin').lsp_code_actions()<CR>]],          {"silent"})
    bmap(bufNr, "n", [[<C-f>o]],    [[:lua require('telescope.builtin').lsp_document_symbols()<CR>]],      {"silent"})
    bmap(bufNr, "n", [[<C-f>O]],    [[:lua require('telescope.builtin').lsp_workspace_symbols()<CR>]],     {"silent"})
    -- bmap(bufNr, "n", [[<leader>e]], [[:lua require('telescope.builtin').lsp_document_diagnostics()<CR>]],  {"silent"})
    -- bmap(bufNr, "n", [[<leader>E]], [[:lua require('telescope.builtin').lsp_workspace_diagnostics()<CR>]], {"silent"})

    bmap(bufNr, "n", [=[gD]=],        [[:lua vim.lsp.buf.declaration()<CR>]],     {"silent"})
    bmap(bufNr, "n", [=[gd]=],        [[:lua vim.lsp.buf.definition()<CR>]],      {"silent"})
    bmap(bufNr, "n", [=[<leader>D]=], [[:lua vim.lsp.buf.type_definition()<CR>]], {"silent"})
    bmap(bufNr, "n", [=[gi]=],        [[:lua vim.lsp.buf.implementation()<CR>]],  {"silent"})
    bmap(bufNr, "n", [=[gR]=],        [[:lua vim.lsp.buf.references()<CR>]],      {"silent"})
    bmap(bufNr, "n", [[K]],           [[:lua vim.lsp.buf.hover()<CR>]],           {"silent"})
    bmap(bufNr, "n", [[<C-p>]],       [[:lua vim.lsp.buf.signature_help()<CR>]],  {"silent"})
    bmap(bufNr, "n", [[<leader>r]],   [[:lua vim.lsp.buf.rename()<CR>]],          {"silent"})
    -- bmap(bufNr, "n", [=[<leader>wa]=], [[:lua vim.lsp.buf.add_workspace_folder()<CR>]],          {"silent"})
    -- bmap(bufNr, "n", [=[<leader>wr]=], [[:lua vim.lsp.buf.remove_workspace_folder()<CR>]],       {"silent"})
    -- bmap(bufNr, "n", [=[<leader>wl]=], [[:lua Print(vim.lsp.buf.list_workspace_folders())<CR>]], {"silent"})
    -- bmap(bufNr, "n", [=[<leader>e]=], [[:lua vim.diagnostic.setqflist()<CR>]],                     {"silent"})
    bmap(bufNr, "n", [[[e]],          [[:lua vim.diagnostic.goto_prev({popup_opts = {border = "rounded"}})<CR>]],                     {"silent"})
    bmap(bufNr, "n", [[]e]],          [[:lua vim.diagnostic.goto_prev({popup_opts = {border = "rounded"}})<CR>]],                     {"silent"})
    bmap(bufNr, "n", [[[E]],          [[:lua vim.diagnostic.goto_prev({popup_opts = {border = "rounded"}, severity = "Error"})<CR>]], {"silent"})
    bmap(bufNr, "n", [[]E]],          [[:lua vim.diagnostic.goto_prev({popup_opts = {border = "rounded"}, severity = "Error"})<CR>]], {"silent"})
    -- Override existing mapping if lsp support
    if client.resolved_capabilities.document_formatting then
        bmap(bufNr, "n", [=[<A-f>]=], [[:lua vim.lsp.buf.formatting()<CR>]],       {"silent"})
    elseif client.resolved_capabilities.document_range_formatting then
        bmap(bufNr, "n", [=[<A-f]=],  [[:lua vim.lsp.buf.range_formatting()<CR>]], {"silent"})
    end
end -- }}}

----
-- Function: M.config: Find and setup configuration for each LSP, including keymaps
----
M.config = function()

local fn  = vim.fn
local cmd = vim.cmd
local lsp = vim.lsp
local lspConfig  = require("lspconfig")
local M          = require("config.nvim-lsp")

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
local border = {
    {"╭", "FloatBorder"},
    {"─", "FloatBorder"},
    {"╮", "FloatBorder"},
    {"│", "FloatBorder"},
    {"╯", "FloatBorder"},
    {"─", "FloatBorder"},
    {"╰", "FloatBorder"},
    {"│", "FloatBorder"}
}
lsp.handlers["textDocument/hover"]         = lsp.with(lsp.handlers.hover,          {border = border})
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {border = border})
-- Format mapping {{{
cmd [[command! -nargs=0 Format lua require("config.nvim-lsp").formatCode("n")]]
map("n", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("n")<CR>]], {"silent"})
map("x", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("v")<CR>]], {"silent"})
-- }}} Format mapping

-- LSP override config {{{
-- Setup() function: https://github.com/neovim/nvim-lspconfig#setup-function
-- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local checkExt = function(serverExec)
    return jit.os == "Windows" and serverExec .. ".cmd" or serverExec
end

-- Python {{{
-- https://github.com/microsoft/pyright
-- npm install -g pyright
-- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
-- https://github.com/microsoft/pyright/blob/96871bec5a427048fead499ab151be87b7baf023/packages/vscode-pyright/package.json

if ex("pyright-langserver") then
    M.servers.python = {
        cmd       = {checkExt("pyright-langserver"), "--stdio" },
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
end
-- }}} Python
-- Lua {{{
-- https://github.com/sumneko/lua-language-server
-- For linux: https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
-- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua
local sumnekoRootPath = fn.glob("~/.config/nvim/lsp/lua-language-server")
local binaryExt       = {macOS = "", Linux = "", Windows = ".exe"}
local sumnekoBinary   = fn.glob(sumnekoRootPath .. "/bin/" .. jit.os .. "/lua-language-server") .. binaryExt[jit.os]
local runtimePath     = vim.split(package.path, ";")
table.insert(runtimePath, "lua/?.lua")
table.insert(runtimePath, "lua/?/init.lua")

if ex(sumnekoBinary) then
    M.servers.lua = {
        cmd = {sumnekoBinary, "-E", sumnekoRootPath .. "/main.lua"};
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
                    -- NOTE: in favor of https://github.com/folke/lua-dev.nvim
                    maxPreload      = 10000,
                    preloadFileSize = 10000,
                    ignoreDir       = {".vscode", ".git"}
                },
            },
        }
    }
end
-- }}} Lua
-- Vimscript {{{
-- npm install -g vim-language-server
vim.g.markdown_fenced_languages = {
      'vim',
      'help'
}
if ex("vim-language-server") then
    M.servers.vim = {
        cmd = {checkExt("vim-language-server"), "--stdio"},
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
end
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
    if jit.os == "Windows" then
        if ex("clangd") then
            table.insert(cmdStr, 1, "clangd")
            return cmdStr
        else
            return ""
        end
    elseif jit.os == "Linux" then
        if ex("clangd-11") then -- The current clangd version. 2021-08-23
            table.insert(cmdStr, 1, "clangd-11")
            return cmdStr
        else
            local clangdVersion = string.match(fn.system[[apt list --installed | grep -Eo "clangd-.."]], "clangd%-%d%d") -- Query installed clangd on Ubuntu
            if not nil then return "" end
            table.insert(cmdStr, 1, clangdVersion)
            return cmdStr
        end
    else
        return ""
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
if ex("vscode-json-language-server") then
    M.servers.json = {
        cmd = {checkExt("vscode-json-language-server"), "--stdio"},
    }
end
if ex("vscode-html-language-server") then
    M.servers.html = {
        cmd = {checkExt("vscode-html-language-server"), "--stdio"},
    }
end
if ex("typescript-language-server") then
    M.servers.typescript = {
        cmd = {checkExt("typescript-language-server"), "--stdio"},
    }
end
if ex("yaml-language-server") then
    M.servers.yaml = {
        cmd = {checkExt("yaml-language-server"), "--stdio"},
    }
end
if ex("vscode-css-language-server") then
    M.servers.css = {
        cmd = {checkExt("vscode-css-language-server"), "--stdio"},
    }
end
if ex("bash-language-server") then
    M.servers.bash = {
        cmd = {checkExt("bash-language-server"), "start"}
    }
end
-- }}} LSP override config

M.setupServers()

end


return M

