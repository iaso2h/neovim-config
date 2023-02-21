-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles
-- Version: 0.0.7
-- Last Modified: 2023-2-20
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local M   = {
    curBuf = nil,
    lastBuf = nil,
}


local lines = {"< New Buffer >"}
local curWin
local oldBuf


--- Display history in new buffer
--- @param force boolean Force to display historyStartup. Set to it to false
--- when start from autocommand
M.display = function(force)
    if (not force and fn.argc() > 0) or
        #vim.v.oldfiles == 1 then

        return
    end

    for _, fileStr in pairs(vim.v.oldfiles) do
        if jit.os ~= "Windows" then
            if vim.loop.fs_stat(fileStr) then
                table.insert(lines, fileStr)
            end
        else
            -- Upper case the first dirver character in Windows
            fileStr = string.sub(fileStr, 1, 1):upper() .. string.sub(fileStr, 2, -1)
            -- Substitue the / character with the \ one
            fileStr = string.gsub(fileStr, "/", "\\")
            -- Filter out duplicates and check validity
            if not vim.tbl_contains(lines, fileStr) and vim.loop.fs_stat(fileStr) then
                table.insert(lines, fileStr)
            end
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
    oldBuf = api.nvim_get_current_buf()
    if api.nvim_buf_is_valid(1) and api.nvim_buf_get_option(1, "modified") and api.nvim_buf_get_option(1, "filetype") ~= nil then
        M.curBuf = 1
    else
        -- HACK:
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
    api.nvim_buf_set_option(M.curBuf, "modified",   true)
    api.nvim_buf_set_option(M.curBuf, "filetype",   "HistoryStartup")

    api.nvim_buf_set_lines(M.curBuf, 0, -1, false, lines)
    api.nvim_buf_set_option(M.curBuf, "modifiable", false)
    api.nvim_buf_set_option(M.curBuf, "modified",   false)


    for _, key in ipairs {"o", "<C-s>", "<C-v>", "<CR>", "q"} do
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
    key = string.lower(key)

    if key == "q" then
        local bufNrTbl = vim.tbl_map(function(buf)
            return tonumber(string.match(buf, "%d+"))
            end, require("buf.util").bufLoadedTbl(false))
        if #bufNrTbl == 0 then
            cmd("noa q!")
        else
            api.nvim_win_set_buf(curWin, oldBuf)
        end

    elseif key == "o" or key == "<cr>" then
        if target == "< New Buffer >" then
            cmd("enew")
        else
            cmd("edit " .. target)
        end
    elseif key == "<c-s>" then
        if target == "< New Buffer >" then
            cmd("noa split")
            cmd("enew")
        else
            api.nvim_win_set_buf(curWin, M.lastBuf)
            cmd("split " .. target)
        end
    elseif key == "<c-v>" then
        if target == "< New Buffer >" then
            cmd("vnew")
        else
            api.nvim_win_set_buf(curWin, M.lastBuf)
            cmd("vsplit " .. target)
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

