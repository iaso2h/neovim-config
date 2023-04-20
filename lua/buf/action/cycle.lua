-- File: cycle.lua
-- Author: iaso2h
-- Description: Improved bp and bn
-- Version: 0.0.8
-- Last Modified: 2023-4-20


local api = vim.api
local M   = {
    buftypeBlacklist = {
        "quickfix"
    },

    --Options
    registerInJumplist = false
}


local checkTsLoaded = function()
    local ok, _ = pcall(vim.treesitter.get_parser, nil, nil, nil)
    if not ok then
        vim.cmd "e! | norm zv"
    end
end


local bufferCycle = function(currentBufNr, direction)
    repeat
        -- Deliberately leave track on jumplist so that you can traceback to
        -- the help file or other non-standard buffer via <C-o>
        if direction == 1 then
            if M.registerInJumplist then
                vim.cmd[[bn]]
            else
                vim.cmd[[noa keepjump bn]]
            end
        else
            if M.registerInJumplist then
                vim.cmd[[bp]]
            else
                vim.cmd[[noa keepjump bp]]
            end
        end

        local bufNr = api.nvim_get_current_buf()
        local bufType = api.nvim_buf_get_option(bufNr, "buftype")
        if bufType == "" or bufType == "nofile" then
            break
        end
    until bufNr == currentBufNr

    checkTsLoaded()
end


local function findCandidate(bufTbl, currentBufIdx, direction)
    local candidateIdx
    for i = 1, #bufTbl do
        if i == #bufTbl then return 0 end

        candidateIdx = currentBufIdx + direction
        -- Loop through the buffer table
        if direction == -1 and candidateIdx == 0 then candidateIdx = #bufTbl end
        if direction == 1 and candidateIdx == #bufTbl + 1 then candidateIdx = 1 end

        local candidateBuftype = api.nvim_buf_get_option(bufTbl[candidateIdx], "buftype")

        -- Filter out quickfix
        if not vim.tbl_contains(M.buftypeBlacklist, candidateBuftype) then
            return candidateIdx
        end
    end
end


--- Get all listed buffers. Just like what you see in the :ls command
---@param direction number Set to 1 to jump to next buffer, -1 to previous buffer
M.init = function(direction)
    local currentBufNr = api.nvim_get_current_buf()
    local bufTbl
    ---@diagnostic disable-next-line: undefined-field
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
    local candidateIdx = findCandidate(bufTbl, currentBufIdx, direction)
    if candidateIdx == 0 then
        return vim.notify("No valid buffer to cycle", vim.log.levels.INFO)
    end

    -- Use the Ex command to enter a buffer without writing jumplist
    vim.cmd([[noa keepjump buffer ]] .. bufTbl[candidateIdx])
    checkTsLoaded()
    if M.registerInJumplist then
        api.nvim_exec_autocmds("BufEnter", {modeline = false, buffer = bufTbl[candidateIdx]})
    end
end

return M
