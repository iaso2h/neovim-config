-- File: cursorRecall
-- Author: iaso2h
-- Description: Derived from and simplified:
-- Credit: https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
-- Version: 0.0.8
-- Last Modified: 2023-10-21

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
local log = function(...)
    if _G._cursor_recall_dev then
        logBuf(...)
    end
end


--- Recall the cursor position
---@param args table Argument from calling a Neovim command
return function(args)
    -- Only handle valid file
    if not args or args.file == "*" then
        log('DEBUGPRINT[1]: cursorRecall.lua:31 (after end)')
        return
    end

    -- Do nothing if the buffer is listed and loaded
    local bufNr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_loaded(bufNr) and not vim.api.nvim_buf_get_option(bufNr, "bufhidden") then
        log('DEBUGPRINT[2]: cursorRecall.lua:38 (after end)')
        return
    end

    -- Only deal with situation where curpos is placed at {1, 0}
    local cursorPos = vim.api.nvim_win_get_cursor(0)
    if cursorPos[1] ~= 1 then
        log('DEBUGPRINT[3]: cursorRecall.lua:45 (after end)')
        return
    end

    -- Check filetype and buftype against ignore lists
    if vim.tbl_contains(ignoreBuftype, vim.bo.buftype) or vim.tbl_contains(ignoreFiletype, vim.bo.filetype) then
        log('DEBUGPRINT[4]: cursorRecall.lua:51 (after end)')
        return
    end

    -- Do nothing if file does not exist on disk
    if not vim.loop.fs_stat(vim.api.nvim_buf_get_name(bufNr)) then
        log('DEBUGPRINT[5]: cursorRecall.lua:57 (after end)')
        return
    end

    local lastPos = vim.fn.line('`"')
    local bufEnd  = vim.api.nvim_buf_line_count(bufNr)

    if lastPos > 0 and lastPos <= bufEnd then
        local winEnd   = vim.fn.line('w$')
        local winStart = vim.fn.line('w0')
        -- Last edit pos is set and is less than the number of lines in this buffer
        if winEnd == bufEnd then
            log('DEBUGPRINT[6]: cursorRecall.lua:69 (after if winend == buffend then)')
            -- Last line in buffer is also the last line visible in this window
            vim.cmd 'normal! g`"'
        elseif bufEnd - lastPos > ((winEnd - winStart) / 2) - 1 then
            log('DEBUGPRINT[7]: cursorRecall.lua:73 (after elseif buffend - lastpos > ((winend - wi…)')
            vim.cmd 'normal! g`"zz'
        else
            log('DEBUGPRINT[8]: cursorRecall.lua:76 (after else)')
            -- Otherwise, show as much context as we can
            vim.cmd('normal! G`"' .. t'<c-e>')
        end
    else
        -- Jump to recent last change instead
        if vim.api.nvim_win_get_cursor(0)[1] == 1 then
            -- Go to the newest change first then the older one
            local jumpUtil = require("jump.util")
            local changesCmdRaw = jumpUtil.getJumpsCmd("changes", false)
            if #changesCmdRaw == 2 then
                -- It's a newfile with no changelist or it's already at newest change
                return
            else
                local cmdIdx = jumpUtil.getJumpCmdIdx(changesCmdRaw)
                local newestRecord
                if cmdIdx == #changesCmdRaw and
                    not next(jumpUtil.jumpCmdParse(changesCmdRaw[#changesCmdRaw])) then
                    -- Empty change record like:
                    --     4    93    0 not next(jumpUtil.jumpCmdParse(changesCmdRaw[#changesCmdRaw])) then
                    --     3    96    0 local newestChangeCmd = jumpUtil.jumpCmdParse(changesCmdRaw[#changesCmdRaw - 1])
                    --     2    95    0
                    --     1    94   47 -- Empty change record like:
                    -- >
                    newestRecord = jumpUtil.jumpCmdParse(changesCmdRaw[#changesCmdRaw - 1])
                else
                    newestRecord = jumpUtil.jumpCmdParse(changesCmdRaw[#changesCmdRaw])
                end

                if newestRecord.text == "-invalid-" then
                    -- Sometimes file will be modified by external editor while the
                    -- change record within neovim become outdated, which will
                    -- incur problems like line number doesn't match up
                    return
                else
                    local cmdStr = string.format("norm! %s%s", newestRecord.count, "g,")
                    local ok, msgOrVal = pcall(vim.api.nvim_command, cmdStr)
                    if not ok then
                        vim.notify(msgOrVal, vim.log.levels.ERROR)
                        vim.notify("Error occurred when executing command: " .. cmdStr, vim.log.levels.ERROR)
                    end
                end
            end
        end
    end

    if vim.fn.foldclosed('.') ~= -1 then
        log("DEBUGPRINT[11]: cursorRecall.lua:93 (after if not ok then)")
        -- Cursor was inside a fold; open it
        vim.cmd 'normal! zv'
    end
end
