local api = vim.api
local fn  = vim.fn
local M = {
    lastItems = nil
}


--- Delete quickfix item and reflect immediately. vim.v.count prefix will result
--- in delete corresponding line in quickfix
---@param vimMode string Vim mode. "n" or "v"
M.delete = function (vimMode) -- {{{
    local qfCursorPos = api.nvim_win_get_cursor(0)
    local qfItems = fn.getqflist()
    vim.defer_fn(require("quickfix.highlight").clear, 0)

    if vimMode == "n" then
        local itemNr  = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
        if #qfItems == 0 then return end

        -- Backup items
        require("quickfix.undo").lastItems = qfItems

        table.remove(qfItems, itemNr)
        fn.setqflist({}, "r", {items = qfItems})

        -- Neovim will take care of the new position even the row number is out of scope
        api.nvim_win_set_cursor(0, qfCursorPos)
    else
        -- Backup items
        require("quickfix.undo").lastItems = qfItems
        local startPos = api.nvim_buf_get_mark(0, "<")
        local endPos   = api.nvim_buf_get_mark(0, ">")

        for _ = 1, endPos[1] - startPos[1] + 1, 1 do
            table.remove(qfItems, startPos[1])
        end
        fn.setqflist({}, "r", {items = qfItems})

        -- Neovim will take care of the new position even the row number is out of scope
        api.nvim_win_set_cursor(0, startPos)
    end
end -- }}}


M.recovery = function () -- {{{
    if require("quickfix.undo").lastItems then
        fn.setqflist({}, "r", {items = require("quickfix.undo").lastItems})
        require("quickfix.undo").lastItems = nil
    else
        return
    end
end -- }}}

return M
