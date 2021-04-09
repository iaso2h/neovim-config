local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local bmap = require("util").bmap
local lspConfig = require('lspconfig')
-- local lspStatus = require('lsp-status')
local M = {}
require("config.lsp-status-nvim").setup()


local snippetCapabilities = vim.lsp.protocol.make_client_capabilities()
snippetCapabilities.textDocument.completion.completionItem.snippetSupport = true
local capabilities = snippetCapabilities
-- local capabilities = vim.tbl_deep_extend("keep", {}, lspStatus.capabilities, snippetCapabilities)


-- Gerneral format mapping {{{
function M.formatCode(vimMode)
    cmd "up"
    local fileType = vim.bo.filetype
    if vimMode == "n" then
        if fileType == "lua" then
            local saveView = fn.winsaveview()
            local flags
            flags = vim.b.luaFormatflags or [[--indent-width=4 --tab-width=4 --continuation-indent-width=4]]
            cmd([[silent %!lua-format % ]] .. flags)
            fn.winrestview(saveView)
        elseif fileType == "json" then
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
map("n", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("n")<cr>]], {"silent"})
map("v", [[<A-f>]], [[:lua require("config.nvim-lsp").formatCode("v")<cr>]], {"silent"})
-- }}} Gerneral format mapping

----
-- Function: onAttach :Mappings or commands need to be loaded when specific LSP is attach
--
-- @param client: ___
-- @param bufNr:  ___
----
local onAttach  = function(client, bufNr)
    -- lspStatus.on_attach(client)

    -- Mappings
    bmap(bufNr, "n", [=[gD]=],         [[:lua vim.lsp.buf.declaration()<cr>]],                                {"silent"})
    bmap(bufNr, "n", [=[gd]=],         [[:lua vim.lsp.buf.definition()<cr>]],                                 {"silent"})
    bmap(bufNr, "n", [=[<leader>D]=],  [[:lua vim.lsp.buf.type_definition()<cr>]],                            {"silent"})
    bmap(bufNr, "n", [=[gi]=],         [[:lua vim.lsp.buf.implementation()<cr>]],                             {"silent"})
    function M.references()
        vim.lsp.buf.references()
        require("buffer").quickfixToggle()
    end
    bmap(bufNr, "n", [=[gR]=],         [[:lua vim.lsp.buf.references()<cr>]],                                 {"silent"})
    bmap(bufNr, "n", [=[<leader>wa]=], [[:lua vim.lsp.buf.add_workspace_folder()<cr>]],                       {"silent"})
    bmap(bufNr, "n", [=[<leader>wr]=], [[:lua vim.lsp.buf.remove_workspace_folder()<cr>]],                    {"silent"})
    bmap(bufNr, "n", [=[<leader>wl]=], [[:lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>]], {"silent"})
    bmap(bufNr, "n", [=[<leader>e]=],  [[:lua vim.lsp.diagnostic.set_loclist()<cr>]],                         {"silent"})

    -- Override existing mapping if lsp support
    if client.resolved_capabilities.document_formatting then
        bmap(bufNr, "n", [=[<A-f>]=], [[:lua vim.lsp.buf.formatting()<cr>]],       {"silent"})
    elseif client.resolved_capabilities.document_range_formatting then
        bmap(bufNr, "n", [=[<A-f]=],  [[:lua vim.lsp.buf.range_formatting()<cr>]], {"silent"})
    end

    -- lspsaga.nvim {{{
    -- BUG: break in new version of newovim
    bmap(bufNr, "n", [[gF]],         [[:lua require("lspsaga.provider").lsp_finder()<cr>]],                 {"silent"})
    bmap(bufNr, "n", [[<C-enter>]],  [[:lua require("lspsaga.codeaction").code_action()<cr>]],              {"silent"})
    bmap(bufNr, "v", [[<C-enter>]],  [[:lua require("lspsaga.codeaction").range_code_action()<cr>]],        {"silent"})
    bmap(bufNr, "n", [[K]],          [[:lua require("lspsaga.hover").render_hover_doc()<cr>]],              {"silent"})
    bmap(bufNr, "n", [[<A-d>]],      [[:lua require("lspsaga.action").smart_scroll_with_saga(1)<cr>]],      {"silent"})
    bmap(bufNr, "n", [[<A-e>]],      [[:lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>]],     {"silent"})
    bmap(bufNr, "n", [[<C-p>]],      [[:lua require("lspsaga.signaturehelp").signature_help()<cr>]],        {"silent"})
    bmap(bufNr, "n", [[<leader>r]],  [[:lua require("lspsaga.rename").rename()<cr>]],                       {"silent"})
    bmap(bufNr, "n", [[<leader>gd]], [[:lua require("lspsaga.provider").preview_definition()<cr>]],         {"silent"})
    bmap(bufNr, "n", [[<leader>E]],  [[:lua require("lspsaga.diagnostic").show_line_diagnostics()<cr>]],    {"silent"})

    bmap(bufNr, "n", [[[e]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<cr>]],                     {"silent"})
    bmap(bufNr, "n", [[]e]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<cr>]],                     {"silent"})
    bmap(bufNr, "n", [[[E]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev({severity = "Error"})<cr>]], {"silent"})
    bmap(bufNr, "n", [[]E]], [[:lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next({severity = "Error"})<cr>]], {"silent"})
    -- }}} lspsaga.nvim

    -- Set some keybinds conditional on server capabilities

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
    augroup lspDocumentHighlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]], false)
    end
end

-- LSP config {{{
-- Setup() function: https://github.com/neovim/nvim-lspconfig#setup-function
-- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local checkExt = function(langServer)
    return vim.fn.has('win32') == 1 and langServer .. ".cmd" or langServer
end

-- Python {{{
-- https://github.com/microsoft/pyright
-- npm i -g pyright
-- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
-- https://github.com/microsoft/pyright/blob/96871bec5a427048fead499ab151be87b7baf023/packages/vscode-pyright/package.json
lspConfig.pyright.setup{
    capabilities = capabilities,
    on_attach    = onAttach,
    setting      = {
        python = {
            pythonPath = "python",
            venvPath = "",
            analysis = {
                diagnosticMode = "openFileOnly",
                extraPaths = "",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = false
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
    print("Unsupported system for sumneko")
end

local findSumnekoLua = function()
    sumneko_root_path = fn.glob("~/.vscode/extensions/sumneko.lua*", 0, 1)
    if not next(sumneko_root_path) then
        print("Sumneko not found")
        return
    end
    sumneko_root_path = sumneko_root_path[#sumneko_root_path] .. "/server"
    sumneko_binary = sumneko_root_path .. "/bin/".. systemName .. "/lua-language-server" .. binaryExt[systemName]
end

findSumnekoLua()

if sumneko_root_path then
    require("lspconfig").sumneko_lua.setup {
        cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
        capabilities = capabilities,
        on_attach = onAttach,
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
                    enable  = true,
                    globals = {'vim'},
                },
                workspace = {
                    library = {
                        [fn.expand('$VIMRUNTIME/lua')] = true,
                        [fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                    },
                    -- maxPreload = 2000,
                    -- preloadFileSize = 1000,
                    ignoreDir = {".vscode", ".git"}
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    }
end
-- }}} Lua
-- Vimscript {{{
-- npm install -g vim-language-server
vim.g.markdown_fenced_languages = {
      'vim',
      'help'
}
lspConfig.vimls.setup{
    cmd = {checkExt("vim-language-server"), "--stdio"},
    capabilities = capabilities,
    on_attach = onAttach,
    filetypes = {"vim"},
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
    root_dir = function(fname)
          return lspConfig.util.find_git_ancestor(fname) or fn.getcwd()
    end,
}
-- }}} Vimscript
-- CCLS {{{
-- https://github.com/MaskRay/ccls
lspConfig.ccls.setup {
    cmd = {"ccls"},
    on_attach = onAttach,
    filetypes = {"c", "cpp", "objc", "objcpp"},
    init_options = {
        -- capabilities = capabilities,
        compilationDatabaseDirectory = "",
        clang = {
            excludeArgs = {"-frounding-math"},
            -- TODO linux
            resourceDir = fn.has("win32") == 1 and "D:/LLVM/lib/clang/11.1.0" or ""
        },
        completion = {
            caseSensitivity = 1
        },
        diagnostics = {
            blacklist = {
            }
        },
        index = {
            threads = 2,
        },
    },
    root_dir = lspConfig.util.root_pattern(".git", "compile_commands.json", "compile_flags.txt", "build", "README.md", "makefile"),
}
-- }}} CCLS
-- JSON {{{
-- https://github.com/vscode-langservers/vscode-json-languageserver
-- npm install -g vscode-json-languageserver
lspConfig.jsonls.setup {
    cmd = {checkExt("vscode-json-languageserver"), "--stdio"},
    filetypes = {"json"},
    init_options = {
        provideFormatter = true
    },
    commands = {
        Format = {
            function()
                vim.lsp.buf.range_formatting({},{0,0},{fn.line("$"),0})
            end
        }
    },
    capabilities = capabilities,
    on_attach = onAttach,
    root_dir = lspConfig.util.root_pattern(".git", vim.fn.getcwd())
}
-- }}} JSON
-- HTML {{{
-- npm install -g vscode-html-languageserver-bin
lspConfig.html.setup {
    capabilities = capabilities,
    cmd = {checkExt("html-languageserver"), "--stdio"},
    on_attach = onAttach,
    filetypes = {"html"},
    init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = {
            css = true,
            javascript = true
        },
    },
    root_dir = function(fname)
          return lspConfig.util.find_git_ancestor(fname) or fn.getcwd()
    end,
    settings = {}
}
-- }}} HTML
-- TypeScript {{{
-- npm install -g typescript typescript-language-server
require'lspconfig'.tsserver.setup{
    cmd = {"typescript-language-server", "--stdio"},
    capabilities = capabilities,
    on_attach = onAttach,
    filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
    root_dir = lspConfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")
}
-- }}} TypeScript
-- }}} LSP config

-- glepnir/lspsaga.nvim {{{
local saga = require 'lspsaga'

saga.init_lsp_saga {
    use_saga_diagnostic_sign = true,
    error_sign            = "❌",
    warn_sign             = "⚠️",
    hint_sign             = "💡",
    infor_sign            = "🔎",
    dianostic_header_icon = '   ',
    code_action_icon      = ' ',
    code_action_prompt = {
        enable        = true,
        sign          = false,
        sign_priority = 20,
        virtual_text  = true,
    },
    finder_definition_icon = '  ',
    finder_reference_icon  = '  ',
    max_preview_lines = 10,
    finder_action_keys = {
        open = 'o', vsplit = 'v',split = 's',quit = 'q',scroll_down = '<A-d>', scroll_up = '<A-e>'
    },
    code_action_keys = {
        quit = 'q',exec = '<CR>'
    },
    rename_action_keys = {
        quit = '<C-c>',exec = '<CR>'
    },
    definition_preview_icon = '  ',
    -- 1: thin border | 2: rounded border | 3: thick border | 4: ascii border
    border_style = 2,
    rename_prompt_prefix = '>>>',
    -- server_filetype_map = {}
}
-- }}} glepnir/lspsaga.nvim

-- keymaps
-- local onAttach = function(client, bufNr)
    -- vim.api.nvim_buf_set_option(bufNr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    -- -- Mappings.
    -- local opts = { noremap=true, silent=true}

-- end

-- -- Configure lua language server for neovim development
-- local luaSettings = {
    -- Lua = {
        -- runtime = {
            -- -- LuaJIT in the case of Neovim
            -- version = 'LuaJIT',
            -- path = vim.split(package.path, ';'),
        -- },
        -- diagnostics = {
            -- -- Get the language server to recognize the `vim` global
            -- globals = {'vim'},
        -- },
        -- workspace = {
            -- -- Make the server aware of Neovim runtime files
            -- library = {
                -- [fn.expand('$VIMRUNTIME/lua')] = true,
                -- [fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            -- },
        -- },
    -- }
-- }

-- -- config that activates keymaps and enables snippet support
-- local makeConfig = function()
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities.textDocument.completion.completionItem.snippetSupport = true
    -- return {
        -- -- enable snippet support
        -- capabilities = capabilities,
        -- -- map buffer local keybindings when the language server attaches
        -- on_attach = onAttach,
    -- }
-- end

-- -- lsp-install
-- local function setup_servers()
    -- require('lspinstall').setup()

    -- -- get all installed servers
    -- local servers = require('lspinstall').installed_servers()
    -- -- ... and add manually installed servers
    -- table.insert(servers, "pyright")

    -- for _, server in pairs(servers) do
        -- local config = makeConfig()

        -- -- language specific config
        -- if server == "lua" then
            -- config.settings = luaSettings
            -- config.filetypes = {"lua"}
        -- end
    -- end

    -- if server == "clangd" then
        -- config.filetypes = {"c", "cpp"} -- we don't want objective-c and objective-cpp!
    -- end

    -- require'lspconfig'[server].setup(config)
-- end

-- setup_servers()

-- -- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
-- require'lspinstall'.post_install_hook = function ()
    -- setup_servers() -- reload installed servers
    -- vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
-- end
return M

