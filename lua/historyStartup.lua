-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles
-- Dependencies: 0
-- Version: 0.0.10
-- Last Modified: 2023-3-8
-- TODO: strike through the files that are already loaded and listed in Neovim
local api = vim.api
local fn  = vim.fn
local M   = {
    curBuf = -1,
    lastBuf = -1,
    curWin = -1,
    oldBuf = -1,
}

local resetLine = function ()
    -- TODO: ? to trigger manupage
    M.lines = {
        firstline = {"< New Buffer >"},
        absolute = {}
    }
end

--- Display history in new buffer
--- @param refreshChk boolean Set it true to refresh the history files everytime
M.display = function(refreshChk)
    if fn.argc() > 0 or #vim.v.oldfiles == 1 then
        return
    end

    if not M.lines then resetLine() end

    if vim.bo.filetype == "HistoryStartup" then return end
    M.curWin = api.nvim_get_current_win()

    local relative = {}
    local absolute = {}
    for _, absolutePath in pairs(vim.v.oldfiles) do
        if _G._os_uname.sysname ~= "Windows_NT" then
            if vim.loop.fs_stat(absolutePath) then
                if #absolutePath > api.nvim_win_get_width(M.curWin) then
                    local relativePath = fn.pathshorten(absolutePath)
                    table.insert(relative, relativePath)
                end
                table.insert(absolute, absolutePath)
            end
        else
            -- Upper case the first dirver character in Windows
            absolutePath = string.sub(absolutePath, 1, 1):upper() .. string.sub(absolutePath, 2, -1)
            -- Substitue the / character with the \ one
            absolutePath = string.gsub(absolutePath, "/", "\\")
            -- Filter out duplicates and check validity
            if not vim.tbl_contains(absolute, absolutePath) and vim.loop.fs_stat(absolutePath) then
                if #absolutePath > api.nvim_win_get_width(M.curWin) then
                    local relativePath = fn.pathshorten(absolutePath)
                    table.insert(relative, relativePath)
                end
                table.insert(absolute, absolutePath)
            end
        end
    end


    if refreshChk then
        resetLine()
    end
    M.lines.absolute = absolute
    M.lines.relative = relative

    -- Save last opened buffer and restore it after open a new buffer
    if vim.bo.buftype == "" and nvim_buf_get_name(0) ~= "" then
        M.lastBuf = api.nvim_get_current_buf()
    else
        M.lastBuf = nil
    end


    -- The factor that vim will always display a buffer for you in the very beginning
    if api.nvim_buf_is_valid(1) and api.nvim_buf_get_option(1, "modified") and api.nvim_buf_get_option(1, "filetype") ~= nil then
        -- Use the first buffer whenever possible
        M.curBuf = 1
    else
        vim.cmd [[noa enew]]
        M.curBuf = api.nvim_get_current_buf()
    end

    -- Options
    api.nvim_buf_set_option(M.curBuf, "bufhidden",  "hide")
    api.nvim_buf_set_option(M.curBuf, "buflisted",  false)
    api.nvim_buf_set_option(M.curBuf, "modifiable", true)
    api.nvim_buf_set_option(M.curBuf, "modified",   true)
    api.nvim_buf_set_option(M.curBuf, "filetype",   "HistoryStartup")

    api.nvim_win_set_buf(M.curWin, M.curBuf)
    api.nvim_buf_set_lines(M.curBuf, 0, 1, false, M.lines.firstline)
    if not next(M.lines.relative) then
        api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.absolute)
    else
        api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.relative)
    end
    api.nvim_buf_set_option(M.curBuf, "modifiable", false)
    api.nvim_buf_set_option(M.curBuf, "modified",   false)

    -- Key mapppings
    for _, key in ipairs {"o", "<C-s>", "<C-v>", "<CR>", "q"} do
        api.nvim_buf_set_keymap(
            M.curBuf,
            "n",
            key,
            string.format([=[<CMD>lua require("historyStartup").execMap([[%s]])<CR>]=], string.gsub(key, [[<]], [[<lt>]])),
            {silent = true}
        )
    end

    -- Don't creat the self-destroy AutoCMD yet for the first time leaving historyStartup
    if M.curBuf ~= 1 then
        api.nvim_create_autocmd(
            "BufReadPost", {
            buffer = M.curBuf,
            desc = "Destory historyStartup",
            callback = require("historyStartup").deleteBuf,
        })
    end
end


M.execMap = function(key)
    local lnum = api.nvim_win_get_cursor(0)[1]
    key = string.lower(key)

    if key == "q" then
        local bufNrTbl = vim.tbl_map(function(buf)
            return tonumber(string.match(buf, "%d+"))
            end, require("buf.util").bufLoadedTbl(false))
        if #bufNrTbl == 0 then
            vim.cmd("noa q!")
        else
            if M.lastBuf and api.nvim_buf_is_valid(M.lastBuf) then
                api.nvim_win_set_buf(M.curWin, M.lastBuf)
            end
        end
    elseif key == "o" or key == "<cr>" then
        if lnum == 1 then
            vim.cmd("enew")
        else
            vim.cmd("edit " .. M.lines.absolute[lnum - 1])
        end
    elseif key == "<c-s>" then
        if lnum == 1 then
            vim.cmd("noa split")
            vim.cmd("enew")
        else
            if M.lastBuf and api.nvim_buf_is_valid(M.lastBuf) then
                api.nvim_win_set_buf(M.curWin, M.lastBuf)
            end
            vim.cmd("split " .. M.lines.absolute[lnum - 1])
        end
    elseif key == "<c-v>" then
        if lnum == 1 then
            vim.cmd("vnew")
        else
            if M.lastBuf and api.nvim_buf_is_valid(M.lastBuf) then
                api.nvim_win_set_buf(M.curWin, M.lastBuf)
            end
            vim.cmd("vsplit " ..M.lines.absolute[lnum - 1])
        end
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

