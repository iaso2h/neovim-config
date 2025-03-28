-- File: zeal.lua
-- Author: iaso2h
-- Description: Look up words in Zeal
-- Version: 0.0.8
-- Last Modified: 2025-03-02

local M = {
    plugMap = ""
}
local zealGlobalChk

--- Look up motionwise selected text with Zeal, Goldendict, Cheat or TL;DR
---@param opInfo GenericOperatorInfo
local function lookUp(opInfo) -- {{{
    local operator = require("operator")
    if opInfo.motionType == "block" or opInfo.motionType == "line" then
        return vim.api.nvim_echo({ { "Blockwise or linewise is not supported", "WarningMsg" } }, true, {})
    end

    local command
    local content
    local posStart
    local posEnd
    local winID = vim.api.nvim_get_current_win()
    local bufNr = vim.api.nvim_get_current_buf()

    -- Get content {{{
    if opInfo.vimMode == "n" then
        local motionRegion = operator.getMotionRegion(opInfo.vimMode, bufNr)
        posStart = motionRegion.Start
        posEnd   = motionRegion.End
        vim.api.nvim_win_set_cursor(0, posStart)
        vim.cmd "noa normal! v"
        vim.api.nvim_win_set_cursor(0, posEnd)
        vim.cmd "noa normal! v"
    else
        vim.cmd("noa normal! gv" .. t"<Esc>")
        posStart = vim.api.nvim_buf_get_mark(0, "<")
        posEnd   = vim.api.nvim_buf_get_mark(0, ">")
    end
    content = require("selection").get("string", false)
    -- }}} Get content

    vim.cmd "noa echohl MoreMsg"
    local answer = vim.fn.confirm("Save modification?",
        ">>> &Zeal\n&Goldendict\nch&Eat\n&Thesaurus\n&Cancel", 5, "Question")
    vim.cmd "noa echohl None"

    if answer == 1 then
        if vim.fn.executable("zeal") ~= 1 then
            return vim.api.nvim_echo({{"Zeal not found on environment",}}, true, {err=true})
        end
        command = zealGlobalChk and "zeal " or string.format("zeal %s:", vim.bo.filetype)
        vim.fn.jobstart(command .. content)
    elseif answer == 2 then
        if vim.fn.executable("goldendict") ~= 1 then
            return vim.api.nvim_echo({{"Goldentdict not found on environment",}}, true, {err=true})
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
        vim.api.nvim_win_set_cursor(winID, operator.cursorPos)
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
---@param args GenericOperatorInfo
function M.zealGlobal(args)
    zealGlobalChk = true
    lookUp(args)
end


--- Look up keyword specific to its language in the zeal
---@param args GenericOperatorInfo
function M.zeal(args)
    zealGlobalChk = false
    lookUp(args)
end

return M
