return function()
    require("Comment").setup {
        ---Add a space b/w comment and the line
        padding = true,
        ---Whether the cursor should stay at its position
        sticky = true,
        ---Lines to be ignored while (un)comment
        ignore = "^%s*$",
        mappings = {
            ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
            basic = false,
            ---Extra mapping; `gco`, `gcO`, `gcA`
            extra = false,
        },
    }
    map("n", [[gc]], [[<Plug>(comment_toggle_linewise)]],  "Comment toggle linewise")
    map("x", "C", "<Plug>(comment_toggle_linewise_visual)", "Comment toggle linewise (visual)")

    map("n", [[gcc]], function()
        return vim.v.count == 0 and t"<Plug>(comment_toggle_linewise_current)"
            or t"<Plug>(comment_toggle_linewise_count)"
    end, {"expr"}, "Comment toggle current line")
    map("n", [[gcy]], function()
        vim.cmd [[noa norm! yy]]
        vim.cmd("norm " .. t"<Plug>(comment_toggle_linewise_current)")
    end, "Yank then comment")
    map("x", [[gcy]], function()
        vim.cmd [[noa norm! ygv]]
        vim.cmd("norm " .. t"<Plug>(comment_toggle_linewise_visual)")
    end, "Yank then comment")

    map("n", [[gco]], require("Comment.api").insert.linewise.below,         "Comment insert below")
    map("n", [[gcO]], require("Comment.api").insert.linewise.above,         "Comment insert above")
    map("n", [[gcA]], require("Comment.api").locked("insert.linewise.eol"), "Comment insert end of line")

    -- Invert comments {{{
    _G.__flip_flop_comment = function(vimMode)
            local U = require("Comment.utils")
            local s = vim.api.nvim_buf_get_mark(0, "[")
            local e = vim.api.nvim_buf_get_mark(0, "]")
            local range = { srow = s[1], scol = s[2], erow = e[1], ecol = e[2] }
            local ctx = {
                ctype = U.ctype.linewise,
                range = range,
            }
            local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
            local ll, rr = U.unwrap_cstr(cstr)
            local padding = true
            local is_commented = U.is_commented(ll, rr, padding)
    
            local rcom = {} -- ranges of commented lines
            local cl = s[1] -- current line
            local rs, re = nil, nil -- range start and end
            local lines = U.get_lines(range)
            for _, line in ipairs(lines) do
                if #line == 0 or not is_commented(line) then -- empty or uncommented line
                    if rs ~= nil then
                        table.insert(rcom, { rs, re })
                        rs, re = nil, nil
                    end
                else
                    rs = rs or cl -- set range start if not set
                    re = cl -- update range end
                end
                cl = cl + 1
            end
            if rs ~= nil then
                table.insert(rcom, { rs, re })
            end
    
            local cursor_position = vim.api.nvim_win_get_cursor(0)
            local vmark_start = vim.api.nvim_buf_get_mark(0, "<")
            local vmark_end = vim.api.nvim_buf_get_mark(0, ">")
    
            ---Toggle comments on a range of lines
            ---@param sl integer: starting line
            ---@param el integer: ending line
            local toggle_lines = function(sl, el)
                vim.api.nvim_win_set_cursor(0, { sl, 0 }) -- idk why it's needed to prevent one-line ranges from being substituted with line under cursor
                vim.api.nvim_buf_set_mark(0, "[", sl, 0, {})
                vim.api.nvim_buf_set_mark(0, "]", el, 0, {})
                require("Comment.api").locked("toggle.linewise")("")
            end
    
            toggle_lines(s[1], e[1])
            for _, r in ipairs(rcom) do
                toggle_lines(r[1], r[2]) -- uncomment lines twice to remove previous comment
                toggle_lines(r[1], r[2])
            end
    
            vim.api.nvim_win_set_cursor(0, cursor_position)
            vim.api.nvim_buf_set_mark(0, "<", vmark_start[1], vmark_start[2], {})
            vim.api.nvim_buf_set_mark(0, ">", vmark_end[1], vmark_end[2], {})
            vim.o.operatorfunc = "v:lua.__flip_flop_comment" -- make it dot-repeatable
    
    end
    map({ "n", "x" }, [[gci]], [[<CMD>set operatorfunc=v:lua.__flip_flop_comment<cr>g@]],
        { "silent" }, "Comment flip flop selection")
        -- }}} Invert comments
end
