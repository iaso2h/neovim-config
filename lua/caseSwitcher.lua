-- File: caseSwitcher
-- Author: iaso2h
-- Description: prerequisite zatchheems/vim-camelsnek
-- Version: 0.0.2
-- Last Modified: 2021-12-24
local cmd = vim.cmd
local api = vim.api
local M   = {}

M.timer = {}
M.CMDList = {}
M.defaultCMDList = {"Camel", "Snake", "Pascal", "Snakecaps"}

function M.cycleCase() -- {{{
    local timeout = 1000
    local cursorPos = api.nvim_win_get_cursor(0)
    -- When timer fire, the timer list will be empty, and the default cmdlist ->
    -- will be used
    if not next(M.CMDList) or not next(M.timer) then
        M.CMDList = vim.deepcopy(M.defaultCMDList)
    end

    -- Always re-append then vimCMD after pop it up
    local vimCMD = table.remove(M.CMDList, 1)
    table.insert(M.CMDList, vimCMD)

    -- Execute the vim command to switch case
    cmd("noa silent " .. vimCMD)
    api.nvim_echo({{string.format("\nSwitch to %s", vimCMD), "MoreMsg"}}, false, {})

    -- Restore cursor position
    api.nvim_win_set_cursor(0, cursorPos)

    -- Stop all existing timers in advance if the func M.cycleCase is call
    -- agian within the timeout
    if #M.timer ~= 0 then
        for index, timer in ipairs(M.timer) do
            if getmetatable(timer).timer_stop then
                timer:timer_stop()
                table.remove(M.timer, index)
            end
        end
    end

    -- Set new timer and insert the timer object before the first element of
    -- M.timer
    table.insert(M.timer, 1, vim.defer_fn(function () table.remove(M.timer) end, timeout))
end -- }}}

function M.cycleDefaultCMDList() -- {{{
    table.insert(M.defaultCMDList, table.remove(M.defaultCMDList, 1))
    api.nvim_echo({{string.format("Default CMD order has been changed to: %s", vim.inspect(M.defaultCMDList)), "MoreMsg"}}, true, {})
end -- }}}

return M

