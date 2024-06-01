-- File: modification
-- Author: iaso2h
-- Description: Modify the quickfix item
-- Version: 0.0.6
-- Last Modified: 2023-10-22
local M = { }
local init = function()
    M.lastTitle = ""
    M.lastType  = ""
    M.history = {}
    M.lastIdx = 0
end
init()
local util = require("util")
local u    = require("quickfix.util")
local highlight = require("quickfix.highlight")


--- Store quickfix items and title
---@param currentItems table Quickfix/Localist items retrieved by calling `vim.fn.getqflist()` or `vim.fn.getloclist()`
---@param currentTitle string Quickfix/Localist title
M.infoCheck = function(currentItems, currentTitle) -- {{{
    local currentType = vim.b._is_local and "local" or "quickfix"
    if M.lastTitle ~= "" and currentTitle == M.lastTitle and M.lastType ~= "" and M.lastType == currentType then
        -- Do nothing
    else
        M.lastTitle = currentTitle
        M.lastType = currentType
        M.lastIdx = 0
    end
    M.lastIdx = M.lastIdx + 1
    M.history[M.lastIdx] = vim.deepcopy(currentItems)
    M.lastType = vim.b._is_local and "local" or "quickfix"
end -- }}}
--- Delete quickfix item and reflect immediately. vim.v.count prefix will result
--- in delete corresponding line in quickfix
---@param vimMode string Vim mode. "n" or "v"
M.delete = function(vimMode) -- {{{
    local qfCursorPos = vim.api.nvim_win_get_cursor(0)
    local qfBufNr     = vim.api.nvim_get_current_buf()
    local qfItems, qfTitle = u.getlist()
    local qfLastline = vim.api.nvim_buf_line_count(0)
    if #qfItems == 0 then return end

    -- Backup items
    M.infoCheck(qfItems, qfTitle)

    -- Modify items
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

    highlight.refreshHighlight(qfBufNr, qfItems, qfTitle)
end -- }}}
--- Restored the last modified quickfix items
M.recovery = function() -- {{{
    local qfBufNr = vim.api.nvim_get_current_buf()
    local qfItems, qfTitle = u.getlist()
    if M.lastTitle == qfTitle then
        if M.lastType == "quickfix" and not vim.b._is_local then
            if M.lastTitle == "Workspace Diagnostics" then
                if not require("quickfix.diagnostics").filteredChk then
                    -- The new diagnostics has been updated and populated into
                    -- quickfix so there is no need to recovery it any more
                    return init()
                end
            end

            if M.lastIdx == 0 then
                return vim.notify("There is no older quickfix in history", vim.log.levels.INFO)
            end

            vim.fn.setqflist({}, "r", {items = M.history[M.lastIdx], title = M.lastTitle})
            highlight.refreshHighlight(qfBufNr, M.history[M.lastIdx], qfTitle)
            M.lastIdx = M.lastIdx - 1
        elseif M.lastType == "local" and vim.b._is_local then
            if M.lastTitle == "Local Diagnostics" then
                if not require("quickfix.diagnostics").filteredChk then
                    -- The new diagnostics has been updated and populated into
                    -- quickfix so there is no need to recovery it any more
                    return init()
                end
            end

            if M.lastIdx == 0 then
                return vim.notify("There is no older quickfix in history", vim.log.levels.INFO)
            end

            vim.fn.setloclist(0, {}, "r", {items = M.history[M.lastIdx], title = M.lastTitle})
            highlight.refreshHighlight(qfBufNr, M.history[M.lastIdx], qfTitle)
            M.lastIdx = M.lastIdx - 1
        else
            vim.notify("Wrong quickfix type")
        end
    else
        return init()
    end
end -- }}}
--- Change a quickfix list into a local list and vice versa
M.interConvert = function() -- {{{
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
end -- }}}
--- Refresh quickfix item
M.refresh = function() -- {{{
    local qfItems, qfTitle = u.getlist()
    for idx, item in ipairs(qfItems) do
        if item.valid ~= 0 and item.bufnr ~= 0 and
            vim.api.nvim_buf_is_valid(item.bufnr) and
            vim.api.nvim_get_option_value("buflisted", {buf = item.bufnr})
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
end -- }}}


return M
