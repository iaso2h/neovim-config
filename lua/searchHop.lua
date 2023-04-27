-- File: searchHop
-- Author: iaso2h
-- Description: Jump & Search utilities
-- Version: 0.0.7
-- Last Modified: 2023-4-27


local fn  = vim.fn
local api = vim.api
local M   = {}

--- Echo search pattern and result index at the commandline
local echoSearch = function()
    local searchDict = fn.searchcount()
    local result = string.format("[%s/%s]", searchDict.current, searchDict.total)
    local searchPat = fn.histget("search")
    local echoStr = string.format('%s %s', searchPat, result)

    if searchDict.current == 1 or
            math.abs(searchDict.current - searchDict.total) == 0 then
        -- When search reaches the end
        api.nvim_echo({{echoStr, "TelescopePromptCounter"}}, false, {})
    else
        api.nvim_echo({{echoStr}}, false, {})
    end
end


--- Search func wraps around the native n/N exCMD
---@param exCMD string "n" or "N"
M.cycleSearch = function(exCMD)
    local ok, msg = pcall(vim.cmd, "noa norm! " .. exCMD)
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        if string.match(msg, "E486") then
            api.nvim_echo({{"Pattern not found: " .. fn.histget("search")}}, false, {})
            return
        else
            return vim.notify(msg, vim.log.levels.ERROR)
        end
    end

    vim.cmd("norm! " .. "zv")
    echoSearch()
end


--- Search func wraps around the native //? exCMD in Visual mode
---@param exCMD string "/" or "?"
M.searchSelected = function(exCMD)
    local cursorPos = api.nvim_win_get_cursor(0)
    local selectedStr = fn.escape(
        require("selection").getSelect("string", true),
        [=[\/.-][]=]
    )
    selectedStr = exCMD .. selectedStr
    vim.cmd(selectedStr)
    api.nvim_echo({{selectedStr}}, false, {})
    api.nvim_win_set_cursor(0, cursorPos)
end


--- Execute ex command then center the screen situationally
---@param exCMD string Ex command
---@param suppressMsgChk boolean
---@param remapChk boolean
M.centerHop = function(exCMD, suppressMsgChk, remapChk)
    local winID      = api.nvim_get_current_win()
    local prevBufNr  = api.nvim_get_current_buf()
    local preWinInfo = vim.fn.getwininfo(winID)[1]

    -- Execute the command first
    if type(exCMD) == "string" then
        local remapStr = remapChk and "normal " or "normal! "
        local ok, valOrMsg = pcall(vim.cmd, remapStr .. vim.v.count1 .. t(exCMD))
        if not ok and not suppressMsgChk then
            local idx = select(2,string.find(valOrMsg, "E%d+: "))
            valOrMsg = string.sub(valOrMsg, idx + 1, -1)
            vim.notify(valOrMsg, vim.log.levels.INFO)
        end
    elseif type(exCMD) == "function" then
        exCMD()
    else
        return
    end

    local curBufNr = api.nvim_get_current_buf()

    -- Jump to a different buffer
    if prevBufNr ~= curBufNr then return end

    -- Make sure cursor does not sit on a fold line
    vim.cmd[[norm! zv]]

    local postCursorPos = api.nvim_win_get_cursor(winID)
    if postCursorPos[1] < preWinInfo.topline or postCursorPos[1] > preWinInfo.botline then
        vim.cmd [[norm! zz]]
    end
end


M.searchCurrentWord = function(exCmd, WORDChk)
    exCmd = WORDChk and "g" .. exCmd or exCmd
    local util = require("util")

    util.saveViewCursor()
    vim.cmd("norm! " .. exCmd .. "``")
    if vim.is_callable(util.restoreViewCursor) then
        util.restoreViewCursor(vim.fn.winheight(0))
    end
    echoSearch()
end


return M

