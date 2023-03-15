local vim = vim
local api = vim.api
local M   = {}

function M.main()
    local newWidth = vim.bo.shiftwidth == 4 and 2 or 4
    local flags = string.format("setlocal shiftwidth=%d softtabstop=%d tabstop=%d", newWidth, newWidth, newWidth)
    vim.cmd(flags)
    api.nvim_echo({ { string.format("Shiftwidth has been changed to %d", newWidth), "Moremsg" } }, true, {})
end

return M
