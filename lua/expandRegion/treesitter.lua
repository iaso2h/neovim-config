local M = {}
local util = require("util")

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
--- Get the first named child treesitter node form the given parent treesitter
--and make sure the position table is inside the range of that named child
--treesitter node
---@param parentNode TSNode
---@param position integer[] (1, 0) indexed.
---@return TSNode
local getNamedChildNode = function(parentNode, position) -- {{{
    for node in parentNode:iter_children() do
        if node:named() then
            if vim.treesitter.is_in_node_range(node, position[1] - 1, position[2]) then
                return node
            end
        end
    end

    -- Fallback returned treesitter node
    return parentNode:named_child(0)
end -- }}}
--- Generate a region table containing all the treesitter node infos needed to
--be selected in visual mode
---@param bufNr integer Buffer number
---@param initNode TSNode Treesitter object
---@param direction integer 1 indicates expand, -1 indicates shrink
---@param cursorPos? integer[] (1, 0) indexed. Returned valuf from calling `vim.api.nvim_win_get_cursor()`. When direction is -1, a cursorPos must be provided
---@return ExpandRegionCandidate
M.getNodeCandidate = function(bufNr, initNode, direction, cursorPos) -- {{{
    if direction == -1 then
        assert(type(cursorPos) == "table", "A table must be provided as #4 parameter when -1 is passed as #3 parameter")
    end
    -- Find the valid child
    local node = initNode
    local initRange = {node:range()}
    repeat
        local range = {node:range()}
        if not vim.deep_equal(initRange, range) then
            break
        end

        local nextHierarchyNode
        if direction == 1 then
            nextHierarchyNode = node:parent()
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            getNamedChildNode(node, cursorPos)
        end

        -- Before entering into next iteration
        if not nextHierarchyNode then
            return {}
        else
            node = nextHierarchyNode
        end
    until false

    local candidate = M.getNodeRange(node)
    candidate.type = "treesitter"
    candidate.tsNode = node
    candidate.content = util.getNodeText(bufNr, {initNode:range()})

    return candidate
end -- }}}
--- Get treesitter node candidate by visual selection
---@param bufNr integer Buffer number
---@param visualStart table Line number and column index in (1, 0) based
---@param visualEnd table Line number and column index in (1, 0) based
---@param direction integer 1 indicates expand, -1 indicates shrink
---@return ExpandRegionCandidate
M.getNodeCandidateBySelection = function(bufNr, visualStart, visualEnd, direction) -- {{{
    local initNode = vim.treesitter.get_node()
    if not initNode then return {} end

    -- Loop until find a treesitter candidate has a bigger range than
    -- the current selected region
    local candidate = M.getNodeRange(initNode)
    candidate.type = "treesitter"
    candidate.tsNode = initNode
    candidate.content = util.getNodeText(bufNr, {initNode:range()})
    local candidateLastIter
    repeat
        if util.compareDist(visualStart, candidate.posStart) == 0 and
            util.compareDist(visualEnd, candidate.posEnd) == 0 then
            if direction == -1 then
                if candidateLastIter then
                    return candidateLastIter
                else
                    return {}
                end
            end
        elseif util.compareDist(visualStart, candidate.posStart) >= 0 and
            util.compareDist(visualEnd, candidate.posEnd) <= 0 then
            if direction == -1 then
                if candidateLastIter then
                    return candidateLastIter
                else
                    return {}
                end
            else
                return candidate
            end
        end

        local parentCandidate = M.getNodeCandidate(bufNr, candidate.tsNode, 1)
        if not next(parentCandidate) then
            return {}
        end


        -- Before entering into next iteration
        candidateLastIter = candidate
        candidate = parentCandidate
    until false

    return {}
end -- }}}


return M
