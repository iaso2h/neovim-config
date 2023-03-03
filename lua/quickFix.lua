-- Author: iaso2h
-- Description: Cfilter in lua way
-- Version: 0.0.10
-- Last Modified: 2023-3-3
-- TODO: quifix convert into a window localist
local fn  = vim.fn
local api = vim.api
local M   = {
    floatWinId = nil,
    bufNr = nil,
    lastQuickfixItems = nil
}

-- cfilter.lua: Plugin to filter entries from a quickfix/location list
-- Last Change: Aug 23, 2018
-- Maintainer: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
-- Version: 1.1
--
-- Commands to filter the quickfix list:
--   :Cfilter[!] /{pat}/
--       Create a new quickfix list from entries matching {pat} in the current
--       quickfix list. Both the file name and the text of the entries are
--       matched against {pat}. If ! is supplied, then entries not matching
--       then
--       {pat} are used. The pattern can be optionally enclosed using one of
--       the following characters: ', ", /. If the pattern is empty, then the
--       then
--       last used search pattern is used.
--   :Lfilter[!] /{pat}/
--       Same as :Cfilter but operates on the current location list.
--

local function refreshTodoComment()
    if package.loaded["todo-comments"] then
        require("todo-comments.highlight").highlight_win(api.nvim_get_current_win(), true)
    end
end

local lastFilterPat = ""
--- Filter out quickfix list or locallist by specific pattern
--- @param qfChk boolean whether filter out quickfix or not
--- @param pat string pattern to filter out
--- @param bang string if bang value is "!", then items not matching the
---        pattern will be preserved
_G.qFilter = function(qfChk, pat, bang)
    local items = qfChk and fn.getqflist() or fn.getloclist(0)

    -- Parsing the pat
    local firstChar = string.sub(pat, 1, 1)
    local lastChar  = string.sub(pat, -1, -1)
    if firstChar == lastChar and (firstChar == '/' or firstChar == '"' or firstChar == "'") then
        pat = string.sub(pat, 2, -2)
        if pat == '' then
            -- Use the last search pattern
            pat = lastFilterPat
        end
    else
        pat = pat
    end

    if pat == "%" or pat == "#" then
        pat = fn.expand("#:t:r")
    end

    if pat == '' then return end


    local cond
    local regex = vim.regex(fn.escape(pat, "\\"))
    if not regex then return end

    if bang == '!' then
        cond = function(i)
            return (not regex:match_str(i.text)) and (not regex:match_str(fn.bufname(i.bufnr)))
        end
    else
        cond = function(i)
            return regex:match_str(i.text) or regex:match_str(fn.bufname(i.bufnr))
        end
    end

    local newItems = vim.tbl_filter(cond, items)
    -- Check whether item list is emptry and prompt for continuation
    if not next(newItems) then
        vim.cmd "noa echohl MoreMsg"
        local answer = fn.confirm("No satisified items, proceed?  ",
            ">>> &Yes\n&No\n&Cancel", 3, "Question")
        vim.cmd "noa echohl None"

        if answer ~= 1 then
            return
        end
    end

    -- Store the previous item list
    if #newItems ~= #items then M.lastQuickfixItems = items end

    -- Populate new items
    if qfChk then
        fn.setqflist({}, " ", {items = newItems})
    else
        fn.setloclist(0, {}, " ", {items = newItems})
    end

    -- Optional step need to do for todo-comment
    refreshTodoComment()
end


--- Open an item in quickfix window like :cc do, except that it will always use
--- the last window to open a quickfix item, which is what I call the
--- 'uselastWin' method for 'switchbuf' option. The vim.v.count will only open
--- a specific line, of which line number is decided by vim.v.count
---@param closeQuickfix boolean
M.cc = function(closeQuickfix, useWinCall) -- {{{
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
        return
    end

    -- TODO: highlight the invalid item?
    if not api.nvim_buf_is_valid(qfItem.bufnr) then vim.notify("Buffer is no longer valid") end

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

end -- }}}


--- Destroy floating window and the buffer within created by M.info() before
--- leaving quickfix. This func is mainly used as a autocmd callback
M.closeFloatWin = function(_) -- {{{
    if not M.floatWinID then return end
    if not api.nvim_win_is_valid(M.floatWinID) then return end

    api.nvim_win_close(M.floatWinID, false)
    M.floatWinID = nil

    -- Delete buffer as well
    if M.bufNr and api.nvim_buf_is_valid(M.bufNr) then
        api.nvim_buf_delete(M.bufNr, {force = true})
        M.bufNr = nil
    end
end -- }}}


M.info = function () -- {{{
    local qfWinId = api.nvim_get_current_win()
    local qfCursorPos = api.nvim_win_get_cursor(qfWinId)
    local qfWinInfo = fn.getwininfo(qfWinId)
    qfWinInfo = #qfWinInfo == 1 and qfWinInfo[1] or qfWinInfo
    local qfBotlineNr = qfWinInfo.botline

    local qfItems = fn.getqflist()
    local itemInfo = qfItems[qfCursorPos[1]]
    local bufName
    local ok, _  = pcall(fn.bufname, itemInfo.bufnr)
    if not ok then bufName = "" end

    -- Create win
    local padding = string.rep(" ", 1)
    local winWidth = 35
    local winHeight = 11 + #padding +
        math.ceil(#bufName / winWidth) +
        math.ceil((string.len(itemInfo.text) + 5) / winWidth)

    local anchorVer = qfBotlineNr - qfCursorPos[1] < winHeight + 1 and "S" or "N"
    local anchorHor = qfWinInfo.width - qfCursorPos[2] - 8 < winWidth and "E" or "W"

    M.floatWinID = api.nvim_open_win(0, false, {
        relative = "cursor",
        width = winWidth,
        height = winHeight,
        anchor = anchorVer .. anchorHor,
        row = 0,
        col = 1,
        style = "minimal",
        border = "rounded"
    })
    api.nvim_win_set_option(M.floatWinID, "signcolumn", "no")

    -- Create buf
    if not M.bufNr then
        M.bufNr = api.nvim_create_buf(false, true)
    end

    local lines = {}
    -- Insert at the top filename
    table.insert(lines, padding .. bufName)
    table.insert(lines, string.rep("─", winWidth))

    -- Insert item info
    for _, key in ipairs(vim.tbl_keys(itemInfo)) do
        local line = string.format("%s%s: %s", padding, key, itemInfo[key])
        table.insert(lines, line)
    end

    api.nvim_buf_set_lines(M.bufNr, 0, -1, false, lines)
    api.nvim_buf_set_option(M.bufNr, "modified", false)
    api.nvim_win_set_buf(M.floatWinID, M.bufNr)
end -- }}}

--- Delete quickfix item and reflect immediately. vim.v.count prefix will result
--- in delete corresponding line in quickfix
---@param vimMode string Vim mode. "n" or "v"
M.delete = function (vimMode) -- {{{
    local qfCursorPos = api.nvim_win_get_cursor(0)
    local qfItems = fn.getqflist()

    if vimMode == "n" then
        local itemNr  = vim.v.count == 0 and qfCursorPos[1] or vim.v.count
        if #qfItems == 0 then return end

        -- Backup items
        M.lastQuickfixItems = qfItems

        table.remove(qfItems, itemNr)
        fn.setqflist({}, "r", {items = qfItems})

        refreshTodoComment()

        -- Neovim will take care of the new position even the row number is out of scope
        api.nvim_win_set_cursor(0, qfCursorPos)
    else
        -- Backup items
        M.lastQuickfixItems = qfItems
        local startPos = api.nvim_buf_get_mark(0, "<")
        local endPos   = api.nvim_buf_get_mark(0, ">")

        for _ = 1, endPos[1] - startPos[1] + 1, 1 do
            table.remove(qfItems, startPos[1])
        end
        fn.setqflist({}, "r", {items = qfItems})

        refreshTodoComment()

        -- Neovim will take care of the new position even the row number is out of scope
        api.nvim_win_set_cursor(0, startPos)
    end
end -- }}}


M.recovery = function () -- {{{
    if M.lastQuickfixItems then
        fn.setqflist({}, "r", {items = M.lastQuickfixItems})
        M.lastQuickfixItems = nil
    else
        return
    end
end -- }}}


return M
