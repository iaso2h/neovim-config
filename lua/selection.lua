local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.oppoSelection() -- {{{
    local curPos         = api.nvim_win_get_cursor(0)
    local startSelectPos = api.nvim_buf_get_mark(0, "<")
    if startSelectPos[1] == 0 then return end  -- Sanity check
    local endSelectPos   = api.nvim_buf_get_mark(0, ">")
    if curPos[1] == startSelectPos[1] then
        api.nvim_win_set_cursor(0, endSelectPos)
        return
    elseif curPos[1] == endSelectPos[1] then
        api.nvim_win_set_cursor(0, startSelectPos)
        return
    end
    local closerToEnd = require("util").posDist(startSelectPos, curPos) > require("util").posDist(endSelectPos, curPos) and true or false
    if closerToEnd then
        local endSelectLen = #api.nvim_buf_get_lines(0, endSelectPos[1] - 1, endSelectPos[1], false)[1]
        if endSelectLen < endSelectPos[2] then
            api.nvim_win_set_cursor(0, {endSelectPos[1], endSelectLen - 1})
        else
            api.nvim_win_set_cursor(0, endSelectPos)
        end
    else
        api.nvim_win_set_cursor(0, startSelectPos)
    end
end -- }}}

return M

