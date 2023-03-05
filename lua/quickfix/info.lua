-- TODO: quifix convert into a window localist
local fn  = vim.fn
local api = vim.api
local M   = {
    floatWinId = nil,
    bufNr = nil,
}


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
    local ok, msg  = pcall(fn.bufname, itemInfo.bufnr)
    local bufName = ok and msg or ""

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



return M
