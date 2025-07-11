-- File: interestingWord
-- Author: iaso2h
-- Description: Highlight word in different random colors, heavily inspired
--              by https://github.com/lfv89/vim-interestingwords/blob/master/plugin/interestingwords.vim
-- Version: 0.0.7
-- Last Modified: 2025-03-02
local M   = {
    hlIds = {},
    guibgs = {},
    lastWord = {},
    plugMap = ""
}
local restore
-- e.g:
-- M.hlID = {
    -- winID = {
        -- customWord1 = {
            -- count   = 1,
            -- hlID    = 1,
            -- hlGroup = ...
            -- guibg   = ...
        -- }
    -- }
-- }
local defaultOpts = {
    highlightPrefix = "InterestingWord",
    priority        = 0,
    ignoreCase      = false,
    noWordBoundary  = true,
    guiStyle        = "bold",
}

local opts = {}
--- Navigating by the highlighted interesting word under the cursor
---@param direction integer Previous by -1, Next by 1
M.colorNav = function(direction) -- {{{
    if type(direction) ~= "number" and math.abs(direction) ~= 1 then
        vim.api.nvim_echo( { { "Expected -1 or 1 for the argument of colorNav()"} }, true, {err = true} )
    end
end -- }}}
---Generate guifg and guibg in hexadecimal string
---@return string, string # Hexadecimal color string value
local randomGUI = function() -- {{{
    local guibg
    local guifg
    local randomNr

    while true do
        randomNr = math.random(0, 16777216)
        guibg = string.format("#%x", randomNr)
        if randomNr < 1048576 then
            guibg = "#" .. string.rep("0", (7 - #guibg)) .. string.sub(guibg, 2, -1)
        end
        if not M.guibgs[guibg] then break end
    end

    guifg = randomNr >= 8388608 and "#000000" or "#ffffff"

    return guifg, guibg
end -- }}}
--- Get the highlight group based on how many guibgs have been created in current window
---@param opts table Table value contain option configurations
---@param curWinID integer Window ID
---@return string, string # String value of highlight group name and string value of guibg in hexadecimal
local getHlGroup = function(opts, curWinID) -- {{{
    -- Reuse highlightgroup when there are 10
    if #M.guibgs == 10 then
        if not M.lastWord[curWinID] then
            return opts.highlightPrefix ..  1
        else
            local lastWord = M.lastWord[curWinID]
            local offset   = (M.hlIds[curWinID][lastWord]["count"] % 10) + 1
            return opts.highlightPrefix .. offset
        end
    -- Create new highlight group
    else
        local guifg, guibg = randomGUI()
        local highlightGroup

        highlightGroup = opts.highlightPrefix .. (#M.guibgs + 1)

        vim.cmd(string.format([[hi! %s guifg=%s guibg=%s gui=%s]],
            highlightGroup, guifg, guibg, opts.guiStyle))
        M.guibgs[#M.guibgs+1] = guibg

        return highlightGroup, guibg
    end
end -- }}}
--- Apply color for interesting words by calling and wrapping around matchadd()
---@param word string String value of word to be highlighted
---@param opts table Table value contain option configurations
---@param curWinID integer Window ID
local applyColor = function(word, opts, curWinID) -- {{{
    M.hlIds[curWinID] = M.hlIds[curWinID] or {}

    local ignoreCase = opts.ignoreCase and [[\c]] or [[\C]]
    local pattern
    if opts.noWordBoundary then
        pattern = string.format([[\V%s%s]], ignoreCase, word)
    else
        pattern = string.format([[\V%s\<%s\>]], ignoreCase, word)
    end
    local hlGroup, guibg = getHlGroup(opts, curWinID)
    local hlID    = vim.fn.matchadd(hlGroup, pattern, opts.priority)

    -- Record {{{
    M.hlIds[curWinID][word] = {}
    M.hlIds[curWinID][word].count   = #vim.tbl_keys(M.hlIds[curWinID])
    M.hlIds[curWinID][word].hlID    = hlID
    M.hlIds[curWinID][word].hlGroup = hlGroup
    M.hlIds[curWinID][word].guibg   = guibg
    M.lastWord[curWinID] = word
    -- }}} Record
end -- }}}
---This the function where g@ function call in normal mode and visual mode to start adding the highlighting to interesting words
---@param opInfo GenericOperatorInfo
local operator = function(opInfo) -- {{{
    -- Only support characterwise
    if opInfo.motionType == "block" or opInfo.motionType == "line" then
        return vim.api.nvim_echo(
            { {string.format("%swise is not supported", opInfo.motionType), "WarningMsg" } },
            true,
            {}
        )
    end

    local op = require("operator")
    local winId = vim.api.nvim_get_current_win()
    local bufNr = vim.api.nvim_get_current_buf()

    local posStart
    local posEnd
    local word
    -- Get content {{{
    if opInfo.vimMode == "n" then
        local motionRegion = op.getMotionRegion(opInfo.vimMode, bufNr)
        posStart = motionRegion.Start
        posEnd   = motionRegion.End
        vim.api.nvim_win_set_cursor(winId, posStart)
        vim.cmd "noa normal! v"
        vim.api.nvim_win_set_cursor(winId, posEnd)
        vim.cmd "noa normal! v"
    else
        vim.cmd("noa normal! gv" .. t"<Esc>")
        posStart = vim.api.nvim_buf_get_mark(0, "<")
        posEnd   = vim.api.nvim_buf_get_mark(0, ">")
    end
    word = vim.fn.escape(require("selection").get("string", false), [=[\/.-][]=])

    -- }}} Store word info

    applyColor(word, opts, winId)
    -- Restore cursor position
    if opInfo.vimMode == "n" and not require("util").withinRegion(op.cursorPos, posStart, posEnd) then
        return
    else
        vim.api.nvim_win_set_cursor(winId, op.cursorPos)
    end

    -- Dot repeat
    if opInfo.vimMode ~= "n" then
        if vim.fn.exists("g:loaded_repeat") == 1 then
            vim.fn["repeat#set"](t(M.plugMap))
        end
        if vim.fn.exists("g:loaded_visualrepeat") == 1 then
            vim.fn["visualrepeat#set"](t(M.plugMap))
        end
    end
    -- }}} Get content
end -- }}}
--- Mark the word with no word boundary
---@param args table see `operator()`
M.operatorWordBoundary = function(args) -- {{{
    opts = defaultOpts
    opts.noWordBoundary = false
    M.plugMap = [[<Plug>InterestingWordOperatorWordBoundary]]
    operator(args)
end -- }}}
--- Mark the word with no word boundary(`\<` and `\>`)
---@param args table see `operator()`
M.operatorNoWordBoundary = function(args) -- {{{
    opts = defaultOpts
    opts.noWordBoundary = true
    M.plugMap = [[<Plug>InterestingWordOperatorNoWordBoundary]]
    operator(args)
end -- }}}
---Reapplying color to the last word when you feels like the last highlighting word not favouring you
---@param opts table Table value contain option configurations
M.reapplyColor = function(opts) -- {{{
    local curWinID = vim.api.nvim_get_current_win()
    local lastWord = M.lastWord[curWinID]
    if not lastWord then return vim.api.nvim_echo({ { "No interesting highlighted word in this window yet", "WarningMsg" } }, true, {}) end

    opts = opts or defaultOpts
    local hlGroup = M.hlIds[curWinID][lastWord]["hlGroup"]
    local guibg   = M.hlIds[curWinID][lastWord]["guibg"]

    local guifg, guibgNew = randomGUI()
    tbl_replace(M.guibgs, guibgNew, guibg, false, 1, true)
    vim.cmd(string.format("noa hi! %s guifg=%s guibg=%s gui=%s", hlGroup, guifg, guibgNew, opts.guiStyle))
    M.hlIds[curWinID][lastWord]["guibg"] = guibgNew
end -- }}}
---Clear all the highlightings on all interesting words in current window. But it still can recovered by call restoreColor()
M.clearColor = function() -- {{{
    local curWinID = vim.api.nvim_get_current_win()
    if not M.hlIds[curWinID] then
        vim.cmd "noa echohl MoreMsg"
        local answer = vim.fn.confirm("There're no match set in this window, do you want perform a clearmatch() anyway?",
            ">>> &Yes\n&No", 2, "Question")
        vim.cmd "noa echohl None"
        if answer == 1 then
            return vim.fn.clearmatches()
        else
            return
        end
    end

    for _, word in ipairs(vim.tbl_keys(M.hlIds[curWinID])) do
        vim.fn.matchdelete(M.hlIds[curWinID][word]["hlID"])
    end
    restore = {hlIDs = M.hlIds, guibgs = M.guibgs, lastWord = M.lastWord}
    M.hlIds    = {}
    M.guibgs   = {}
    M.lastWord = {}
end -- }}}
---Only restorable when you called clear in current window
---@param opts table Table value contain option configurations
M.restoreColor = function(opts) -- {{{
    if next(M.hlIds) then return vim.api.nvim_echo({ { "Interesting highlighted words in this window need to be clear before restoration", "WarningMsg" } }, true, {}) end

    opts = opts or defaultOpts

    M.hlIds    = restore.hlIDs
    M.guibgs   = restore.guibgs
    M.lastWord = restore.lastWord
    for _, win in ipairs(vim.tbl_keys(M.hlIds)) do
        if not vim.api.nvim_win_is_valid(win) then
            M.hlIds[win]    = nil
            M.lastWord[win] = nil
        end
    end

    local curWinID = vim.api.nvim_get_current_win()
    local hlGroup
    local pattern
    local hlID

    if not M.hlIds[curWinID] then return vim.api.nvim_echo({ { "No interesting highlighted words to be recolored in this window", "WarningMsg" } }, true, {}) end
    for _, word in ipairs(vim.tbl_keys(M.hlIds[curWinID])) do
        hlGroup = M.hlIds[curWinID][word]["hlGroup"]
        hlID    = M.hlIds[curWinID][word]["hlID"]
        pattern = opts.ignoreCase and string.format([[\c%s]], word) or string.format([[\C%s]], word)
        vim.fn.matchadd(hlGroup, pattern, opts.priority, hlID)
    end
end -- }}}


return M
