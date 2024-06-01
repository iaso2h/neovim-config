local M   = {}


--- Universally warp around `getlocist()` and `getqflist()`
---@vararg any
M.getlist = function(...) -- {{{
    if vim.b._is_local then
        return vim.fn.getloclist(0, ...), vim.fn.getloclist(0, {title = 0}).title
    else
        return vim.fn.getqflist(...), vim.fn.getqflist({title = 0}).title
    end
end -- }}}
--- Whether the quickfix window is visible
---@return boolean
M.isVisible = function() -- {{{
    local winIDTbl = require("buffer.util").winIds(false)
    local bufInWin
    for _, win in ipairs(winIDTbl) do
        bufInWin = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_get_option_value("buftype", {buf = bufInWin}) == "quickfix" then
            return true
        end
    end

    return false
end -- }}}
--- Delay the function after `ms` then call it
---@param ms integer How long the function will be after a certain milliseconds
---@param func function The function to be called
---@return function
M.debounce = function(ms, func) -- {{{
    local timer = vim.loop.new_timer()
    if not timer then return end

    return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(function()
                func(unpack(argv))
            end)()
        end)
    end
end -- }}}
--- Convert diagnostics type into number
---@param t table `vim.diagnostic.severity`
local diagnosticsTypeToNum = function(t) -- {{{
    if t == 'E' then
        return 1
    elseif t == 'W' then
        return 2
    elseif t == 'I' then
        return 3
    else
        return 4
    end
end -- }}}
--- Sort the diagnostics table in place by nearest to current file path
---@param tbl table
---@param curBufNr integer
M.sortByFile = function(tbl, curBufNr) -- {{{
    local curBufName = nvim_buf_get_name(curBufNr)

    table.sort(tbl, function(a, b)
        if a.type ~= b.type then
            return diagnosticsTypeToNum(a.type) < diagnosticsTypeToNum(b.type)
        else
            local aOk, aBufName = pcall(nvim_buf_get_name, a.bufnr)
            local bOk, bBufName = pcall(nvim_buf_get_name, a.bufnr)
            if aOk and bOk and aBufName == bBufName then
                return a.lnum < b.lnum
            elseif aOk then
                return aBufName == curBufName
            end
        end

        return false
    end)
end -- }}}


return M
