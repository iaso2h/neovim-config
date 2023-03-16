return function()
    require("Comment").setup {
        ---Add a space b/w comment and the line
        padding = true,
        ---Whether the cursor should stay at its position
        sticky = true,
        ---Lines to be ignored while (un)comment
        ignore = nil,
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


    map("n", "gco", require("Comment.api").insert.linewise.below,         "Comment insert below")
    map("n", "gcO", require("Comment.api").insert.linewise.above,         "Comment insert above")
    map("n", "gcA", require("Comment.api").locked("insert.linewise.eol"), "Comment insert end of line")
end
