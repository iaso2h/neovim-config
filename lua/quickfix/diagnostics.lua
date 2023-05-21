-- File: diagnostics
-- Author: iaso2h
-- Description: Open diagnostics in quickfix window
-- Credit: https://github.com/onsails/diaglist.nvim
-- Version: 0.0.5
-- Last Modified: 04/30/2023 Sun
-- TODO: Preview mode implementation
-- TODO: Auto highlight selection
local setupAutoCmd = {
    changeTick         = false,
    highlightParseTick = false,
    autocmdSetupTick   = false,
    autocmdId          = -1,

    -- Options
    remainFocus  = true, -- Remain the focus in the current window when open a quickfix when it's not visible
    debounceTime = 150,  -- The bigger it's, the longer time quickfix will react
    delAutocmd   = true  -- Delete autocmd when the quickfix title doesn't contain "Diagnostics" any more
}
local u  = require("quickfix.util")
local ns = vim.api.nvim_create_namespace("myQuickfix")


--- Setup the Neovim autocmd
local autocmdSetup = function() -- {{{
    if not setupAutoCmd.autocmdSetupTick then
        setupAutoCmd.autocmdId = vim.api.nvim_create_autocmd({"DiagnosticChanged", "WinEnter", "BufEnter"}, {
            callback = function(args)
                if args.event == "DiagnosticChanged" and
                    not setupAutoCmd.changeTick and not setupAutoCmd.highlightParseTick then

                    local title = require("quickfix.util").getlist{title = 0}.title
                    if not string.find(title, "Diagnostics") then
                        -- Delete this autocmd if other items and titles get
                        -- populated into quickfix window
                        if setupAutoCmd.delAutocmd then
                            vim.api.nvim_del_autocmd(setupAutoCmd.autocmdId)
                            setupAutoCmd.autocmdId = -1
                            setupAutoCmd.autocmdSetupTick = false
                        end
                        return
                    end
                    setupAutoCmd.debounceFunc(false, false)
                    setupAutoCmd.changeTick = true
                else
                    -- The "WinEnter" and "BufEnter" will trigger
                    -- "DiagnosticsChanged" somehow. If we are lucky enough,
                    -- and "WinEnter" and "BufEnter" event are fired right
                    -- after "DiagnosticChanged" setting the `changeTick` to
                    -- true and the debounce function isn't called within
                    -- `debounceTime`, then we can't halt the processing at
                    -- earlier stage inside the `allDiagnostics` function
                    setupAutoCmd.changeTick = false
                end
            end,
        })

        setupAutoCmd.autocmdSetupTick = true
    end
end -- }}} 
--- Add missing highlight for warning, note, info in error column
---@param qfItems table Returned value of `vim.fn.getqflist()`
---@param qfBufNr integer The buffer number of quickfix
local moreHighlight = function(qfItems, qfBufNr) -- {{{
    setupAutoCmd.highlightParseTick = true

    local qfLines = vim.api.nvim_buf_get_lines(qfBufNr, 0, -1, false)
    for qfLineNr, item in ipairs(qfItems) do
        if item.type ~= "E" then
            local fileName = vim.fn.bufname(item.bufnr)
            local qfLine   = qfLines[qfLineNr]
            local vBarIdx  = string.find(qfLine, "|", fileName:len() + 2, true) -- 1 based index
            if vBarIdx then
                local errorText
                local errorStartIdx
                local errorHighlightGroup
                if item.type == "W" then
                    errorText = "warning"
                    errorHighlightGroup = "DiagnosticWarn"
                elseif item.type == "N" then
                    errorText = "note"
                    errorHighlightGroup = "DiagnosticHint"
                elseif item.type == "I" then
                    errorText = "info"
                    errorHighlightGroup = "DiagnosticInfo"
                end
                errorStartIdx = vBarIdx - errorText:len() -- 1 based index
                vim.api.nvim_buf_add_highlight(qfBufNr, ns, errorHighlightGroup, qfLineNr - 1, errorStartIdx - 1, vBarIdx - 1)
            end
        end
    end

    setupAutoCmd.highlightParseTick = false
end -- }}} 
--- Open diagnostics in quickfix window
---@param forceChk boolean Set it to true if this function is called by a mapping instead of autocommand
---@param localChk boolean Whether it's a locallist or a quickfix
setupAutoCmd.open = function(forceChk, localChk) -- {{{
    -- Setup autocmd monitoring the diagnostics changed event
    if not setupAutoCmd.autocmdSetupTick then autocmdSetup() end

    -- Don't open quickfix if diagnostic haven't change
    if not setupAutoCmd.changeTick and not forceChk then return end

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

    -- Clear the namespace highlight
    vim.api.nvim_buf_clear_namespace(qfBufNr, ns, 0, -1)

    -- Setting up quickfix
    local title = localChk and "Local " or "Workspace "
    if localChk then
        vim.fn.setloclist(qfWinId, {}, "r", { title = title .. "Diagnostics", items = qfItems })
    else
        vim.fn.setqflist({},           'r', { title = title .. "Diagnostics", items = qfItems })
    end

    -- Make up the highlights for character string "warning", "note"
    setupAutoCmd.changeTick = false
    local asyncHandler = vim.loop.new_async(
        vim.schedule_wrap(function()
            moreHighlight(qfItems, qfBufNr)
        end)
    )
    if asyncHandler then
        asyncHandler:send()
    else
        setupAutoCmd.highlightParseTick = true
    end
end -- }}} 


setupAutoCmd.debounceFunc = u.debounce(setupAutoCmd.debounceTime, setupAutoCmd.open)


return setupAutoCmd
