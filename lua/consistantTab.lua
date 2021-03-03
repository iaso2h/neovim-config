-- File: consistantTab
-- Author: iaso2h
-- Description: Make sure every buffer has correct and consistance tab related settings
-- Version: 0.0.1
-- Last Modified: 2021/02/27
local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local M = {}

function M.splitCopy(command)
    if vim.bo.buftype == "" then
        local shiftwidth = vim.bo.shiftwidth
        local softtabstop = vim.bo.softtabstop
        local tabstop = vim.bo.tabstop
        cmd(command)
        vim.bo.shiftwidth = shiftwidth
        vim.bo.softtabstop = softtabstop
        vim.bo.tabstop = tabstop
    else
        cmd(command)
    end
end

function M.adaptBufTab()
    local supportFileType = {"vim", "lua", "python"}
    if vim.tbl_contains(supportFileType, vim.bo.filetype) then
        local lastLines = api.nvim_buf_get_lines(0, -3, -1, false)
        for idx, line in ipairs(lastLines) do
            if line ~= "" and
                vim.startswith(line,
                               vim.g.FiletypeCommentDelimiter[vim.bo.filetype]) then
                local result = string.match(line, "vim: ?set.*")
                if result then
                    -- cmd(result)
                    api.nvim_echo({{result, "Moremsg"}}, false, {})
                    return
                end
            end
        end
    end
end

return M

