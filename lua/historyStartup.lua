-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles
-- Version: 0.0.5
-- Last Modified: 2021-09-16
-- TODO: mapping
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local M   = {
    curBuf = nil,
    lastBuf = nil,
}


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

    -- Save last opened buffer and restore it after open a new buffer
    if vim.bo.buftype == "" and api.nvim_buf_get_name(0) ~= "" then
        M.lastBuf = api.nvim_get_current_buf()
    else
        M.lastBuf = nil
    end


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

    api.nvim_buf_set_option(M.curBuf, "modifiable", true)
    api.nvim_buf_set_option(M.curBuf, "bufhidden",  "hide")
    api.nvim_buf_set_option(M.curBuf, "buflisted",  false)
    api.nvim_buf_set_option(M.curBuf, "modified",   false)
    api.nvim_buf_set_option(M.curBuf, "filetype",   "HistoryStartup")

    api.nvim_buf_set_lines(M.curBuf, 0, -1, false, lines)

    api.nvim_buf_set_option(M.curBuf, "modifiable", false)

    for _, key in ipairs({"o", "<C-s>", "<C-v>", "<CR>"}) do
        api.nvim_buf_set_keymap(
            M.curBuf,
            "n",
            key,
            string.format([=[:lua require("historyStartup").execMap([[%s]])<CR>]=], string.gsub(key, [[<]], [[<lt>]])),
            {silent = true}
        )
    end

end

M.execMap = function(key)
    local target = lines[api.nvim_win_get_cursor(0)[1]]

    if target == "< New Buffer >" then
        cmd("enew")
    elseif key == "o" or string.lower(key) == "<cr>" then
        cmd("edit " .. target)
    elseif string.lower(key) == "<c-s>" then
        api.nvim_win_set_buf(curWin, M.lastBuf)
        cmd("split " .. target)
    elseif string.lower(key) == "<c-v>" then
        api.nvim_win_set_buf(curWin, M.lastBuf)
        cmd("vsplit " .. target)
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

