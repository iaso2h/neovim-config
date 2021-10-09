local vim = vim
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- Add trailing ;
function M.trailingChar(trailingChar) -- {{{
    local curPos = api.nvim_win_get_cursor(0)
    -- local curLine = api.nvim_get_current_line()
    -- if string.sub(curLine, #curLine) ~= trailingChar then
        cmd("noa normal! A" .. trailingChar)
        api.nvim_win_set_cursor(0, curPos)
    -- end
end -- }}}

return M

