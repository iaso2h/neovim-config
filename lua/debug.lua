local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
map("v", "<leader>t", [[:lua Print(require('util').visualSelection("string"))<cr>]], {})

return M

