local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local M = {}
local map = require("util").map

-- map("v", "<leader>t", [[:lua Print(require('util').visualSelection("string"))<cr>]], {})
map("", [[<leader>t]], [[luaeval("require('operator').main(require('debug').main, false)")]], {"silent", "expr"})
function M.main(...)
    -- local cursorPos = api.nvim_win_get_cursor(0)
    -- api.nvim_buf_set_lines(0, cursorPos[1] - 1, cursorPos[1], false, {api.nvim_get_current_line()})
    Print(...)
    -- Print(vim.api.nvim_buf_get_mark(0, "["));
    -- Print(vim.api.nvim_buf_get_mark(0, "]"))
end

return M

