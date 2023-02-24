local fn  = vim.fn
local api = vim.api
local M   = {}

--- Echo search pattern and result index at the commandline
M.echoSearch = function()
    local searchDict = fn.searchcount()
    local result = string.format("[%s/%s]", searchDict.current, searchDict.total)
    local searchPat = fn.histget("search")
    local echoStr = string.format('%s %s', searchPat, result)

    if searchDict.current == 1 or
            math.abs(searchDict.current - searchDict.total) == 0 then
        -- When search reaches the end
        api.nvim_echo({{echoStr, "CmpItemAbbrMatch"}}, false, {})
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
    -- cmd("norm! " .. "zzzv")
    M.echoSearch()
end


--- Search func wraps around the native //? exCMD in Visual mode
---@param exCMD string "/" or "?"
M.searchSelected = function(exCMD)
    local cursorPos = api.nvim_win_get_cursor(0)
    local selectedStr = fn.escape(
        require("selection").getSelect("string", true),
        [[\]]
    )
    selectedStr = exCMD .. [[\V]] .. selectedStr
    vim.cmd(selectedStr)
    api.nvim_echo({{selectedStr}}, false, {})
    api.nvim_win_set_cursor(0, cursorPos)
end

return M

