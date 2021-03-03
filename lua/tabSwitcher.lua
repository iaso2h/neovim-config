local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.main()
  if vim.bo.shiftwidth == 4 then
    local flags = [[setlocal shiftwidth=2 softtabstop=2 tabstop=2]]
    vim.b.luaFormatflags = [[--indent-width=2 --tab-width=2 --continuation-indent-width=2]]
    cmd(flags)
    api.nvim_echo({{"Shiftwidth has been changed to 2", "Moremsg"}}, true, {})
  elseif vim.bo.shiftwidth == 2 then
    local flags = [[setlocal shiftwidth=4 softtabstop=4 tabstop=4]]
    vim.b.luaFormatflags = [[--indent-width=4 --tab-width=4 --continuation-indent-width=4]]
    cmd(flags)
    api.nvim_echo({{"Shiftwidth has been changed to 4", "Moremsg"}}, true, {})
  end
end

return M

