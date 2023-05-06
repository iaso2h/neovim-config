-- File: foldmarker.lua
-- Author: iaso2h
-- Description: Improve fold marker
-- Version: 0.0.4
-- Last Modified: Sat 06 May 2023

local util = require("util")
local M = {
    ns = vim.api.nvim_create_namespace("foldmarker"),
    highlightNormalGroup = "Search",
    highlightDeleteGroup = "IncSearch",
    highlightTimeout = 500,
    commentText = ""
}


local foldmarkerStartQuery = [[
((comment) @comment
  (#lua-match? @comment "{{{")) @fold_marker_start
]]
local foldmarkerEndQuery = [[
((comment) @comment
  (#lua-match? @comment "}}}")) @fold_marker_end
]]


local chkMarkerOption = function()
    if not vim.wo.foldmethod == "marker" then
    -- if not (vim.wo.foldmethod == "expr" and
    --     vim.wo.foldexpr == "EnhanceFoldExpr()" and
    -- vim.wo.foldmarker == vim.opt.foldmarker._info.default) then
        return false
    else
        return true
    end
end


--- Get all the comment nodes that contain foldmark in the current buffer
---@param bufNr number
---@return table Table of Treesitter nodes
local getFoldmarkers = function(bufNr)
    local nodesStart = util.getQueryNodes(bufNr, foldmarkerStartQuery, 2)
    local nodesEnd   = util.getQueryNodes(bufNr, foldmarkerEndQuery, 2)

    if next(nodesStart) then
        if #nodesStart ~= #nodesEnd then
            vim.notify("Fold marker aren't symmetrical")
            return {}
        else
            return {Start = nodesStart, End = nodesEnd}
        end
    else
        vim.notify("Can't get fold markers from queries")
        return {}
    end
end


--- Get the current folder marker region
---@param cursorPos table (1, 0) indexed
---@param bufNr number
---@return table Table of Treesitter nodes
local getCurrentMarkers = function(cursorPos, bufNr)
    local markers = getFoldmarkers(bufNr)
    if not markers.Start then return {} end

    -- Find which marker region the cursor resides in
    local cursorIdx = {cursorPos[1] - 1, cursorPos[2]}
    local cursorFoldLevel = vim.fn.foldlevel(cursorPos[1])
    local nodeStart
    local nodeEnd
    for _, n in ipairs(markers.Start) do
        -- Store all the fold marker node with the one has the same foldlevel
        -- When the fold line is bigger than the cursorline, use the last stored one
        local lineNr = n:range() + 1
        if cursorIdx[1] < lineNr then
            break
        end

        if vim.fn.foldlevel(lineNr) == cursorFoldLevel then
            nodeStart = n
        end
    end

    for _, n in ipairs(markers.End) do
        -- Store the fold marker node when the fold line is bigger than the
        -- cursorline and has the same fold level
        local lineNr = n:range() + 1
        if cursorIdx[1] <= lineNr and vim.fn.foldlevel(lineNr) == cursorFoldLevel then
            nodeEnd = n
            break
        end
    end

    if not nodeStart or not nodeEnd then
        vim.notify("Can't find foldmarker region that contains the cursor", vim.log.levels.INFO)
        return {}
    end

    return {Start = nodeStart, End = nodeEnd}
end


local clearNS = function(bufNr)
    vim.api.nvim_buf_clear_namespace(bufNr, M.ns, 0, -1)
end


--- Highlight Treesitter node content
---@param bufNr number
---@param markerNodes table Treesitter nodes
---@param highlightGroup string
local addHighlight = function(bufNr, markerNodes, highlightGroup, markerOnlyChk)
    -- Always clear all namespace
    clearNS(bufNr)
    for i, n in ipairs(markerNodes) do
        local range = {n:range()}
        if markerOnlyChk then
            if i == 1 then -- Start node {{{
                vim.api.nvim_buf_add_highlight(bufNr, M.ns, highlightGroup, range[1], range[2], range[4])
            else
                -- End node }}}
            end
        else
            vim.api.nvim_buf_add_highlight(bufNr, M.ns, highlightGroup, range[1], range[2], range[4])
        end
    end
    -- Clear highlight after certain timeout
    vim.defer_fn(function() clearNS(bufNr) end, M.highlightTimeout)
end


M.highlightCurrentMarkerRegion = function()
    if not chkMarkerOption() then return end

    local cursorPos = vim.api.nvim_win_get_cursor(0)
    if vim.fn.foldlevel(cursorPos[1]) == 0 then
        vim.notify("Not inside any foldmarker region", vim.log.levels.INFO)
        return
    end

    local bufNr = vim.api.nvim_get_current_buf()
    local markers = getCurrentMarkers(cursorPos, bufNr)
    if not markers.Start then
        return
    end

    addHighlight(bufNr, vim.tbl_values(markers), M.highlightNormalGroup)
end


--- Modify a specific foldmarker
---@param bufNr number
---@param nodeRange table Captured by calling {node:range()}
---@param markerString string
---@param preserveHeadCommentChk boolean Whether to preserve the comment
--content from the start folder marker
---@param newMarkerString string The new fold marker string
---@param commentString string See: `:h commentstring`
---@return boolean Return true when a buffer line is deleted
local modifyMarker = function(bufNr, nodeRange, markerString, preserveHeadCommentChk, newMarkerString, commentString)
    local nodeText    = vim.api.nvim_buf_get_text(bufNr, nodeRange[1], nodeRange[2], nodeRange[1], nodeRange[4] + 1, {})[1]
    local nodePreText = vim.api.nvim_buf_get_text(bufNr, nodeRange[1], 0, nodeRange[1], nodeRange[2], {})[1]

    if markerString == "{{{" and preserveHeadCommentChk and not newMarkerString then
        nodeText = string.gsub(nodeText, markerString, "")
        vim.api.nvim_buf_set_text(bufNr, nodeRange[1], nodeRange[2], nodeRange[1], nodeRange[4], {nodeText})
    else
        if newMarkerString then
            if markerString == "{{{" then
                nodeText = string.format("%s %s {{{", commentString, newMarkerString)
            else
                nodeText = string.format("%s }}} %s", commentString, newMarkerString)
            end

            vim.api.nvim_buf_set_lines(bufNr, nodeRange[1], nodeRange[1] + 1, false, {nodePreText .. nodeText})
        else
            if string.match(nodePreText, "^%s*$") then
                vim.cmd(nodeRange[1] + 1 .. "d")
                return true
            else
                vim.api.nvim_buf_set_lines(bufNr, nodeRange[1], nodeRange[1] + 1, false, {nodePreText})
            end
        end
    end

    return false
end


--- Modify(delete/change) the current foldmarker in which the cursor resides
---@param preserveHeadCommentChk boolean Whether to preserve the comment
--content from the start folder marker
---@param changeChk boolean Whether to change the foldmarkers instead of deleting them
M.modifyCurrentMarkerRegion = function(preserveHeadCommentChk, changeChk)
    if not chkMarkerOption() then return end

    local cursorPos = vim.api.nvim_win_get_cursor(0)
    if vim.fn.foldlevel(cursorPos[1]) == 0 then
        vim.notify("Not inside any foldmarker region", vim.log.levels.INFO)
        return
    end

    local bufNr = vim.api.nvim_get_current_buf()
    local markers = getCurrentMarkers(cursorPos, bufNr)
    if not markers.Start then
        return
    end

    -- Highlighting
    if not changeChk then
        addHighlight(bufNr, {markers.Start, markers.End}, M.highlightDeleteGroup)
    end

    if changeChk then
        local commentString = string.gsub(vim.bo.commentstring, "%s+%%s$", "")
        local regex         = vim.regex(commentString .. [[\zs.*\ze{{{]])
        if not regex then return end
        local nodeRange     = {markers.Start:range()}
        local nodeText      = vim.api.nvim_buf_get_text(bufNr, nodeRange[1], nodeRange[2], nodeRange[1], nodeRange[4] + 1, {})[1]

        local matchStrIdx = {regex:match_str(nodeText)}
        if not next(matchStrIdx) then
            vim.notify("Can't find comment text", vim.log.levels.ERROR)
            return
        else
            M.commentText = string.sub(nodeText, matchStrIdx[1] + 1, matchStrIdx[2])
            M.commentText = vim.trim(M.commentText)
        end
        -- Prompt for new text following a fold marker
        vim.ui.input({
            prompt  = "Enter new fold marker string: ",
            default = require("foldmarker").commentText,
        }, function(input)
            if input and input ~= "" then
                if modifyMarker(bufNr, markers.Start, "{{{", preserveHeadCommentChk, input, commentString) then
                    modifyMarker(bufNr, markers.End, "}}}", preserveHeadCommentChk, input, commentString)
                end
            end
        end)
    else
        vim.defer_fn(function()
            local rangeStart = {markers["Start"]:range()}
            local rangeEnd = {markers["End"]:range()}
            if modifyMarker(bufNr, rangeStart, "{{{", preserveHeadCommentChk) then
                rangeEnd = {rangeEnd[1] - 1, rangeEnd[2], rangeEnd[3] - 1, rangeEnd[4]}
            end
            modifyMarker(bufNr, rangeEnd, "}}}", preserveHeadCommentChk)
        end, M.highlightTimeout)
    end
end


--- Get the next non-folded line number. If topline is already a non-folded
--- line, then topline will be return
---@param topline number
---@param botline number
---@return number
local getNextNonFoldLine = function(topline, botline)
    local nextline = topline
    while nextline < botline do
        if vim.fn.foldlevel(nextline) ~= 0 then
            -- Inside a fold
            local closedEnd = vim.fn.foldclosedend(nextline)

            if closedEnd == -1 then
                -- The fold is open

                -- Find the end of a opened-fold till calling
                -- vim.fn.foldlevel(nextline) return 0 because the fold is
                -- already open, and the return value of vim.fn.foldclosedend()
                -- is always -1 whenever it receives lineNr inside a fold or
                -- outside
                while nextline < botline do
                    nextline = nextline + 1
                    if vim.fn.foldlevel(nextline) == 0 then
                        return nextline
                    end
                end
            else
                -- The fold is closed
                nextline = closedEnd + 1
            end
        else
            -- Not inside a fold
            return nextline
        end
    end

    return -1
end


--- Get the first non-folded region in a bigger region specified by a topline
--- number and a botline number
---@param topline number
---@param botline number
---@return table Ex: {1, 34}
local getNonFoldRegion = function(topline, botline)
    for i = topline, botline, 1 do
        if vim.fn.foldlevel(i) ~= 0 then
            -- If the first line is also a fold line
            return { topline, i - 1 }
        end
    end

    -- No folds in the whole range
    return { topline, botline }
end


--- Get all non-folded regions inside a bigger region specified by a topline
--- number and a botline number
---@param topline number
---@param botline number
---@return table Ex: {{1, 34}, {54, 131}, {185, 202}}
M.getAllNonFoldRegion = function(topline, botline)
    local region
    local nextTopline = topline
    local nonFoldRegion = {}

    -- Make sure the first line is always a nonfoldline
    nextTopline = getNextNonFoldLine(nextTopline, botline)
    if nextTopline == -1 then
        -- There is no non-folded line available
        return nonFoldRegion
    end

    while true do
        region = getNonFoldRegion(nextTopline, botline)
        table.insert(nonFoldRegion, region)

        if region[2] ~= botline then
            -- Pick up where getNonFoldRegion stops
            local nextLine = region[2] + 1
            -- Make sure next line is always a nonfoldline and continue the loop
            nextTopline = getNextNonFoldLine(nextLine, botline)
            if nextTopline == -1 then
                return nonFoldRegion
            end

            if nextTopline == botline then break end

        else
            -- Stop when range[2] is the botline
            break
        end
    end

    return nonFoldRegion
end


--- Snap to a specific line
---@param curWinNr  number Current window number
---@param curBufNr  number Current buffer number
---@param cursorPos table  Cursor info retrieved by calling nvim_win_set_cursor
---@param lineNr    number Destination line number
local function snapToLine(curWinNr, curBufNr, cursorPos, lineNr)
    local regionEndTextLen = #vim.api.nvim_buf_get_lines(curBufNr, lineNr - 1, lineNr, false)[1]
    if regionEndTextLen - 1 < cursorPos[2] then
        if regionEndTextLen == 0 then
            vim.api.nvim_win_set_cursor(curWinNr, { lineNr, 0 })
        else
            vim.api.nvim_win_set_cursor(curWinNr, { lineNr, regionEndTextLen - 1 })
        end
    else
        vim.api.nvim_win_set_cursor(curWinNr, { lineNr, cursorPos[2] })
    end
end


--- Execute an Ex command or a function
---@param exCmd string|function
local function exeCommand(exCmd)
    if type(exCmd) == "string" then
        return vim.cmd(exCmd)
    elseif type(exCmd) == "function" then
        exCmd()
    end
end


--- Snap to the closest fold and execute a Ex command or a function
---@param exCmd string|function An Ex command or a function. Note that it will
---be executed right away if the cursor is right above a fold start or a fold
---end
---@param snapEnable boolean Whether to enable the snap. If this set to false,
--- the exCmd will act like a right hand side of a normal mapping
---@param threshold number Multiplied by the Neovim window height to get the
--- minimum number for the snap taking place
M.snap = function(exCmd, snapEnable, threshold)
    --
    -- {
    -- botline = 12,
    -- bufnr = 42,
    -- height = 61,
    -- loclist = 0,
    -- quickfix = 0,
    -- tabnr = 1,
    -- terminal = 0,
    -- textoff = 10,
    -- topline = 1,
    -- variables = {
        -- last_changedtick = 1209,
        -- last_cursor = { 0, 9, 18, 0, 18 },
        -- matchup_hi_time = { 980, -1958460276 },
        -- matchup_match_id_list = {},
        -- matchup_need_clear = 1,
        -- matchup_pulse_time = { 980, -1957157176 },
        -- matchup_timer = 1
    -- },
    -- width = 141,
    -- winbar = 0,
    -- wincol = 1,
    -- winid = 1000,
    -- winnr = 1,
    -- winrow = 2
    -- }
    -- Execute command right away
    if snapEnable == nil then snapEnable = true end
    if not snapEnable then return exeCommand(exCmd) end

    -- Default value
    threshold = threshold or 1

    -- Initiation
    local curWinNr = vim.api.nvim_get_current_win()
    local curBufNr = vim.api.nvim_get_current_buf()
    -- (1, 0) indexed table
    local cursorPos = vim.api.nvim_win_get_cursor(curWinNr)
    if vim.fn.foldlevel(cursorPos[1]) ~= 0 then
        return exeCommand(exCmd)
    end

    local winInfo = vim.fn.getwininfo(curWinNr)
    -- Make table clean
    winInfo = #winInfo == 1 and winInfo[1] or winInfo

    -- Get non-folded range inclusively
    local nonFoldRegions = M.getAllNonFoldRegion(winInfo.topline, winInfo.botline)

    -- No visible folds in Neovim window
    if #nonFoldRegions == 1 and nonFoldRegions[1][1] == winInfo.topline and nonFoldRegions[1][2] == winInfo.botline then
        -- Do nothing
        return vim.api.nvim_echo({ { "No visible folds in sight" } }, false, {})
    end

    -- Check which region cursor resides in
    local cursorRegion
    for _, region in ipairs(nonFoldRegions) do
        if cursorPos[1] >= region[1] and cursorPos[1] <= region[2] then
            cursorRegion = region
            break
        end
    end
    if not cursorRegion then
        return vim.notify("Cannot find cursor region for snapToFold", vim.log.levels.ERROR)
    end

    -- Check dist from cursor line to both region ends then snap to the closest one
    -- Make sure topLineNr and botLineNr do not fall out of region
    local topLineNr = cursorRegion[1] == winInfo.topline and winInfo.topline or cursorRegion[1] - 1
    local botLineNr = cursorRegion[2] == winInfo.botline and winInfo.botline or cursorRegion[2] + 1
    -- Get distances from cursor to both ends
    local distTop = util.posDist({ topLineNr, cursorPos[2] }, cursorPos)
    local distBot = util.posDist({ botLineNr, cursorPos[2] }, cursorPos)
    -- Compare distance
    if distTop < distBot then
        if topLineNr == winInfo.topline then
            -- Snap to bottom instead
            if distBot <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        else
            if distTop <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            else
                return
            end
        end
    elseif distTop > distBot then
        if botLineNr == winInfo.botline then
            -- Snap to top instead
            if distTop <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            else
                return
            end
        else
            if distBot <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        end
    else
        if topLineNr == winInfo.topline and botLineNr ~= winInfo.botline then
            -- Snap to bottom instead
            if distBot <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        elseif topLineNr ~= winInfo.topline and botLineNr == winInfo.botline then
            -- Snap to top instead
            if distTop <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            else
                return
            end
        else
            local answer = vim.fn.confirm("Select direction: ", "&Up\n&Down\nCancel", 0, "Info")
            if answer == 1 then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            elseif answer == 2 then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        end

    end

    -- Last but not least
    exeCommand(exCmd)
end


return M
