-- File: init
-- Author: iaso2h
-- Description: Expand region in visual character mode.
-- For treesitter support, only tested on python, lua, c files
-- Version: 0.0.16
-- Last Modified: 2021-10-09
local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local ts      = require("expandRegion.treesitter")
local tx      = require("expandRegion.textobj")
local cbPairs = require("expandRegion.treesitterCodeBlockPairs")
local util    = require("util")
local M   = {}

local optsDefault = {
    -- textObjs = {"i,w", "iw", 'i"', "ib", "iB"},
    textObjs = {"i,w", "iw", 'i"'},
    treesitterExtent = true,
    putCursorAtStart = true
}

_G.ExpandRegionDebugMode = false

M.candidates    = nil
M.candidateIdx  = nil
M.saveView      = nil
M.cursorPos     = nil
M.curBufNr      = nil
M.restoreOption = nil


--- Save vim options
local saveOption = function()
    if vim.o.wrapscan == false and vim.o.selection == "inclusive" then return end
    local wrapscan
    local selection
    wrapscan = vim.o.wrapscan
    vim.opt.wrapscan = false
    selection = vim.o.selection
    vim.opt.selection = "inclusive"

    M.restoreOption = function()
        vim.opt.wrapscan  = wrapscan
        vim.opt.selection = selection
    end
end


--- Initiate all the settings
local initExpand = function()
    M.curBufNr     = api.nvim_get_current_buf()
    M.cursorPos    = api.nvim_win_get_cursor(0)
    M.candidates   = {}
    M.candidateIdx = 0
    M.saveView     = fn.winsaveview()
end


--- Select region in visual character mode
--- @param opts table Option table
--- @param candidate table A region contain infomation about the start and end of
---        an area going to be selected
local selectRegion = function(opts, candidate)
    if ExpandRegionDebugMode and candidate.type == "treesitter" then
        Print(candidate.nodes[1]:type())
    end
    if opts.putCursorAtStart then
        api.nvim_win_set_cursor(0, candidate.posEnd)
        cmd [[noa norm v]]
        api.nvim_win_set_cursor(0, candidate.posStart)
    else
        api.nvim_win_set_cursor(0, candidate.posStart)
        cmd [[noa norm v]]
        api.nvim_win_set_cursor(0, candidate.posEnd)
    end
end


--- Check the whether the targetCandidateIdx is out of scope of table candidates
local validateCandidates = function()
    if #M.candidates == 0 then return false end

    if api.nvim_get_current_buf() == M.curBufNr
        -- Compare the visual seleted region with the last candidate
        and (M.candidateIdx <= #M.candidates and M.candidateIdx >= 1) then
        local posStart = api.nvim_buf_get_mark(M.curBufNr, "<")
        local posEnd   = api.nvim_buf_get_mark(M.curBufNr, ">")
        local cand     = M.candidates[M.candidateIdx]

        if util.compareDist(posStart, cand.posStart) == 0
            and util.compareDist(posEnd, cand.posEnd) == 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end


--- Decide which region to be selected
--- @param opts table option table
--- @param direction number 1 indicates expand, -1 indicates shrink
local getCandidate = function(opts, direction)
    local lastCand = M.candidates[M.candidateIdx]
    M.candidateIdx = M.candidateIdx + direction

    if M.candidateIdx - #M.candidates == 1 then
        -- Target index is out of scope. No more new candidate can be
        -- generated for textobject type candidate, but treesitter might still
        -- can get new parent node dynamically
        if lastCand.type == "textObj" then
            -- Text Object
            -- Do not generate any more candidates when reach maximum index
            vim.notify("No more candidates", vim.log.levels.INFO)

            selectRegion(opts, lastCand)
        else
            -- Treesitter
            -- Try to get new treesitter node candidate
            -- NOTE: pairNode and parentNode might be empty
            local startNode, pairNode, parentNode = ts.getParentNode(lastCand.nodes)
            if startNode then
                M.candidates[#M.candidates+1] = ts.getNodeCandidate(startNode, pairNode, parentNode, lastCand)
            else
                vim.notify("No more candidates", vim.log.levels.INFO)
            end

            -- BUG: comment node was not parsed correctly
            -- Always get the last candidate whether new node is insert or not
            selectRegion(opts, M.candidates[#M.candidates])
        end

        -- Always reset the index to the length of the candidates table
        M.candidateIdx = #M.candidates

    elseif M.candidateIdx == 0 then
        -- index value of 0 means get back to normal mode
        fn.winrestview(M.saveView)
    else
        selectRegion(opts, M.candidates[M.candidateIdx])
    end
end


--- Compute and generate candidates table, which contain info about the start and end of regions
--- @param opts table option table
--- @param direction number 1 indicates expand, -1 indicates shrink
local computeCandidate = function(opts, direction)
    local startNode, pairNode, parentNode
    if opts.treesitterExtent then
        startNode = ts.getCursorNode(M.cursorPos)
        -- Check code block if the treesitter node matches the compouned statement
        if cbPairs["ts_" .. startNode:type()] then
            startNode, pairNode, parentNode = ts.getPairNode(startNode)
        end
    end

    if opts.treesitterExtent and startNode and not startNode:has_error() then
        M.candidates = tx.getTextObj(opts, M.curBufNr, M.cursorPos, startNode)
        -- Generate subword text objects first, and then append
        -- Treesitter node in the end
        M.candidates[#M.candidates+1] = ts.getNodeCandidate(startNode, pairNode, parentNode)

        getCandidate(opts, direction)
    else
        M.candidates = tx.getTextObj(opts, M.curBufNr, M.cursorPos)
        if M.candidates[#M.candidates] then
            getCandidate(opts, direction)
        else
            vim.notify("No candidates", vim.log.levels.INFO)
        end
    end
end


--- Start the expanding and shrinking of regioin
--- @param vimMode string
--- @param direction number 1 indicates expand, -1 indicates shrink
--- @param opts table option table
M.expandShrink = function(vimMode, direction, opts)
    -- Doen't support visual block or visual line mode
    if vimMode == "\22" or vimMode == "V" then return end
    opts = opts or optsDefault

    if vimMode == "v" then
        -- TODO: not support custom visual selected region yet
        if not validateCandidates() then return end

        getCandidate(opts, direction)
    else
        -- Normal mode
        -- Initiate expansion in Normal mode
        initExpand()
        saveOption()

        local ok, msg = pcall(computeCandidate, opts, direction)
        if not ok then vim.notify(msg, vim.log.levels.ERROR) end

        -- Restore vim options
        if vim.is_callable(M.restoreOption) then M.restoreOption(); M.restoreOption = nil end
    end

end

return M
