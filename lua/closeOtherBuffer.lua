-- File: closeOtherBuffer.lua
-- Author: iaso2h
-- Description: Close other buffers without changing the layout as less as possible
-- Version: 0.0.2
-- Last Modified: 2021/02/26
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local vim = vim
local util = require("util")
local M = {}

function M.main()
    local curBufNr = vim.api.nvim_get_current_buf()
    local bufNrTbl = vim.tbl_map(function(bufNr)
        return tonumber(string.match(bufNr, "%d+"))
    end, util.tblLoaded(false))
    -- Filter out terminal and special buffer, because I don't want close them yet
    bufNrTbl = vim.tbl_filter(function(bufNr)
        return bufNr ~= curBufNr and
        api.nvim_buf_get_option(bufNr, "buftype") == "" end, bufNrTbl)
    local winIDTbl = api.nvim_list_wins()
    local unsavedChange = false
    local answer = -1
    -- Check unsaved change
    for idx, bufNr in ipairs(bufNrTbl) do
        if bufNr ~= curBufNr then
            local modified = api.nvim_buf_get_option(bufNr, "modified")
            if modified then unsavedChange = true; break end
        end
    end
    -- Ask for saving, return when cancel is input
    if unsavedChange then
        cmd "echohl MoreMsg"
        answer = fn.confirm("Save modification?",
        ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "echohl None"
        -- Interrupt
        if answer == 3 or answer == 0 then
            return
        elseif answer == 1 then
            cmd "bufdo update"
        end
    end
    -- Close other window that doesn't contain the current buffers
    if #winIDTbl > 1 then
        for idx, winID in ipairs(winIDTbl) do
            if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(winID)) then
                api.nvim_win_close(winID, false)
            end
        end
    end
    -- Wipe buffers
    for idx, bufNr in ipairs(bufNrTbl) do
        if api.nvim_buf_is_valid(bufNrTbl) then
            cmd("bwipe! " .. bufNr)
        end
    end
end

return M

