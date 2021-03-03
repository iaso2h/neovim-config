local vim = vim
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- Add trailing ;
function M.trailingChar(trailingChar) -- {{{
    local curPos = api.nvim_win_get_cursor(0)
    if trailingChar == "O" then
        cmd [[normal! O]]
    elseif trailingChar == "o" then
        cmd [[normal! o]]
    else
        if string.sub(api.nvim_get_current_line(), -1) ~= trailingChar then
            cmd("normal! A" .. trailingChar)
        end
    end
    api.nvim_win_set_cursor(0, curPos)
end -- }}}

return M

