local M = {}

--- Get the region range of a treesitter node
---@param tsNode TSNode Treesitter node
---@return table (1,0) index based region position of the treesitter node, can be passed to
M.getNodeRange = function(tsNode) -- {{{
    local startRow, startCol, endRow, endCol = tsNode:range()
    return {
        posStart = {startRow + 1, startCol},
        posEnd   = {endRow + 1,   endCol - 1}
    }
end -- }}}
--- Generate a region table containing all the treesitter node infos needed to
--- be selected in visual mode
--- @param initNode TSNode Treesitter object
--- @return ExpandRegionCandidate
M.getNodeCandidate = function(initNode) -- {{{
    -- Find the valid child
    local node = initNode
    local initRange = {node:range()}
    repeat
        local parentNode = node:parent()
        if not parentNode then
            return {}
        else
            node = parentNode
        end

        local range = {node:range()}
        if not vim.deep_equal(initRange, range) then
            break
        end
    until false

    local candidate = M.getNodeRange(initNode)

    candidate.type = "treesitter"
    candidate.tsNode = node

    return candidate
end -- }}}


return M
