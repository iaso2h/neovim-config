local M = {
    plugMap   = nil,
    cursorPos = {},
}

---@class GenericOperatorInfo
---@field motionType string "line" or "char". Determine whether the motion is linewise
---@field vimMode string Vim mode. See: `:help mode()`

---@class MotionRegion
---@field Start integer[] The row number and column index where motion started
---@field End integer[] The row number and column index where motion ended


-- NOTE: see ":help g@" for details about motionType
vim.cmd [[
function! LuaExprCallback(motionType)
    return v:lua._opfunc({"motionType": a:motionType, "vimMode": mode()})
endfunction
]]

--- Save the cursor position. (1, 0) based
function _G.saveCursorPos() -- {{{
    M.cursorPos = vim.api.nvim_win_get_cursor(0)
end -- }}}
--- Expression function that evaluated to return str for mapping
---@param func            function
---@param checkModifiable boolean Set this to true if the operator will modify the buffer
---@param plugMap         string e.g: <Plug>myPlug
---@return string # "g@" if successful
-- TODO:use hook func to preserve info
function M.expr(func, checkModifiable, plugMap) -- {{{
    if checkModifiable then
        if not vim.o.modifiable or vim.o.readonly then
            vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
            return ""
        end
    end
    if vim.v.register == "=" then return "" end

    _G._opfunc   = func
    M.plugMap    = plugMap
    M.cursorPos  = vim.api.nvim_win_get_cursor(0)
    vim.o.opfunc = "LuaExprCallback"
    return "g@"
end -- }}}
--- Using to detect the motion type of Neovim visual mode
---@param saveCursorChk boolean Whether to save cursor position
---@return GenericOperatorInfo
function M.visualOpInfo(saveCursorChk) -- {{{
    -- NOTE: see ":help g@" for details about motionType
    local vimMode = vim.fn.visualmode()
    local motionType
    if vimMode == "V" then
        -- Visual Line Mode the cursor will place at the first column once
        -- entering commandline mode.
        motionType = "line"
        if saveCursorChk then
            vim.cmd([[noa norm! gv]])
            M.cursorPos = vim.api.nvim_win_get_cursor(0)
            vim.cmd([[noa norm! ]] .. t"<Esc>")
        end
    else
        motionType = "char"
        if saveCursorChk then M.cursorPos = vim.api.nvim_win_get_cursor(0) end
    end

    return {motionType = motionType, vimMode = vimMode}
end -- }}}
--- Get motion region in `"[` and `"]`. Support multibyte character
---@param vimMode string Vim mode
---@param bufNr? integer Retrieved by calling `vim.api.nvim_get_current_bufnr()`
---@retrun MotionRegion
function M.getMotionRegion(vimMode, bufNr)
    bufNr = bufNr or 0
    if vimMode == "n" then
        local region = {
            Start = vim.api.nvim_buf_get_mark(bufNr, "["),
            End   = vim.api.nvim_buf_get_mark(bufNr, "]")
        }

        -- Avoid out of bound column index
        if region.End[2] > 0 then
            local endCharToEnd = vim.api.nvim_buf_get_text(
                0,
                region.End[1] - 1,
                region.End[2],
                region.End[1] - 1,
                -1,
                {}
            )[1]
            region.End[2] = region.End[2] + vim.fn.byteidx(endCharToEnd, 1) - 1
        end
        return region
    else
        region = {
            Start = vim.api.nvim_buf_get_mark(bufNr, "<"),
            End   = vim.api.nvim_buf_get_mark(bufNr, ">")
        }
        endLine = vim.api.nvim_buf_get_lines(bufNr, region.End[1] - 1, region.End[1], false)[1]

        -- Avoid out of bound column index
        if #endLine > 0 then
            if region.End[2] > #endLine then
                region.End[2] = #endLine - 1
            end
        else
            region.End[2] = 0
        end

        return region
    end

end

return M
