-- File: closeOther
-- Author: iaso2h
-- Description: Close other buffers or windows
-- Version: 0.0.7
-- Last Modified: Sat 06 May 2023
local u     = require("buffer.util")
local close = require("buffer.close")

local filetypeWhitelist = {"qf", "help", "terminal"}
local buftypeWhitelist  = {"terminal"}


--- Check modified state of specified buffer numbers and prompt for saving if unsave changes found
---@param bufNrs table
---@param saveBufNr integer
---@return boolean # Evaluate to `false` if cancel signal has input
local saveModified = function(bufNrs, saveBufNr)  -- {{{
    local changeTick = require("util").any(function(bufNr)
        if bufNr == saveBufNr then return false end
        return vim.api.nvim_get_option_value("modified", {buf = bufNr})
    end, bufNrs)
    local answer = -1
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
end -- }}}


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
            not vim.list_contains(filetypeWhitelist, vim.api.nvim_get_option_value("filetype", {buf = bufNr})) and
            not vim.list_contains(buftypeWhitelist, vim.api.nvim_get_option_value("buftype", {buf = bufNr})) then
            u.initBuf(bufNr)
            close.bufHandler(false, false)
        end
    end

    -- Refocus window if necessary
    if vim.api.nvim_get_current_win() ~= saveWinId and vim.api.nvim_win_is_valid(saveWinId) then
        vim.api.nvim_set_current_win(saveWinId)
    end

    if package.loaded["cokeline"] then
        require("cokeline/augroups").toggle()
    end
end
