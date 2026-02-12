-- https://github.com/neovim/nvim-lspconfig

return function()
    local lspConfig     = require("lspconfig")
    local u             = require("lspconfig.util")
    local icon          = require("icon")

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
                    vim.api.nvim_win_set_cursor(0, { i.lnum, i.col - 1 })
                    vim.cmd [[norm! zv]]
                end, false)
            else
                vim.fn.setqflist({}, "r", { items = tbl.items, title = tbl.title })
                require("buffer.toggle")("quickfix", false)
            end
        end
    end -- }}}

    ---@param args table
    local onAttach      = function(args) -- {{{
        -- Deprecated: local onAttach = function(client, bufNr)

        local bufNr = args.buf

        -- Signature
        require("plugins.nvim-lsp-signature").setup(bufNr)

        -- Mappings

        bmap(bufNr, "n", [[K]], function() vim.lsp.buf.hover { border = _G._float_win_border } end, "Documentation")
        bmap(bufNr, "n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]], { "silent" },
            "LSP workspace symbols")
        bmap(bufNr, "n", [[<C-f><C-o>]], [[<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>]],
            { "silent" },
            "LSP workspace symbols")
        bmap(bufNr, "n", [[<C-f>O]], [[<CMD>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>]],
            { "silent" }, "LSP workspace symbols")

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

        -- bmap(bufNr, {"x", "n"}, [[ga]],  vim.lsp.buf.code_action,    "LSP code action")
        bmap(bufNr, "n", [[<leader>rn]], vim.lsp.buf.rename, "LSP rename")
        bmap(bufNr, "n", [[<F2>]], vim.lsp.buf.rename, "LSP rename")
        bmap(bufNr, "n", [[<C-p>]], vim.lsp.buf.signature_help, "LSP signature help")

        bmap(bufNr, "n", [[<C-q>r]], [[<CMD>lua vim.lsp.buf.references{includeDeclaration=true}<CR>]], { "silent" },
            "LSP references")
        -- bmap(bufNr, "n", [=[<leader>wa]=], vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wr]=], vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
        -- bmap(bufNr, "n", [=[<leader>wl]=], Print(vim.lsp.buf.list_workspace_folders, "LSP list workspace folder")

        -- Bring back the gqq for formatting comments and stuff
        vim.bo.formatexpr = ""
        vim.opt.formatexpr = ""
        bmap(bufNr, "n", [[<A-f>]], function()
            vim.lsp.buf.format()
        end, "Format document")
        bmap(bufNr, "x", [[<A-f>]], function()
            vim.cmd([[noa norm! ]] .. t("<Esc>"))
            vim.lsp.buf.format({
                range = {
                    ["start"] = vim.api.nvim_buf_get_mark(bufNr, "<"),
                    ["end"] = vim.api.nvim_buf_get_mark(bufNr, ">"),
                },
            })
        end, "Format visual selection")
    end -- }}}

    vim.api.nvim_create_autocmd('LspAttach', { callback = onAttach })


    -- LSP servers override {{{
    -- Individual configuration: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md

    -- }}}
    -- Set up servers {{{
    local ok, _ = pcall(require, "cmp_nvim_lsp")
    local cmpCapabilities = ok and require("cmp_nvim_lsp").default_capabilities() or {}
    capabilities = vim.tbl_deep_extend("force", {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            }
        }
    }, cmpCapabilities)

    vim.lsp.config('*', {
        capabilities = capabilities,
        root_markers = { '.git' },
    })
    -- }}} Setup servers

    -- vim.diagnostic setups {{{
    vim.diagnostic.config {
        underline        = true,
        virtual_text     = true,
        update_in_insert = false,
        severity_sort    = true,
        signs            = {
            severity = { min = vim.diagnostic.severity.WARN },
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
