-- File: init
-- Author: iaso2h
-- Description: Expand region in visual character mode
-- Version: 0.0.12
-- Last Modified: 2021-10-02
local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local ts   = require("expandRegion.treesitter")
local tx   = require("expandRegion.textobj")
local util = require("util")
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
--- @param opts table option table
--- @param region table a region contain infomation about the start and end of
---        an area going to be selected
local selectRegion = function(opts, region)
    if opts.putCursorAtStart then
        api.nvim_win_set_cursor(0, region.posEnd)
        cmd [[noa norm v]]
        api.nvim_win_set_cursor(0, region.posStart)
    else
        api.nvim_win_set_cursor(0, region.posStart)
        cmd [[noa norm v]]
        api.nvim_win_set_cursor(0, region.posEnd)
    end
end


--- Check the whether the targetCandidateIdx is out of scope of table candidates
local validateCandidates = function()
    if #M.candidates == 0 then return false end

    if api.nvim_get_current_buf() == M.curBufNr and
        -- Compare the visual seleted region with the last candidate
        (M.candidateIdx <= #M.candidates and M.candidateIdx >= 1) then
        local posStart = api.nvim_buf_get_mark(M.curBufNr, "<")
        local posEnd   = api.nvim_buf_get_mark(M.curBufNr, ">")
        local cand     = M.candidates[M.candidateIdx]
        if type(cand) ~= "table" then cand = ts.getNodeRange(cand, true) end

        if util.compareDist(posStart, cand.posStart) == 0 and
            util.compareDist(posEnd, cand.posEnd) == 0 then
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
    local cand     = M.candidates[M.candidateIdx + direction]
    local lastCand = M.candidates[M.candidateIdx]
    M.candidateIdx = M.candidateIdx + direction

    -- Do not generate any more candidates when reach maximum index
    if M.candidateIdx - #M.candidates == 1 then
        if type(lastCand) == "table" then
            vim.notify("No more candidates", vim.log.levels.INFO)

            selectRegion(opts, lastCand)
        else
            local newNode = ts.getParentNode(lastCand)
            if newNode then
                M.candidates[#M.candidates+1] = newNode
            else
                newNode = lastCand
                vim.notify("No more candidates", vim.log.levels.INFO)
            end

            selectRegion(opts, ts.getNodeRange(newNode))
        end

        -- Always reset the index to the length of the candidates table
        M.candidateIdx = #M.candidates

    elseif M.candidateIdx == 0 then
        fn.winrestview(M.saveView)
    else
        if type(cand) == "table" then
            selectRegion(opts, cand)
        else
            selectRegion(opts, ts.getNodeRange(cand))
        end
    end
end


--- Compute and generate candidates table, which contain info about the start and end of regions
--- @param opts table option table
--- @param direction number 1 indicates expand, -1 indicates shrink
local computeCandidate = function(opts, direction)
    local tsNode
    if opts.treesitterExtent then
        tsNode = ts.getCursorNode(M.cursorPos)
    end

    if opts.treesitterExtent and tsNode then
        M.candidates = tx.getTextObj(opts, M.curBufNr, M.cursorPos, tsNode)
        -- Generate subword text objects first, and then append
        -- Treesitter node in the end
        M.candidates[#M.candidates+1] = tsNode

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
        -- BUG:
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
