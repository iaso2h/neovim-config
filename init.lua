-- THE MOST IMPORTANT OPTION
vim.opt.undofile = true

if vim.fn.has("nvim-0.11.0") ~= 1 then
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify("Neovim with 0.11.0 or higher build version is required", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    return
end

local ok, msg = pcall(require, "global")
if not ok then
    return vim.notify(msg, vim.log.levels.ERROR)
end

require "core"

if _G._enable_plugin then
    vim.defer_fn(function()
        ok, msg = pcall(require, "plugins")
        if not ok then
            _G._enable_plugin = false
            return vim.notify(msg, vim.log.levels.ERROR)
        end
    end, 0)
end
