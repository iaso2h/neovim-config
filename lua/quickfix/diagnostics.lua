-- File: diagnostics
-- Author: iaso2h
-- Description: Open diagnostics in quickfix window
-- Credit: https://github.com/onsails/diaglist.nvim
-- Version: 0.0.7
-- Last Modified: 2023-10-22
-- TODO: Preview mode implementation
-- TODO: Auto highlight selection
local M = {
    changedTick         = false,
    autocmdSetupTick   = false,
    autocmdId          = -1,

    -- Options
    remainFocus  = true, -- Remain the focus in the current window when open a quickfix when it's not visible
    debounceTime = 100,  -- The bigger it's, the longer time quickfix will react
    delAutocmd   = true,  -- Delete autocmd when the quickfix title doesn't contain "Diagnostics" any more

    filteredChk = false -- Set this to true if the the diagnostics list has been filtered before
}
local u  = require("quickfix.util")


local vimModeValidate = function()
    local vimMode = vim.api.nvim_get_mode().mode
    local filterModes = {
        "i", "ic", "ix"
    }
    if vim.tbl_contains(filterModes, vimMode) then
        return false
    end
    return true
end
--- Setup the Neovim autocmd
local autocmdSetup = function() -- {{{
    if not M.autocmdSetupTick then
        M.autocmdId = vim.api.nvim_create_autocmd({"DiagnosticChanged", "WinEnter", "BufEnter"}, {
            callback = function(args)
                if not vimModeValidate() then
                    -- Don't refresh the quickfix while editing in certain Vim mode
                    M.changedTick = false
                    return
                end

                if args.event == "DiagnosticChanged" and
                    not M.changedTick then

                    local title = require("quickfix.util").getlist{title = 0}.title
                    if not string.find(title, "Diagnostics") then
                        -- Delete this autocmd if other items and titles get
                        -- populated into quickfix window
                        if M.delAutocmd then
                            vim.api.nvim_del_autocmd(M.autocmdId)
                            M.autocmdId = -1
                            M.autocmdSetupTick = false
                        end
                        return
                    end
                    M.changedTick = true
                    M.debounceFunc(false, false)
                else
                    -- The "WinEnter" and "BufEnter" will trigger
                    -- "DiagnosticsChanged" somehow. If we are lucky enough,
                    -- and "WinEnter" and "BufEnter" event are fired right
                    -- after "DiagnosticChanged" setting the `changeTick` to
                    -- true and the debounce function isn't called within
                    -- `debounceTime`, then we can't halt the processing at
                    -- earlier stage inside the `allDiagnostics` function
                    M.changedTick = false
                end
            end,
        })

        M.autocmdSetupTick = true
    end
end -- }}}
--- Open diagnostics in quickfix window
---@param forceChk boolean Set it to true if this function is called by a mapping instead of autocommand
---@param localChk boolean Whether it's a locallist or a quickfix
M.refresh = function(forceChk, localChk) -- {{{
    -- Setup autocmd monitoring the diagnostics changed event
    if not M.autocmdSetupTick then autocmdSetup() end

    -- Don't open quickfix if diagnostic haven't change
    if not M.changedTick and not forceChk then return end

    -- Check visibility of quickfix window
    local qfBufNr
    local qfWinId
    local quickfixVisibleTick = false
    local winIds = require("buffer.util").winIds(false)
    local bufInWin
    for _, win in ipairs(winIds) do
        bufInWin = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(bufInWin, "buftype") == "quickfix" then
            quickfixVisibleTick = true
            qfWinId = win
            qfBufNr = bufInWin
            break
        end
    end
    -- Don't auto-open quickfix when it's already close
    if not quickfixVisibleTick and not forceChk then return end

    local diagnostics = vim.diagnostic.get(nil, { severity = { min = vim.diagnostic.severity.HINT } })
    local qfItems     = vim.diagnostic.toqflist(diagnostics)
    -- Don't auto-open quickfix when there's no diagnostics
    if not next(qfItems) then
        return vim.notify("No available diagnostics")
    end

    -- Get window id and buffer number of quickfix
    if quickfixVisibleTick then
        if vim.bo.buftype == "quickfix" then
            qfBufNr = vim.api.nvim_get_current_buf()
            qfWinId = vim.api.nvim_get_current_win()
        else
            -- Do nothing
        end
    else
        if forceChk then
            vim.cmd [[noa copen]]
            qfBufNr = vim.api.nvim_get_current_buf()
            qfWinId = vim.api.nvim_get_current_win()
        else
            return
        end
    end

    -- Sort file so that errors from current buffer has a higher priority
    u.sortByFile(qfItems, qfBufNr)

    -- Setting up quickfix
    local qfTitle = localChk and "Local Diagnostics" or "Workspace Diagnostics"
    if localChk then
        vim.fn.setloclist(qfWinId, {}, "r", { title = qfTitle, items = qfItems })
    else
        vim.fn.setqflist({},           'r', { title = qfTitle, items = qfItems })
    end

    -- Reset the filtered check since it has been refreshed an updated
    if M.filtered then M.filtered = false end

    -- Make up the highlights for character string "warning", "note"
    require("quickfix.highlight").refreshHighlight(qfBufNr, qfItems, qfTitle)

    M.changedTick = false
end -- }}}


M.debounceFunc = u.debounce(M.debounceTime, M.refresh)


return M
