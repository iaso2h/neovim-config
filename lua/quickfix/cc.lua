-- File: cc.lua
-- Author: iaso2h
-- Description: Enhance version of the :cc
-- Version: 0.0.8
-- Last Modified: Sat 06 May 2023

--- Set current window focus
---@param closeQfChk boolean Whether to close the quickfix window
---@param qfWinId integer Window ID of the quickfix window
---@param targetCursorPos table target cursor position
local setCurrentWin = function(closeQfChk, qfWinId, targetCursorPos) -- {{{
    if not closeQfChk then
        local ok, msg = pcall(vim.api.nvim_set_current_win, qfWinId)
        if not ok then
            vim.api.nvim_echo({{msg, "WarningMsg"}}, true, {})
            vim.cmd[[wincmd p]]
        end
        ok, msg = pcall(vim.api.nvim_win_set_cursor, qfWinId, targetCursorPos)
        if not ok then
            vim.api.nvim_echo({{msg, "WarningMsg"}}, true, {})
        end
    else
        vim.api.nvim_win_close(qfWinId, false)
    end
end -- }}}
--- Open quickfix item
---@param targetLineNr integer
---@vararg any see `setCurrentWin()`
local open = function(targetLineNr, ...) -- {{{
    local prevBufNr = vim.fn.bufnr("$")
    local prevWinId = require("buffer.util").winIdPrev()
    require("jump.util").posCenter(function()
        vim.cmd([[cc ]] .. targetLineNr)
    end, false, prevWinId, prevBufNr)
    if not vim.bo.buflisted then
        vim.opt_local.buflisted = true
    end

    if vim.o.splitkeep ~= "cursor" then
        local vargs = {...}
        vim.defer_fn(function() setCurrentWin(unpack(vargs)) end, 0)
    else
        setCurrentWin(...)
    end
end -- }}}
--- Open an item in quickfix window like :cc do, except that it will always use
--- the last window to open a quickfix item, which is what I call the
--- 'uselastWin' method for 'switchBuf' option. The vim.v.count will only open
--- a specific line, of which line number is decided by vim.v.count
---@param closeQfChk boolean Whether to close the quifix after open an item
---@param offset integer Open the item based on the given offset to the
--cursor. Set it to -1 to open the previous item, 1 to open the next item
return function(closeQfChk, offset) -- {{{
    local u = require("quickfix.util")
    local qfItems = u.getlist()
    if not next(qfItems) then
        return vim.api.nvim_echo({{"No quickfix items available", "Normal"}}, true, {})
    end

    local qfWinId     = vim.api.nvim_get_current_win()
    local qfCursorPos = vim.api.nvim_win_get_cursor(qfWinId)
    local targetCursorPos = {}

    -- Get target line
    local qfLastLine = vim.api.nvim_buf_line_count(0)
    local targetLineNr
    if offset ~= 0 then
        targetLineNr = u.getlist({idx = 0}).idx + offset
        if targetLineNr > qfLastLine then
            targetCursorPos = {qfLastLine, qfCursorPos[2]}
            targetLineNr = qfLastLine
        elseif targetLineNr < 1 then
            targetCursorPos = {1, qfCursorPos[2]}
            targetLineNr = 1
        else
            targetCursorPos = {targetLineNr, qfCursorPos[2]}
        end
    else
        targetLineNr = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
        if targetLineNr > qfLastLine then targetLineNr = qfLastLine end
        targetCursorPos = {targetLineNr, qfCursorPos[2]}
    end


    -- Local list. Terminate the function
    if vim.b._is_local then
        vim.api.nvim_win_set_cursor(qfWinId, {targetLineNr, 0})
        vim.cmd(t[[norm! <CR>]])
        if closeQfChk then
            vim.api.nvim_win_close(qfWinId, false)
        end
        return
    end

    -- Global quick list
    local targetItem = qfItems[targetLineNr]
    if not targetItem then
        return vim.api.nvim_echo({{"Invalid quickfix item",}}, true, {err=true})
    end

    -- Comment out invalid item
    if targetItem.valid == 1 and (targetItem.bufnr == 0 or
            not vim.api.nvim_buf_is_valid(targetItem.bufnr)) then

        local ns = vim.api.nvim_create_namespace("myQuickfix")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        require("quickfix.highlight").addLines(
            {targetLineNr},
            "Comment",
            ns
        )
        return vim.api.nvim_echo({{"This item is no longer valid", "Normal"}}, true, {})
    elseif targetItem.valid == 0 then
        return vim.api.nvim_echo({{"Cannot open this item", "Normal"}}, true, {})
    end

    -- User the built-in `:cc` command to open quickfix item
    return open(targetLineNr, closeQfChk, qfWinId, targetCursorPos)
end -- }}}
