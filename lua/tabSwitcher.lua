local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.main()
  local newWidth = vim.bo.shiftwidth == 4 and 2 or 4
  if vim.bo.filetype == "lua" then
    vim.b.luaFormatflags = string.format("--indent-width=%d --tab-width=%d --continuation-indent-width=%d", newWidth, newWidth, newWidth)
  end
  local flags = string.format("setlocal shiftwidth=%d softtabstop=%d tabstop=%d", newWidth, newWidth, newWidth)
  cmd(flags)
  api.nvim_echo({{string.format("Shiftwidth has been changed to %d", newWidth), "Moremsg"}}, true, {})
end

return M

