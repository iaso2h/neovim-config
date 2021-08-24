-- File: cursorRecall
-- Author: iaso2h
-- Description: Derived from and simplified:
    -- https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
-- Version: 0.0.1
-- Last Modified: 2021-04-09

local ignoreBuftype = {
        'quickfix',
        'nofile',
        'help',
}
local ignoreFiletype = {
        'gitcommit',
        'gitrebase',
        'svn',
        'hgcommit',
}
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}


function M.main()

    -- Check filetype and buftype against ignore lists
    if vim.tbl_contains(ignoreBuftype, vim.bo.buftype) or vim.tbl_contains(ignoreFiletype, vim.bo.filetype) then
        return
    end

    -- Do nothing if file does not exist on disk
    if fn.empty(fn.glob("@%")) == 0 then
        return
    end
    local lastpos  = fn.line("'\"")
    local buffend  = fn.line('$')
    local winend   = fn.line('w$')
    local winstart = fn.line('w0')

    if lastpos > 0 and lastpos <= buffend then
        -- Last edit pos is set and is < no of lines in buffer
        if winend == buffend then
            -- Last line in buffer is also last line visible
            cmd 'normal! g`"'
        elseif buffend - lastpos > ((winend - winstart) / 2) - 1 then
            -- Center cursor on screen if not at bottom
            cmd 'normal! g`"zz'
        else
            -- Otherwise, show as much context as we can
            cmd "normal! \\G'\"\\<c-e>"
        end
    end

    if fn.foldclosed('.') ~= -1 then
        -- Cursor was inside a fold; open it
        cmd 'normal! zA'
    end
end

return M

