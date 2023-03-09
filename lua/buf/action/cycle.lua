local api = vim.api
local M   = {
    buftypeBlacklist = {
        "quickfix"
    }
}


local function findCandi(bufTbl, currentBufIdx, direction)
    local candiIdx
    for i = 1, #bufTbl + 1 do
        if i == #bufTbl + 1 then return 0 end

        candiIdx = currentBufIdx + direction
        -- Loop through the buffer table
        if direction == -1 and candiIdx == 0 then candiIdx = #bufTbl end
        if direction == 1 and candiIdx == #bufTbl + 1 then candiIdx = 1 end

        local candiBuftype = api.nvim_buf_get_option(bufTbl[candiIdx], "buftype")

        -- Filter out quickfix
        for _, buftype in ipairs(M.buftypeBlacklist) do
            if candiBuftype ~= buftype then
                return candiIdx
            else
                break
            end
        end
    end
end


--- Get all listed buffers. Just like what you see in the :ls command
---@param direction number Set to 1 to jump to next buffer, -1 to previous buffer
M.init = function(direction)
    if vim.o.buftype ~= "" and api.nvim_buf_get_name(0) == "" then
        vim.cmd[[noa keepjump buffer #]]
    end
    local bufTbl = api.nvim_list_bufs()
    local cond = function (buf)
        return api.nvim_buf_get_option(buf, "buflisted")
    end
    bufTbl = vim.tbl_filter(cond, bufTbl)

    local currentBufNr = api.nvim_get_current_buf()
    local currentBufIdx = tbl_idx(bufTbl, currentBufNr, false)

    -- Find the valid candidate
    local candiIdx = findCandi(bufTbl, currentBufIdx, direction)
    if candiIdx == 0 then
        return vim.notify("No valid buffer to cycle", vim.log.level.INFO)
    end

    -- Use the Ex command to enter a buffer without writing jumplist
    vim.cmd([[noa keepjump buffer ]] .. bufTbl[candiIdx])
end

return M
