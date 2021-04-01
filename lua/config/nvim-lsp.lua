local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local bmap = require("util").bmap
local lspConfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true


----
-- Function: onAttach :Mappings or commands need to be loaded when specific LSP is attach
--
-- @param client: ___
-- @param bufNr:  ___
----
local onAttach  = function(client, bufNr)
    -- api.nvim_buf_set_option(bufNr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    bmap(bufNr, "n", [=[gD]=],         [[:lua vim.lsp.buf.declaration()<cr>]],                                {"silent"})
    bmap(bufNr, "n", [=[gd]=],         [[:lua vim.lsp.buf.definition()<cr>]],                                 {"silent"})
    bmap(bufNr, "n", [=[gi]=],         [[:lua vim.lsp.buf.implementation()<cr>]],                             {"silent"})
    bmap(bufNr, "n", [=[<leader>wa]=], [[:lua vim.lsp.buf.add_workspace_folder()<cr>]],                       {"silent"})
    bmap(bufNr, "n", [=[<leader>wr]=], [[:lua vim.lsp.buf.remove_workspace_folder()<cr>]],                    {"silent"})
    bmap(bufNr, "n", [=[<leader>wl]=], [[:lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>]], {"silent"})
    bmap(bufNr, "n", [=[gR]=],         [[:lua vim.lsp.buf.references()<cr>]],                                 {"silent"})
    bmap(bufNr, "n", [=[<leader>D]=],  [[:lua vim.lsp.buf.type_definition()<cr>]],                            {"silent"})
    bmap(bufNr, "n", [=[<leader>q]=],  [[:lua vim.lsp.diagnostic.set_loclist()<cr>]],                         {"silent"})

    -- lspsaga.nvim {{{
    bmap(bufNr, "n", [[gF]],         [[:lua require'lspsaga.provider'.lsp_finder()<cr>]],                 {"silent"})
    bmap(bufNr, "n", [[<C-enter>]],  [[:lua require('lspsaga.codeaction').code_action()<cr>]],            {"silent"})
    bmap(bufNr, "v", [[<C-enter>]],  [[:lua require('lspsaga.codeaction').range_code_action()<cr>]],      {"silent"})
    bmap(bufNr, "n", [[K]],          [[:lua require('lspsaga.hover').render_hover_doc()<cr>]],            {"silent"})
    bmap(bufNr, "n", [[<A-d>]],      [[:lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>]],    {"silent"})
    bmap(bufNr, "n", [[<A-e>]],      [[:lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>]],   {"silent"})
    bmap(bufNr, "n", [[<C-p>]],      [[:lua require('lspsaga.signaturehelp').signature_help()<cr>]],      {"silent"})
    bmap(bufNr, "n", [[<leader>r]],  [[:lua require('lspsaga.rename').rename()<cr>]],                     {"silent"})
    bmap(bufNr, "n", [[<leader>gd]], [[:lua require'lspsaga.provider'.preview_definition()<cr>]],         {"silent"})
    bmap(bufNr, "n", [[<leader>e]],  [[:lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<cr>]],  {"silent"})
    bmap(bufNr, "n", [[<leader>E]],  [[:lua require'lspsaga.diagnostic'.show_line_diagnostics()<cr>]],    {"silent"})
    bmap(bufNr, "n", [[[e]],         [[:lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<cr>]], {"silent"})
    bmap(bufNr, "n", [[]e]],         [[:lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<cr>]], {"silent"})
    -- }}} lspsaga.nvim

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        map("n", [[<A-f>]], [[:lua vim.lsp.buf.formatting()<cr>]], {"silent"})
    elseif client.resolved_capabilities.document_range_formatting then
        map("n", [[<A-f>]], [[:lua vim.lsp.buf.range_formatting()<cr>]], {"silent"})
    end

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
-- Python {{{
lspConfig.pyright.setup{
    capabilities = capabilities,
    on_attach    = onAttach
}
-- }}} Python
-- Lua {{{
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
                diagnostics = {
                    enable  = true,
                    globals = {'vim'},
                },
                workspace = {
                    library = {
                        [fn.expand('$VIMRUNTIME/lua')] = true,
                        [fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                    },
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
vim.g.markdown_fenced_languages = {
      'vim',
      'help'
}
lspConfig.vimls.setup{
    cmd = {"vim-language-server", "--stdio"},
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
lspConfig.ccls.setup {
    cmd = {"ccls"},
    on_attach = onAttach,
    filetypes = {"c", "cpp", "objc", "objcpp"},
    init_options = {
        -- capabilities = capabilities,
        compilationDatabaseDirectory = "build",
        index = {
            threads = 3,
        },
        clang = {
            excludeArgs = {"-frounding-math"},
        },
    },
    root_dir = lspConfig.util.root_pattern(".git", "compile_commands.json", "compile_flags.txt", "build", "README.md", "makefile"),
}
-- }}} CCLS
-- JSON {{{
lspConfig.jsonls.setup {
    commands = {
        Format = {
            function()
                vim.lsp.buf.range_formatting({},{0,0},{fn.line("$"),0})
            end
        }
    },
    capabilities = capabilities,
    on_attach = onAttach
}
-- }}} JSON
-- HTML {{{
--Enable (broadcasting) snippet capability for completion

lspConfig.html.setup {
    capabilities = capabilities,
    cmd = {"html-languageserver", "--stdio"},
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
    warn_sign             = "💡",
    hint_sign             = "🔎",
    infor_sign            = "⚠️",
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

