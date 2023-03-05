local fn  = vim.fn
local api = vim.api
local M   = {}
--- Open an item in quickfix window like :cc do, except that it will always use
--- the last window to open a quickfix item, which is what I call the
--- 'uselastWin' method for 'switchbuf' option. The vim.v.count will only open
--- a specific line, of which line number is decided by vim.v.count
---@param closeQuickfix boolean
M.cc = function(closeQuickfix, useWinCall)
    local savedLastWinID = _G._lastWinID
    local qfWinID        = api.nvim_get_current_win()
    -- In some cases the autocmd for retriving the last window id before
    -- entering into the quifix is not working well, then we have to use the
    -- fallback mathod
    local fallbackTick   = qfWinID == savedLastWinID

    local qfCursorPos = api.nvim_win_get_cursor(qfWinID)
    local itemNr      = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
    local qfItem      = fn.getqflist()[itemNr]
    if not next(qfItem) then
        -- qf items are created by pressing gO in help docs?
        return vim.notify("No qf items available", vim.log.levels.INFO)
    end

    if qfItem.valid == 0 or not qfItem.bunr or
            not api.nvim_buf_is_valid(qfItem.bufnr) then
            -- TODO: highlight the invalid item?
        require("quickfix.highlight").add(
            {qfCursorPos[1]},
            "Comment",
            api.nvim_create_namespace(M.nsName)
        )
        return vim.notify("Buffer isn't valid", vim.log.levels.INFO)
    end

    if not api.nvim_buf_is_valid(qfItem.bufnr) then
        return vim.notify("Quickfix item isn't valid", vim.log.levels.INFO)
    end

    local itemPos = {qfItem.lnum, qfItem.col - 1}

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
    if useWinCall then
        api.nvim_win_call(savedLastWinID, function()
            vim.cmd([[cc ]] .. itemNr)
            vim.cmd[[norm! zzzv]]
        end)
    else
        -- Switch the window and buffer, then center cursorline
        api.nvim_win_set_buf(savedLastWinID, qfItem.bufnr)
        api.nvim_win_set_cursor(savedLastWinID, itemPos)
        api.nvim_win_call(savedLastWinID, function()
            vim.cmd[[norm! zzzv]]
        end)
    end

    -- HACK:sometimes the winID where qf is located will change somehow
    if not closeQuickfix then
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
        if savedLastWinID ~= qfWinID and api.nvim_win_is_valid(qfWinID) then
            api.nvim_win_close(qfWinID, false)
        else
            -- TODO:
        end
    end

end


return M
