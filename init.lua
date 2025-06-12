-- THE MOST IMPORTANT OPTION
vim.opt.undofile = true


if vim.fn.has("nvim-0.11.0") ~= 1 then
    vim.api.nvim_echo({ { " ", "WarningMsg" } }, true, {})
    vim.api.nvim_echo({ { " ", "WarningMsg" } }, true, {})
    vim.api.nvim_echo({ { "Neovim with 0.11.0 or higher build version is required", "WarningMsg" } }, true, {})
    vim.api.nvim_echo({ { " ", "WarningMsg" } }, true, {})
    vim.api.nvim_echo({ { " ", "WarningMsg" } }, true, {})
    return
end

local ok, msg = pcall(require, "global")
if not ok then
    return vim.api.nvim_echo({{msg,}}, true, {err=true})
end

require "core"

if _G._enable_plugin then
    vim.defer_fn(function()
        ok, msg = pcall(require, "plugins")
        if not ok then
            _G._enable_plugin = false
            return vim.api.nvim_echo({ { msg } }, true, { err=true })
        end
    end, 0)
end
