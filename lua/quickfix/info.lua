-- File: quickfix.info
-- Author: iaso2h
-- Description: Show quickfix item info
-- Version: 0.0.5
-- Last Modified: 2023-4-28
local M   = {
    floatWinId = nil,
    hoverBufNr = nil,
    ns = vim.api.nvim_create_namespace("quickfixHover")
}
local pallette = require("onenord.pallette")

vim.cmd(string.format([[hi! quickfixHoverKey guifg=%s ]], pallette.n9))

--- Destroy floating window and the buffer within created by `M.info()` before leaving quickfix. This func is mainly used as a autocmd callback
M.closeFloatWin = function(_) -- {{{
    if not M.floatWinID then return end
    if not vim.api.nvim_win_is_valid(M.floatWinID) then
        M.floatWinID = nil
        return
    end
    vim.api.nvim_win_close(M.floatWinID, false)
    M.floatWinID = nil

    -- Delete buffer as well
    if not M.hoverBufNr then return end
    if not vim.api.nvim_buf_is_valid(M.hoverBufNr) then
        M.hoverBufNr = nil
        return
    end
    vim.api.nvim_buf_delete(M.hoverBufNr, {force = true})
    M.hoverBufNr = nil
end -- }}}
--- Display quickfix item info under the current cursor
---@param printChk boolean Set it to true to print the info table instead
M.hover = function(printChk) -- {{{
    local qfWinId = vim.api.nvim_get_current_win()
    local qfBufNr = vim.api.nvim_get_current_buf()
    local qfCursorPos = vim.api.nvim_win_get_cursor(qfWinId)
    local qfWinInfo = vim.fn.getwininfo(qfWinId)
    qfWinInfo = #qfWinInfo == 1 and qfWinInfo[1] or qfWinInfo
    local qfBotlineNr = qfWinInfo.botline

    local qfItems  = require("quickfix.util").getlist()
    local itemInfo = qfItems[qfCursorPos[1]]

    if printChk then return Print(itemInfo) end

    local ok, msg = pcall(vim.fn.bufname, itemInfo.bufnr)
    local bufName = ok and msg or ""

    -- Create window
    local paddingNr = 1
    local padding = string.rep(" ", paddingNr)
    local winWidth = 35
    local winHeight = 11 + #padding +
        math.ceil(#bufName / winWidth) +
        math.ceil((string.len(itemInfo.text) + 5) / winWidth)

    local anchorVer = qfBotlineNr - qfCursorPos[1] < winHeight + 1 and "S" or "N"
    local anchorHor = qfWinInfo.width - qfCursorPos[2] - 8 < winWidth and "E" or "W"

    M.floatWinID = vim.api.nvim_open_win(0, false, {
        relative = "cursor",
        width = winWidth,
        height = winHeight,
        anchor = anchorVer .. anchorHor,
        row = 0,
        col = 1,
        style = "minimal",
        border = "rounded"
    })
    vim.api.nvim_set_option_value("signcolumn", "no", {win = M.floatWinID})

    -- Create buffer
    if not M.hoverBufNr or not vim.api.nvim_buf_is_valid(M.hoverBufNr) then
        M.hoverBufNr = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_win_set_buf(M.floatWinID, M.hoverBufNr)

    -- Set up autocmd
    if not vim.b.hoverSetup then
        vim.b.hoverSetup = true
        vim.api.nvim_create_autocmd({
            "CursorMoved",
            -- Neovim will enter relative buffer temporarily, so "BufLeave" will allways
            -- trigger then destroy the brand new float window and buffer within
            "WinLeave",
            "TabLeave",
            "ModeChanged",
        }, {
            buffer = qfBufNr,
            desc = "Close floating win inside quickfix when cursor moves",
            callback = require("quickfix.info").closeFloatWin,
        })
    end

    -- Setting up lines
    vim.loop.new_async(vim.schedule_wrap(function()
        local lines = {}
        -- Insert at the top filename
        table.insert(lines, { text = padding .. bufName })
        table.insert(lines, { text = string.rep("-", winWidth) })

        -- Insert item info
        for _, key in ipairs(vim.tbl_keys(itemInfo)) do     -- {{{
            if key == "bufnr" then
                lines[3] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = "Constant"
                }
            elseif key == "col" then
                lines[4] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = "Constant"
                }
            elseif key == "lnum" then
                lines[5] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = "Constant"
                }
            elseif key == "end_col" then
                lines[6] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = "Constant"
                }
            elseif key == "end_lnum" then
                lines[7] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = "Constant"
                }
            elseif key == "valid" then
                lines[8] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = "Constant"
                }
            elseif key == "text" then
                local text = itemInfo[key]
                lines[9] = {
                    text = string.format("%s%s: %s", padding, key, vim.inspect(text)),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = text == "" and "Comment" or "String"
                }
            elseif key == "type" then
                local text = itemInfo[key]
                lines[10] = {
                    text = string.format("%s%s: %s", padding, key, vim.inspect(text)),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "quickfixHoverKey",
                    valueHighlight = text == "" and "Comment" or "String"
                }
            elseif key == "module" then
                lines[11] = {
                    text = string.format("%s%s: %s", padding, key, vim.inspect(itemInfo[key])),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "Comment",
                    valueHighlight = "Comment"
                }
            elseif key == "pattern" then
                lines[12] = {
                    text = string.format("%s%s: %s", padding, key, vim.inspect(itemInfo[key])),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "Comment",
                    valueHighlight = "Comment"
                }
            elseif key == "nr" then
                lines[13] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "Comment",
                    valueHighlight = "Comment"
                }
            elseif key == "vcol" then
                lines[14] = {
                    text = string.format("%s%s: %s", padding, key, itemInfo[key]),
                    colonIdx = paddingNr + string.len(key),
                    keyHighlight = "Comment",
                    valueHighlight = "Comment"
                }
            end
        end     -- }}}

        for lineNr, line in ipairs(lines) do
            local lineIdx = lineNr - 1
            vim.api.nvim_buf_set_lines(M.hoverBufNr, lineIdx, lineNr, false, { line.text })
            if lineNr > 2 then
                if line.keyHighlight == "Comment" then
                    vim.api.nvim_buf_add_highlight(M.hoverBufNr, M.ns, "Comment", lineIdx, 0, -1)
                else
                    vim.api.nvim_buf_add_highlight(M.hoverBufNr, M.ns, line.keyHighlight, lineIdx, paddingNr,
                    line.colonIdx)
                    vim.api.nvim_buf_add_highlight(M.hoverBufNr, M.ns, "Identifier", lineIdx, line.colonIdx,
                    line.colonIdx + 1)
                    vim.api.nvim_buf_add_highlight(M.hoverBufNr, M.ns, line.valueHighlight, lineIdx, line.colonIdx + 2,
                    -1)
                end
            elseif lineNr == 2 then
                vim.api.nvim_buf_add_highlight(M.hoverBufNr, M.ns, "Comment", lineIdx, 0, -1)
            end
        end
        vim.api.nvim_set_option_value("modifiable", false, {buf = M.hoverBufNr})
        vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = M.hoverBufNr})
    end)):send()
end -- }}}


return M
