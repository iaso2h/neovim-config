-- TODO: tabnine priority
return function()
    local completionItemKind = {
        -- -- UbuntuMono
        -- Text          = "",
        -- Method        = "",
        -- Function      = "",
        -- Constructor   = "",
        -- Field         = "ﰠ",
        -- Variable      = "",
        -- Class         = "ﴯ",
        -- Interface     = "",
        -- Module        = "",
        -- Property      = "ﰠ",
        -- Unit          = "塞",
        -- Value         = "",
        -- Enum          = "",
        -- Keyword       = "",
        -- Snippet       = "",
        -- Color         = "",
        -- File          = "",
        -- Reference     = "",
        -- Folder        = "",
        -- EnumMember    = "",
        -- Constant      = "",
        -- Struct        = "",
        -- Event         = "",
        -- Operator      = "",
        -- TypeParameter = "",
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "ﴯ",
        Interface = "",
        Module = "",
        Property = "ﰠ",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = ""
        -- VS Code
        -- Text = '  ',
        -- Method = '  ',
        -- Function = '  ',
        -- Constructor = '  ',
        -- Field = '  ',
        -- Variable = '  ',
        -- Class = '  ',
        -- Interface = '  ',
        -- Module = '  ',
        -- Property = '  ',
        -- Unit = '  ',
        -- Value = '  ',
        -- Enum = '  ',
        -- Keyword = '  ',
        -- Snippet = '  ',
        -- Color = '  ',
        -- File = '  ',
        -- Reference = '  ',
        -- Folder = '  ',
        -- EnumMember = '  ',
        -- Constant = '  ',
        -- Struct = '  ',
        -- Event = '  ',
        -- Operator = '  ',
        -- TypeParameter = '  ',
}

    local cmp     = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup{

        enabled = function()
            -- Disable for (telescope)prompt
            if vim.bo.buftype == "prompt" then
                return false
            end
            -- Disable completion in comments
            local context = require("cmp.config.context")
            -- keep command mode completion enabled when cursor is in a comment
            if vim.api.nvim_get_mode().mode == 'c' then
                return true
            else
                return not context.in_treesitter_capture("comment")
                and not context.in_syntax_group("Comment")
            end
        end,
        completion = {
            completeopt = "menu,menuone,noinsert",
        },
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        window = {
            completion = cmp.config.window.bordered{
                winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel',
                scrollbar = {
                    thumb_char = "│",
                    position = "edge",
                },
            },
            documentation = cmp.config.window.bordered{
                winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
            }
        },
        mapping = {
            ["<A-e>"] = cmp.mapping.scroll_docs(-4),
            ["<A-d>"] = cmp.mapping.scroll_docs(4),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if package.loaded["neogen"] and require("neogen").jumpable() then
                    vim.api.nvim_feedkeys(t[[<cmd>lua require("neogen").jump_next()<CR>]], "", true)
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, {"i", "s"}),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if package.loaded["neogen"] and require("neogen").jumpable() then
                    vim.api.nvim_feedkeys(t[[<cmd>lua require("neogen").jump_prev()<CR>]], "", true)
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, {"i", "s"}),
            ["<C-Space>"] = function(_)
                if cmp.visible() then
                    require("cmp.utils.autocmd").emit("InsertLeave")
                else
                    -- TODO: better trigger mechanics
                    vim.api.nvim_feedkeys(t"<C-n>", "n", true)

                end
            end,
            ["<C-i>"] = function(fallback)
                if cmp.visible() then
                    require("cmp.utils.autocmd").emit("InsertLeave")
                else
                    fallback()
                end
            end,
            ["<C-e>"] = function(_)
                if cmp.visible() then
                    cmp.abort()
                end
                vim.api.nvim_feedkeys(t"<End>", "n", true)
            end,
            ["<CR>"]  = cmp.mapping.confirm{
                select   = true,
                behavior = cmp.ConfirmBehavior.Replace,
            },
            ["<C-CR>"] = function()
                if cmp.visible() then
                    cmp.abort()
                    vim.api.nvim_feedkeys("o", "n", true)
                else
                    vim.api.nvim_feedkeys("<CR>", "n", true)
                end
            end
        },

        sources = {
            {name = "nvim_lsp"},
            {name = "buffer"},
            {name = "path"},
            {name = "luasnip"},
            {name = "cmp_tabnine"},
        },

        formatting = {
            format = function(entry, vimItem)
                vimItem.kind = completionItemKind[vimItem.kind] .. " " .. vimItem.kind
                vimItem.menu = ({
                    nvim_lsp    = "[LSP]",
                    buffer      = "[Buffer]",
                    path        = "[Path]",
                    luasnip     = "[LuaSnip]",
                    cmp_tabnine = "[Tabnine]",
                })[entry.source.name]
                return vimItem
            end
        },
        keyword_length   = 2,
        default_behavior = cmp.ConfirmBehavior.Replace,
    }
end

