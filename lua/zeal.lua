-- File: zeal.lua
-- Author: iaso2h
-- Description: Loop up words
-- Version: 0.0.5
-- Last Modified: 2023-4-26

local M = {
    plugMap = ""
}
local zealGlobalChk

--- Look up motionwise selected text with Zeal, Goldendict, Cheat or TL;DR
---@param opInfo GenericOperatorInfo
local function lookUp(opInfo) -- {{{
    local operator = require("operator")
    if opInfo.motionType == "block" or opInfo.motionType == "line" then
        return vim.notify("Blockwise or linewise is not supported", vim.log.levels.WARN)
    end

    local command
    local content
    local posStart
    local posEnd
    local curWinID  = vim.api.nvim_get_current_win()

    -- Get content {{{
    if opInfo.vimMode == "n" then
        posStart = vim.api.nvim_buf_get_mark(0, "[")
        posEnd   = vim.api.nvim_buf_get_mark(0, "]")
        vim.api.nvim_win_set_cursor(0, posStart)
        vim.cmd "noa normal! v"
        vim.api.nvim_win_set_cursor(0, posEnd)
        vim.cmd "noa normal! v"
    else
        vim.cmd("noa normal! gv" .. t"<Esc>")
        posStart = vim.api.nvim_buf_get_mark(0, "<")
        posEnd   = vim.api.nvim_buf_get_mark(0, ">")
    end
    content = require("selection").get("string")
    -- }}} Get content

    vim.cmd "noa echohl MoreMsg"
    local answer = vim.fn.confirm("Save modification?",
        ">>> &Zeal\n&Goldendict\nch&Eat\n&Thesaurus\n&Cancel", 5, "Question")
    vim.cmd "noa echohl None"

    if answer == 1 then
        if vim.fn.executable("zeal") ~= 1 then
            return vim.notify("Zeal not found on environment", vim.log.levels.ERROR)
        end
        command = zealGlobalChk and "zeal " or string.format("zeal %s:", vim.bo.filetype)
        vim.fn.jobstart(command .. content)
    elseif answer == 2 then
        if vim.fn.executable("goldendict") ~= 1 then
            return vim.notify("Goldentdict not found on environment", vim.log.levels.ERROR)
        end
        command = "goldendict "
        vim.fn.jobstart(command .. content)
    elseif answer == 3 then
        vim.cmd(string.format("noa Cheat %s %s", vim.bo.filetype, content))
    elseif answer == 4 then
        return require("thesaurus").lookUp(content)
    else
        return
    end

    -- Restore cursor position
    if opInfo.vimMode == "n" and not require("util").withinRegion(operator.cursorPos, posStart, posEnd) then
        return
    else
        vim.api.nvim_win_set_cursor(curWinID, operator.cursorPos)
    end

    -- Dot repeat
    if opInfo.vimMode ~= "n" then
        if vim.fn.exists("g:loaded_repeat") == 1 then
            vim.fn["repeat#set"](t(M.plugMap))
        end
        if vim.fn.exists("g:loaded_visualrepeat") == 1 then
            vim.fn["visualrepeat#set"](t(M.plugMap))
        end
    end
end -- }}}

--- Look up keyword globally in the zeal(ignore language)
---@param args table see `operator()`
function M.zealGlobal(args)
    zealGlobalChk = true
    lookUp(args)
end


--- Look up keyword specific to its language in the zeal
---@param args table see `operator()`
function M.zeal(args)
    zealGlobalChk = false
    lookUp(args)
end

return M
