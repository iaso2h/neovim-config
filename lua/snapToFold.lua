-- File: snapToFold
-- Author: iaso2h
-- Description: Snap to closest fold in sight then execute an Ex command or
-- a function
-- Version: 0.0.8
-- Last Modified: 2023-3-20
local api  = vim.api
local fn   = vim.fn
local util = require("util")
local M    = {}


--- Get the next non-folded line number. If topline is already a non-folded
--- line, then topline will be return
---@param topline number
---@param botline number
---@return number
local getNextNonFoldLine = function(topline, botline)
    local nextline = topline
    while nextline < botline do
        if fn.foldlevel(nextline) ~= 0 then
            -- Inside a fold
            local closedEnd = fn.foldclosedend(nextline)

            if closedEnd == -1 then
                -- The fold is open

                -- Find the end of a opened-fold till calling
                -- vim.fn.foldlevel(nextline) return 0 because the fold is
                -- already open, and the return value of vim.fn.foldclosedend()
                -- is always -1 whenever it receives lineNr inside a fold or
                -- outside
                while nextline < botline do
                    nextline = nextline + 1
                    if fn.foldlevel(nextline) == 0 then
                        return nextline
                    end
                end
            else
                -- The fold is closed
                nextline = closedEnd + 1
            end
        else
            -- Not inside a fold
            return nextline
        end
    end

    return -1
end


--- Get the first non-folded region in a bigger region specified by a topline
--- number and a botline number
---@param topline number
---@param botline number
---@return table Ex: {1, 34}
local getNonFoldRegion = function(topline, botline)
    for i = topline, botline, 1 do
        if fn.foldlevel(i) ~= 0 then
            -- If the first line is also a fold line
            return { topline, i - 1 }
        end
    end

    -- No folds in the whole range
    return { topline, botline }
end


--- Get all non-folded regions inside a bigger region specified by a topline
--- number and a botline number
---@param topline number
---@param botline number
---@return table Ex: {{1, 34}, {54, 131}, {185, 202}}
M.getAllNonFoldRegion = function(topline, botline)
    local region
    local nextTopline = topline
    local nonFoldRegion = {}

    -- Make sure the first line is always a nonfoldline
    nextTopline = getNextNonFoldLine(nextTopline, botline)
    if nextTopline == -1 then
        -- There is no non-folded line available
        return nonFoldRegion
    end

    while true do
        region = getNonFoldRegion(nextTopline, botline)
        table.insert(nonFoldRegion, region)

        if region[2] ~= botline then
            -- Pick up where getNonFoldRegion stops
            local nextLine = region[2] + 1
            -- Make sure next line is always a nonfoldline and continue the loop
            nextTopline = getNextNonFoldLine(nextLine, botline)
            if nextTopline == -1 then
                return nonFoldRegion
            end

            if nextTopline == botline then break end

        else
            -- Stop when range[2] is the botline
            break
        end
    end

    return nonFoldRegion
end


--- Snap to a specific line
---@param curWinNr  number Current window number
---@param curBufNr  number Current buffer number
---@param cursorPos table  Cursor info retrieved by calling nvim_win_set_cursor
---@param lineNr    number Destination line number
local function snapToLine(curWinNr, curBufNr, cursorPos, lineNr)
    local regionEndTextLen = #api.nvim_buf_get_lines(curBufNr, lineNr - 1, lineNr, false)[1]
    if regionEndTextLen - 1 < cursorPos[2] then
        if regionEndTextLen == 0 then
            api.nvim_win_set_cursor(curWinNr, { lineNr, 0 })
        else
            api.nvim_win_set_cursor(curWinNr, { lineNr, regionEndTextLen - 1 })
        end
    else
        api.nvim_win_set_cursor(curWinNr, { lineNr, cursorPos[2] })
    end
end


--- Execute an Ex command or a function
---@param exCMD string|function
local function exeCommand(exCMD)
    if type(exCMD) == "string" then
        return vim.cmd(exCMD)
    elseif type(exCMD) == "function" then
        exCMD()
    end
end


--- Snap to the closest fold and execute a Ex command or a function
---@param exCMD string|function An Ex command or a function. Note that it will
---be executed right away if the cursor is right above a fold start or a fold
---end
---@param snapEnable boolean Whether to enable the snap. If this set to false,
--- the exCMD will act like a right hand side of a normal mapping
---@param threshold number Multiplied by the Neovim window height to get the
--- minimum number for the snap taking place
M.main = function(exCMD, snapEnable, threshold)
    --
    -- {
    -- botline = 12,
    -- bufnr = 42,
    -- height = 61,
    -- loclist = 0,
    -- quickfix = 0,
    -- tabnr = 1,
    -- terminal = 0,
    -- textoff = 10,
    -- topline = 1,
    -- variables = {
        -- last_changedtick = 1209,
        -- last_cursor = { 0, 9, 18, 0, 18 },
        -- matchup_hi_time = { 980, -1958460276 },
        -- matchup_match_id_list = {},
        -- matchup_need_clear = 1,
        -- matchup_pulse_time = { 980, -1957157176 },
        -- matchup_timer = 1
    -- },
    -- width = 141,
    -- winbar = 0,
    -- wincol = 1,
    -- winid = 1000,
    -- winnr = 1,
    -- winrow = 2
    -- }
    -- Execute command right away
    if snapEnable == nil then snapEnable = true end
    if not snapEnable then return exeCommand(exCMD) end

    -- Default value
    threshold = threshold or 1

    -- Initiation
    local curWinNr = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    -- (1, 0) indexed table
    local cursorPos = api.nvim_win_get_cursor(curWinNr)
    if fn.foldlevel(cursorPos[1]) ~= 0 then
        return exeCommand(exCMD)
    end

    local winInfo = fn.getwininfo(curWinNr)
    -- Make table clean
    winInfo = #winInfo == 1 and winInfo[1] or winInfo

    -- Get non-folded range inclusively
    local nonFoldRegions = M.getAllNonFoldRegion(winInfo.topline, winInfo.botline)

    -- No visible folds in Neovim window
    if #nonFoldRegions == 1 and nonFoldRegions[1][1] == winInfo.topline and nonFoldRegions[1][2] == winInfo.botline then
        -- Do nothing
        return api.nvim_echo({ { "No visible folds in sight" } }, false, {})
    end

    -- Check which region cursor resides in
    local cursorRegion
    for _, region in ipairs(nonFoldRegions) do
        if cursorPos[1] >= region[1] and cursorPos[1] <= region[2] then
            cursorRegion = region
            break
        end
    end
    if not cursorRegion then
        return vim.notify("Cannot find cursor region for snapToFold", vim.log.levels.ERROR)
    end

    -- Check dist from cursor line to both region ends then snap to the closest one
    -- Make sure topLineNr and botLineNr do not fall out of region
    local topLineNr = cursorRegion[1] == winInfo.topline and winInfo.topline or cursorRegion[1] - 1
    local botLineNr = cursorRegion[2] == winInfo.botline and winInfo.botline or cursorRegion[2] + 1
    -- Get distances from cursor to both ends
    local distTop = util.posDist({ topLineNr, cursorPos[2] }, cursorPos)
    local distBot = util.posDist({ botLineNr, cursorPos[2] }, cursorPos)
    -- Compare distance
    if distTop < distBot then
        if topLineNr == winInfo.topline then
            -- Snap to bottom instead
            if distBot <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        else
            if distTop <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            else
                return
            end
        end
    elseif distTop > distBot then
        if botLineNr == winInfo.botline then
            -- Snap to top instead
            if distTop <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            else
                return
            end
        else
            if distBot <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        end
    else
        if topLineNr == winInfo.topline and botLineNr ~= winInfo.botline then
            -- Snap to bottom instead
            if distBot <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            else
                return
            end
        elseif topLineNr ~= winInfo.topline and botLineNr == winInfo.botline then
            -- Snap to top instead
            if distTop <= (winInfo.height) ^ 2 * threshold then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            else
                return
            end
        else
            local answer = fn.confirm("Select direction: ", "&Up\n&Down", 0, "Info")
            if answer == 1 then
                snapToLine(curWinNr, curBufNr, cursorPos, topLineNr)
            elseif answer == 2 then
                snapToLine(curWinNr, curBufNr, cursorPos, botLineNr)
            end
        end

    end

    -- Last but not least
    exeCommand(exCMD)
end

return M
