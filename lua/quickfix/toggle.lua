return function (closeChk)
    local api = vim.api
    local fn  = vim.fn

    -- Close the current window if it's a quickfix window
    if vim.bo.buftype == "quickfix" then
        return api.nvim_win_close(0, false)
    end

    -- Toggle on
    local winInfo = fn.getwininfo()
    for _, tbl in ipairs(winInfo) do
        if tbl["quickfix"] == 1 then
            if closeChk then
                return api.nvim_win_close(tbl.winid, false)
            else
                api.nvim_set_current_win(tbl.winid)
            end
        end
    end

    -- Fallback
    vim.cmd "copen"
end
