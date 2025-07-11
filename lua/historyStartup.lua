-- File: historyStartup
-- Author: iaso2h
-- Description: Startup page with oldfiles listed
-- Version: 0.0.29
-- Last Modified: 2025-03-30
-- TODO: ? to trigger menupage

local M   = {
    initBuf = -1,
    lastBuf = -1,
    initWin = -1,

    floatWinID = -1,
    floatBufNr = -1,
    floatTick = false,
    floatLine = "",

    autoresizeCmdId = -1,

    ns = vim.api.nvim_create_namespace("historyStartup"),
    lines = {
        firstline = {"< New Buffer >"},
        bufNrs   = {},
        absolute = {},
        relative = {},
        relativeTick = false,
    }
}

local WidthExceedOffset = 6

-- Modified options wrapped around the func
---@param func function Implementation of modifying the lines
local modifyLines = function(func) -- {{{
    vim.api.nvim_set_option_value("modifiable", true, {buf = M.initBuf})
    func()
    vim.api.nvim_set_option_value("modifiable", false, {buf = M.initBuf})
end -- }}}
--- Check whether historyStartup is loaded
---@return boolean
local isLoaded = function() -- {{{
    return vim.api.nvim_buf_is_loaded(M.initBuf)
end -- }}}
--- Check whether historyStartup is visible
---@return boolean
local isVisible = function() -- {{{
    local winIds = require("buffer.util").winIds(false)
    return require("util").any(function(winId)
        local bufNr    = vim.api.nvim_win_get_buf(winId)
        local fileType = vim.api.nvim_get_option_value("filetype", {buf = bufNr})
        return fileType == "HistoryStartup"
    end, winIds)
end -- }}}
--- Initiate the absolute lines and relative lines
local initLines = function () -- {{{
    M.lines.absolute = {}
    M.lines.relative = {}
    M.lines.bufNrs   = {}
    M.lines.relativeTick = false
    for _, absolutePath in pairs(vim.v.oldfiles) do
        if _G._os_uname.sysname == "Windows_NT" then
            -- Upper case the first drive character in Windows
            absolutePath = string.sub(absolutePath, 1, 1):upper() .. string.sub(absolutePath, 2, -1)
            -- Substitute the / character with the \ one
            absolutePath = string.gsub(absolutePath, "/", "\\")
        end
        -- Filter out duplicates and check validity
        if not vim.list_contains(M.lines.absolute, absolutePath) and vim.loop.fs_stat(absolutePath) then
            -- Check for converting paths to relative paths
            if not M.lines.relativeTick and #absolutePath + WidthExceedOffset > vim.api.nvim_win_get_width(M.initWin) then
                M.lines.relativeTick = true
            end
            ---@diagnostic disable-next-line: param-type-mismatch
            local bufNr = vim.fn.bufnr(absolutePath)
            table.insert(M.lines.absolute, absolutePath)
            table.insert(M.lines.bufNrs, bufNr)
        end
    end

    if M.lines.relativeTick then
        M.lines.relative = vim.tbl_map(function(p)
            return vim.fn.pathshorten(p)
        end, M.lines.absolute)
    end
end -- }}}
--- Add strike thorugh style for the specific lines
local strikeThroughOpened = function() -- {{{
    local bufNrs = require("buffer.util").bufNrs(true)
    for _, buf in ipairs(bufNrs) do
        local bufIdx = tbl_idx(M.lines.bufNrs, buf, false) -- 1 indexed
        if bufIdx ~= -1 then
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.hl.range(M.initBuf, M.ns, "Comment", {bufIdx, 0}, {bufIdx, -1})
        end
    end
end -- }}}
--- Setup autoCmd
local setupAutoCmd = function() -- {{{
    local stopResize = function()
        if M.autoresizeCmdId ~= -1 then
            -- When `M.autoresizeCmdId` isn't the initiation value -1
            vim.api.nvim_del_autocmd(M.autoresizeCmdId)
            M.autoresizeCmdId = -1
        end
    end

    M.autoresizeCmdId = vim.api.nvim_create_autocmd("WinResized", {
        desc     = "Re-adjust filepath length",
        callback = function() -- {{{
            if not vim.api.nvim_buf_is_valid(M.initBuf) then return stopResize() end
            -- Find the window contains historyStartup
            local winId = -1
            if vim.api.nvim_get_current_win() == M.initWin then
                winId = M.initWin
            else
                -- The window may not be the same window as the one when
                -- historyStartup was created
                local winIds = require("buffer.util").winIds(false)
                for _, w in ipairs(winIds) do
                    local b = vim.api.nvim_win_get_buf(w)
                    local fileType = vim.api.nvim_get_option_value("filetype", {buf = b})
                    if fileType == "HistoryStartup" then
                        winId = w
                        break
                    end
                end
            end

            -- If historyStartup is not in sight, delete this autocmd
            if winId == -1 then
                return stopResize()
            end

            -- Check window width exceeding
            local widthExceedTick = false
            local width = vim.api.nvim_win_get_width(winId)
            require("util").any(function(line)
                return #line + WidthExceedOffset > width
            end, M.lines.absolute)

            if widthExceedTick then
                if not M.lines.relativeTick then
                    if not next(M.lines.relative) then
                        M.lines.relative = vim.tbl_map(function(i)
                            return vim.fn.pathshorten(i)
                        end, M.lines.absolute)
                    end

                    modifyLines(function()
                        vim.api.nvim_buf_set_lines(M.initBuf, 1, -1, false, M.lines.relative)
                    end)

                    M.lines.relativeTick = true
                end
            else
                if M.lines.relativeTick then
                    modifyLines(function()
                        vim.api.nvim_buf_set_lines(M.initBuf, 1, -1, false, M.lines.absolute)
                    end)

                    M.lines.relativeTick = false
                end
            end
        end
    }) -- }}}
end -- }}}
--- Pop up the float window for current item
local hover = function() -- {{{
    if not M.lines.relativeTick then return end
    local cursorPos = vim.api.nvim_win_get_cursor(M.initWin)
    local lineIdx = cursorPos[1] - 1
    if lineIdx < 1 then return end
    M.floatLine = M.lines.absolute[lineIdx]

    -- Construct float window
    local line = " " .. M.floatLine .. " "
    local winInfo = vim.fn.getwininfo(M.initWin)[1]
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
        border = _G._float_win_border,
    })
    vim.api.nvim_set_option_value("signcolumn", "no", {win = M.floatWinID})

    -- Create buf
    if not M.floatBufNr or not vim.api.nvim_buf_is_valid(M.floatBufNr) then
        M.floatBufNr = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_buf_set_lines(M.floatBufNr, 0, -1, false, {line})
    vim.api.nvim_set_option_value("modifiable", false, {buf = M.floatBufNr})
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
        buffer = M.initBuf,
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
            M.floatLine = ""
        end
    })

    -- Set floatTick to true at the end of the function in case the float will
    -- be terminated too early by autocmd
    M.floatTick = true
end -- }}}
--- Execute actions for corresponding mappings
---@param key string Left-Hand side key mappings
local execMap = function(key) -- {{{
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local pathTarget = vim.fn.escape(M.lines.absolute[lnum - 1], [[ #"]])
    if key == "o" or key == "<CR>" or key == "<2-LeftMouse>" then -- {{{
        if lnum == 1 then
            vim.cmd("enew")
        else
            vim.cmd("edit " .. pathTarget)
            if isVisible() then
                vim.hl.range(M.initBuf, M.ns, "Comment", {lnum - 1, 0}, {lnum - 1, -1})
            end
        end -- }}}
    elseif key == "go" then -- {{{
        if lnum == 1 then
            vim.cmd("noa enew")
        else
            vim.cmd("noa edit " .. pathTarget)
        end -- }}}
    elseif key == "<C-t>" then -- {{{
        if lnum == 1 then
            vim.cmd("tabnew")
        else
            vim.cmd("tabnew")
            vim.cmd("edit " .. pathTarget)
            if isVisible() then
                vim.hl.range(M.initBuf, M.ns, "Comment", {lnum - 1, 0}, {lnum - 1, -1})
            end
        end -- }}}
    elseif key == "yp" then -- {{{
        local cursorPos = vim.api.nvim_win_get_cursor(M.initWin)
        local lineIdx = cursorPos[1] - 1
        local line
        if not M.floatBufNr or not vim.api.nvim_buf_is_valid(M.floatBufNr) then
            line = M.lines.absolute[lineIdx]
        else
            line = M.floatLine
        end
        vim.fn.setreg(vim.v.register, line, "v")
        vim.api.nvim_echo({{"File path copied", "Normal"}}, true, {}) -- }}}
    elseif key == "K" then
        hover()
    else
        -- Related to spliting window or rearranging the window layout
        local lastBufVisibleTick = false
        if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
            local winIds = require("buffer.util").winIds(false)

            lastBufVisibleTick = require("util").any(function(winId)
                return vim.api.nvim_win_get_buf(winId) == M.lastBuf
            end, winIds)
        end
        if key == "<C-s>" then -- {{{
            if lnum == 1 then
                vim.cmd("noa split")
                vim.cmd("enew")
            else
                if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                    if not lastBufVisibleTick then
                        vim.api.nvim_win_set_buf(M.initWin, M.lastBuf)
                        vim.cmd("split " .. pathTarget)
                        if isVisible() then
                            vim.hl.range(M.initBuf, M.ns, "Comment", {bufIdx, 0}, {bufIdx, -1})
                        end
                    else
                        vim.cmd("noa q!")
                    end
                end
            end -- }}}
        elseif key == "<C-v>" then -- {{{
            if lnum == 1 then
                vim.cmd("vnew")
            else
                if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                    if not lastBufVisibleTick then
                        vim.api.nvim_win_set_buf(M.initWin, M.lastBuf)
                        vim.cmd("vsplit " .. pathTarget)
                        if isVisible() then
                            vim.hl.range(M.initBuf, M.ns, "Comment", {bufIdx, 0}, {bufIdx, -1})
                        end
                    else
                        vim.cmd("noa q!")
                    end
                end
            end -- }}}
        elseif key == "q" or key == "Q" then -- {{{
            local bufsNonScratchOccurInWins = require("buffer.util").bufsNonScratchOccurInWins(
                require("buffer.util").bufNrs(true) )
            if bufsNonScratchOccurInWins == 0 then
                vim.defer_fn(function()
                    vim.api.nvim_feedkeys("ZZ", "n", true)
                end, 0)
            else
                -- Switch to last buffer or close the current window
                if M.lastBuf and vim.api.nvim_buf_is_valid(M.lastBuf) then
                    if not lastBufVisibleTick then
                        vim.api.nvim_win_set_buf(M.initWin, M.lastBuf)
                    else
                        vim.defer_fn(function()
                            vim.api.nvim_feedkeys("ZZ", "n", true)
                        end, 0)
                    end
                else
                    vim.defer_fn(function()
                        vim.api.nvim_feedkeys("ZZ", "n", true)
                    end, 0)
                end
            end
        end -- }}}
    end
end -- }}}
--- Display history in new buffer
--- @param refreshChk boolean Set it true to refresh the history files everytime
M.display = function(refreshChk) -- {{{
    -- For VimEnter autocmd
    if not refreshChk and vim.fn.argc() > 0 or #vim.v.oldfiles == 0 then
        return
    end
    if vim.bo.filetype == "HistoryStartup" then return end

    -- Reset lines
    M.initWin = vim.api.nvim_get_current_win()
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
    if vim.api.nvim_buf_get_name(0) == "" and vim.bo.modifiable and
            vim.api.nvim_buf_line_count(0) == 1 and vim.fn.getline(1) == "" then
        -- Use the current buffer if it's a scratch buffer
        M.initBuf  = vim.api.nvim_get_current_buf()
        M.lastBuf = nil
        vim.api.nvim_set_option_value("buflisted", false, {buf = M.initBuf})
        vim.api.nvim_set_option_value("buftype", "nofile", {buf = M.initBuf})
    else
        if not vim.api.nvim_buf_is_valid(M.initBuf) then
            M.initBuf = vim.api.nvim_create_buf(false, true)
        else
            -- Use last historyStartup buffer?
        end
    end
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = M.initBuf})
    vim.api.nvim_set_option_value("filetype",  "HistoryStartup", {buf = M.initBuf})

    -- Setting up autocmd
    setupAutoCmd()

    -- Set lines
    vim.defer_fn(function()
        vim.api.nvim_win_set_buf(M.initWin, M.initBuf)
        modifyLines(function()
            vim.api.nvim_buf_set_lines(M.initBuf, 0, 1, false, M.lines.firstline)
            if not next(M.lines.relative) then
                vim.api.nvim_buf_set_lines(M.initBuf, 1, -1, false, M.lines.absolute)
                M.lines.relativeTick = false
            else
                vim.api.nvim_buf_set_lines(M.initBuf, 1, -1, false, M.lines.relative)
                M.lines.relativeTick = true
            end

            -- Strike through openned files
            if refreshChk then
                strikeThroughOpened()
            end
        end)
    end, 0)

    -- Key mappings
    vim.defer_fn(function()
        for _, key in ipairs {"o", "<2-LeftMouse>", "go", "<C-s>", "<C-v>", "<C-t>", "<CR>", "q", "Q", "K","yp"} do
            vim.api.nvim_buf_set_keymap(M.initBuf, "n", key, "",
                {callback = function() execMap(key) end} )
        end
    end, 0)
end -- }}}


-- Exposed API
M.isLoaded = isLoaded


return M
