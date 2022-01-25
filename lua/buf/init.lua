-- File: buf.lua
-- Author: iaso2h
-- Description: A few of buffer-related utilities
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.25
-- Last Modified: 2022-01-25
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local var = require("buf.var")
local M   = {}


M.close = function(type)
    require("buf.action.close").init(type)
end


M.closeOther = function ()
    require("buf.action.closeOther").init()
end


M.restoreClosedBuf = function()
    Print(var.lastClosedFilePath)
    if var.lastClosedFilePath then
        cmd(string.format("e %s", var.lastClosedFilePath))
    end
end


M.quickfixToggle = function () -- {{{
    -- Toogle off
    if vim.bo.buftype == "quickfix" then
        return cmd "q"
    end

    -- Toggle on
    local winInfo = fn.getwininfo()
    for _, tbl in ipairs(winInfo) do
        if tbl["quickfix"] == 1 then
            QuickfixSwitchBufNr = api.nvim_get_current_buf()
            return api.nvim_set_current_win(tbl["winid"])
        end
    end

    cmd "copen"
end -- }}}


M.newSplit = function (func, funcArgList, bufnamePat, bufListed, scratchBuf)
    require("buf.action.newSplit").init(func, funcArgList, bufnamePat, bufListed, scratchBuf)
end

return M

