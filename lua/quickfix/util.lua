local M   = {}


--- Universally warp around getlocist() and getqflist()
---@vararg any
M.getlist = function(...)
    if vim.b._is_loc then
        return vim.fn.getloclist(0, ...)
    else
        return vim.fn.getqflist(...)
    end
end


M.isVisible = function()
    local winIDTbl = vim.tbl_filter(function(i)
        return vim.api.nvim_win_get_config(i).relative == ""
    end, vim.api.nvim_list_wins())

    local bufInWin
    for _, win in ipairs(winIDTbl) do
        bufInWin = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(bufInWin, "buftype") == "quickfix" then
            return true
        end
    end

    return false
end


M.debounce = function(ms, func)
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
end

local typeToNum = function(t) -- {{{
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


M.sortByFile = function(tbl, curBufNr)
    local curBufName = vim.api.nvim_buf_get_name(curBufNr)
    table.sort(tbl, function(a, b)
        if typeToNum(a.type) < typeToNum(b.type) then
            return true
        elseif a.type == b.type then
            local aOk, aBufName = pcall(vim.api.nvim_buf_get_name, a.bufnr)
            local bOk, bBufName = pcall(vim.api.nvim_buf_get_name, a.bufnr)
            if aOk and bOk and aBufName == bBufName then
                return a.lnum < b.lnum
            end
            if aOk then
                return aBufName == curBufName
            end
        end

        return false
    end)
end


return M
