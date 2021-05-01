local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

cmd [[
function! LuaExprCallback(...)
    return luaeval("Opfunc(_A)", a:000)
endfunction
]]

----
-- Function: M.main
--
-- @param func:            lua function object
-- @param checkModifiable: expected boolean value. When this is set to True,
-- function will abort when the modifiable option is off
-- @return: string value "g@" when successful
----
function M.main(func, checkModifiable)
    if checkModifiable then
        if not vim.o.modifiable or vim.o.readonly then
            api.nvim_echo({{"Cannot make changes", "MoreMsg"}}, true, {})
            return ""
        end
    end
    if vim.v.register == "=" then return end

    Opfunc = func
    M.cursorPos = api.nvim_win_get_cursor(0)
    vim.o.opfunc = "LuaExprCallback"
    return "g@"
end

return M

