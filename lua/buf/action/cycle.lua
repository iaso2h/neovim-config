local fn  = vim.fn
local api = vim.api
local M   = {}


local function findCandi(bufTbl, currentBufIdx, direction)
    local candiIdx
    local loopbackTick = false
    for i = 1, #bufTbl do
        candiIdx = currentBufIdx + direction
        if direction == -1 and candiIdx == 0 then candiIdx = #bufTbl end
        if direction == 1 and candiIdx == #bufTbl + 1 then candiIdx = 1 end

        local candiBufType = api.nvim_buf_get_option(bufTbl[candiIdx], "buftype")

        -- Filter out quickfix
        if candiBufType ~= "quickfix" then return candiIdx end

        if i == #bufTbl then return 0 end
    end
end


--- Get all listed buffers. Just like what you see in the :ls command
---@param direction number Set to 1 to jump to next buffer, -1 to previous buffer
M.init = function(direction)
    if not vim.bo.buflisted then
        if direction == 1 then
            return vim.cmd[[bn]]
        else
            return vim.cmd[[bp]]
        end
    end

    local bufTbl = api.nvim_list_bufs()
    local cond = function (buf)
        return api.nvim_buf_get_option(buf, "buflisted")
    end
    bufTbl = vim.tbl_filter(cond, bufTbl)

    local currentBufNr = api.nvim_get_current_buf()
    local currentBufIdx
    local ok, msg = pcall(tbl_idx, bufTbl, currentBufNr, false)
    if not ok then
        return vim.notify(msg, vim.log.levels.ERROR)
    else
        currentBufIdx = msg
    end

    -- Find the valid candidate
    local candiIdx = findCandi(bufTbl, currentBufIdx, direction)
    if not candiIdx then vim.notify("Not valid buffer to cycle", vim.log.level.INFO) end

    api.nvim_win_set_buf(0, bufTbl[candiIdx])
end

return M
