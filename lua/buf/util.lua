local M = {}
local var = require("buf.var")


--- Gather information about buffers and windows for further processing
M.initBuf = function()
    var.bufNr    = vim.api.nvim_get_current_buf()
    var.bufName  = nvim_buf_get_name(var.bufNr)
    var.bufType  = vim.bo.buftype
    var.fileType = vim.bo.filetype
    var.winID    = vim.api.nvim_get_current_win()
    var.winIDTbl = vim.tbl_filter(function(i)
        return vim.api.nvim_win_get_config(i).relative == ""
        end, vim.api.nvim_list_wins())
    -- NOTE: Do not use results from:
    -- vim.tbl_filter(function(i) return api.nvim_buf_is_loaded(i) end, api.nvim_list_bufs())
    var.bufNrTbl = M.bufTbl(true, false)
end


--- Function wrapped around the vim.api.nvim_list_bufs()
--- @param validLoadedOnly boolean Whether contains loaded buffers only
--- @param hiddenIncluded boolean Whether include hidden buffer
--- @return table
function M.bufTbl(validLoadedOnly, hiddenIncluded) -- {{{
    local unListedBufTbl = vim.api.nvim_list_bufs()
    local cond = function(buf)
        if hiddenIncluded then
            if validLoadedOnly then
                return vim.api.nvim_buf_is_loaded(buf)
            else
                return true
            end
        else
            if validLoadedOnly then
                return vim.api.nvim_buf_is_loaded(buf) and
                    vim.api.nvim_buf_get_option(buf, "bufhidden") == ""
            else
                return vim.api.nvim_buf_get_option(buf, "bufhidden") == ""
            end

        end
    end

    return vim.tbl_filter(cond, unListedBufTbl)
end -- }}}


--- Force wipe the given buffer, if no bufNr is provided, then current buffer
--- will be wiped
--- @param bufNr boolean Buffer number handler
M.bufWipe = function(bufNr)
    -- bufNr = bufNr or 0
    -- :bdelete will register in both the jumplist and the changelist
    pcall(vim.cmd, "bdelete! " .. bufNr)
    -- These two don't register in both the changelist and the changelist
    -- pcall(cmd, "keepjump bwipe! " .. bufNr)
    -- pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end


--- Switch to alternative buffer or previous buffer before wiping current buffer
--- @param winID number Window ID in which alternative will be set
M.bufSwitchAlter = function(winID)
    local altBufNr = vim.fn.bufnr("#")
    if altBufNr ~= var.bufNr and vim.api.nvim_buf_is_valid(altBufNr) and
            vim.tbl_contains(var.bufNrTbl, altBufNr) then
        vim.api.nvim_win_set_buf(winID, altBufNr)
        return true
    else
        -- Fallback method
        for _, b in ipairs(var.bufNrTbl) do
            if b ~= var.bufNr then
                vim.api.nvim_win_set_buf(var.winID, b)
                return true
            end
        end
    end

    vim.notify("Failed to switch alternative buffer in Windows: " .. winID)

    return false
end


M.isSpecBuf = function (bufType)
    bufType = bufType or var.bufType
    return bufType ~= ""
end


M.isScratchBuf = function ()
   return var.bufName == "" or not vim.tbl_contains(var.bufNrTbl, var.bufNr)
end


M.closeWin = function (winID)
    local ok, msg = pcall(vim.api.nvim_win_close, winID, false)
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end
end


M.winCnt = function()
    -- Take two NNP windows into account
    if package.loaded["no-neck-pain"] then
        local totalWinCnts = #var.winIDTbl
        for _, winId in ipairs(var.winIDTbl) do
            if vim.api.nvim_win_is_valid(winId) then
                local bufNr    = vim.api.nvim_win_get_buf(winId)
                local filetype = vim.api.nvim_buf_get_option(bufNr, "filetype")
                if filetype == "no-neck-pain" then
                    totalWinCnts = totalWinCnts - 1
                end
            else
                totalWinCnts = totalWinCnts - 1
            end
        end
        return totalWinCnts
    else
        return #var.winIDTbl
    end
end


M.getAllBufCntsInWins = function()
    local bufCnt = 0
    for _, w in ipairs(var.winIDTbl) do
        if vim.tbl_contains(var.bufNrTbl, vim.api.nvim_win_get_buf(w)) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end


M.getCurBufCntsInWins = function(buf)
    local bufCnt = 0
    for _, w in ipairs(var.winIDTbl) do
        if buf == vim.api.nvim_win_get_buf(w) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end


--- Return valid and loaded buffer count
---@param bufNrTbl? table Use `var.bufNrTbl` if no bufNrTbl provided
---@return number
M.bufValidCnt = function(bufNrTbl)
    bufNrTbl = bufNrTbl or var.bufNrTbl

    if bufNrTbl then
        local cnt = #vim.tbl_filter(function(bufNr)
            return vim.api.nvim_buf_get_name(bufNr) ~= ""
        end, bufNrTbl)
        return cnt
    else
        return 0
    end
end


return M
