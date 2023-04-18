-- File: cursorRecall
-- Author: iaso2h
-- Description: Derived from and simplified:
-- Credit: https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
-- Version: 0.0.3
-- Last Modified: 2023-3-2

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
local api = vim.api
local M   = {}


function M.main(args)
    -- Only handle valid file
    if not args or args.file == "*" then
        return
    end

    -- Only deal with situation where curpos is placed at {1, 0}
    local cursorPos = api.nvim_win_get_cursor(0)
    if cursorPos[1] ~= 1 and cursorPos[2] ~= 0 then
        return
    end

    -- Check filetype and buftype against ignore lists
    if vim.tbl_contains(ignoreBuftype, vim.bo.buftype) or vim.tbl_contains(ignoreFiletype, vim.bo.filetype) then
        return
    end

    -- Do nothing if file does not exist on disk
    if not vim.loop.fs_stat(fn.expand("%:p")) then
        return
    end

    local lastpos  = fn.line('`"')
    local buffend  = fn.line('$')

    if lastpos > 0 and lastpos <= buffend then
        local winend   = fn.line('w$')
        local winstart = fn.line('w0')
        -- Last edit pos is set and is less than the number of lines in this buffer
        if winend == buffend then
            -- Last line in buffer is also the last line visible in this window
            vim.cmd 'normal! g`"'
        elseif buffend - lastpos > ((winend - winstart) / 2) - 1 then
            vim.cmd 'normal! g`"zz'
        else
            -- Otherwise, show as much context as we can
            vim.cmd('normal! G`"' .. t'<c-e>')
        end
    else
        -- Jump to recent last change instead
        if vim.api.nvim_win_get_cursor(0)[1] == 1 then
            require("searchHop").centerHop("g,", true)
        end
    end

    if fn.foldclosed('.') ~= -1 then
        -- Cursor was inside a fold; open it
        vim.cmd 'normal! zvzz'
    end


end

return M

