local cmd = vim.cmd
local api = vim.api
local M   = {}

cmd [[
function! LuaExprCallback(...)
    let l:args = deepcopy(a:000)
    call add(l:args, mode())
    return v:lua.Opfunc(l:args)
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

function M.vMotion()
    local lastVisual = vim.fn.visualmode()
    local motionwise
    if lastVisual == "v" then
        motionwise = "char"
    elseif lastVisual == "V" then
        motionwise = "line"
    elseif lastVisual == "\22" then
        motionwise = "block"
    end
    return {motionwise, lastVisual}
end

return M

