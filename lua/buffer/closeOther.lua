-- File: closeOther
-- Author: iaso2h
-- Description: Close other buffers or windows
-- Version: 0.0.6
-- Last Modified: 05/03/2023 Wed
local u     = require("buffer.util")
local var   = require("buffer.var")
local close = require("buffer.close")

local filetypeWhitelist = {"qf", "help", "terminal"}
local buftypeWhitelist  = {"terminal"}


--- Check modified state of specified buffer numbers and prompt for saving if
--unsave changes found
---@param bufNrs table
---@param saveBufNr number
---@return boolean Evaluate to false if cancel signal has input
local saveModified = function(bufNrs, saveBufNr)
    local changeTick = false
    local answer = -1
    for _, bufNr in ipairs(bufNrs) do
        if bufNr ~= saveBufNr then
            local modified = vim.api.nvim_buf_get_option(bufNr, "modified")
            if modified then
                changeTick = true
                break
            end
        end
    end
    -- Ask for saving, return when cancel is input
    if changeTick then
        vim.cmd "noa echohl MoreMsg"
        answer = vim.fn.confirm("Save all modification?",
            ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        vim.cmd "noa echohl None"
        if answer == 3 or answer == 0 then
            return false
        elseif answer == 1 then
            vim.cmd "noa silent bufdo update"
            return true
        end
    end

    return true
end

--- Wipe all the other buffers except for the special buffers without changing the window layout
return function()
    local saveWinId = vim.api.nvim_get_current_win()
    local saveBufNr = vim.api.nvim_get_current_buf()

    local bufNrs = u.bufNrs()
    if not saveModified(bufNrs, saveBufNr) then
        return
    end

    -- Deleting other buffers
    for _, bufNr in ipairs(bufNrs) do
        if bufNr ~= saveBufNr and
            not vim.tbl_contains(filetypeWhitelist, vim.api.nvim_buf_get_option(bufNr, "filetype")) and
            not vim.tbl_contains(buftypeWhitelist, vim.api.nvim_buf_get_option(bufNr, "buftype")) then
            u.initBuf(bufNr)
            close.bufHandler(false, false)
        end
    end
    -- TODO: whether to close windows don't contain the current buffer as
    -- post processing

    -- Refocus window if necessary
    if vim.api.nvim_get_current_win() ~= saveWinId and vim.api.nvim_win_is_valid(saveWinId) then
        vim.api.nvim_set_current_win(saveWinId)
    end
end
