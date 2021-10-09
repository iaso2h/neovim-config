-- TODO: tabnine priority
return function()
    local completionItemKind = {
        -- Sarasa Mono Nerd
        -- Text          = "",
        -- Function      = "",
        -- Method        = "",
        -- Constructor   = "",
        -- Field         = "",
        -- Variable      = "",
        -- Class         = "",
        -- Interface     = "",
        -- Module        = "",
        -- Property      = "",
        -- Unit          = "",
        -- Value         = "",
        -- Enum          = "",
        -- Keyword       = "",
        -- Snippet       = "",
        -- Color         = "",
        -- File          = "",
        -- Reference     = "",
        -- Folder        = "",
        -- EnumMember    = "",
        -- Constant      = "",
        -- Struct        = "",
        -- Event         = "",
        -- Operator      = "⨋",
        -- TypeParameter = "",

        -- UbuntuMono
        Text          = "",
        Method        = "",
        Function      = "",
        Constructor   = "",
        Field         = "ﰠ",
        Variable      = "",
        Class         = "ﴯ",
        Interface     = "",
        Module        = "",
        Property      = "ﰠ",
        Unit          = "塞",
        Value         = "",
        Enum          = "",
        Keyword       = "",
        Snippet       = "",
        Color         = "",
        File          = "",
        Reference     = "",
        Folder        = "",
        EnumMember    = "",
        Constant      = "",
        Struct        = "",
        Event         = "",
        Operator      = "",
        TypeParameter = ""
}

    local cmp = require("cmp")
    cmp.setup{
        sources = {
            {name = "nvim_lsp"},
            {name = "nvim_lua"},
            {name = "buffer"},
            {name = "path"},
            {name = "vsnip"},
            {name = "cmp_tabnine"},
        },
        formatting = {
            format = function(entry, vimItem)
                vimItem.kind = completionItemKind[vimItem.kind] .. " " .. vimItem.kind
                vimItem.menu = ({
                    nvim_lsp    = "[LSP]",
                    nvim_lua    = "[Lua]",
                    buffer      = "[Buffer]",
                    path        = "[Path]",
                    vsnip       = "[VSnip]",
                    cmp_tabnine = "[Tabnine]",
                })[entry.source.name]
                return vimItem
            end
        },
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end,
        },
        preselect = cmp.PreselectMode.Item,
        documentation = {
            border = "rounded",
        },
        experimental = {
            ghost_text = true,
            cusom_menu = true,
        },
        mapping = {
            ["<A-e>"] = cmp.mapping.scroll_docs(-4),
            ["<A-d>"] = cmp.mapping.scroll_docs(4),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if package.loaded["neogen"] and require("neogen").jumpable() then
                    vim.api.nvim_feedkeys(t[[<cmd>lua require("neogen").jump_next()<CR>]], "", true)
                elseif vim.fn["vsnip#jumpable"](1) == 1 then
                    -- NOTE: maybe use "<Plug>(vsnip-jump-or-expand)" instead when cmp support <tab>
                    -- key to expand snippet provided by LSP?
                    vim.api.nvim_feedkeys(t"<Plug>(vsnip-jump-next)", "", true)
                -- elseif cmp.visible() then
                -- else
                    -- vim.api.nvim_feedkeys(t"<Plug>(Tabout)", "", true)
                else
                    fallback()
                end
            end, {"i", "s"}),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if vim.fn["vsnip#jumpable"](-1) == 1 then
                    vim.api.nvim_feedkeys(t"<Plug>(vsnip-jump-prev)", "", true)
                -- elseif cmp.visible() then
                -- else
                    -- vim.api.nvim_feedkeys(t"<Plug>(TaboutBack)", "", true)
                else
                    fallback()
                end
            end, {"i", "s"}),
            ["<C-Space>"] = function(fallback)
                -- cmp.mapping.complete()
                if cmp.visible() then
                    cmp.abort()
                else
                    vim.api.nvim_feedkeys(t"<C-n>", "n", true)
                end
            end,
            -- ["<C-e>"] = cmp.mapping.close(),
            ["<C-e>"] = function(fallback)
                if cmp.visible() then
                    cmp.abort()
                end
                vim.api.nvim_feedkeys(t"<End>", "n", true)
            end,
            ["<CR>"]  = cmp.mapping.confirm{
                select   = true,
                behavior = cmp.ConfirmBehavior.Replace,
            },
        },
        keyword_length   = 2,
        default_behavior = cmp.ConfirmBehavior.Replace,
    }

    require("nvim-autopairs.completion.cmp").setup{
        map_cr       = true,
        map_complete = true,
        auto_select  = true
    }
end

