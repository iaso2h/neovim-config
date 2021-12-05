local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

M.main = function ()
    local line      = api.nvim_get_current_line()
    local cursorPos = api.nvim_win_get_cursor(0)
    local cursorChar = string.sub(line, cursorPos[2] + 1, cursorPos[2] + 1)
    if cursorChar == " " then
        api.nvim_feedkeys(t"s<CR><Esc>l", "n", false)
    else
        api.nvim_feedkeys(t"i<CR><Esc>l", "n", false)
    end
end

return M
