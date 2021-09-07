local M = {servers = {}}

M.ex = function(executable) return vim.fn.executable(executable) == 1 end

M.formatCode = function(vimMode)
    if not vim.bo.modified then return end

    cmd "up"
    local cmd      = vim.cmd
    local fn       = vim.fn
    local fileType = vim.bo.filetype
    if vimMode == "n" then
        if fileType == "lua" then
            if not M.ex("lua-format") then return end
            local saveView = fn.winsaveview()
            local flags
            flags = vim.b.luaFormatflags or [[--indent-width=4 --tab-width=4 --continuation-indent-width=4]]
            cmd([[silent %!lua-format % ]] .. flags)
            fn.winrestview(saveView)
        elseif fileType == "json" then
            if not M.ex("js-beautify") then return end
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

-- kabouzeid/nvim-lspinstall {{{
M.setupServers = function()
    local lspInstall = require("lspinstall")

    lspInstall.setup()
    -- Get all installed servers
    local servers = lspInstall.installed_servers()

    local config
    for _, server in pairs(servers) do
        if vim.tbl_contains(vim.tbl_keys(require("config.nvim-lsp").servers), server) then
            config = vim.tbl_extend("force", {}, require("config.nvim-lsp").makeBasicConfig(), require("config.nvim-lsp").servers[server])
        end

        if config then
            require("lspconfig")[server].setup(config)
        end
    end
end
-- }}} kabouzeid/nvim-lspinstall

M.makeBasicConfig = function()
    local snippetCapabilities = vim.lsp.protocol.make_client_capabilities()
    snippetCapabilities.textDocument.completion.completionItem.snippetSupport = true
    -- local capabilities = vim.tbl_deep_extend("keep", {}, lspStatus.capabilities, snippetCapabilities)

    return {
        -- enable snippet support
        capabilities = snippetCapabilities,
        -- map buffer local keybindings when the language server attaches
        on_attach    = require("config.nvim-lsp").onAttach
    }
end

----
-- Function: onAttach :Mappings or commands need to be loaded when specific LSP is attach
--
-- @param client: language-server client
-- @param bufNr: buffer number
----
M.onAttach = function(client, bufNr) -- {{{
    -- Mappings
    bmap(bufNr, "n", [=[gD]=],         [[:lua vim.lsp.buf.declaration()<cr>]],                                {"silent"})
    bmap(bufNr, "n", [=[gd]=],         [[:lua vim.lsp.buf.definition()<cr>]],                                 {"silent"})
    bmap(bufNr, "n", [=[<leader>D]=],  [[:lua vim.lsp.buf.type_definition()<cr>]],                            {"silent"})
    bmap(bufNr, "n", [=[gi]=],         [[:lua vim.lsp.buf.implementation()<cr>]],                             {"silent"})
    bmap(bufNr, "n", [=[gR]=],         [[:lua vim.lsp.buf.references()<cr>]],                                 {"silent"})
    bmap(bufNr, "n", [=[<leader>wa]=], [[:lua vim.lsp.buf.add_workspace_folder()<cr>]],                       {"silent"})
    bmap(bufNr, "n", [=[<leader>wr]=], [[:lua vim.lsp.buf.remove_workspace_folder()<cr>]],                    {"silent"})
    bmap(bufNr, "n", [=[<leader>wl]=], [[:lua Print(vim.lsp.buf.list_workspace_folders())<cr>]], {"silent"})
    bmap(bufNr, "n", [=[<leader>e]=],  [[:lua vim.lsp.diagnostic.set_loclist()<cr>]],                         {"silent"})

    -- Override existing mapping if lsp support
    if client.resolved_capabilities.document_formatting then
        bmap(bufNr, "n", [=[<A-f>]=], [[:lua vim.lsp.buf.formatting()<cr>]],       {"silent"})
    elseif client.resolved_capabilities.document_range_formatting then
        bmap(bufNr, "n", [=[<A-f]=],  [[:lua vim.lsp.buf.range_formatting()<cr>]], {"silent"})
    end

    -- lspsaga.nvim {{{
    bmap(bufNr, "n", [[<C-enter>]],  [[:lua require("lspsaga.codeaction").code_action()<cr>]],           {"silent"})
    bmap(bufNr, "v", [[<C-enter>]],  [[:lua require("lspsaga.codeaction").range_code_action()<cr>]],     {"silent"})
    bmap(bufNr, "n", [[gf]],         [[:lua require("lspsaga.provider").lsp_finder()<cr>]],              {"silent"})
    bmap(bufNr, "n", [[K]],          [[:lua require("lspsaga.hover").render_hover_doc()<cr>]],           {"silent"})
    bmap(bufNr, "n", [[<C-p>]],      [[:lua require("lspsaga.signaturehelp").signature_help()<cr>]],     {"silent"})
    bmap(bufNr, "n", [[<leader>r]],  [[:lua require("lspsaga.rename").rename()<cr>]],                    {"silent"})
    bmap(bufNr, "n", [[<leader>gd]], [[:lua require("lspsaga.provider").preview_definition()<cr>]],      {"silent"})
    bmap(bufNr, "n", [[<leader>E]],  [[:lua require("lspsaga.diagnostic").show_line_diagnostics()<cr>]], {"silent"})

    bmap(bufNr, "n", [[[e]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<cr>]],                     {"silent"})
    bmap(bufNr, "n", [[]e]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<cr>]],                     {"silent"})
    bmap(bufNr, "n", [[[E]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev({severity = "Error"})<cr>]], {"silent"})
    bmap(bufNr, "n", [[]E]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next({severity = "Error"})<cr>]], {"silent"})


    bmap(bufNr, "n", [[<A-d>]], [[v:lua.isFloatWin() ? luaeval('require("lspsaga.action").smart_scroll_with_saga(1)') : "\<PageDown>"]], {"expr"})
    bmap(bufNr, "n", [[<A-e>]], [[v:lua.isFloatWin() ? luaeval('require("lspsaga.action").smart_scroll_with_saga(-1)') : "\<PageUp>"]],  {"expr"})
    -- bmap(bufNr, "n", [[<A-e>]], [[:lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>]],  {"silent", "expr"})
    -- }}} lspsaga.nvim

    -- Set some keybinds conditional on server capabilities

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
    vim.cmd[[
    augroup lspDocumentHighlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]]
    end
end -- }}}

----
-- Function: M.config: Find and setup configuration for each LSP, including keymaps
----
M.config = function()

local fn         = vim.fn
local api        = vim.api
local lspConfig  = require("lspconfig")

-- Format mapping {{{
vim.cmd [[command! -nargs=0 Format lua require("config.nvim-lsp").formatCode("n")]]
map("n", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("n")<cr>]], {"silent"})
map("v", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("v")<cr>]], {"silent"})
-- }}} Format mapping

-- LSP override config {{{
-- Setup() function: https://github.com/neovim/nvim-lspconfig#setup-function
-- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local checkExt = function(serverExec)
    return fn.has('win32') == 1 and serverExec .. ".cmd" or serverExec
end

-- Python {{{
-- https://github.com/microsoft/pyright
-- npm install -g pyright
-- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
-- https://github.com/microsoft/pyright/blob/96871bec5a427048fead499ab151be87b7baf023/packages/vscode-pyright/package.json

if require("config.nvim-lsp").ex("pyright-langserver") then
    require("config.nvim-lsp").servers.python = {
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
local sumneko_root_path
local sumneko_binary
local systemName
local binaryExt = {
    macOS   = "",
    Linux   = "",
    Windows = ".exe"
}
if fn.has("mac") == 1 then
    systemName = "macOS"
elseif fn.has("unix") == 1 then
    systemName = "Linux"
elseif fn.has('win32') == 1 then
    systemName = "Windows"
else
    api.nvim_echo({{"Unsupported system for sumneko", "WarningMsg"}}, true, {})
end

if fn.has("win32") == 1 then
    sumneko_root_path = fn.glob("~/.vscode/extensions/sumneko.lua*", 0, 1)
    if not next(sumneko_root_path) then
        api.nvim_echo({{"Sumneko not found", "WarningMsg"}}, true, {})
    end

    sumneko_root_path = sumneko_root_path[#sumneko_root_path] .. "/server"
    sumneko_binary = sumneko_root_path .. "/bin/".. systemName .. "/lua-language-server" .. binaryExt[systemName]
elseif fn.has("unix") == 1 then
    sumneko_binary = fn.glob("~/.config/nvim/lsp/lua-language-server/bin/Linux/lua-language-server")
    if require("config.nvim-lsp").ex(sumneko_binary) then
        sumneko_root_path = fn.glob("~/.config/nvim/lsp/lua-language-server")
    end
end

if sumneko_root_path then
    require("config.nvim-lsp").servers.lua = {
        cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
        settings = {
            Lua = {
                runtime = {
                    -- For neovim
                    version = 'LuaJIT',
                    -- Setup your lua path
                    path = vim.split(package.path, ';'),
                },
                completion = {
                    callSnippet = "Replace",
                },
                diagnostics = {
                    globals = {'vim'},
                },
                workspace = {
                    library = {
                        [fn.expand('$VIMRUNTIME/lua')]         = true,
                        [fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                    },
                    maxPreload      = 10000,
                    preloadFileSize = 10000,
                    ignoreDir = {".vscode", ".git"}
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
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
if require("config.nvim-lsp").ex("vim-language-server") then
    require("config.nvim-lsp").servers.vim = {
        cmd = {checkExt("vim-language-server"), "--stdio"},
        init_options = {
            isNeovim = true,
            iskeyword = "@,48-57,_,192-255,-#",
            diagnostic = {
                enable = true
            },
            indexes = {
                count = 3,
                gap = 100,
                projectRootPatterns = {"runtime", "nvim", ".git", "autoload", "plugin"},
                runtimepath = true
            },
            runtimepath = "",
            vimruntime = "",
            suggest = {
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
    if fn.has("win32") == 1 then
        if require("config.nvim-lsp").ex("clangd") then
            table.insert(cmdStr, 1, "clangd")
            return cmdStr
        else
            return ""
        end
    elseif fn.has("unix") == 1 then
        if require("config.nvim-lsp").ex("clangd-11") then -- The current clangd version. 2021-08-23
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
    require("config.nvim-lsp").servers.clangd = {
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
-- CCLS {{{
-- https://github.com/MaskRay/ccls
-- if require("config.nvim-lsp").ex("ccls") then
    -- lspConfig.ccls.setup {
        -- cmd = {"ccls"},
        -- on_attach = onAttach,
        -- filetypes = {"c", "cpp", "objc", "objcpp"},
        -- init_options = {
            -- -- capabilities = capabilities,
            -- compilationDatabaseDirectory = "",
            -- clang = {
                -- excludeArgs = {"-frounding-math"},
                -- -- TODO linux
                -- resourceDir = fn.has("win32") == 1 and "D:/LLVM/lib/clang/11.1.0" or ""
            -- },
            -- completion = {
                -- caseSensitivity = 1
            -- },
            -- diagnostics = {
                -- blacklist = {
                -- }
            -- },
            -- index = {
                -- threads = 2,
            -- },
        -- },
        -- root_dir = lspConfig.util.root_pattern(".git", "compile_commands.json", "compile_flags.txt", "build", "README.md", "makefile"),
    -- }
-- end
-- }}} CCLS
-- JSON {{{
-- https://github.com/hrsh7th/vscode-langservers-extracted
-- npm i -g vscode-langservers-extracted
if require("config.nvim-lsp").ex("vscode-json-languageserver") then
    require("config.nvim-lsp").servers.json = {
        cmd = {checkExt("vscode-json-languageserver"), "--stdio"},
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({},{0,0},{fn.line("$"),0})
                end
            }
        },
    }
end
-- }}} JSON
-- HTML {{{
-- https://github.com/hrsh7th/vscode-langservers-extracted
-- npm i -g vscode-langservers-extracted
if require("config.nvim-lsp").ex("html-languageserver") then
    require("config.nvim-lsp").servers.html = {
        cmd = {checkExt("html-languageserver"), "--stdio"},
        init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
                css        = true,
                javascript = true
            },
        },
    }
end
-- }}} HTML
-- TypeScript {{{
-- https://github.com/theia-ide/typescript-language-server
-- npm install -g typescript typescript-language-server
if require("config.nvim-lsp").ex("typescript-language-server") then
    require("config.nvim-lsp").servers.typescript = {
        cmd = {checkExt("typescript-language-server"), "--stdio"},
    }
end
-- }}} TypeScript
-- YAML {{{
-- https://github.com/redhat-developer/yaml-language-server#readme
-- yarn global add yaml-language-server
if require("config.nvim-lsp").ex("yaml-language-server") then
    require("config.nvim-lsp").servers.yaml = {
        cmd = {checkExt("yaml-language-server"), "--stdio"},
    }
end
-- }}} YAML
-- CSS {{{
-- https://github.com/hrsh7th/vscode-langservers-extracted
-- npm i -g vscode-langservers-extracted
if require("config.nvim-lsp").ex("vscode-css-language-server") then
    require("config.nvim-lsp").servers.css = {
        cmd = {checkExt("vscode-css-language-server"), "--stdio"},
    }
end
-- }}} CSS
-- Bash {{{
-- https://github.com/mads-hartmann/bash-language-server
if require("config.nvim-lsp").ex("bash-language-server") then
    require("config.nvim-lsp").servers.bash = {
        cmd = {checkExt("bash-language-server"), "start"}
    }
end

-- }}} Bash
-- }}} LSP override config

require("config.nvim-lsp").setupServers()

end




return M

