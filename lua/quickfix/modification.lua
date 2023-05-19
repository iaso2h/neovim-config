-- File: modification
-- Author: iaso2h
-- Description: Modify the quickfix item
-- Version: 0.0.5
-- Last Modified: 2023 05 May
local M = {
    lastItems = nil,
    lastTitle = "",
    lastType  = ""
}
local util = require("util")
local u    = require("quickfix.util")


--- Delete quickfix item and reflect immediately. vim.v.count prefix will result
--- in delete corresponding line in quickfix
---@param vimMode string Vim mode. "n" or "v"
M.delete = function (vimMode) -- {{{
    local qfCursorPos = vim.api.nvim_win_get_cursor(0)
    local qfItems, qfTitle = u.getlist()
    local qfLastline = vim.api.nvim_buf_line_count(0)
    vim.defer_fn(require("quickfix.highlight").clear, 0)
    if #qfItems == 0 then return end

    -- Backup items
    M.lastItems = vim.deepcopy(qfItems)
    M.lastTitle = qfTitle
    M.lastType  = vim.b._is_local and "local" or "quickfix"

    if vimMode == "n" then
        local itemNr = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
        itemNr = itemNr > #qfItems and #qfItems or itemNr

        -- Set up qf
        table.remove(qfItems, itemNr)
        if vim.b._is_local then
            vim.fn.setloclist(0, {}, "r", {items = qfItems, title = qfTitle})
        else
            vim.fn.setqflist({}, "r", {items = qfItems, title = qfTitle})
        end

        -- Neovim will take care of the new position even the row number is out of scope
        if qfCursorPos[1] == qfLastline then
            vim.api.nvim_win_set_cursor(0, {qfCursorPos[1] - 1, qfCursorPos[2]})
        else
            vim.api.nvim_win_set_cursor(0, qfCursorPos)
        end
    else
        local startPos = vim.api.nvim_buf_get_mark(0, "<")
        local endPos   = vim.api.nvim_buf_get_mark(0, ">")

        for _ = 1, endPos[1] - startPos[1] + 1, 1 do
            table.remove(qfItems, startPos[1])
        end
        if vim.b._is_local then
            vim.fn.setloclist(0, {}, "r", {items = qfItems, title = qfTitle})
        else
            vim.fn.setqflist({}, "r", {items = qfItems, title = qfTitle})
        end

        -- Neovim will take care of the new position even the row number is out of scope
        if endPos[1] == qfLastline then
            vim.api.nvim_win_set_cursor(0, {startPos[1] - 1, startPos[2]})
        else
            vim.api.nvim_win_set_cursor(0, startPos)
        end
    end
end -- }}}


M.recovery = function () -- {{{
    if M.lastItems then
        if M.lastType == "quickfix" and not vim.b._is_local then
            vim.fn.setqflist({}, "r", {items = M.lastItems, title = M.lastTitle})
        elseif M.lastType == "local" and vim.b._is_local then
            vim.fn.setloclist(0, {}, "r", {items = M.lastItems, title = M.lastTitle})
        else
            return vim.notify("Wrong quickfix type")
        end
        M.lastItems = nil
    else
        return
    end
end -- }}}


M.interConvert = function ()
    local qfItems, qfTitle = u.getlist()
    local winInfo = vim.fn.getwininfo()
    local qfVisibleTick = util.any(function(i)
        return i.quickfix == 1
    end, winInfo)
    if vim.b._is_local then
        vim.fn.setqflist({}, " ", {items = qfItems, title = qfTitle})
    else
        vim.fn.setloclist(0, {}, " ", {items = qfItems, title = qfTitle})
    end

    if not qfVisibleTick then
        local preCmd = require("buffer.split").handler(true)
        vim.cmd(preCmd .. " copen")
    end
end


M.main = function ()
    local qfItems, qfTitle = u.getlist()
    for idx, item in ipairs(qfItems) do
        if item.valid ~= 0 and item.bufnr ~= 0 and
            vim.api.nvim_buf_is_valid(item.bufnr) and
            vim.api.nvim_buf_get_option(item.bufnr, "buflisted")
            then
            -- Only update listed buffer because otherwise
            -- vim.api.nvim_buf_get_lines can't get content from unlisted buffer
            qfItems[idx].text = vim.api.nvim_buf_get_lines(item.bufnr, item.lnum - 1, item.lnum, false)[1]
        end
    end
    if vim.b._is_local then
        vim.fn.setloclist(0, {}, "r", {items = qfItems, title = qfTitle})
    else
        vim.fn.setqflist({}, "r", {items = qfItems, title = qfTitle})
    end
end


return M
