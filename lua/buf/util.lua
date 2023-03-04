local M = {}
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local var = require("buf.var")



--- Gather informatioin about buffers and windows for further processing
M.initBuf = function()
    var.bufName  = api.nvim_buf_get_name(0)
    var.bufNr    = api.nvim_get_current_buf()
    var.bufType  = vim.o.buftype
    var.winID    = api.nvim_get_current_win()
    var.winIDtbl = vim.tbl_filter(function(i)
        return api.nvim_win_get_config(i).relative == ""
        end, api.nvim_list_wins())
    -- NOTE: Do not use results from:
    -- vim.tbl_filter(function(i) return api.nvim_buf_is_loaded(i) end, api.nvim_list_bufs())
    var.bufNrTbl = vim.tbl_map(function(buf)
        return tonumber(string.match(buf, "%d+"))
        end, M.bufLoadedTbl(false))
end


--- Return all loaded buffer listed in the :ls command in a table
--- @param termInclude boolean Value to determine whether contains terminal or not
--- @return table
function M.bufLoadedTbl(termInclude) -- {{{
    local bufTbl
    if not termInclude then
        bufTbl = vim.tbl_filter(function(buf) return string.match(buf, "term://") == nil end,
            vim.split(fn.execute("ls"), '\n', false))
        table.remove(bufTbl, 1)
    else
        -- NOTE: Execute ls! will incur Neovim built-in LSP complain
        bufTbl = vim.split(fn.execute("ls"), '\n', false)
        table.remove(bufTbl, 1)
    end
    return bufTbl
end -- }}}


--- Force wipe the given buffer, if no bufNr is provided, then current buffer
--- will be wiped
--- @param bufNr boolean Buffer number handler
M.bufWipe = function(bufNr)
    -- bufNr = bufNr or 0
    -- pcall(cmd, "bdelete! " .. bufNr)
    pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end


--- Switch to alternative buffer or previous buffer before wiping current buffer
--- @param winID number Window ID in which alternative will be set
M.switchAlter = function(winID)
    local altBufNr = fn.bufnr("#")
    if altBufNr ~= var.bufNr and api.nvim_buf_is_valid(altBufNr) and
            vim.tbl_contains(var.bufNrTbl, altBufNr) then
        api.nvim_win_set_buf(winID, altBufNr)
    else
        -- Fallback method
        cmd(string.format("noautocmd %swincmd w", fn.getwininfo(winID)[1].winnr))
        cmd "bprevious"
    end
end


M.isSpecBuf = function (bufType)
    bufType = bufType or var.bufType
    return bufType ~= ""
end

M.isScratchBuf = function ()
   return var.bufName == "" or not vim.tbl_contains(var.bufNrTbl, var.bufNr)
end

M.closeWin = function (winID)
    local ok, msg = pcall(api.nvim_win_close, winID, false)
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end
end

M.winCnt = function ()
    return #var.winIDtbl
end

M.getBufCntInWins = function ()
    local bufCnt = 0
    for _, w in ipairs(var.winIDtbl) do
        if vim.tbl_contains(var.bufNrTbl, api.nvim_win_get_buf(w)) then
            bufCnt = bufCnt + 1
        end
    end
    return bufCnt
end

M.bufCnt = function()
    return #var.bufNrTbl
end

return M
