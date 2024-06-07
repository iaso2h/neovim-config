-- File: toggle.lua
-- Author: iaso2h
-- Description: Toggle terminal like VS Code does
-- Last Modified: 2024-06-07
-- Version: 0.0.7

--- Toggle the quickfix window
---@param closeChk boolean Whether to close the quickfix window if it's visible
local quickfix = function(closeChk) -- {{{
    -- Close the current window if it's a quickfix window
    if vim.bo.buftype == "quickfix" then
        return vim.cmd [[cclose]]
    end

    -- Toggle on
    local winInfos = vim.fn.getwininfo()
    for _, winInfo in ipairs(winInfos) do
        if winInfo["quickfix"] == 1 then
            if closeChk then
                return vim.api.nvim_win_close(winInfo.winid, false)
            else
                return vim.api.nvim_set_current_win(winInfo.winid)
            end
        end
    end

    if closeChk then
        return
    end

    -- Fallback
    vim.cmd "copen"
end -- }}}
--- Toggle the terminal window
---@param closeChk boolean Whether to close the terminal window if it's visible
local terminal = function(closeChk) -- {{{
    local winInfos = vim.fn.getwininfo()

    if vim.bo.buftype ~= "terminal" then
        for _, winInfo in ipairs(winInfos) do
            if winInfo["terminal"] == 1 then
                if closeChk then
                    return vim.api.nvim_win_close(winInfo.winid, false)
                else
                    return vim.api.nvim_set_current_win(winInfo.winid)
                end
            end
        end

        if closeChk then
            return
        end

        -- Search terminal in hidden buffer list
        for exCmd in ipairs{"R", "F"} do
            local output = vim.api.nvim_exec2("ls! " .. exCmd, {output = true}).output
            if output ~= "" then
                local cmdLines = vim.split(output, "\n", {plain = true})
                for _, cmdLine in ipairs(cmdLines) do
                    local bufNr = string.match(cmdLine, "(%d+).* ['\"]term://")
                    if bufNr then
                        return vim.cmd("split | buffer " .. bufNr)
                    end
                end
            end
        end

        vim.cmd "split"
        vim.cmd "terminal"
    else
        if #require("buffer.util").winIds(false) == 1 then
            vim.notify("Cannot close the last window", vim.log.levels.INFO)
        else
            vim.api.nvim_win_close(0, false)
        end
    end
end -- }}}


--- Toggle different window based on `type`
---@param type string `"quickfix"|"terminal"`
---@param closeChk boolean Wether to close the target window if it's visible
return function(type, closeChk)
    if type == "quickfix" then
        return quickfix(closeChk)
    elseif type == "terminal" then
        return terminal(closeChk)
    end
end
