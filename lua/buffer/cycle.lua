-- File: cycle.lua
-- Author: iaso2h
-- Description: Improved bp and bn
-- Version: 0.0.13
-- Last Modified: 2024-06-01


local M   = {
    buftypeBlacklist = {
        "quickfix"
    },

    --Options
    registerInJumplist = true
}


--- Reload the buffer if the buffer has treesttier highlighter supported but
--somehow the highlight hasn't been enabled yet. Especially targeting the
--buffer loaded after sourcing a vim session file
---@param bufNr integer Buffer number
local checkTreeSitterLoaded = function(bufNr) -- {{{
    if not require("vim.treesitter.highlighter").active[M.curBufNr] then
        if vim.bo.ft == "" and vim.bo.bt == "" and not vim.bo.modified then
            local extension = vim.fn.expand("%:e")
            if extension == "" then return end

            if _G._treesitter_supported_languages[extension] then
                vim.cmd "e! | norm zv"
            end
        end
    end
end -- }}}
--- Cycle through buffers until standard buffer is found
---@param currentBufNr integer Buffer number
---@param direction integer `1|-1` `1` indicates cycling forward
---@return integer `1|-1` `1`indicates cycling to a standard buffer
local fallbackCycle = function(currentBufNr, direction) -- {{{
    local bufNr
    local returnCode

    repeat
        -- Deliberately leave track on jumplist so that you can traceback to
        -- the help file or other non-standard buffer via <C-o>
        if direction == 1 then
            if M.registerInJumplist then
                vim.cmd[[keepjump bn]]
            else
                vim.cmd[[noa keepjump bn]]
            end
        else
            if M.registerInJumplist then
                vim.cmd[[keepjump bp]]
            else
                vim.cmd[[noa keepjump bp]]
            end
        end

        bufNr = vim.api.nvim_get_current_buf()
        local bufType = vim.api.nvim_get_option_value("buftype", {buf = bufNr})
        if bufType == "" or bufType == "nofile" then
            returnCode = 1
            break
        end
    until bufNr == currentBufNr

    checkTreeSitterLoaded(bufNr)

    return returnCode
end -- }}}
--- Find the standard buffer idx in the `bufNrs`
---@param bufNrs integer[] Buffer numbers
---@param currentBufIdx integer
---@param direction `1|-1` `1` indicate cycling forward
local function findCandidate(bufNrs, currentBufIdx, direction) -- {{{
    local candidateIdx
    for i = 1, #bufNrs do
        if i == #bufNrs then return 0 end

        candidateIdx = currentBufIdx + direction
        -- Loop through the buffer table
        if direction == -1 and candidateIdx == 0 then candidateIdx = #bufNrs end
        if direction == 1 and candidateIdx == #bufNrs + 1 then candidateIdx = 1 end

        local candidateBuftype = vim.api.nvim_get_option_value("buftype", {buf = bufNrs[candidateIdx]})

        -- Filter out quickfix
        if not vim.tbl_contains(M.buftypeBlacklist, candidateBuftype) then
            return candidateIdx
        end
    end
end -- }}}
--- Get all listed buffers. Just like what you see in the :ls command
---@param direction integer `1|-1` `1` indicate cycling forward
M.init = function(direction) -- {{{
    local currentBufNr = vim.api.nvim_get_current_buf()
    local bufTbl
    if package.loaded["cokeline"] and next(require("cokeline.state").visible_buffers) then
        -- Use buffers from cokeline plug-in
        bufTbl = vim.tbl_map(function(buffer)
            return buffer.number
        end, require("cokeline.state").visible_buffers)
    else
        -- Create buffer table when data from cokeline is unavailable
        bufTbl = require("buffer.util").bufNrs(true)
    end
    if #bufTbl == 1 then
        return vim.notify("No valid buffer to cycle", vim.log.levels.INFO)
    end

    -- Deal with non-standard buffer
    if not vim.api.nvim_get_option_value("buflisted", {buf = currentBufNr}) or
        vim.o.buftype ~= "" or
        nvim_buf_get_name(0) == "" or
        tbl_idx(bufTbl, currentBufNr, false) == -1 then
        -- Use fallback function if current buffer index is not found
        return fallbackCycle(currentBufNr, direction)
    end

    -- Find the valid candidate
    local candidateIdx = findCandidate(bufTbl, currentBufIdx, direction)
    if candidateIdx == 0 then
        return vim.notify("No valid buffer to cycle", vim.log.levels.INFO)
    end

    -- Use the Ex command to enter a buffer without writing jumplist
    local candidateBufNr = bufTbl[candidateIdx]
    vim.cmd([[keepjump noa buffer ]] .. candidateBufNr)

    checkTreeSitterLoaded(candidateBufNr)
    if M.registerInJumplist then
        vim.api.nvim_exec_autocmds("BufEnter", {modeline = false, buffer = bufTbl[candidateIdx]})
    end
end -- }}}


return M
