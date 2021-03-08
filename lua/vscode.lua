local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = require("util").map
local M   = {}

function M.exitInsert()
    fn.VSCodeCall("vscode-neovim.compositeEscape1")
    fn.VSCodeCall("cursorLeft")
end

return M
