-- File: expandRegion/init.lua
-- Author: iaso2h
-- Description: Expand region in visual character mode.
-- For treesitter support, only tested on python, lua, c files
-- Version: 0.1.4
-- Last Modified: 2023-10-25
local ts   = require("expandRegion.treesitter")
local tx   = require("expandRegion.textobj")
local util = require("util")
local M    = {}

---@class ExpandRegionCandidate
---@field type? string
---@field posStart? integer[]
---@field posEnd? integer[]
---@field tsNode? TSNode|nil
---@field textObj? TSNode|nil
---@field length? integer|nil
---@field content? string|nil

---@class ExpandRegionTextObj
---@field mapping string
---@field builtin boolean

local optsDefault = {
    ---@type ExpandRegionTextObj
    textObjs = {
        {
            mapping = "i,w",
            builtin = false,
        },
        {
            mapping = "iw",
            builtin = true,
        },
        {
            mapping = 'i"',
            builtin = true,
        },
        {
            mapping = "ib",
            builtin = true,
        },
        {
            mapping = "iB",
            builtin = true,
        },
    },
    putCursorAtStart = true
}

M.opts = {}
M.dev = false
M.candidates    = nil
M.candidateIdx  = nil
M.saveView      = nil
M.cursorPos     = nil
M.bufNr         = nil
M.restoreOption = nil


--- Save vim options
local saveOption = function() -- {{{
    if vim.o.wrapscan == false and vim.o.selection == "inclusive" then return end

    local wrapscan  = vim.o.wrapscan
    local selection = vim.o.selection
    vim.o.wrapscan  = false
    vim.o.selection = "inclusive"

    M.restoreOption = function()
        vim.o.wrapscan  = wrapscan
        vim.o.selection = selection
    end
end -- }}}
--- Check the whether the targetCandidateIdx is out of scope of table candidates
---@param visualStart table Line number and column index in (1, 0) based
---@param visualEnd table Line number and column index in (1, 0) based
---@return boolean # Return true to indicate the current visual selection has
--the same range of the current candidate and it's ok to expand or shrink by
--selecting the sibling candidates on the fly. Return false to indicate that
--the existing candidates doesn't apply to the visual selection
local compareSelectionWithCandidate = function(visualStart, visualEnd) -- {{{
    if M.candidates and
        vim.api.nvim_get_current_buf() == M.bufNr and
        -- Compare the visual selected region with the last candidate
        (M.candidateIdx <= #M.candidates and M.candidateIdx >= 1) then

        local candidate = M.candidates[M.candidateIdx]

        if util.compareDist(visualStart, candidate.posStart) == 0
            and util.compareDist(visualEnd, candidate.posEnd) == 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end -- }}}
--- Decide which region to be selected
---@param direction integer 1 indicates expand, -1 indicates shrink
local selectCandidate = function(direction) -- {{{
    --- Select candidate in Neovim according to its field
    ---@param candidate ExpandRegionCandidate
    local selectRegion = function(candidate) -- {{{
        if M.opts.putCursorAtStart then
            vim.api.nvim_win_set_cursor(M.winId, candidate.posEnd)
            vim.cmd [[noa norm v]]
            vim.api.nvim_win_set_cursor(M.winId, candidate.posStart)
        else
            vim.api.nvim_win_set_cursor(M.winId, candidate.posStart)
            vim.cmd [[noa norm v]]
            vim.api.nvim_win_set_cursor(M.winId, candidate.posEnd)
        end
    end -- }}}

    local lastCandidate = M.candidates[M.candidateIdx]
    M.candidateIdx = M.candidateIdx + direction

    if M.candidateIdx - #M.candidates == 1 then
        -- When target index is out of scope. No more new candidate can be
        -- generated for textobject type candidate, but treesitter might still
        -- can get new parent node on the fly
        if lastCandidate.type == "textobject" then
            -- Do not generate any more candidates when reach maximum index
            vim.notify("No more textobject candidates", vim.log.levels.INFO)

            -- Always reset the index to the length of the candidates table
            M.candidateIdx = #M.candidates
            -- Remain selection
            selectRegion(M.candidates[M.candidateIdx])
        else
            -- Treesitter type candidate

            -- Try to get new treesitter node candidate
            -- NOTE: pairNode and parentNode might be empty
            local parentCandidate = ts.getNodeCandidate(M.bufNr, lastCandidate.tsNode, 1)
            if next(parentCandidate) and parentCandidate.tsNode:id() ~= lastCandidate.tsNode:id() then
                table.insert(M.candidates, parentCandidate)
                selectRegion(M.candidates[M.candidateIdx])
            else
                vim.notify("No more wider treesitter candidates", vim.log.levels.INFO)

                -- Always reset the index to the length of the candidates table
                M.candidateIdx = #M.candidates
                selectRegion(M.candidates[M.candidateIdx])
            end
        end
    elseif M.candidateIdx == 0 then
        -- When target index is qeual 0. Exit into normal mode for textobject
        -- type candidate, but treesitter might still can get new parent node on the fly
        if lastCandidate.type == "textobject" then
            -- index value of 0 means get back to normal mode
            vim.fn.winrestview(M.saveView)
        else
            -- Treesitter
            -- Try to get new treesitter node candidate
            -- NOTE: pairNode and parentNode might be empty
            local childCandidate = ts.getNodeCandidate(M.bufNr, lastCandidate.tsNode, -1, M.cursorPos)
            if next(childCandidate) and childCandidate.tsNode:id() ~= lastCandidate.tsNode:id() then
                table.insert(M.candidates, 1, childCandidate)
                selectRegion(M.candidates[1])
            else
                vim.notify("No more narrower treesitter candidates", vim.log.levels.INFO)

                -- Always reset the index to 1 to refer to the first candidate
                M.candidateIdx = 1
                selectRegion(M.candidates[M.candidateIdx])
            end
        end
    else
        selectRegion(M.candidates[M.candidateIdx])
    end
end -- }}}
--- Compute and generate textobject candidates
local computeCandidateTextObject = function() -- {{{
    M.candidates = tx.getTextObjCandidate(M.opts, M.bufNr, M.cursorPos)
end -- }}}
--- Compute and generate candidates table, which contain info about the start and end of regions
local generateCandidates = function() -- {{{
    if require("vim.treesitter.highlighter").active[M.bufNr] then
        local initNode = vim.treesitter.get_node()
        if not initNode then
            if M.dev then logBuf("Unabled to find treesitter node at cursor position") end
            return computeCandidateTextObject()
        end

        ---@diagnostic disable-next-line: undefined-field
        if not initNode:has_error() then
            -- Generate subword text objects first, and then append
            -- Treesitter node in the end
            local initCandidate = ts.getNodeCandidate(M.bufNr, initNode, 1)
            M.candidates = tx.getTextObjCandidate(
                M.opts,
                M.bufNr,
                M.cursorPos,
                initCandidate
            )
        else
            return computeCandidateTextObject()
        end
    else
        return computeCandidateTextObject()
    end
end -- }}}
--- Initiate all the settings
local initExpand = function() -- {{{
    M.winId        = vim.api.nvim_get_current_win()
    M.bufNr        = vim.api.nvim_get_current_buf()
    M.cursorPos    = vim.api.nvim_win_get_cursor(M.winId)
    M.candidates   = {}
    M.candidateIdx = 0
    M.saveView     = vim.fn.winsaveview()
end -- }}}
--- Start the expanding and shrinking of region
---@param vimMode string See: `:help mode()`
---@param direction integer 1 indicates expand, -1 indicates shrink
---@param opts? table Option table
M.expandShrink = function(vimMode, direction, opts) -- {{{
    -- Don't support visual block or visual line mode
    if vimMode == "\22" or vimMode == "V" then return end
    assert(direction == 1 or direction == -1, "#2 parameter must be either 1 or -1")

    opts = opts or {}
    M.opts = vim.tbl_deep_extend("keep", opts, optsDefault)

    if vimMode == "v" then
        local bufNrTemp   = vim.api.nvim_get_current_buf()
        local visualStart = vim.api.nvim_buf_get_mark(bufNrTemp, "<")
        local visualEnd   = vim.api.nvim_buf_get_mark(bufNrTemp, ">")

        if compareSelectionWithCandidate(visualStart, visualEnd) then
            selectCandidate(direction)
        else
            if require("vim.treesitter.highlighter").active[bufNrTemp] then
                -- TODO: placing cursor at anthoer end of the selection might
                -- lead to a different treesitter node outcome
                local candidate = ts.getNodeCandidateBySelection(bufNrTemp, visualStart, visualEnd, direction)

                if not next(candidate) then
                    local descStr = direction == 1 and "wider" or "narrower"
                    vim.notify("Can't find treesitter node that has a " .. descStr .. " region than the current visual selection", vim.log.levels.INFO)
                else
                    initExpand()
                    M.candidates = {candidate}
                    if direction == 1 then
                        M.candidateIdx = 0
                    else
                        M.candidateIdx = 2
                    end
                    selectCandidate(direction)
                end
            else
                -- saveOption()
                local descStr = direction == 1 and "wider" or "narrower"
                vim.notify("Can't find textobject that has a " .. descStr .. " region than the current visual selection", vim.log.levels.INFO)
            end
        end
    elseif vimMode == "n" then
        initExpand()
        saveOption()

        local ok, msgOrVal = pcall(generateCandidates)
        if not ok then
            vim.notify(msgOrVal, vim.log.levels.ERROR)
        end

        -- Select candidate
        if next(M.candidates) then
            selectCandidate(direction)
        else
            vim.notify("No candidates", vim.log.levels.INFO)
        end

        -- Restore vim options
        if vim.is_callable(M.restoreOption) then M.restoreOption(); M.restoreOption = nil end
    end
end -- }}}

return M
