local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
map = require("util").map
function M.printMode()
    cmd "normal! gv"
    Print(api.nvim_get_mode())
end
-- map("n", "<leader>t", ":lua require('debug').printMode()<cr>", {})
-- map("v", "<leader>t", ":lua require('debug').printMode()<cr>", {})

return M

