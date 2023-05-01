local M = {}
local var = require("buffer.var")


--- Gather information about buffers and windows for further processing
M.initBuf = function()
    var.bufNr    = vim.api.nvim_get_current_buf()
    var.bufNrs   = M.bufNrs(true)
    var.bufName  = nvim_buf_get_name(var.bufNr)
    var.bufType  = vim.bo.buftype
    var.fileType = vim.bo.filetype
    var.winId    = vim.api.nvim_get_current_win()
    var.winIds   = M.winIds(false)
end


M.isSpecBuf = function(bufType) -- {{{
    bufType = bufType or var.bufType
    return bufType ~= ""
end -- }}}
M.isScratchBuf = function() -- {{{
    return var.bufName == "" or not vim.tbl_contains(var.bufNrs, var.bufNr)
end -- }}}
--- Force wipe the given buffer, if no bufNr is provided, then current buffer
--- will be wiped
--- @param bufNr boolean Buffer number handler
M.bufClose = function(bufNr) -- {{{
    -- bufNr = bufNr or 0
    -- :bdelete will register in both the jumplist and the changelist
    pcall(vim.api.nvim_command, "bdelete! " .. bufNr)
    -- These two don't register in both the changelist and the changelist
    -- pcall(vim.api.nvim_command, "keepjump bwipe! " .. bufNr)
    -- pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end -- }}}
--- Function wrapped around the vim.api.nvim_list_bufs()
--- @param validLoadedOnly boolean Whether contains loaded buffers only
--- @return table
M.bufNrs = function(validLoadedOnly) -- {{{
    local unListedBufTbl = vim.api.nvim_list_bufs()
    local cond = function(buf)
        if validLoadedOnly then
            return vim.api.nvim_buf_is_loaded(buf) and
                vim.api.nvim_buf_get_option(buf, "buflisted")
        else
            return vim.api.nvim_buf_get_option(buf, "buflisted")
        end
    end

    return vim.tbl_filter(cond, unListedBufTbl)
end -- }}}
--- Switch to alternative buffer or previous buffer before wiping current buffer
--- @param winID number Window ID in which alternative will be set
M.bufSwitchAlter = function(winID) -- {{{
    ---@diagnostic disable-next-line: param-type-mismatch
    local altBufNr = vim.fn.bufnr("#")
    if altBufNr ~= var.bufNr and vim.api.nvim_buf_is_valid(altBufNr) and
            vim.tbl_contains(var.bufNrs, altBufNr) then
        vim.api.nvim_win_set_buf(winID, altBufNr)
        return true
    else
        -- Fallback method
        for _, b in ipairs(var.bufNrs) do
            if b ~= var.bufNr then
                vim.api.nvim_win_set_buf(var.winId, b)
                return true
            end
        end
    end

    vim.notify("Failed to switch alternative buffer in Windows: " .. winID)

    return false
end -- }}}
--- Return valid and loaded buffer count
---@param bufNrTbl? table Use `var.bufNrs` if no bufNrTbl provided
---@return number
M.bufsVisibleOccur = function(bufNrTbl) -- {{{
    bufNrTbl = bufNrTbl or var.bufNrs

    if bufNrTbl then
        local cnt = #vim.tbl_filter(function(bufNr)
            return vim.api.nvim_buf_get_name(bufNr) ~= ""
        end, bufNrTbl)
        return cnt
    else
        return 0
    end
end -- }}}
M.bufOccurInWins = function(buf) -- {{{
    local bufCnt = 0
    for _, w in ipairs(var.winIds) do
        if buf == vim.api.nvim_win_get_buf(w) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end -- }}}
M.bufsOccurInWins = function() -- {{{
    local bufCnt = 0
    for _, w in ipairs(var.winIds) do
        if vim.tbl_contains(var.bufNrs, vim.api.nvim_win_get_buf(w)) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end -- }}}
M.winIds = function(relativeIncludeChk) -- {{{
    if not relativeIncludeChk then
        return vim.tbl_filter(function(i)
            return vim.api.nvim_win_get_config(i).relative == ""
        end, vim.api.nvim_list_wins())
    else
        return vim.api.nvim_list_wins()
    end
end -- }}}
M.winsOccur = function() -- {{{
    -- Take two NNP windows into account
    if package.loaded["no-neck-pain"] and
        require("no-neck-pain").state.enabled then

        local totalWinCnts = #var.winIds
        for _, winId in ipairs(var.winIds) do
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
        return #var.winIds
    end
end -- }}}
M.winClose = function (winID) -- {{{
    local ok, msg = pcall(vim.api.nvim_win_close, winID, false)
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end
end -- }}}


return M
