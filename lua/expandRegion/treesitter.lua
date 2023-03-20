local fn      = vim.fn
-- local cmd  = vim.cmd
local api     = vim.api
local util    = require("util")
local cbPairs = require("expandRegion.treesitterCodeBlockPairs")
local M       = {}

local codeBlockPairBlackList = {"python"}


--- Get the region range of a treesitter node
--- @param tsNode object treesitter node
--- @param getStrNodeContent boolean set it true to subtract the region to the
---        content a string, excluding the quotation marks
--- @return table (1,0) index based region position of the treesitter node, can be passed to
--- vim.api.nvim_win_set_cursor()
M.getNodeRange = function(tsNode, getStrNodeContent)
    local startRow, startCol, endRow, endCol = tsNode:range()
    if getStrNodeContent and tsNode:type() == "string" then
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


--- Get the two treesitter nodes at the start and end of a code block
--- determined by a parentNode
--- @param parentNode userdata two treesitter node objects or just one treesitter when
---        there is only one child node for the parentNode
M.getPairNode = function(parentNode)
    -- The first node at code block determined by parentNode
    local startNode = parentNode:named_child(
        cbPairs["ts_" .. parentNode:type()].childStart)
    -- Initiation
    local lastNextNamedSibling
    local nextNamedSibling = startNode
    while true do
        lastNextNamedSibling = nextNamedSibling
        nextNamedSibling = nextNamedSibling:next_named_sibling()

        -- Return the last valid node to mark as the end of code block when
        -- there is no available siblings
        if not nextNamedSibling then
            return startNode, lastNextNamedSibling, parentNode
        end

        -- Return the treesitter node that matches the pair statement to mark
        -- the end of the code block
        if vim.tbl_contains(cbPairs["ts_" .. startNode:parent():type()].pairs,
            nextNamedSibling:type()) then

            return startNode, nextNamedSibling, parentNode
        end
    end
end


--- Get the parent node of a treesitter node
--- @param nodeTbl table Treesitter node object
--- the start node and the end node to indicate the code block
--- @return boolean or objects of treesitter node If no available parent node, false will be return
M.getParentNode = function(nodeTbl)
    -- When arguments is composed of two treesitter nodes, which are used to
    -- determined the code block they wrap around, we can just use the parent
    -- node of the first argument as the the new parent node. If the new
    -- parent node is "if_statement", then the range of it if should include
    -- the code block as well as the if statement and the conditional
    -- statements.
    if #nodeTbl == 2 then return nodeTbl[1]:parent() end

    local nodeRange = M.getNodeRange(nodeTbl[1], false)
    local parentNodeRange
    local cnt = 0
    local parentNode = nodeTbl[1]
    local lastParentNode
    local cmpStart
    local cmpEnd

    local indentical
    repeat
        -- looping threshold set to 5
        cnt            = cnt + 1
        lastParentNode = parentNode
        parentNode     = parentNode:parent()
        -- Abort when parentNode is nil
        if not parentNode then return false end

        parentNodeRange = M.getNodeRange(parentNode, false)
        cmpStart = util.compareDist(nodeRange.posStart, parentNodeRange.posStart)
        cmpEnd   = util.compareDist(nodeRange.posEnd,   parentNodeRange.posEnd)
        indentical = cmpStart == 0 and cmpEnd == 0
    until (cmpStart >= 0 and cmpEnd <= 0 and not indentical) or cnt == 5

    -- Abort when line index of posEnd is larger than the whole buffer line count
    if parentNodeRange.posEnd[1] > fn.line("$") then return false end

    -- Make sure paren node has no error
    if parentNode:has_error() then return false end

    -- Check if the new parentNode matching the syntax type of code block pairs
    if not vim.tbl_contains(codeBlockPairBlackList, vim.bo.filetype)
        and cbPairs["ts_" .. parentNode:type()]
        -- Avoid get the code block when the lastParentNode comes from thoese treesitter nodes
        and not vim.tbl_contains(cbPairs["ts_" .. parentNode:type()].skips, lastParentNode:type())
        then

        return M.getPairNode(parentNode)
    else
        return parentNode
    end
end


--- Generate a region table containing all the treesitter node infos needed to
--- be selected in visual mode
--- @param startNode  treesitter object
--- @param pairNode   optional treesitter object
--- @param parentNode optional treesitter object Parent node of last treesitter candidate
--- @param lastCand   optional table Last candidate
--- @return table
M.getNodeCandidate = function(startNode, pairNode, parentNode, lastCand)
    local tsRange

    if not pairNode then
        -- Store the startNode as the only treesitter node inside a candidate
        -- table. The range is determined by the scope of its range() method
        tsRange = M.getNodeRange(startNode, false)
        tsRange.nodes = {startNode}
    else
        -- The candidate region is determine by two treesitter nodes

        -- Find the valid child
        local pairTypes = cbPairs["ts_" .. parentNode:type()].pairs
        local blockStartRange = M.getNodeRange(startNode, false)
        local blockEndRange
        -- Figure out whether the pairNode is the treesitter node has the name
        -- matching the given pair statement table or the last valid treesitter
        -- node before it run out of sibling check
        if vim.tbl_contains(pairTypes, pairNode:type()) then
            blockEndRange = M.getNodeRange(pairNode:prev_named_sibling(), false)
        else
            blockEndRange = M.getNodeRange(pairNode, false)
        end
        tsRange = {
            posStart = blockStartRange.posStart,
            posEnd   = blockEndRange.posEnd,
        }
        -- Check whether the range of new code block is identical to
        -- the last candidate. This usually happens when the code
        -- block is composed of only one single statement
        if lastCand then
            local cmpStart = util.compareDist(lastCand.posStart, tsRange.posStart)
            local cmpEnd = util.compareDist(lastCand.posEnd, tsRange.posEnd)
            if cmpStart == 0 and cmpEnd == 0 then
                -- Fallback to the parentNode instead
                tsRange = M.getNodeRange(parentNode, false)
                tsRange.nodes = {parentNode}
            else
                tsRange.nodes = {startNode, pairNode}
            end
        else
            tsRange.nodes = {startNode, pairNode}
        end
    end

    tsRange.type  = "treesitter"

    return tsRange
end


return M
