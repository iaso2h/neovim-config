-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles
-- Version: 0.0.4
-- Last Modified: 2021-09-16
-- TODO: mapping
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local M   = {}


local lines = {"< New Buffer >"}
local curWin

M.display = function()
    if fn.argc() > 0 or #vim.v.oldfiles == 1 then
        return
    end

    for _, file in pairs(vim.v.oldfiles) do
        if vim.loop.fs_stat(file) then
            table.insert(lines, file)
        end
    end

    if vim.bo.filetype == "HistoryStartup" then return end

    -- -- TODO: alert warning
    -- if vim.fn.line2byte("$") ~= -1 then return end

    curWin = api.nvim_get_current_win()
    if api.nvim_buf_is_valid(1) then
        M.curBuf = 1
    else
        -- BUG:
        -- M.curBuf = api.nvim_create_buf(true, true)

        -- if M.curBuf == 0 then
            cmd [[noa enew]]
            M.curBuf = api.nvim_get_current_buf()
        -- end
    end

    api.nvim_win_set_buf(curWin, M.curBuf)

    -- Always close all the other windows
    if api.nvim_list_wins() ~= 1 then
        require("buffer").closeOtherWin()
    end

    api.nvim_buf_set_option(M.curBuf, "modifiable", true)
    api.nvim_buf_set_option(M.curBuf, "bufhidden",  "hide")
    api.nvim_buf_set_option(M.curBuf, "buflisted",  false)
    api.nvim_buf_set_option(M.curBuf, "modified",   false)
    api.nvim_buf_set_option(M.curBuf, "filetype",   "HistoryStartup")

    api.nvim_buf_set_lines(M.curBuf, 0, -1, false, lines)

    api.nvim_buf_set_option(M.curBuf, "modifiable", false)

    for _, key in ipairs({"o", "s", "v", "<cr>"}) do
        api.nvim_buf_set_keymap(
            M.curBuf,
            "n",
            key,
            string.format([=[:lua require("historyStartup").do_map([[%s]])<cr>]=], key),
            {silent = true}
        )
    end

end

M.do_map = function(key)
    local target = lines[api.nvim_win_get_cursor(0)[1]]

    if target == "< New Buffer >" then
        cmd("enew!")
    elseif key == "o" or key == "<cr>" then
        cmd("edit! " .. target)
    elseif key == "s" then
        cmd("split! " .. target)
    elseif key == "v" then
        cmd("vsplit! " .. target)
    end
    M.deleteBuf()
end

M.deleteBuf = function()
    if not M.curBuf then return end
    if api.nvim_buf_is_valid(M.curBuf) then
        api.nvim_buf_delete(M.curBuf, {force = true})
    end
    M.curBuf = nil
end

return M

