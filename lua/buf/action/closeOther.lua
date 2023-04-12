local fn    = vim.fn
local cmd   = vim.cmd
local api   = vim.api
local util  = require("buf.util")
local var   = require("buf.var")
local M    = {}

-- Filter out terminal and special buffer, because I don't want to close them yet
local filterBuf = function(bufNr)
    local bufType = vim.bo.buftype
    return bufNr ~= var.bufNr and (bufType == "" or bufType == "nofile" or bufType == "nowrite")
end


--- Wipe all the other buffers except for the special buffers without changing the window layout
function M.init() -- {{{
    util.initBuf()
    if util.isSpecBuf() then return end


    -- TODO: implement in hook function
    -- Check whether call from Nvim Tree
    var.winIDTbl = api.nvim_list_wins()
    if vim.bo.filetype == "NvimTree" then
        util.switchAlter(var.winID)
        if vim.bo.filetype == "NvimTree" then
            return
        end
    end

    var.bufNrTbl = vim.tbl_filter(filterBuf, var.bufNrTbl)
    local unsavedChange = false
    local answer = -1

    -- Check unsaved change
    for _, bufNr in ipairs(var.bufNrTbl) do
        if bufNr ~= var.bufNr then
            local modified = api.nvim_buf_get_option(bufNr, "modified")
            if modified then unsavedChange = true; break end
        end
    end

    -- Ask for saving, return when cancel is input
    if unsavedChange then
        cmd "noa echohl MoreMsg"
        answer = fn.confirm("Save all modification?",
            ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "noa echohl None"
        -- Interrupt
        if answer == 3 or answer == 0 then
            return
        elseif answer == 1 then
            cmd "noa bufdo update"
        end
    end

    -- Close other window that doesn't contain the current buffers while
    -- Reserving windows that contain special buffer like help, quickfix
    if util.winCnt() > 1 then
        for _, winID in ipairs(var.winIDTbl) do
            if vim.tbl_contains(var.bufNrTbl, api.nvim_win_get_buf(winID))
                and api.nvim_buf_get_option(api.nvim_win_get_buf(winID), "buftype") == "" then

                util.closeWin(winID)
            end
        end
    end

    -- Wipe buffers
    for _, bufNr in ipairs(var.bufNrTbl) do
        if api.nvim_buf_is_valid(bufNr) then util.bufWipe(bufNr) end
    end
    if package.loaded["cokeline"] then
        require('cokeline/augroups').toggle()
    end
end -- }}}

return M
