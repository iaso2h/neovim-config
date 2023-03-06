-- File: buf.lua
-- Author: iaso2h
-- Description: A few of buffer-related utilities
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.26
-- Last Modified: 2023-3-6
-- TODO: jump to relative buf in quickfix?
local fn  = vim.fn
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
    if var.lastClosedFilePath then
        vim.cmd(string.format("e %s", var.lastClosedFilePath))
    end
end


M.quickfixToggle = function () -- {{{
    -- Toogle off
    if vim.bo.buftype == "quickfix" then
        return api.nvim_win_close(0, false)
    end

    -- Toggle on
    local winInfo = fn.getwininfo()
    for _, tbl in ipairs(winInfo) do
        if tbl["quickfix"] == 1 then
            return api.nvim_set_current_win(tbl["winid"])
        end
    end

    vim.cmd "copen"
end -- }}}


M.newSplit = function(...)
    require("buf.action.newSplit").init(...)
end

return M

