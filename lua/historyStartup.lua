-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles
-- Dependencies: 0
-- Version: 0.0.16
-- Last Modified: 2023-4-14
-- TODO: ? to trigger menupage

local M   = {
    curBuf  = nil,
    lastBuf = nil,
    curWin  = nil,
    oldBuf  = nil,
    ns      = vim.api.nvim_create_namespace("historyStartup"),
    lines = {
        firstline = {"< New Buffer >"},
        absolute = {},
        relative = {},
        bufNr    = {},
        display  = ""
    }
}


-- Modified options wrapped around the func
---@param func function Implementation of modifying the lines
local modifyLines = function(func)
    vim.api.nvim_buf_set_option(M.curBuf, "modifiable", true)
    vim.api.nvim_buf_set_option(M.curBuf, "modified",   true)
    func()
    vim.api.nvim_buf_set_option(M.curBuf, "modifiable", false)
    vim.api.nvim_buf_set_option(M.curBuf, "modified",   false)
end


local initLines = function ()
    M.lines.absolute = {}
    M.lines.relative = {}
    M.lines.bufNr    = {}
    local relativeTick = false
    for _, absolutePath in pairs(vim.v.oldfiles) do
        if _G._os_uname.sysname == "Windows_NT" then
            -- Upper case the first drive character in Windows
            absolutePath = string.sub(absolutePath, 1, 1):upper() .. string.sub(absolutePath, 2, -1)
            -- Substitute the / character with the \ one
            absolutePath = string.gsub(absolutePath, "/", "\\")
        end
        -- Filter out duplicates and check validity
        if not vim.tbl_contains(M.lines.absolute, absolutePath) and vim.loop.fs_stat(absolutePath) then
            if not relativeTick and #absolutePath > vim.api.nvim_win_get_width(M.curWin) then
                relativeTick = true
            end
            table.insert(M.lines.absolute, absolutePath)
            ---@diagnostic disable-next-line: param-type-mismatch
            local bufNr = vim.fn.bufnr(absolutePath)
            table.insert(M.lines.bufNr, bufNr)
        end
    end
    if relativeTick then
        M.lines.relative = vim.tbl_map(function(p)
            return vim.fn.pathshorten(p)
        end, M.lines.absolute)
    end
end


local strikeThroughOpened = function()
    local bufListed = vim.tbl_filter(function (buf)
        return vim.api.nvim_buf_get_option(buf, "buflisted")
    end, vim.api.nvim_list_bufs())
    for _, buf in ipairs(bufListed) do
        local bufIdx = tbl_idx(M.lines.bufNr, buf, false) -- 1 indexed
        if bufIdx then
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.api.nvim_buf_add_highlight(M.curBuf, M.ns, "Comment", bufIdx, 0, -1)
        end
    end
end


-- Destory historyStartup buffer
local destoryBuf = function()
    if not M.curBuf then return end

    local winIDTbl = vim.tbl_filter(function(i)
        return vim.api.nvim_win_get_config(i).relative == ""
    end, vim.api.nvim_list_wins())
    local historyStartupLostTick = true
    for _, win in ipairs(winIDTbl) do
        if vim.api.nvim_win_get_buf(win) == M.curBuf then
            historyStartupLostTick = false
            break
        end
    end
    -- Don't destroy historyStartup yet if it's still visible in other windows
    if not historyStartupLostTick then
        return strikeThroughOpened()
    end

    if vim.api.nvim_buf_is_valid(M.curBuf) then
        vim.api.nvim_buf_delete(M.curBuf, {force = true})
    end
    M.curBuf = nil
end


local autoCMD = function(bufNr)

    vim.api.nvim_create_autocmd("WinResized", {
    buffer   = bufNr,
    desc     = "Re-adjust filepath length",
    callback = function()
        if not next(M.lines.absolute) then return end

        local widthExceedTick = false
        local width = vim.api.nvim_win_get_width(M.curWin)
        for _, line in ipairs(M.lines.absolute) do
            if #line > width then
                widthExceedTick = true
                break
            end
        end

        if widthExceedTick then
            if M.lines.display == "absolute" then
                if not next(M.lines.relative) then
                    M.lines.relative = vim.tbl_map(function(i)
                        return vim.fn.pathshorten(i)
                    end, M.lines.absolute)
                end

                modifyLines(function()
                    vim.api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.relative)
                    M.lines.display = "relative"
                end)
            end
        else
            if M.lines.display == "relative" then
                modifyLines(function()
                    vim.api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.absolute)
                    M.lines.display = "absolute"
                end)
            end
        end
    end
    })

    -- Don't create the self-destroy AutoCMD yet for the first time leaving historyStartup
    if M.curBuf ~= 1 then
        vim.api.nvim_create_autocmd(
            "BufReadPost", {
            buffer   = M.curBuf,
            desc     = "Destory historyStartup",
            callback = destoryBuf
        })
    end
end


--- Display history in new buffer
--- @param refreshChk boolean Set it true to refresh the history files everytime
M.display = function(refreshChk)
    -- For VimEnter autocmd
    if not refreshChk and vim.fn.argc() > 0 or #vim.v.oldfiles == 1 then
        return
    end
    if vim.bo.filetype == "HistoryStartup" then return end

    M.curWin = vim.api.nvim_get_current_win()

    -- Reset lines
    if refreshChk or not next(M.lines.absolute) then
        initLines()
    end

    -- Save last opened buffer and restore it after open a new buffer
    if vim.bo.buftype == "" and nvim_buf_get_name(0) ~= "" then
        M.lastBuf = vim.api.nvim_get_current_buf()
    else
        M.lastBuf = nil
    end

    -- The factor that vim will always display a buffer for you in the very beginning
    if vim.api.nvim_buf_is_valid(1) and vim.api.nvim_buf_get_option(1, "modified") and vim.api.nvim_buf_get_option(1, "filetype") ~= nil then
        -- Use the first buffer whenever possible
        M.curBuf = 1
    elseif not M.curBuf then
        vim.cmd [[noa enew]]
        M.curBuf = vim.api.nvim_get_current_buf()
    else
        -- Use the existing historyStartup buffer
    end

    -- Setting up autocmd
    autoCMD(M.curBuf)

    -- Options
    vim.api.nvim_buf_set_option(M.curBuf, "bufhidden",  "hide")
    vim.api.nvim_buf_set_option(M.curBuf, "buflisted",  false)
    vim.api.nvim_buf_set_option(M.curBuf, "filetype",   "HistoryStartup")

    -- Set lines
    vim.defer_fn(function()
        vim.api.nvim_win_set_buf(M.curWin, M.curBuf)
        modifyLines(function()
            vim.api.nvim_buf_set_lines(M.curBuf, 0, 1, false, M.lines.firstline)
            if not next(M.lines.relative) then
                vim.api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.absolute)
                M.lines.display = "absolute"
            else
                vim.api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.relative)
                M.lines.display = "relative"
            end

            -- Strike through openned files
            if refreshChk then
                strikeThroughOpened()
            end
        end)
    end, 0)

    -- Key mappings
    vim.defer_fn(function()
        for _, key in ipairs {"o", "go", "<C-s>", "<C-v>", "<C-t>", "<CR>", "q"} do
            vim.api.nvim_buf_set_keymap(
                M.curBuf,
                "n",
                key,
                string.format([=[<CMD>lua require("historyStartup").execMap([[%s]])<CR>]=], string.gsub(key, [[<]], [[<lt>]])),
                {silent = true}
            )
        end
    end, 0)

end


M.execMap = function(key)
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    key = string.lower(key)

    if key == "o" or key == "<cr>" then
        if lnum == 1 then
            vim.cmd("enew")
        else
            vim.cmd("edit " .. M.lines.absolute[lnum - 1])
        end
    elseif key == "go" then
        if lnum == 1 then
            vim.cmd("noa enew")
        else
            vim.cmd("noa edit " .. M.lines.absolute[lnum - 1])
        end
    elseif key == "<c-t>" then
        if lnum == 1 then
            vim.cmd("tabnew")
        else
            if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                vim.cmd("tabnew")
                vim.cmd("edit " .. M.lines.absolute[lnum - 1])
            end
        end
    else
        local lastBufVisibleTick = false
        if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
            local winIDTbl = vim.tbl_filter(function(i)
                return vim.api.nvim_win_get_config(i).relative == ""
            end, vim.api.nvim_list_wins())
            for _, win in ipairs(winIDTbl) do
                if vim.api.nvim_win_get_buf(win) == M.lastBuf then
                    lastBufVisibleTick = true
                    break
                end
            end
        end
        if key == "<c-s>" then
            if lnum == 1 then
                vim.cmd("noa split")
                vim.cmd("enew")
            else
                if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                    if not lastBufVisibleTick then
                        vim.api.nvim_win_set_buf(M.curWin, M.lastBuf)
                        vim.cmd("split " ..M.lines.absolute[lnum - 1])
                    else
                        vim.cmd("noa q!")
                    end
                end
            end
        elseif key == "<c-v>" then
            if lnum == 1 then
                vim.cmd("vnew")
            else
                if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                    if not lastBufVisibleTick then
                        vim.api.nvim_win_set_buf(M.curWin, M.lastBuf)
                        vim.cmd("vsplit " ..M.lines.absolute[lnum - 1])
                    else
                        vim.cmd("noa q!")
                    end
                end
            end
        elseif key == "q" then
            local bufNrTbl = vim.tbl_map(function(buf)
                return tonumber(string.match(buf, "%d+"))
                end, require("buf.util").bufLoadedTbl(false))
            if #bufNrTbl == 0 then
                vim.cmd("noa q!")
            else
                -- Switch to last buffer or close the current window
                if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                    if not lastBufVisibleTick then
                        vim.api.nvim_win_set_buf(M.curWin, M.lastBuf)
                    else
                        vim.cmd("noa q!")
                    end
                else
                    vim.cmd("noa q!")
                end
            end
        end
    end

    destoryBuf()
end


return M

