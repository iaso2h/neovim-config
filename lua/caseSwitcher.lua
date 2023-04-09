-- File: caseSwitcher
-- Author: iaso2h
-- Description: prerequisite zatchheems/vim-camelsnek
-- Version: 0.0.3
-- Last Modified: 2022-01-13
local cmd = vim.cmd
local api = vim.api
local M   = {}

M.timer = nil
M.CMDList = {}
M.defaultCMDList = {"Camel", "Snake", "Pascal", "Snakecaps"}
M.lastSwitchPos = {}
M.lastSwitchBufNr = nil
M.timeout = 1000

function M.cycleCase() -- {{{
    local curPos   = api.nvim_win_get_cursor(0)
    local curBufNr = api.nvim_get_current_buf()

    -- When function is first time called or cursor have been moved from last
    -- switch position, the value of M.CMDList reset to default
    if curBufNr ~= M.lastSwitchBufNr or
        curPos[1] ~= M.lastSwitchPos[1] or
        curPos[2] ~= M.lastSwitchPos[2] then
        M.CMDList = vim.deepcopy(M.defaultCMDList)
    end

    -- Stop the previous deferred function if this func is quick enough to be
    -- called again
    if M.timer then M.timer:stop() end

    -- Always re-append then vimCMD after pop it up
    local vimCMD = table.remove(M.CMDList, 1)
    table.insert(M.CMDList, vimCMD)

    -- Execute the vim command to switch case
    cmd("noa silent " .. vimCMD)
    api.nvim_echo({{string.format("\nSwitch to %s", vimCMD), "MoreMsg"}}, false, {})


    -- Store the cursor position. When this function is called again, the
    -- value of M.lastSwitchBufNr and M.lastSwitchPos will be checked whether
    -- the cursor move or not after last case switch.
    -- If the cursor have been moved, then the value of M.CMDList will be copied
    -- from M.defaultCMDList
    M.lastSwitchPos = api.nvim_buf_get_mark(0, "[")
    M.lastSwitchBufNr = api.nvim_get_current_buf()

    -- Always set cursor position to the first character of the text changed area
    api.nvim_win_set_cursor(0, M.lastSwitchPos)

    -- Set the deferred func.
    M.timer = vim.defer_fn(function ()
        M.CMDList = vim.deepcopy(M.defaultCMDList)
        M.timer = nil
    end, M.timeout)
end -- }}}


function M.cycleDefaultCMDList() -- {{{
    table.insert(M.defaultCMDList, table.remove(M.defaultCMDList, 1))
    api.nvim_echo({{string.format("Default CMD order has been changed to: %s", vim.inspect(M.defaultCMDList)), "MoreMsg"}}, true, {})
end -- }}}

return M

