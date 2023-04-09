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
---@param feedkeyChk boolean Use the ex command to feed keys
---@param suppressMsgChk boolean
M.centerHop = function(exCMD, feedkeyChk, suppressMsgChk)
    local winID     = api.nvim_get_current_win()
    local prevBufNr = api.nvim_get_current_buf()

    -- Execute the command first
    if feedkeyChk then
        api.nvim_feedkeys(exCMD, "n", true)
    else
        local ok, msg = pcall(vim.cmd, "norm! " .. exCMD)
        if not ok and not suppressMsgChk then
            local idx = select(2,string.find(msg, "E%d+: "))
            msg = string.sub(msg, idx + 1, -1)
            vim.notify(msg, vim.log.levels.INFO)
        end
    end

    local curBufNr = api.nvim_get_current_buf()

    -- Jump to a different buffer
    if prevBufNr ~= curBufNr then return end

    -- Make sure cursor does not sit on a fold line
    vim.cmd[[norm! zv]]

    local postCursorPos = api.nvim_win_get_cursor(winID)
    local winInfo = vim.fn.getwininfo(winID)[1]
    if postCursorPos[1] < winInfo.topline or postCursorPos[1] > winInfo.botline then
        vim.cmd [[norm! zz]]
    end
end


M.searchCword = function(exCMD)
    local util = require("util")
    util.saveViewCursor()
    vim.cmd("norm! " .. exCMD .. "``")
    if vim.is_callable(util.restoreViewCursor) then
        util.restoreViewCursor(vim.fn.winheight(0))
    end
    echoSearch()
end


return M

