local api = vim.api
local M   = {
    plugMap   = nil,
    cursorPos = nil,
    extraArgs = nil
}

vim.cmd [[
function! LuaExprCallback(...)
    let l:args = deepcopy(a:000)
    call add(l:args, mode())
    return v:lua._opfunc(l:args)
endfunction
]]

function _G.saveCursorPos()
    M.cursorPos = api.nvim_win_get_cursor(0)
end


---Expression function that evaluated to return str for mapping
---@param func            function
---@param checkModifiable boolean Set this to true if the operator will
---                       modify the buffer
---@param plugMap         string e.g: <Plug>myPlug
---@return string "g@" if successful
-- TODO:use hook func to preserve info
function M.expr(func, checkModifiable, plugMap)
    if checkModifiable then
        if not vim.o.modifiable or vim.o.readonly then
            vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
            return ""
        end
    end
    if vim.v.register == "=" then return "" end

    _G._opfunc   = func
    M.plugMap    = plugMap
    M.cursorPos  = api.nvim_win_get_cursor(0)
    vim.o.opfunc = "LuaExprCallback"
    return "g@"
end


--- Using to detect the motion type of vim visual mode
--- @param saveCursorChk boolean Whether to save cursor position or not
--- @return table with two str represent motion type and vim visual mode
function M.vMotion(saveCursorChk)
    -- NOTE: see ":help g@" for details about motionType
    local visualMode = vim.fn.visualmode()
    local motionType
    if visualMode == "v" then
        motionType = "char"
        if saveCursorChk then M.cursorPos = api.nvim_win_get_cursor(0) end
    elseif visualMode == "V" then
        -- Visual Line Mode the cursor will place at the first column once
        -- entering commandline mode.
        motionType = "line"
        if saveCursorChk then
            vim.cmd([[noa norm! gv]])
            M.cursorPos = api.nvim_win_get_cursor(0)
            vim.cmd([[noa norm! ]] .. t"<Esc>")
        end
    elseif visualMode == "\22" then
        motionType = "block"
        if saveCursorChk then M.cursorPos = api.nvim_win_get_cursor(0) end
    else
        vim.notify(string.format([[Uncaptrued visual mode: %s]], visualMode), vim.log.levels.ERROR)
    end
    return {motionType, visualMode}
end

return M

