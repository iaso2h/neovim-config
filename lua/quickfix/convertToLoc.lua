return function ()
    local fn  = vim.fn
    local api = vim.api

    local qfItems = require("quickfix.util").getlist()
    local winInfo = fn.getwininfo()
    for _, tbl in ipairs(winInfo) do
        if tbl["quickfix"] == 1 then
            api.nvim_win_close(tbl.winid, false)
            break
        end
    end
    fn.setloclist(0, {}, " ", {items = qfItems})
end
