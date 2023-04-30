-- File: cc.lua
-- Author: iaso2h
-- Description: Enhance version of the :cc
-- Version: 0.0.5
-- Last Modified: Sun 30 Apr 2023

--- Set current window focus
---@param closeQfChk boolean Whether to close the quickfix window
---@param qfWinID number Window ID of the quickfix window
---@param targetCursorPos table target cursor position
local setCurrentWin = function(closeQfChk, qfWinID, targetCursorPos)
    if not closeQfChk then
        local ok, msg = pcall(vim.api.nvim_set_current_win, qfWinID)
        if not ok then
            vim.notify(msg, vim.log.levels.WARN)
            vim.cmd[[wincmd p]]
        end
        ok, msg = pcall(vim.api.nvim_win_set_cursor, qfWinID, targetCursorPos)
        if not ok then
            vim.notify(msg, vim.log.levels.WARN)
        end
    else
        vim.api.nvim_win_close(qfWinID, false)
    end
end


local fallback = function(targetLineNr, ...)
    vim.cmd([[cc ]] .. targetLineNr)
    vim.cmd[[norm! zvzz]]
    if not vim.bo.buflisted then
        vim.opt_local.buflisted = true
    end
    setCurrentWin(...)
end


--- Open an item in quickfix window like :cc do, except that it will always use
--- the last window to open a quickfix item, which is what I call the
--- 'uselastWin' method for 'switchBuf' option. The vim.v.count will only open
--- a specific line, of which line number is decided by vim.v.count
---@param closeQfChk boolean Whether to close the quifix after open an item
---@param offset number Open the item based on the given offset to the
--cursor. Set it to -1 to open the previous item, 1 to open the next item
return function(closeQfChk, offset)
    local u = require("quickfix.util")
    local qfItems     = u.getlist()
    if not next(qfItems) then
        return vim.notify("No quickfix items available")
    end

    local qfWinID     = vim.api.nvim_get_current_win()
    local qfCursorPos = vim.api.nvim_win_get_cursor(qfWinID)
    local targetCursorPos = {}

    -- Get target line
    local lastLine = vim.fn.line("$")
    local targetLineNr
    if offset ~= 0 then
        targetLineNr = u.getlist({idx = 0}).idx + offset
        if targetLineNr > lastLine then
            targetCursorPos = {lastLine, qfCursorPos[2]}
            targetLineNr = lastLine
        elseif targetLineNr < 1 then
            targetCursorPos = {1, qfCursorPos[2]}
            targetLineNr = 1
        else
            targetCursorPos = {targetLineNr, qfCursorPos[2]}
        end
    else
        targetLineNr = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
        if targetLineNr > lastLine then targetLineNr = lastLine end
        targetCursorPos = {targetLineNr, qfCursorPos[2]}
    end

    local targetItem = qfItems[targetLineNr]
    if not targetItem then
        return vim.notify("Invalid quickfix item", vim.log.levels.ERROR)
    end

    -- Comment out invalid item
    if targetItem.valid == 1 and (targetItem.bufnr == 0 or
            not vim.api.nvim_buf_is_valid(targetItem.bufnr)) then

        require("quickfix.highlight").addLines(
            {targetLineNr},
            "Comment",
            vim.api.nvim_create_namespace("myQuickfix")
        )
        return vim.notify("This item is no longer valid")
    elseif targetItem.valid == 0 then
        return vim.notify("Cannot open this item")
    end

    -- User the built-in :cc command to open quickfix item
    return fallback(targetLineNr, closeQfChk, qfWinID, targetCursorPos)
end
