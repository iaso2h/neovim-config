-- File: interestingWord
-- Author: iaso2h
-- Description: Highlight word in different random colors, heavily inspired
--              by https://github.com/lfv89/vim-interestingwords/blob/master/plugin/interestingwords.vim
-- Version: 0.0.5
-- Last Modified: 2023-4-19
-- TODO: implement do repeat
local M   = {
    hlIDs = {},
    guibgs = {},
    lastWord = {}
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
    guiStyle        = "bold"
}


---Navigating by the highlighted interesting word under -          the cursor
---@param direction number Previous by -1, Next by 1
M.colorNav = function(direction)
    if type(direction) ~= "number" and math.abs(direction) ~= 1 then
        vim.notify("Expected -1 or 1 for the argument of colorNav()", vim.log.levels.ERROR)
    end
end


---Generate guifg and guibg in hexadecimal string
---@return string, string hexadecimal color string value
local randomGUI = function()
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
end


---Get highlight group base on how many guibgs have been created
---@param opts table Table value contain option configurations
---@param curWinID number Window ID
---@return string, string String value of highlight group name and string value of guibg in hexadecimal
local getHLGroup = function(opts, curWinID)
    -- Reuse highlightgroup when there are 10
    if #M.guibgs == 10 then
        if not M.lastWord[curWinID] then
            return opts.highlightPrefix ..  1
        else
            local lastWord = M.lastWord[curWinID]
            local offset   = (M.hlIDs[curWinID][lastWord]["count"] % 10) + 1
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
end


---Apply color for interesting words by calling and wrapping around matchadd()
---@param word string String value of word to be highlighted
---@param opts table Table value contain option configurations
---@param curWinID number Window ID
local applyColor = function(word, opts, curWinID)
    M.hlIDs[curWinID] = M.hlIDs[curWinID] or {}

    local ignoreCase = opts.ignoreCase and [[\c]] or [[\C]]
    local pattern
    if opts.noWordBoundary then
        pattern = string.format([[\V%s%s]], ignoreCase, word)
    else
        pattern = string.format([[\V%s\<%s\>]], ignoreCase, word)
    end
    local hlGroup, guibg = getHLGroup(opts, curWinID)
    local hlID    = vim.fn.matchadd(hlGroup, pattern, opts.priority)

    -- Record {{{
    M.hlIDs[curWinID][word] = {}
    M.hlIDs[curWinID][word].count   = #vim.tbl_keys(M.hlIDs[curWinID])
    M.hlIDs[curWinID][word].hlID    = hlID
    M.hlIDs[curWinID][word].hlGroup = hlGroup
    M.hlIDs[curWinID][word].guibg   = guibg
    M.lastWord[curWinID] = word
    -- }}} Record
end


---This the function where g@ function call in normal mode and visual mode to
--start adding the highlighting to interesting words
---@param args table {motionType, vimMode, plugMap}
--        motionType: String. Motion type by which how the operator perform.
--                    Can be "line", "char" or "block"
--        vimMode:    String. Vim mode. See: `:help mode()`
--        plugMap:    String. eg: <Plug>myPlug
---@return nil
local operator = function(args)
    local motionType = args[1]
    -- Only support characterwise
    if motionType == "block" or motionType == "line" then
        return vim.notify(string.format("%swise is not supported", motionType), vim.log.levels.WARN)
    end

    local vimMode = args[2]
    local op      = require("operator")
    local plugMap = vimMode == "n" and op.plugMap or args[3]
    local opts    = args[4]
    local curWinID = vim.api.nvim_get_current_win()

    local posStart
    local posEnd
    local word
    -- Get content {{{
    if vimMode == "n" then
        posStart = vim.api.nvim_buf_get_mark(0, "[")
        posEnd   = vim.api.nvim_buf_get_mark(0, "]")
        vim.api.nvim_win_set_cursor(curWinID, posStart)
        vim.cmd "noa normal! v"
        vim.api.nvim_win_set_cursor(curWinID, posEnd)
        vim.cmd "noa normal! v"
    else
        vim.cmd("noa normal! gv" .. t"<Esc>")
        posStart = vim.api.nvim_buf_get_mark(0, "<")
        posEnd   = vim.api.nvim_buf_get_mark(0, ">")
    end
    word = vim.fn.escape(require("selection").get("string"), [=[\/.-][]=])

    -- }}} Store word info

    applyColor(word, opts, curWinID)
    -- Restore cursor position
    if vimMode == "n" and not require("util").withinRegion(op.cursorPos, posStart, posEnd) then
        return
    else
        vim.api.nvim_win_set_cursor(curWinID, op.cursorPos)
    end

    -- Dot repeat
    if vimMode ~= "n" then
        vim.fn["repeat#set"](t(plugMap))
        vim.fn["visualrepeat#set"](t(plugMap))
    end
    -- }}} Get content
end


M.operatorWordBoundary = function(args)
    local opts = defaultOpts
    opts.noWordBoundary = false
    args[4] = opts
    operator(args)
end


M.operatorNoWordBoundary = function(args)
    local opts = defaultOpts
    opts.noWordBoundary = true
    args[4] = opts
    operator(args)
end


---Reapplying color to the last word when you feels like the last highlighting word not favouring you
---@param opts table Table value contain option configurations
---@return nil
M.reapplyColor = function(opts)
    local curWinID = vim.api.nvim_get_current_win()
    local lastWord = M.lastWord[curWinID]
    if not lastWord then return vim.notify("No interesting highlighted word in this window yet", vim.log.levels.WARN) end

    opts = opts or defaultOpts
    local hlGroup = M.hlIDs[curWinID][lastWord]["hlGroup"]
    local guibg   = M.hlIDs[curWinID][lastWord]["guibg"]

    local guifg, guibgNew = randomGUI()
    tbl_replace(M.guibgs, guibgNew, guibg, false, 1, true)
    vim.cmd(string.format("noa hi! %s guifg=%s guibg=%s gui=%s", hlGroup, guifg, guibgNew, opts.guiStyle))
    M.hlIDs[curWinID][lastWord]["guibg"] = guibgNew
end


---Clear all the highlightings on all interesting words in current window.
-- But it still can recovered by call restoreColor()
---@return nil
M.clearColor = function()
    local curWinID = vim.api.nvim_get_current_win()
    if not M.hlIDs[curWinID] then
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

    for _, word in ipairs(vim.tbl_keys(M.hlIDs[curWinID])) do
        vim.fn.matchdelete(M.hlIDs[curWinID][word]["hlID"])
    end
    restore = {hlIDs = M.hlIDs, guibgs = M.guibgs, lastWord = M.lastWord}
    M.hlIDs    = {}
    M.guibgs   = {}
    M.lastWord = {}
end


---Only restorable when you called clear in current window
---@param opts table Table value contain option configurations
---@return nil
M.restoreColor = function(opts)
    if next(M.hlIDs) then return vim.notify("Interesting highlighted words in this window need to be clear before restoration", vim.log.levels.WARN) end

    opts = opts or defaultOpts

    M.hlIDs    = restore.hlIDs
    M.guibgs   = restore.guibgs
    M.lastWord = restore.lastWord
    for _, win in ipairs(vim.tbl_keys(M.hlIDs)) do
        if not vim.api.nvim_win_is_valid(win) then
            M.hlIDs[win]    = nil
            M.lastWord[win] = nil
        end
    end

    local curWinID = vim.api.nvim_get_current_win()
    local hlGroup
    local pattern
    local hlID

    if not M.hlIDs[curWinID] then return vim.notify("No interesting highlighted words to be recolored in this window", vim.log.levels.WARN) end
    for _, word in ipairs(vim.tbl_keys(M.hlIDs[curWinID])) do
        hlGroup = M.hlIDs[curWinID][word]["hlGroup"]
        hlID    = M.hlIDs[curWinID][word]["hlID"]
        pattern = opts.ignoreCase and string.format([[\c%s]], word) or string.format([[\C%s]], word)
        vim.fn.matchadd(hlGroup, pattern, opts.priority, hlID)
    end
end


return M
