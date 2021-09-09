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
            -- {name = "nvim_lua"},
            {name = "buffer"},
            {name = "spell"},
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
                    spell       = "[Spell]",
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
        documentation = {
            border = "none",
        },
        mapping = {
            ['<A-e>'] = cmp.mapping.scroll_docs(-4),
            ['<A-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if vim.fn.pumvisible() == 1 then
                    vim.fn.feedkeys(t"<C-S-]>")
                elseif vim.fn['vsnip#available']() == 1 then
                    vim.fn.feedkeys(t"<Plug>(vsnip-expand-or-ump)")
                else
                    fallback()
                end
            end, {"i", "s"}),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if vim.fn.pumvisible() == 1 then
                    vim.fn.feedkeys(t"<C-S-[>")
                elseif vim.fn['vsnip#available']() == 1 then
                    vim.fn.feedkeys(t"<Plug>(vsnip-jump-prev)")
                else
                    fallback()
                end
            end, {"i", "s"}),
            ['<C-Space>'] = function(fallback)
                if vim.fn.pumvisible() == 1 then
                    -- vim.fn.feedkeys(t"<C-e>")
                    cmp.mapping.complete()
                else
                    cmp.abort()
                end
            end,
            -- ['<C-e>'] = cmp.mapping.close(),
            ['<C-e>'] = function(fallback)
                if vim.fn.pumvisible() == 1 then
                    cmp.abort()
                end
                vim.fn.feedkeys(t"<End>")
            end,
            ['<CR>']  = cmp.mapping.confirm{
                select   = true,
                behavior = cmp.ConfirmBehavior.Replace,
            }
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

