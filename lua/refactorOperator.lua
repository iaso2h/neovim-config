-- File: refactorOperator.lua
-- Author: iaso2h
-- Description: Operator func that wraps around refactor.nvim
-- Version: 0.0.1
-- Last Modified: 2023-2-23
local api  = vim.api
require("operator")
local M = {
    cursorPos = nil, -- (1, 0) indexed
}


----
-- Function: warnRead Warn when buffer is not modifiable
--
-- @return: return true when buffer is readonly
----
local warnRead = function()
    if not vim.o.modifiable or vim.o.readonly then
        vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
        return false
    end
    return true
end


function M.operator(_) -- {{{
    if not warnRead() then return end

    -- NOTE: see ":help g@" for details about motionType
    local startPos = api.nvim_buf_get_mark(0, "[")
    local endPos   = api.nvim_buf_get_mark(0, "]")

    -- Set cursor
    api.nvim_win_set_cursor(0, startPos)
    vim.cmd("noa normal! v")
    api.nvim_win_set_cursor(0, endPos)

    require("refactoring").select_refactor()
end -- }}}


--- Expression callback for refactor operator
--- @param restoreCursorChk boolean Whether to restore the cursor if possible
--- @return string "g@"
function M.expr(restoreCursorChk) -- {{{
    if not warnRead() then return "" end

    _opfunc = M.operator
    vim.o.opfunc = "LuaExprCallback"

    if restoreCursorChk then
        -- Preserving cursor position as its position will changed once the
        -- vim.o.opfunc() being called
        M.cursorPos = api.nvim_win_get_cursor(0)
    else
        M.cursorPos = nil
    end

    return "g@"
end -- }}}


return M

