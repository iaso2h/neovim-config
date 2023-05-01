local u   = require("buffer.util")
local var = require("buffer.var")
local M   = {}

-- Filter out terminal and special buffer, because I don't want to close them yet
local filterBuf = function(bufNr)
    local bufType = vim.bo.buftype
    return bufNr ~= var.bufNr and (bufType == "" or bufType == "nofile" or bufType == "nowrite")
end


--- Wipe all the other buffers except for the special buffers without changing the window layout
function M.init() -- {{{
    -- TODO: parsing all buffers in buf.close instead
    u.initBuf()
    if u.isSpecBuf() then return end


    -- TODO: implement in hook function
    -- Check whether call from Nvim Tree
    var.winIds = vim.api.nvim_list_wins()
    if vim.bo.filetype == "NvimTree" then
        u.switchAlter(var.winId)
        if vim.bo.filetype == "NvimTree" then
            return
        end
    end

    var.bufNrs = vim.tbl_filter(filterBuf, var.bufNrs)
    local unsavedChange = false
    local answer = -1

    -- Check unsaved change
    for _, bufNr in ipairs(var.bufNrs) do
        if bufNr ~= var.bufNr then
            local modified = vim.api.nvim_buf_get_option(bufNr, "modified")
            if modified then unsavedChange = true; break end
        end
    end

    -- Ask for saving, return when cancel is input
    if unsavedChange then
        vim.cmd "noa echohl MoreMsg"
        answer = vim.fn.confirm("Save all modification?",
            ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        vim.cmd "noa echohl None"
        -- Interrupt
        if answer == 3 or answer == 0 then
            return
        elseif answer == 1 then
            vim.cmd "noa bufdo update"
        end
    end

    -- Close other window that doesn't contain the current buffers while
    -- Reserving windows that contain special buffer like help, quickfix
    if u.winsOccur() > 1 then
        for _, winID in ipairs(var.winIds) do
            if vim.tbl_contains(var.bufNrs, vim.api.nvim_win_get_buf(winID))
                and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(winID), "buftype") == "" then

                u.winClose(winID)
            end
        end
    end

    -- Wipe buffers
    for _, bufNr in ipairs(var.bufNrs) do
        if vim.api.nvim_buf_is_valid(bufNr) then u.bufClose(bufNr) end
    end
    if package.loaded["cokeline"] then
        require('cokeline/augroups').toggle()
    end
end -- }}}

return M
