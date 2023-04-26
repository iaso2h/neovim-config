-- File: foldmarker.lua
-- Author: iaso2h
-- Description: Improve fold marker
-- Version: 0.0.3
-- Last Modified: 2023-4-18


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
    local nodesStart = require("util").getQueryNodes(bufNr, foldmarkerStartQuery, 2)
    local nodesEnd   = require("util").getQueryNodes(bufNr, foldmarkerEndQuery, 2)

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


return M
