-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles
-- Dependencies: 0
-- Version: 0.0.20
-- Last Modified: 2023-4-25
-- TODO: ? to trigger menupage

local M   = {
    curBuf  = -1,
    lastBuf = -1,
    curWin  = -1,
    oldBuf  = -1,
    floatWinID = -1,
    floatBufNr = -1,
    floatTick = false,
    ns      = vim.api.nvim_create_namespace("historyStartup"),
    lines = {
        firstline = {"< New Buffer >"},
        absolute = {},
        relative = {},
        relativeTick = false,
        bufNr    = {},
        display  = ""
    }
}


-- Modified options wrapped around the func
---@param func function Implementation of modifying the lines
local modifyLines = function(func)
    vim.api.nvim_buf_set_option(M.curBuf, "modifiable", true)
    func()
    vim.api.nvim_buf_set_option(M.curBuf, "modifiable", false)
end


local initLines = function () -- {{{
    M.lines.absolute = {}
    M.lines.relative = {}
    M.lines.bufNr    = {}
    M.lines.relativeTick = false
    for _, absolutePath in pairs(vim.v.oldfiles) do
        if _G._os_uname.sysname == "Windows_NT" then
            -- Upper case the first drive character in Windows
            absolutePath = string.sub(absolutePath, 1, 1):upper() .. string.sub(absolutePath, 2, -1)
            -- Substitute the / character with the \ one
            absolutePath = string.gsub(absolutePath, "/", "\\")
        end
        -- Filter out duplicates and check validity
        if not vim.tbl_contains(M.lines.absolute, absolutePath) and vim.loop.fs_stat(absolutePath) then
            if not M.lines.relativeTick and #absolutePath > vim.api.nvim_win_get_width(M.curWin) then
                M.lines.relativeTick = true
            end
            table.insert(M.lines.absolute, absolutePath)
            ---@diagnostic disable-next-line: param-type-mismatch
            local bufNr = vim.fn.bufnr(absolutePath)
            table.insert(M.lines.bufNr, bufNr)
        end
    end
    if M.lines.relativeTick then
        M.lines.relative = vim.tbl_map(function(p)
            return vim.fn.pathshorten(p)
        end, M.lines.absolute)
    end
end -- }}}


local strikeThroughOpened = function() -- {{{
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
end -- }}}


local autoCMD = function(bufNr) -- {{{
    if not vim.api.nvim_buf_is_valid(bufNr) then return end

    vim.api.nvim_create_autocmd("WinResized", {
        buffer   = bufNr,
        desc     = "Re-adjust filepath length",
        callback = function() -- {{{
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
                        M.lines.relativeTick = true
                    end)
                end
            else
                if M.lines.display == "relative" then
                    modifyLines(function()
                        vim.api.nvim_buf_set_lines(M.curBuf, 1, -1, false, M.lines.absolute)
                        M.lines.display = "absolute"
                        M.lines.relativeTick = false
                    end)
                end
            end
        end
    }) -- }}}

    vim.api.nvim_create_autocmd(
        {"BufReadPost", "BufLeave"}, {
        buffer   = M.curBuf,
        desc     = "Destory historyStartup",
        callback = function() -- {{{
            if not M.curBuf then return end

            -- Get all non-relative window IDs
            local winIDTbl = vim.tbl_filter(function(i)
                return vim.api.nvim_win_get_config(i).relative == ""
            end, vim.api.nvim_list_wins())
            local historyStartupVisibleTick = true
            for _, win in ipairs(winIDTbl) do
                if vim.api.nvim_win_get_buf(win) == M.curBuf then
                    historyStartupVisibleTick = false
                    break
                end
            end

            -- Don't destroy historyStartup yet if it's still visible in other windows
            if not historyStartupVisibleTick then
                return strikeThroughOpened()
            end

            if vim.api.nvim_buf_is_valid(M.curBuf) then
                vim.api.nvim_buf_delete(M.curBuf, {force = true})
            end
            M.curBuf = nil
        end -- }}}
    })
end -- }}}


--- Display history in new buffer
--- @param refreshChk boolean Set it true to refresh the history files everytime
M.display = function(refreshChk) -- {{{
    -- For VimEnter autocmd
    if not refreshChk and vim.fn.argc() > 0 or #vim.v.oldfiles == 1 then
        return
    end
    if vim.bo.filetype == "HistoryStartup" then return end

    -- Reset lines
    M.curWin = vim.api.nvim_get_current_win()
    if refreshChk or not next(M.lines.absolute) then
        initLines()
    end

    -- Save last opened buffer and restore it after open a new buffer
    if vim.bo.buftype == "" and nvim_buf_get_name(0) ~= "" then
        M.lastBuf = vim.api.nvim_get_current_buf()
    else
        M.lastBuf = nil
    end

    -- Options
    -- The factor that vim will always display a buffer for you in the very beginning
    if vim.api.nvim_buf_is_valid(1) and vim.api.nvim_buf_get_option(1, "modifiable") and vim.api.nvim_buf_get_option(1, "filetype") ~= nil then
        -- Use the first buffer whenever possible
        M.curBuf = 1
        vim.api.nvim_buf_set_option(M.curBuf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(M.curBuf, "buflisted", false)
    elseif vim.api.nvim_buf_get_name(0) == "" and vim.bo.modifiable and
            vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
        -- Use the current buffer if it's a scratch buffer
        M.curBuf  = vim.api.nvim_get_current_buf()
        M.lastBuf = nil
        vim.api.nvim_buf_set_option(M.curBuf, "buflisted", false)
        vim.api.nvim_buf_set_option(M.curBuf, "buftype", "nofile")
    else
        if not M.curBuf or (not vim.api.nvim_buf_is_valid(M.curBuf)) then
            M.curBuf = vim.api.nvim_create_buf(false, true)
        else
            -- Use last historyStartup buffer?
        end
    end
    vim.api.nvim_buf_set_option(M.curBuf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(M.curBuf, "filetype",  "HistoryStartup")

    -- Setting up autocmd
    autoCMD(M.curBuf)

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
        for _, key in ipairs {"o", "go", "<C-s>", "<C-v>", "<C-t>", "<CR>", "q", "Q", "K"} do
            vim.api.nvim_buf_set_keymap(
                M.curBuf,
                "n",
                key,
                string.format([=[<CMD>lua require("historyStartup").execMap([[%s]])<CR>]=], string.gsub(key, [[<]], [[<lt>]])),
                {silent = true}
            )
        end
    end, 0)
end -- }}}


local hover = function() -- {{{
    if not M.lines.relativeTick then return end
    local lineIdx = vim.api.nvim_win_get_cursor(M.curWin)[1] - 1
    if lineIdx < 1 then return end
    local line = " " .. M.lines.absolute[lineIdx] .. " "
    local cursorPos = vim.api.nvim_win_get_cursor(M.curWin)
    local winInfo = vim.fn.getwininfo(M.curWin)[1]
    local hoverWidth = math.ceil(winInfo.width / 2)
    if #line < hoverWidth then hoverWidth = #line end
    local hoverHeight = math.ceil(#line / hoverWidth)
    local anchorVer = winInfo.botline - cursorPos[1] < hoverHeight+ 1 and "S" or "N"
    local anchorHor = hoverWidth - cursorPos[2] - 8 < hoverWidth and "E" or "W"
    M.floatWinID = vim.api.nvim_open_win(0, false, {
        relative = "cursor",
        width = hoverWidth,
        height = hoverHeight,
        anchor = anchorVer .. anchorHor,
        row = 1,
        col = 1,
        style = "minimal",
        border = "rounded"
    })
    vim.api.nvim_win_set_option(M.floatWinID, "signcolumn", "no")

    -- Create buf
    if not M.floatBufNr then
        M.floatBufNr = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_buf_set_lines(M.floatBufNr, 0, -1, false, {line})
    vim.api.nvim_buf_set_option(M.floatBufNr, "modifiable", false)
    vim.api.nvim_win_set_buf(M.floatWinID, M.floatBufNr)

    vim.api.nvim_create_autocmd({
        "CursorMoved",
        -- Neovim will enter relative buffer temporarily, so "BufLeave" will allways
        -- trigger then destroy the brand new float window and buffer within
        "BufLeave",
        "WinLeave",
        "TabLeave",
        "ModeChanged",
    }, {
        buffer = M.curBuf,
        desc = "Close floating win inside historyStartup when cursor moves",
        callback = function()
            if not M.floatWinID then return end
            if not M.floatTick then return end
            if not vim.api.nvim_win_is_valid(M.floatWinID) then return end

            vim.api.nvim_win_close(M.floatWinID, false)
            M.floatWinID = nil

            -- Delete buffer as well
            if M.floatBufNr and vim.api.nvim_buf_is_valid(M.floatBufNr) then
                vim.api.nvim_buf_delete(M.floatBufNr, {force = true})
                M.floatBufNr = nil
            end
            M.floatTick = false
        end
    })

    -- Set floatTick to true at the end of the function in case the float will
    -- be terminated too early by autocmd
    M.floatTick = true
end -- }}}


M.execMap = function(key) -- {{{
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
    elseif key == "k" then
        hover()
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
            local bufValidCnt = require("buf.util").bufValidCnt(
                require("buf.util").getBufNrTbl(true) )
            if bufValidCnt == 0 then
                vim.cmd("noa qa!")
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
end -- }}}


return M

