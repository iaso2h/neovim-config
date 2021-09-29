local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local util = require("util")
local M   = {}

local textObjsDefault = {"i,w", "iw", 'ib', "iB"}

local candidateIdx = 0
local cursorPos
local curBufNr
local candidates

local restoreOption
local saveView


local saveOption = function()
    if vim.o.wrapscan == false and vim.o.selection == "inclusive" then return end
    local wrapscan
    local selection
    wrapscan = vim.o.wrapscan
    vim.opt.wrapscan = false
    selection = vim.o.selection
    vim.opt.selection = "inclusive"

    restoreOption = function()
        vim.opt.wrapscan  = wrapscan
        vim.opt.selection = selection
    end
end


local initExpand = function(vimMode)
    candidateIdx = 0
    curBufNr = api.nvim_get_current_buf()
    if vimMode == "V" then
        cmd([[noa norm! gvmz]] .. t"<Esc>")
        cursorPos = api.nvim_buf_get_mark(curBufNr, "z")
    else
        cursorPos = api.nvim_win_get_cursor(0)
    end
end


local getVisualStartEnd = function()
    return api.nvim_buf_get_mark(curBufNr, "<"), api.nvim_buf_get_mark(curBufNr, ">")
end


local chkComputeCandidates = function(vimMode)
    if vimMode == "v" and candidateIdx > 0 then
            -- TODO: expansion continues
        if api.nvim_get_current_buf() == curBufNr and candidateIdx ~= #candidates then
            local posStart, posEnd = getVisualStartEnd()
            local candidate = candidates[candidateIdx]
            if util.compareDist(posStart, candidate.posStart) == 0 and
                util.compareDist(posEnd, candidate.posEnd) == 0 then
                    -- TODO: wrap around treesitter
                return false
            end
        end
        return true
    else
        return true
    end
    -- return
end


local getSelectionTbl = function(textObj)
    saveView = fn.winsaveview()
    cmd([[noa norm v]] .. textObj .. t"<Esc>")
    local selection = {
        textObj  = textObj,
        length   = #util.visualSelection("string", true)
    }
    selection.startPos, selection.endPos = getVisualStartEnd()
    fn.winrestview(saveView)
    return selection
end


local removeDuplicate = function(tbl)
local i = 1
    local t = {}
    while i < #tbl do
        if not(tbl[i].length == tbl[i+1].length and tbl[i].startPos[2] == tbl[i+1].startPos[2]) then
            t[#t+1] = tbl[i]
        end
        i = i + 1
    end
    t[#t+1] = tbl[i]

    return t
end


local getCandidateTbl = function(textObjs)
    local filterSelection = function(i)
        -- TODO: filter out selection bigger than current selected area in
        -- visualmode
        return i.length > 1 and util.withinRegion(cursorPos, i.startPos, i.endPos)
    end
    local cnt = 1
    local textObjTbl
    local selectionTbl
    local candidateTble

    repeat
        if cnt == 1 then
            textObjTbl = textObjs
        else
            textObjTbl = vim.tbl_map(function(i) return string.rep(i, cnt) end, textObjs)
        end
        selectionTbl = vim.tbl_map(getSelectionTbl, textObjTbl)
        table.sort(selectionTbl, function(a, b) return b.length > a.length end)
        candidateTble = vim.tbl_filter(filterSelection, selectionTbl)

        cnt = cnt + 1
    until #candidateTble ~= 0 or cnt == 3

    candidateTble = removeDuplicate(candidateTble)

    return candidateTble
end


local selectRegion = function(vimMode, direction)
    if direction == 1 then
        if vimMode == "n" then
            saveView     = fn.winsaveview()
            candidateIdx = candidateIdx + 1
            -- cmd("norm v" .. candidates[candidateIdx].textObj)
        end
    else
        -- TODO: shrink
    end

    local region = candidates[candidateIdx]
    if region.textObj == "i,w" then
        local line = api.nvim_buf_get_lines(0, region.endPos[1] - 1, region.endPos[1], false)[1]
        if string.sub(line, region.endPos[2] + 1, region.endPos[2] + 1) == " " then
            region.endPos = {region.endPos[1], region.endPos[2] - 1}
        end
    end

    api.nvim_win_set_cursor(0, region.endPos)
    cmd [[noa norm! v]]
    api.nvim_win_set_cursor(0, region.startPos)
end


M.expandShrink = function(vimMode, direction, textObjs)
    -- Doen't support visual block or visual line mode
    if vimMode ~= "n" or vimMode ~= "v" then return end

    textObjs = textObjs or textObjsDefault
    saveOption()

    if chkComputeCandidates(vimMode) then
        initExpand()
        candidates = getCandidateTbl(textObjs)
        if #candidates == 0 then return end
    else
        -- TODO: start form last saved cursor position
        -- api.nvim_win_set_cursor(0, M.cursor)
    end

    selectRegion(vimMode, direction)


    if vim.is_callable(restoreOption) then restoreOption(); restoreOption = nil end
end

return M
