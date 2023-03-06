local fn  = vim.fn
local api = vim.api
local M   = {}

local regainFocus = function(closeQfChk, qfWinID, qfCursorPos, savedLastWinID)
    -- HACK:sometimes the winID where qf is located will change somehow
    if not closeQfChk then
        local ok, msg = pcall(api.nvim_set_current_win, qfWinID)
        if not ok then
            vim.notify(msg, vim.log.levels.WARN)
            vim.cmd[[wincmd p]]
        end
        ok, msg = pcall(api.nvim_win_set_cursor, qfWinID, qfCursorPos)
        if not ok then
            vim.notify(msg, vim.log.levels.WARN)
        end
    else
        if savedLastWinID then
            if savedLastWinID ~= qfWinID and api.nvim_win_is_valid(qfWinID) then
                api.nvim_win_close(qfWinID, false)
            else
                -- Cursor is at quickfix window
            end
        else
            api.nvim_win_close(qfWinID, false)
        end
    end
end


local fallback = function(closeQfChk, lineNr, qfWinID, qfCursorPos)
    vim.cmd([[cc ]] .. lineNr)
    regainFocus(closeQfChk, qfWinID, qfCursorPos)
end


--- Open an item in quickfix window like :cc do, except that it will always use
--- the last window to open a quickfix item, which is what I call the
--- 'uselastWin' method for 'switchbuf' option. The vim.v.count will only open
--- a specific line, of which line number is decided by vim.v.count
---@param fallbackChk boolean Whether to use the fallback :cc command to open item
---@param closeQfChk boolean Whether to close the quifix after open an item
---@param offset number Open the item based on the given offset to the
--cursor. Set it to -1 to open the previous item, 1 to open the next item
M.main = function(fallbackChk, closeQfChk, offset)
    local qfWinID     = api.nvim_get_current_win()
    local qfCursorPos = api.nvim_win_get_cursor(qfWinID)
    local lineNr
    if offset ~= 0 then
        local lastLine = fn.line("$")
        lineNr = fn.getqflist({idx = 0}).idx + offset
        if lineNr > lastLine then
            qfCursorPos = {lastLine, qfCursorPos[2]}
            lineNr = lastLine
        elseif lineNr < 1 then
            qfCursorPos = {1, qfCursorPos[2]}
            lineNr = 1
        else
            qfCursorPos = {lineNr, qfCursorPos[2]}
        end
    else
        lineNr = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
    end

    -- User the built-in :cc command to open quickfix item
    if fallbackChk then return fallback(closeQfChk, lineNr, qfWinID, qfCursorPos) end

    local qfItem = fn.getqflist()[lineNr]
    if not next(qfItem) then
        -- qf items are created by pressing gO in help docs?
        return vim.notify("No qf items available", vim.log.levels.INFO)
    end

    if qfItem.valid == 0 or qfItem.bufnr == 0 or
            not api.nvim_buf_is_valid(qfItem.bufnr) then
        require("quickfix.highlight").add(
            {qfCursorPos[1]},
            "Comment",
            api.nvim_create_namespace("myQuickfix")
        )
        return vim.notify("Buffer isn't valid", vim.log.levels.INFO)
    end

    -- In some cases the autocmd for retriving the last window id before
    -- entering into the quickfix is not working well, then we have to use the
    -- fallback mathod
    local savedLastWinID = _G._lastWinID
    local fallbackTick   = qfWinID == savedLastWinID

    -- Validating that savedLastWinID is the window to be switched, and making
    -- sure it is focused
    if fallbackTick or not api.nvim_win_is_valid(savedLastWinID) then
        -- Fallback method by utilizing wincmd to find out

        -- Make the previous winID as the last presevered winID
        vim.cmd[[noa wincmd p]]
        savedLastWinID = api.nvim_get_current_win()
        -- Prevent quickfix from looping back to itself
        if savedLastWinID == qfWinID then
            vim.notify("Quickfix looped back to itself", vim.log.levels.WARN)
            vim.cmd[[noa wincmd w]]
            savedLastWinID = api.nvim_get_current_win()
        end
    else
        api.nvim_win_set_buf(savedLastWinID, qfItem.bufnr)
    end

    -- Switch buf in the window
    api.nvim_win_call(savedLastWinID, function()
        vim.cmd([[cc ]] .. lineNr)
        vim.cmd[[norm! zvzz]]
    end)

    regainFocus(closeQfChk, qfWinID, qfCursorPos, savedLastWinID)
end


return M
