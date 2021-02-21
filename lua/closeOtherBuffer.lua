-- File: closeOtherBuffer.lua
-- Author: iaso2h
-- Description: Close other buffers without changing the layout as less as possible
-- Version: 0.0.1
-- Last Modified: 2021/02/21
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local vim = vim
local util = require("util")
local M = {}

function M.closeOtherBuf()
    local reservedBuf = vim.api.nvim_get_current_buf()
    local bufNrTbl = vim.tbl_map(function(buf)
        return tonumber(string.match(buf, "%d+"))
    end, util.tblLoaded(false))
    local winIDTbl = api.nvim_list_wins()
    local unsavedChange = false
    local answer = -1
    -- Check unsaved change
    for idx, bufNr in ipairs(bufNrTbl) do
        if bufNr ~= reservedBuf then
            local modified = api.nvim_buf_get_option(bufNr, "modified")
            if modified then unsavedChange = true end
        else
            table.remove(bufNrTbl, idx)
        end
    end
    -- Ask for saving, return when cancel is input
    if unsavedChange then
        cmd "echohl MoreMsg"
        answer = fn.confirm("Save modification?",
        ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "echohl None"
        if answer == 3 then
            do return end
        elseif answer == 1 then
            cmd "bufdo update"
        end
    end
    -- Close other window that doesn't contain the current buffers
    if #winIDTbl > 1 then
        for idx, winID in ipairs(winIDTbl) do
            if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(winID)) then
                api.nvim_win_close(winID)
            end
        end
    end
    -- Wipe buffers
    for idx, bufNr in ipairs(bufNrTbl) do
        cmd("bwipe! " .. bufNr)
    end
end

return M

