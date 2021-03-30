local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.query(argTble)
    if fn.executable("zeal") ~= 1 then
        api.nvim_echo({{"Zeal not found on Path", "ErrorMsg"}}, true, {})
    end

    -- local opts     = {hlGroup="Search", timeout=500}
    local curWinID = api.nvim_get_current_win()
    -- local curBufNr = api.nvim_get_current_buf()
    local motionwise = argTble[1]
    local vimMode    = argTble[2] or "n"
    local content    = "zeal " .. vim.bo.filetype .. ":"
    local operator   = require("operator")
    local pos1
    local pos2

    if vimMode == "n" then
        pos1 = api.nvim_buf_get_mark(0, "[")
        pos2 = api.nvim_buf_get_mark(0, "]")
        api.nvim_win_set_cursor(0, pos1)
        cmd("normal! v")
        api.nvim_win_set_cursor(0, pos2)
        cmd("normal! v")
    else
        pos1 = api.nvim_buf_get_mark(0, "<")
        pos2 = api.nvim_buf_get_mark(0, ">")
    end
    content = content .. require("util").visualSelection("string")

    -- fn.system(content)
    fn.jobstart(content)

    -- Change to 0,0 based index
    pos1 = {pos1[1] - 1, pos1[2]}
    pos2 = {pos2[1] - 1, pos2[2]}

    -- Create highlight {{{
    -- local zealHLNS = api.nvim_create_namespace('zealQuery')
    -- api.nvim_buf_clear_namespace(curBufNr, zealHLNS, 0, -1)

    -- local region = vim.region(curBufNr, pos1, pos2, fn.getregtype(),
        -- vim.o.selection == "inclusive" and true or false)
    -- for lineNr, cols in pairs(region) do
        -- api.nvim_buf_add_highlight(curBufNr, zealHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
    -- end

    -- vim.defer_fn(function()
        -- api.nvim_buf_clear_namespace(curBufNr, zealHLNS, 0, -1)
    -- end, opts["timeout"])
    -- }}} Create highlight

    -- Restor cursor position
    api.nvim_win_set_cursor(curWinID, operator.cursorPos)
end

return M

