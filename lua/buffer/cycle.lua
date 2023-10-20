-- File: cycle.lua
-- Author: iaso2h
-- Description: Improved bp and bn
-- Version: 0.0.10
-- Last Modified: 2023-09-17


local M   = {
    buftypeBlacklist = {
        "quickfix"
    },

    --Options
    registerInJumplist = true
}


local checkTreeSitterLoaded = function(bufNr) -- {{{
    -- BUG: Automatically undo a non-treesitter supported buffer
    -- Potential solution: https://neovim.discourse.group/t/check-if-treesitter-is-enabled-in-the-current-buffer/902/3
    -- HACK: figuring out when to call this function. Using ex-command "Q" and "SE"??
    bufNr = bufNr or vim.api.nvim_get_current_buf()
    local bufPath = vim.api.nvim_buf_get_name(0)
    if bufPath ~= "" then
        -- Reload buffer if it's valid
        local ok, _ = pcall(vim.treesitter.get_parser, nil, nil, nil)
        if not ok then
            vim.cmd "e! | norm zv"
        end
    end
end -- }}}
--- Cycle through buffers until standard buffer is found
---@param currentBufNr integer Buffer number
---@param direction integer `1|-1` `1` indicate cycling forward
local bufferCycle = function(currentBufNr, direction) -- {{{
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

        local bufNr = vim.api.nvim_get_current_buf()
        local bufType = vim.api.nvim_buf_get_option(bufNr, "buftype")
        if bufType == "" or bufType == "nofile" then
            break
        end
    until bufNr == currentBufNr

    -- checkTreeSitterLoaded()
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

        local candidateBuftype = vim.api.nvim_buf_get_option(bufNrs[candidateIdx], "buftype")

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
        -- Deal with non-standard buffer
        if not vim.tbl_contains(bufTbl, currentBufNr) or
            vim.o.buftype ~= "" or nvim_buf_get_name(0) == "" then
            return bufferCycle(currentBufNr, direction)
        end
    else
        -- Create buffer table when data from cokeline is unavailable
        bufTbl = vim.api.nvim_list_bufs()
        local cond = function (buf)
            return vim.api.nvim_buf_get_option(buf, "buflisted")
        end
        bufTbl = vim.tbl_filter(cond, bufTbl)
    end

    local currentBufIdx = tbl_idx(bufTbl, currentBufNr, false)
    if currentBufIdx == -1 then
        -- Use fallback function if current buffer index is not found
        return bufferCycle(currentBufNr, direction)
    end

    -- Find the valid candidate
    local candidateIdx = findCandidate(bufTbl, currentBufIdx, direction)
    if candidateIdx == 0 then
        return vim.notify("No valid buffer to cycle", vim.log.levels.INFO)
    end

    -- Use the Ex command to enter a buffer without writing jumplist
    vim.cmd([[noa keepjump buffer ]] .. bufTbl[candidateIdx])

    -- checkTreeSitterLoaded()
    if M.registerInJumplist then
        vim.api.nvim_exec_autocmds("BufEnter", {modeline = false, buffer = bufTbl[candidateIdx]})
    end
end -- }}}


return M
