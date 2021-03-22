local vim = vim
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- Add trailing ;
function M.trailingChar(trailingChar) -- {{{
    local curPos
    if trailingChar == "O" then
        curPos = api.nvim_win_get_cursor(0)
        cmd [[normal! O]]
        api.nvim_win_set_cursor(0, curPos)
    elseif trailingChar == "o" then
        curPos = api.nvim_win_get_cursor(0)
        cmd [[normal! o]]
        api.nvim_win_set_cursor(0, curPos)
    else
        local curLine = api.nvim_get_current_line()
        if string.sub(curLine, #curLine) ~= trailingChar then
            curPos = api.nvim_win_get_cursor(0)
            cmd("normal! A" .. trailingChar)
            api.nvim_win_set_cursor(0, curPos)
        end
    end
end -- }}}

return M

