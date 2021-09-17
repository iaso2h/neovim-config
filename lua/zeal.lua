local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
local zealGlobalChk

local function lookUp(argTble)
    if fn.executable("zeal") ~= 1 then
        api.nvim_echo({{"Zeal not found on Path", "ErrorMsg"}}, true, {})
    end

    -- local opts     = {hlGroup="Search", timeout=500}
    -- local curBufNr = api.nvim_get_current_buf()
    local motionwise = argTble[1]
    local vimMode    = argTble[2]
    if motionwise == "block" or motionwise == "line" then return end

    local command
    local content
    local curWinID = api.nvim_get_current_win()
    local cursorPos
    local pos1
    local pos2

    -- Get content {{{
    if vimMode == "n" then
        cursorPos = require("operator").cursorPos
        pos1 = api.nvim_buf_get_mark(0, "[")
        pos2 = api.nvim_buf_get_mark(0, "]")
        api.nvim_win_set_cursor(0, pos1)
        cmd "normal! v"
        api.nvim_win_set_cursor(0, pos2)
        cmd "normal! v"
    else
        cmd "normal! gv"
        cursorPos = api.nvim_win_get_cursor(0)
        pos1      = api.nvim_buf_get_mark(0, "<")
        pos2      = api.nvim_buf_get_mark(0, ">")
    end
    content = require("util").visualSelection("string")
    -- }}} Get content

    cmd "echohl MoreMsg"
    local answer = fn.confirm("Save modification?",
        ">>> &Zeal\n&Goldendict\nch&Eat\n&TL;DR\n&Cancel", 5, "Question")
    cmd "echohl None"
    if answer == 1 then
        command = zealGlobalChk and "zeal " or string.format("zeal %s:", vim.bo.filetype)
        fn.jobstart(command .. content)
    elseif answer == 2 then
        command = "goldendict "
        fn.jobstart(command .. content)
    elseif answer == 3 then
        cmd(string.format("Cheat %s %s", vim.bo.filetype, content))
    elseif answer == 4 then
        -- TODO:
        -- Print(fn.system(string.format("tldr %s %s", vim.bo.filetype, content)))
    else
        return
    end
    -- Print(execStr)
    -- do return end

    -- -- Change to 0,0 based index
    -- pos1 = {pos1[1] - 1, pos1[2]}
    -- pos2 = {pos2[1] - 1, pos2[2]}

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
    api.nvim_win_set_cursor(curWinID, cursorPos)
end

function M.zealGlobal(argTbl)
    zealGlobalChk = true
    lookUp(argTbl)
end


function M.zeal(argTbl)
    zealGlobalChk = false
    lookUp(argTbl)
end

return M

