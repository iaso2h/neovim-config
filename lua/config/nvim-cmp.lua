return function()
    local cmp     = require("cmp")
    local luasnip = require("luasnip")

    local configArgs = {
        enabled = function()
            -- Disable it for (telescope)prompt, enable it for dap
            if vim.bo.buftype == "prompt" then
                if package.loaded["dap"] and require("cmp_dap").is_dap_buffer() then
                    return true
                else
                    return false
                end
            end

            -- Disable completion in comments
            local context = require("cmp.config.context")
            if context.in_treesitter_capture("comment")
                or context.in_syntax_group("Comment") then
                return false
            else
                return true
            end
        end,
        preselect        = cmp.PreselectMode.None,
        keyword_length   = 2,
        default_behavior = cmp.ConfirmBehavior.Insert,
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        window = {
            completion = cmp.config.window.bordered{
                winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel',
                col_offset = -3,
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
            ["<C-p>"] = function()
                if cmp.visible() then
                    cmp.select_prev_item()
                end
            end,
            ["<C-n>"] = function()
                if cmp.visible() then
                    cmp.select_next_item()
                end
            end,
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                elseif package.loaded["neogen"] and require("neogen").jumpable() then
                    require("neogen").jump_next()
                else
                    fallback()
                end
            end, {"i", "s"}),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                elseif package.loaded["neogen"] and require("neogen").jumpable() then
                    require("neogen").jump_prev()
                else
                    fallback()
                end
            end, {"i", "s"}),
            ["<C-e>"] = function()
                if cmp.visible() then
                    cmp.abort()
                end
                vim.api.nvim_feedkeys(t"<End>", "n", false)
            end,
            ["<C-i>"] = function()
                if cmp.visible() then
                    require("cmp.utils.autocmd").emit("InsertLeave")
                end
            end,
            ["<CR>"]  = cmp.mapping.confirm{
                select   = true,
                behavior = cmp.ConfirmBehavior.Replace,
            },
        },

        sources = {
            {name = "nvim_lsp"},
            {name = "buffer"},
            {name = "path"},
            -- {name = "cmd_line"},
            {name = "luasnip"},
            {name = "cmp_tabnine"},
        },

        formatting = {
            fields = {"kind", "abbr", "menu"},
            format = function(entry, vimItem)
                local maxWidth = 40
                if #vimItem.abbr > maxWidth then
                    vimItem.abbr = string.sub(vimItem.abbr, 1, maxWidth - 1) .. require("util.icon").ui.Ellipsis
                end
                vimItem.menu = vimItem.kind
                vimItem.kind = require("util.icon").kind[vimItem.kind]
                -- vimItem.menu = ({
                    -- nvim_lsp    = "[LSP]",
                    -- buffer      = "[Buffer]",
                    -- path        = "[Path]",
                    -- luasnip     = "[LuaSnip]",
                    -- cmp_tabnine = "[Tabnine]",
                -- })[entry.source.name]
                return vimItem
            end
        },
    }
-- If you want insert `(` after select function or method item

    cmp.setup(configArgs)
    cmp.setup.filetype(
        {"dap-repl", "dapui_watches"},
        {
            sources = {
                -- HACK: Not work for lua dapter yet?
                { name = "dap" },
            },
        }
    )

    local cmpAutopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on(
        "confirm_done",
        cmpAutopairs.on_confirm_done()
    )

end

