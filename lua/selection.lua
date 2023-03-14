-- File: selection
-- Author: iaso2h
-- Description: Selection Utilities
-- Version: 0.0.11
-- Last Modified: 2023-3-13
local api = vim.api
local fn  = vim.fn
local M   = {}


local jumpToEnd = function(selectEndPos)
    local endLineLen = #api.nvim_buf_get_lines(0, selectEndPos[1] - 1, selectEndPos[1], false)[1]
    -- In line-wise selection mode, the cursor is freely move horizontally
    -- in the last while maintain the selection unchanged. In this case,
    -- the cursor need to jump to where it located in the last line while
    -- line-wise selection is active.
    if selectEndPos[2] < endLineLen then
        -- Length of line have to minus 1 to convert to (1,0) based
        api.nvim_win_set_cursor(0, {selectEndPos[1], endLineLen - 1})
    else
        api.nvim_win_set_cursor(0, selectEndPos)
    end

end

local jumpToStart = function(selectStartPos)
    api.nvim_win_set_cursor(0, selectStartPos)
end


--- Jump to the corner position of the last previous selection area
---@param bias number 1 or -1. Set to 1 will make cursor jump to the closest
--- corner. Set to -1 to make cursor jump to furthest corner
function M.cornerSelection(bias) -- {{{
    local cursorPos      = api.nvim_win_get_cursor(0)
    local selectStartPos = api.nvim_buf_get_mark(0, "<")
    if selectStartPos[1] == 0 then return end  -- Sanity check
    local selectEndPos   = api.nvim_buf_get_mark(0, ">")
    local disToStart = require("util").posDist(selectStartPos, cursorPos)
    local disToEnd   = require("util").posDist(selectEndPos, cursorPos)

    -- Out of selection region. Snap to the closest one
    if not require("util").withinRegion(cursorPos, selectStartPos, selectEndPos) then
        if disToStart < disToEnd then
            return api.nvim_win_set_cursor(0, selectStartPos)
        else
            return api.nvim_win_set_cursor(0, selectEndPos)
        end
    end

    if selectEndPos[1] ~= selectStartPos[1] then
        if cursorPos[1] == selectStartPos[1] then
            return api.nvim_win_set_cursor(0, selectEndPos)
        elseif cursorPos[1] == selectEndPos[1] then
            return api.nvim_win_set_cursor(0, selectStartPos)
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
            jumpToStart(selectStartPos)
        else
            jumpToEnd(selectEndPos)
        end
    end
end -- }}}


--- Get the text of selected area
---@param returnType   string  Set to decide to return "string" or "list"
---@param exitToNormal boolean Set to decide to return in Normal mode in Neovim
---@return string|table|nil Decided by returnType
M.getSelect = function(returnType, exitToNormal) -- {{{
    if returnType ~= "list" and returnType ~= "string" then
        return vim.notify("Not a supported string value", vim.log.levels.ERROR)
    end
    -- Not support blockwise visual mode
    local mode = fn.visualmode()
    if mode == "\22" then
        return vim.notify("Blockwise visual mode is not supported", vim.log.levels.WARN)
    end

    -- Return (1,0)-indexed line,col info
    local selectStart = api.nvim_buf_get_mark(0, "<")
    local selectEnd = api.nvim_buf_get_mark(0, ">")
    local lines = api.nvim_buf_get_lines(0, selectStart[1] - 1, selectEnd[1], false)

    if #lines == 0 then
        if returnType == "list" then
            return lines
        elseif returnType == "string" then
            return table.concat(lines, "\n")
        ---@diagnostic disable-next-line: missing-return
        end
    end

    -- Needed to remove the last character to make it match the visual selction
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


return M

