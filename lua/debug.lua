local fn  = vim.fn
local api = vim.api
local M   = {}

map("n", "gh", [[:lua require("debug").main()<cr>]], "which_key_ignore")
-- map("", [[gh]], [[luaeval("require('operator').main(require('debug').main, false)")]], {"silent", "expr"})
function M.main()
    Print("---------")
    Print(vim.v.searchforward)
    vim.cmd[[
        norm! Fe
    ]]
    Print(vim.v.searchforward)
    -- local cursorPos = api.nvim_win_get_cursor(0)
    -- api.nvim_buf_set_lines(0, cursorPos[1] - 1, cursorPos[1], false, {api.nvim_get_current_line()})
    -- Print(vim.api.nvim_buf_get_mark(0, "["));
    -- Print(vim.api.nvim_buf_get_mark(0, "]"))
end

return M

