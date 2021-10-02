local fn     = vim.fn
-- local cmd    = vim.cmd
-- local api    = vim.api
local util = require("util")
local M    = {}


--- Get treesitter node under cursor position
--- @param cursorPos table cursor position
--- @return object treesitter node
M.getCursorNode = function(cursorPos)
    if not package.loaded["nvim-treesitter.parsers"] then return false end
    local parsers = require("nvim-treesitter.parsers")
    local tsUtils = require("nvim-treesitter.ts_utils")

    if not parsers.has_parser() then return false end

    local cursorRange = {cursorPos[1] - 1, cursorPos[2]}

    local rootNode = tsUtils.get_root_for_position(unpack(cursorRange))
    if not rootNode then return false end
    return rootNode:named_descendant_for_range(cursorRange[1], cursorRange[2], cursorRange[1], cursorRange[2])
end


--- Get the region range of a treesitter node
--- @param node object treesitter node
--- @param getStrNodeContent boolean set it true to subtract the region to the
---        content a string, excluding the quotation marks
--- @return table (1,0) index based region position of the treesitter node, can be passed to
--- vim.api.nvim_win_set_cursor()
M.getNodeRange = function(node, getStrNodeContent, c)
    if ExpandRegionDebugMode then
        Print(node:type())
    end
    local startRow, startCol, endRow, endCol = node:range()
    -- TODO: wrap around each if block
    if getStrNodeContent and node:type() == "string" then
        -- Convert to (1,0) based to be passed to vim.api.nvim_win_set_cursor
        return {
            posStart = {startRow + 1, startCol + 1},
            posEnd   = {endRow + 1,   endCol - 2}
        }
    else
        return {
            posStart = {startRow + 1, startCol},
            posEnd   = {endRow + 1,   endCol - 1}
        }
    end
end


--- Get the parent node of a treesitter node
--- @param node object treesitter node
--- @return boolean or object of treesitter node. If no available parent node,
---         false will be returned
M.getParentNode = function(node)
    local nodeRange = M.getNodeRange(node)
    local parentNodeRange
    local cnt = 0
    local parentNode = node
    local compare1
    local compare2
    repeat
        -- looping threshold set to 5
        cnt             = cnt + 1
        parentNode      = parentNode:parent()
        parentNodeRange = M.getNodeRange(parentNode)
        compare1 = util.compareDist(nodeRange.posEnd, parentNodeRange.posEnd) ~= 0
        compare2 = util.compareDist(nodeRange.posStart, parentNodeRange.posStart) ~= 0
    until (parentNodeRange and compare1 and compare2) or cnt == 5

    if parentNodeRange.posEnd[1] > fn.line("$") then return end

    return parentNode or false
end


return M
