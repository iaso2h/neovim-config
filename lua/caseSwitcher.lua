-- File: caseSwitcher
-- Author: iaso2h
-- Description: prerequisite zatchheems/vim-camelsnek
-- Version: 0.0.1
-- Last Modified: 2021/03/13
local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

M.timer = {}
M.defaultCMDList = {"Camel", "Snake", "Pascal", "Snakecaps"}

function M.cycleCase() -- {{{
    local cursorPos = api.nvim_win_get_cursor(0)
    -- When timer fire, the timer list will be empty, and the default cmdlist ->
    -- will be used
    if not M.CMDList or not next(M.timer) then
        M.CMDList = vim.deepcopy(M.defaultCMDList)
    end
    local firstCMD = table.remove(M.CMDList, 1)
    cmd("silent " .. firstCMD)
    api.nvim_echo({{string.format("\nSwitch to %s", firstCMD), "MoreMsg"}}, false, {})

    api.nvim_win_set_cursor(0, cursorPos)
    -- When the first CMD is cmd, it will reappend to the list
    table.insert(M.CMDList, firstCMD)
    -- Stop previous timer, make sure only the latest timer can run
    if #M.timer > 1 then
        for index, timer in ipairs(M.timer) do
            if index ~= 1 then
                timer:stop()
                table.remove(M.timer, index)
            end
        end
    end
    -- Set new timer
    table.insert(M.timer, vim.defer_fn(function () table.remove(M.timer, 1) end, 1000))
end -- }}}

function M.cycleDefaultCMDList() -- {{{
    table.insert(M.defaultCMDList, table.remove(M.defaultCMDList, 1))
    api.nvim_echo({{string.format("Default CMD order has been changed to: %s", vim.inspect(M.defaultCMDList)), "MoreMsg"}}, true, {})
end -- }}}

return M

