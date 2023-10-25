local M = {}
local util = require("util")

--- Get the region range of a treesitter node
---@param tsNode TSNode Treesitter node
---@return table (1,0) index based region position of the treesitter node, can be passed to
M.getNodeRange = function(bufNr, tsNode) -- {{{
    local startRow, startCol, endRow, endCol = tsNode:range()
    if endCol == 0 then
        local endLine = vim.api.nvim_buf_get_lines(bufNr, endRow - 1, endRow, false)[1]
        endRow = endRow - 1
        endCol = #endLine
    end
    return {
        posStart = {startRow + 1, startCol},
        posEnd   = {endRow + 1,   endCol - 1}
    }
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
            nextHierarchyNode = node:named_child(0)
        end

        -- Before entering into next iteration
        if not nextHierarchyNode then
            return {}
        else
            node = nextHierarchyNode
        end
    until false

    local candidate = M.getNodeRange(bufNr, node)
    candidate.type = "treesitter"
    candidate.tsNode = node
    candidate.content = util.getNodeText(bufNr, {initNode:range()})

    return candidate
end -- }}}
--- Get the first named child treesitter node form the given parent treesitter
--and make sure the position table is inside the range of that named child
--treesitter node
---@param bufNr integer Buffer number
---@param parentNode TSNode
---@param visualStart table Line number and column index in (1, 0) based
---@param visualEnd table Line number and column index in (1, 0) based
---@return TSNode|nil
local getSmallerNodeBySelection = function(bufNr, parentNode, visualStart, visualEnd) -- {{{
    --- Iterate through all children inside a treesitter node
    ---@param node TSNode
    ---@return TSNode|nil, boolean
    local function recursiveIterChildren(node)
        for n in node:iter_children() do
            if n:named() then
                local nodeRange = M.getNodeRange(bufNr, n)
                if util.compareDist(nodeRange.posStart, visualStart) >= 0 and
                    util.compareDist(nodeRange.posEnd, visualEnd) <= 0 then
                    return n, true
                end

                if n:child_count() > 0 then
                    -- Entering into deeper recursive call
                    local childNode, returnCode = recursiveIterChildren(n)
                    if returnCode then
                        return childNode, true
                    end
                end
            end
        end

        -- Fallback returned treesitter node
        return nil, false
    end

    local childNode, _ = recursiveIterChildren(parentNode)
    return childNode
end -- }}}
--- Get treesitter node candidate by visual selection
---@param bufNr integer Buffer number
---@param visualStart table Line number and column index in (1, 0) based
---@param visualEnd table Line number and column index in (1, 0) based
---@param direction integer 1 indicates expand, -1 indicates shrink
---@return ExpandRegionCandidate
M.getNodeCandidateBySelection = function(bufNr, visualStart, visualEnd, direction) -- {{{
    local candidateLarger
    local tree = vim.treesitter.get_parser(bufNr, vim.bo.filetype)
    local nodeLarger = tree:named_node_for_range({
        visualStart[1] - 1,
        visualStart[2],
        visualEnd[1] - 1,
        visualEnd[2],
    }, {
        ignore_injections = true
    })
    if not nodeLarger then
        return {}
    else
        candidateLarger = M.getNodeRange(bufNr, nodeLarger)
        candidateLarger.type = "treesitter"
        candidateLarger.tsNode = nodeLarger
        candidateLarger.content = util.getNodeText(bufNr, {nodeLarger:range()})
    end

    if direction == 1 then return candidateLarger end

    local candidateSmaller
    local nodeSmaller = getSmallerNodeBySelection(bufNr, candidateLarger.tsNode, visualStart, visualEnd)
    if not nodeSmaller then
        return {}
    else
        candidateSmaller = M.getNodeRange(bufNr, nodeSmaller)
        candidateSmaller.type = "treesitter"
        candidateSmaller.tsNode = nodeSmaller
        candidateSmaller.content = util.getNodeText(bufNr, {nodeSmaller:range()})
        return candidateSmaller
    end
end -- }}}


return M
