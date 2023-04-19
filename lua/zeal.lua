local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
local zealGlobalChk

--- Look up motionwise selected text with Zeal, Goldendict, Cheat or TL;DR
--- @param args table {motionType, vimMode, plugMap}
---        motionType: String. Motion type by which how the operator perform.
---                    Can be "line", "char" or "block"
---        vimMode:    String. Vim mode. See: `:help mode()`
---        plugMap:    String. eg: <Plug>myplug
---        vimMode:    String. Vim mode. See: `:help mode()`
local function lookUp(args)

    -- local opts     = {hlGroup="Search", timeout=500}
    -- local curBufNr = api.nvim_get_current_buf()
    local operator   = require("operator")
    local motionType = args[1]
    local vimMode    = args[2]
    local plugMap    = vimMode == "n" and operator.plugMap or args[3]
    if motionType == "block" or motionType == "line" then
        return vim.notify("Blockwise or linewise is not supported", vim.log.levels.WARN)
    end

    local command
    local content
    local posStart
    local posEnd
    local curWinID  = api.nvim_get_current_win()

    -- Get content {{{
    if vimMode == "n" then
        posStart = api.nvim_buf_get_mark(0, "[")
        posEnd   = api.nvim_buf_get_mark(0, "]")
        api.nvim_win_set_cursor(0, posStart)
        cmd "noa normal! v"
        api.nvim_win_set_cursor(0, posEnd)
        cmd "noa normal! v"
    else
        cmd("noa normal! gv" .. t"<Esc>")
        posStart = api.nvim_buf_get_mark(0, "<")
        posEnd   = api.nvim_buf_get_mark(0, ">")
    end
    content = require("util").visualSelection("string")
    -- }}} Get content

    cmd "noa echohl MoreMsg"
    local answer = fn.confirm("Save modification?",
        ">>> &Zeal\n&Goldendict\nch&Eat\n&TL;DR\n&Cancel", 5, "Question")
    cmd "noa echohl None"
    if answer == 1 then
        if fn.executable("zeal") ~= 1 then
            return vim.notify("Zeal not found on environment", vim.log.levels.ERROR)
        end
        command = zealGlobalChk and "zeal " or string.format("zeal %s:", vim.bo.filetype)
        fn.jobstart(command .. content)
    elseif answer == 2 then
        if fn.executable("goldendict") ~= 1 then
            return vim.notify("Goldentdict not found on environment", vim.log.levels.ERROR)
        end
        command = "goldendict "
        fn.jobstart(command .. content)
    elseif answer == 3 then
        cmd(string.format("noa Cheat %s %s", vim.bo.filetype, content))
    elseif answer == 4 then
        -- TODO:
        return
        -- Print(fn.system(string.format("tldr %s %s", vim.bo.filetype, content)))
    else
        return
    end

    -- Restore cursor position
    if vimMode == "n" and not require("util").withinRegion(operator.cursorPos, posStart, posEnd) then
        return
    else
        api.nvim_win_set_cursor(curWinID, operator.cursorPos)
    end

    -- Dot repeat
    if vimMode ~= "n" then
        fn["repeat#set"](t(plugMap))
        fn["visualrepeat#set"](t(plugMap))
    end

end

function M.zealGlobal(args)
    zealGlobalChk = true
    lookUp(args)
end


function M.zeal(args)
    zealGlobalChk = false
    lookUp(args)
end

return M
