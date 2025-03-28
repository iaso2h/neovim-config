-- File: selection
-- Author: iaso2h
-- Description: Selection Utilities
-- Version: 0.0.12
-- Last Modified: 2023-4-25
local util = require("util")
local M    = {}


--- Jump to the corner position of the last previous selection area
---@param bias integer 1 or -1. Set to 1 will make cursor jump to the closest
--- corner. Set to -1 to make cursor jump to furthest corner
function M.corner(bias) -- {{{
    local cursorPos      = vim.api.nvim_win_get_cursor(0)
    local selectStartPos = vim.api.nvim_buf_get_mark(0, "<")
    if selectStartPos[1] == 0 then return end  -- Sanity check
    local selectEndPos   = vim.api.nvim_buf_get_mark(0, ">")
    local disToStart = require("util").posDist(selectStartPos, cursorPos)
    local disToEnd   = require("util").posDist(selectEndPos, cursorPos)


    local jumpToEnd = function(selectEndPos)
        local endLineLen = #vim.api.nvim_buf_get_lines(0, selectEndPos[1] - 1, selectEndPos[1], false)[1]
        -- In line-wise selection mode, the cursor is freely move horizontally
        -- in the last while maintain the selection unchanged. In this case,
        -- the cursor need to jump to where it located in the last line while
        -- line-wise selection is active.
        if selectEndPos[2] < endLineLen then
            -- Length of line have to minus 1 to convert to (1,0) based
            vim.api.nvim_win_set_cursor(0, {selectEndPos[1], endLineLen - 1})
        else
            vim.api.nvim_win_set_cursor(0, selectEndPos)
        end

    end
    local jumpToStart = function(selectStartPos)
        vim.api.nvim_win_set_cursor(0, selectStartPos)
    end


    -- Out of selection region. Snap to the closest one
    if not require("util").withinRegion(cursorPos, selectStartPos, selectEndPos) then
        if disToStart < disToEnd then
            return vim.api.nvim_win_set_cursor(0, selectStartPos)
        else
            return vim.api.nvim_win_set_cursor(0, selectEndPos)
        end
    end

    if selectEndPos[1] ~= selectStartPos[1] then
        if cursorPos[1] == selectStartPos[1] then
            return vim.api.nvim_win_set_cursor(0, selectEndPos)
        elseif cursorPos[1] == selectEndPos[1] then
            return vim.api.nvim_win_set_cursor(0, selectStartPos)
        end
    end

    -- Within of selection region. Snap to furthest one
    local closerToEnd = disToStart > disToEnd
    if bias == 1 then
        if closerToEnd then
            jumpToStart(selectStartPos)
        else
            jumpToEnd(selectEndPos)
        end
    elseif bias == -1 then
        if closerToEnd then
            jumpToEnd(selectEndPos)
        else
            jumpToStart(selectStartPos)
        end
    end
end -- }}}
--- Get the text of selected area
---@param returnType   string  Set to decide to return "string" or "list"
---@param exitToNormal boolean Set to decide to return in Normal mode in Neovim
---@return string|string[] # Decided by returnType
M.get = function(returnType, exitToNormal) -- {{{
    if returnType ~= "list" and returnType ~= "string" then
        vim.api.nvim_echo({{"Not a supported string value",}}, true, {err=true})
        return ""
    end
    -- Not support blockwise visual mode
    local mode = vim.fn.visualmode()
    if mode == "\22" then
        vim.api.nvim_echo({ { "Blockwise visual mode is not supported", "WarningMsg" } }, true, {})
        return ""
    end

    -- Return (1,0)-indexed line,col info
    local selectStart = vim.api.nvim_buf_get_mark(0, "<")
    local selectEnd = vim.api.nvim_buf_get_mark(0, ">")
    local lines = vim.api.nvim_buf_get_lines(0, selectStart[1] - 1, selectEnd[1], false)

    if #lines == 0 then
        if returnType == "list" then
            return lines
        elseif returnType == "string" then
            return table.concat(lines, "\n")
        ---@diagnostic disable-next-line: missing-return
        end
    end

    -- Needed to remove the last character to make it match the visual selection
    if vim.o.selection == "exclusive" then selectEnd[2] = selectEnd[2] - 1 end
    if mode == "v" then
        lines[#lines] = lines[#lines]:sub(1, selectEnd[2] + 1)
        lines[1]      = lines[1]:sub(selectStart[2] + 1)
    end

    if exitToNormal then vim.cmd("norm! " .. t"<Esc>") end

    if returnType == "list" then
        return lines
    elseif returnType == "string" then
        return table.concat(lines, "\n")
    ---@diagnostic disable-next-line: missing-return
    end
end -- }}}
--- Extmark select
---@param ns integer namespace
---@param extmark integer
---@param linewise boolean
function M.extmarkSelect(ns, extmark, linewise) -- {{{
    -- Create jump location in jumplist
    if not ns then return end
    vim.cmd [[normal! m`]]

    local curBufNr   = vim.api.nvim_get_current_buf()
    local curWinID   = vim.api.nvim_get_current_win()
    local cursor     = vim.api.nvim_win_get_cursor(curWinID)
    local extmarkPos = vim.api.nvim_buf_get_extmark_by_id(curBufNr, ns, extmark, {details=true})

    -- Validate extmark
    if not next(extmarkPos) then
        return vimapi.nvim_echonotify({ { "No record found on current buffer", "WarningMsg" } }, true, {})
    end
    local selectStart = {extmarkPos[1] + 1, extmarkPos[2]}
    local selectEnd   = {extmarkPos[3]["end_row"] + 1, extmarkPos[3]["end_col"]}

    -- Determine select direction
    local startDist = util.posDist(cursor, selectStart)
    local endDist   = util.posDist(cursor, selectEnd)
    if startDist < endDist then
        if linewise then
            vim.api.nvim_win_set_cursor(curWinID, selectEnd)
            vim.cmd [[noautocmd normal! V]]
            vim.api.nvim_win_set_cursor(curWinID, {selectStart[1], cursor[2]})
        else
            vim.api.nvim_win_set_cursor(curWinID, selectEnd)
            vim.cmd [[noautocmd normal! v]]
            vim.api.nvim_win_set_cursor(curWinID, selectStart)
        end
    else
        if linewise then
            vim.api.nvim_win_set_cursor(curWinID, selectStart)
            vim.cmd [[noautocmd normal! V]]
            vim.api.nvim_win_set_cursor(curWinID, {selectEnd[1], cursor[2]})
        else
            vim.api.nvim_win_set_cursor(curWinID, selectStart)
            vim.cmd [[noautocmd normal! v]]
            vim.api.nvim_win_set_cursor(curWinID, selectEnd)
        end
    end
end -- }}}


return M
