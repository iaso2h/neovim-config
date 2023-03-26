if vim.fn.has("nvim-0.9.0") ~= 1 then
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify("Neovim with 0.9.0 or higher build version required", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    return
end

local ok, msg = pcall(require, "global")
if not ok then
    return vim.notify(msg, vim.log.levels.ERROR)
end

require "core"
