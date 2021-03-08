local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

api.nvim_exec([[
function! LuaExprCallback(...)
    return luaeval("Opfunc(_A)", a:000)
endfunction
]], false)

function M.main(func)
    Opfunc = func
    M.nvimOperatorCursor = api.nvim_win_get_cursor(0)
    vim.o.opfunc = "LuaExprCallback"
    return "g@"
end

return M

