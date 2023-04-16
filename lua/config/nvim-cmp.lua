return function()
    local cmp     = require("cmp")
    local luasnip = require("luasnip")

    local configArgs = { -- {{{
        enabled = function()
            -- Disable it for (telescope)prompt, enable it for dap
            if vim.bo.buftype == "prompt" then
                if package.loaded["dap"] and package.loaded["cmp_dap"] and
                        require("cmp_dap").is_dap_buffer() then
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
        keyword_length   = 3,
        default_behavior = cmp.ConfirmBehavior.Insert,
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
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
            ["<CR>"] = cmp.mapping.confirm {
                select   = true,
                behavior = cmp.ConfirmBehavior.Replace,
            }
        },

        sources = {
            {name = "nvim_lsp"},
            {name = "buffer"},
            {name = "path"},
            {name = 'conjure'},
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
    } -- }}}

    cmp.setup(configArgs)

    local cmpAutopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on(
        "confirm_done",
        cmpAutopairs.on_confirm_done()
    )

    -- Mapping {{{
    local cursorWithinSnippet = function()
        local session = require("luasnip.session")
        -- check if the cursor on a row inside a snippet.
        local node = session.current_nodes[vim.api.nvim_get_current_buf()]
        if not node then
            return false
        end
        local snippet = node.parent.snippet
        local ok, snip_begin_pos, snip_end_pos = pcall(
            snippet.mark.pos_begin_end, snippet.mark)
        if not ok then
            -- if there was an error getting the position, the snippets text was
            -- most likely removed, resulting in messed up extmarks -> error.
            -- remove the snippet.
            luasnip.unlink_current()
            return false
        end
        local cursorPos = vim.api.nvim_win_get_cursor(0)
        cursorPos = {cursorPos[1] - 1, cursorPos[2]}
        if cursorPos[1] < snip_begin_pos[1] or cursorPos[1] >snip_end_pos[1] then
            return false
        elseif cursorPos[1] == snip_begin_pos[1] and cursorPos[2] < snip_begin_pos[2] or
            cursorPos[1] == snip_end_pos[1] and cursorPos[2] > snip_end_pos[2] then
            return false
        else
            local charBeforeCursor = vim.api.nvim_buf_get_text(
                0,
                cursorPos[1],
                0,
                cursorPos[1],
                cursorPos[2],
                {})[1]
            if charBeforeCursor:match("^%s*$") then
                -- Has leading spaces
                return false
            else
                return true
            end
        end
    end


    local mapArgs = {
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
        ["<Tab>"] = {function()
            if (luasnip.jumpable() and cursorWithinSnippet()) or
                    (luasnip.expandable() and cursorWithinSnippet()) then
                luasnip.expand_or_jump()
            elseif package.loaded["neogen"] and require("neogen").jumpable() then
                require("neogen").jump_next()
            else
                vim.api.nvim_feedkeys(t"<Tab>", "n", false)
            end
        end, {"i", "s"}},
        ["<S-Tab>"] = {function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            elseif package.loaded["neogen"] and require("neogen").jumpable() then
                require("neogen").jump_prev()
            else
                vim.cmd("norm! " .. t("<S-Tab>"))
            end
        end, {"i", "s"}},
        ["<C-e>"] = function()
            if cmp.visible() then
                require("cmp.utils.autocmd").emit("InsertLeave")
            end
            vim.api.nvim_feedkeys(t"<End>", "n", false)
        end,
        ["<C-o>"] = function()
            if cmp.visible() then
                require("cmp.utils.autocmd").emit("InsertLeave")
            end
        end,
    }


    for lhs, rhs in pairs(mapArgs) do
        if type(rhs) == "table" then
            map(rhs[2], lhs, rhs[1], "which_key_ignore")
        else
            map({"i", "s"}, lhs, rhs, "which_key_ignore")
        end
    end
    -- }}} Mapping

end

