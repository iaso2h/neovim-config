-- File: diagnostics
-- Author: iaso2h
-- Description: Open diagnostics in quickfix window
-- Credit: https://github.com/onsails/diaglist.nvim
-- Version: 0.0.3
-- Last Modified: 04/29/2023 Sat
-- TODO: Preview mode implementation
-- TODO: Auto highlight selection
local M = {
    changeTick       = false,
    autocmdSetupTick = false,
    autocmdId        = -1,

    -- Options
    debounceTime = 250,  -- The bigger it's, the longer time quickfix will react
    delAutocmd   = true  -- Delete autocmd when the quickfix title doesn't contain "Diagnosics" any more
}
local u  = require("quickfix.util")
local hl = require("quickfix.highlight")

local autocmdSetup = function()
    if not M.autocmdSetupTick then
        M.autocmdId = vim.api.nvim_create_autocmd({"DiagnosticChanged", "WinEnter", "BufEnter"}, {
            callback = function(args)
                if args.event == "DiagnosticChanged" then
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
                    M.debounceFunc(false, false)
                    M.changeTick = true
                else
                    -- The "WinEnter" and "BufEnter" will trigger
                    -- "DiagnosticsChanged" somehow. If we are lucky enough,
                    -- and "WinEnter" and "BufEnter" event are fired right
                    -- after "DiagnosticChanged" setting the `changeTick` to
                    -- true and the debounce function isn't called within
                    -- `debounceTime`, then we can't halt the processing at
                    -- earlier stage inside the `allDiagnostics` function
                    M.changeTick = false
                end
            end,
        })

        M.autocmdSetupTick = true
    end
end


--- Open diagnostics in quickfix window
---@param forceChk boolean Set it to true if this function is called by a mapping instead of autocommand
M.open = function(forceChk, localChk)
    -- Setup autocmd monitoring the diagnostics changed event
    if not M.autocmdSetupTick then autocmdSetup() end

    -- Don't open if quickfix if dianostic haven't change
    if not M.changeTick and not forceChk then return end

    -- Don't auto-open quickfix when it's already close
    if not u.isVisible() and not forceChk then return end

    local diagnostics = vim.diagnostic.get(nil, { severity = { min = vim.diagnostic.severity.HINT } })
    local qfItems     = vim.diagnostic.toqflist(diagnostics)
    -- Don't auto-open quickfix when there's no diagnostics
    if not next(qfItems) then
        return vim.notify("No available diagnostics")
    end

    local curBufQuickfixTick
    local previousWinId
    if vim.bo.buftype == "quickfix" then
        if localChk then
            vim.cmd [[noa wincmd p]]
            previousWinId = vim.api.nvim_get_current_win()
            vim.cmd [[noa wincmd p]]
        end

        curBufQuickfixTick = true
    else
        if localChk then
            previousWinId = vim.api.nvim_get_current_win()
        end

        -- Always make sure current buffer is quickfix
        vim.cmd [[noa copen]]
        curBufQuickfixTick = false
    end

    -- Sort file so that errors from current buffer has a higher priority
    u.sortByFile(qfItems, 0)

    -- Setting up quickfix
    local title = localChk and "Local " or "Workspace "
    if localChk then
        vim.fn.setloclist(previousWinId, {}, "r", { title = title .. "Diagnostics", items = qfItems })
    else
        vim.fn.setqflist({}, 'r', { title = title .. "Diagnostics", items = qfItems })
    end

    -- Make up the highlights for character string "warning", "note"
    local asyncHandler = vim.loop.new_async(
        vim.schedule_wrap(function()
            hl.moreDiagnosticsHighlight(qfItems)
        end)
    )
    asyncHandler:send()

    if not curBufQuickfixTick and not forceChk then
        vim.cmd [[noa wincmd w]]
    end
    M.changeTick = false
end


M.debounceFunc = u.debounce(M.debounceTime, M.open)


return M
