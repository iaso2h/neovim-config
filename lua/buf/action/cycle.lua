-- File: cycle.lua
-- Author: iaso2h
-- Description: Improved bp and bn
-- Version: 0.0.6
-- Last Modified: 2023-3-26


local api = vim.api
local M   = {
    buftypeBlacklist = {
        "quickfix"
    }
}


local bufferCycle = function(currentBufNr, direction)
    repeat
        -- Deliberately leave track on jumplist so that you can traceback to
        -- the help file or other non-standard buffer via <C-o>
        if direction == 1 then
            vim.cmd[[bn]]
        else
            vim.cmd[[bp]]
        end

        local bufNr = api.nvim_get_current_buf()
        local bufType = api.nvim_buf_get_option(bufNr, "buftype")
        if bufType == "" or bufType == "nofile" then
            return
        end
    until bufNr == currentBufNr
end


local function findCandi(bufTbl, currentBufIdx, direction)
    local candiIdx
    for i = 1, #bufTbl do
        if i == #bufTbl then return 0 end

        candiIdx = currentBufIdx + direction
        -- Loop through the buffer table
        if direction == -1 and candiIdx == 0 then candiIdx = #bufTbl end
        if direction == 1 and candiIdx == #bufTbl + 1 then candiIdx = 1 end

        local candiBuftype = api.nvim_buf_get_option(bufTbl[candiIdx], "buftype")

        -- Filter out quickfix
        if not vim.tbl_contains(M.buftypeBlacklist, candiBuftype) then
            return candiIdx
        end
    end
end


--- Get all listed buffers. Just like what you see in the :ls command
---@param direction number Set to 1 to jump to next buffer, -1 to previous buffer
M.init = function(direction)
    local currentBufNr = api.nvim_get_current_buf()
    local bufTbl
    if _G.cokeline and type(_G.cokeline) == "table" then
        bufTbl = vim.tbl_map(function(buffer)
            return buffer.number
        end, _G.cokeline.visible_buffers)
    end

    -- Deal with non-standard buffer
    if (_G.cokeline and type(_G.cokeline) == "table" and
        vim.tbl_contains(bufTbl, currentBufNr)) or
        vim.o.buftype ~= "" or nvim_buf_get_name(0) == "" then
        return bufferCycle(currentBufNr, direction)
    end

    -- Create buffer table when data from cokeline is unavailable
    if not(_G.cokeline and type(_G.cokeline) == "table") then
        bufTbl = api.nvim_list_bufs()
        local cond = function (buf)
            return api.nvim_buf_get_option(buf, "buflisted")
        end
        bufTbl = vim.tbl_filter(cond, bufTbl)
    end

    local currentBufIdx = tbl_idx(bufTbl, currentBufNr, false)
    if not currentBufIdx then
        -- Use fallback function
        return bufferCycle(currentBufNr, direction)
    end

    -- Find the valid candidate
    local candiIdx = findCandi(bufTbl, currentBufIdx, direction)
    if candiIdx == 0 then
        return vim.notify("No valid buffer to cycle", vim.log.levels.INFO)
    end

    -- Use the Ex command to enter a buffer without writing jumplist
    vim.cmd([[noa keepjump buffer ]] .. bufTbl[candiIdx])
    api.nvim_exec_autocmds("BufWinEnter", {modeline = false, buffer = bufTbl[candiIdx]})
end

return M
