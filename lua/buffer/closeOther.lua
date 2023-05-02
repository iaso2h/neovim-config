-- File: closeOther
-- Author: iaso2h
-- Description: Close other buffers or windows
-- Version: 0.0.5
-- Last Modified: 05/02/2023 Tue
local u     = require("buffer.util")
local var   = require("buffer.var")
local close = require("buffer.close")

local filetypeWhitelist = {"qf", "help", "terminal"}
local buftypeWhitelist  = {"terminal"}

--- Wipe all the other buffers except for the special buffers without changing the window layout
return function()
    local saveWinId = vim.api.nvim_get_current_win()
    local saveBufNr = vim.api.nvim_get_current_buf()

    local changeTick = false
    local answer = -1
    -- Check unsaved change
    for _, bufNr in ipairs(var.bufNrs) do
        if bufNr ~= var.bufNr then
            local modified = vim.api.nvim_buf_get_option(bufNr, "modified")
            if modified then changeTick = true; break end
        end
    end
    -- Ask for saving, return when cancel is input
    if changeTick then
        vim.cmd "noa echohl MoreMsg"
        answer = vim.fn.confirm("Save all modification?",
            ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        vim.cmd "noa echohl None"
        -- Interrupt
        if answer == 3 or answer == 0 then
            return
        elseif answer == 1 then
            vim.cmd "noa silent bufdo update"
        end
    end

    -- Deleting other buffers
    for _, bufNr in ipairs(u.bufNrs()) do
        if bufNr ~= saveBufNr and
            not vim.tbl_contains(filetypeWhitelist, vim.api.nvim_buf_get_option(bufNr, "filetype")) and
            not vim.tbl_contains(buftypeWhitelist, vim.api.nvim_buf_get_option(bufNr, "buftype")) then

            u.initBuf()
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
