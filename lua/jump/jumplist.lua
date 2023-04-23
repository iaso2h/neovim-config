-- File: jumplist
-- Author: iaso2h
-- Description: Enhance <C-i>/<C-o>
-- Version: 0.0.9
-- Last Modified: 2023-4-24

local defaultOpts  = {
    checkCursorRedundancy = true,
    returnAllJumps = false -- DEBUG: tests only
}

local jumpUtil = require("jump.util")

local M = {
    _CUR_IDX_OFFSET = 2,
    _ITEM_IDX_OFFSET = 1,
    visualMode = "",
    opts = defaultOpts
}

--- Echo info in the cmdline when there's no available jump
---@param isNewer boolean
---@param filter string "local"|"buffer"
local overJumpInfo = function(isNewer, filter) -- {{{
    local directionStr = isNewer and "newer" or "older"
    vim.notify(
        string.format("Cannot jump to any %s place in the %s jumplist",
            directionStr, filter), vim.log.levels.INFO)
end -- }}}

--- Get the filtered out jumplist so that is ready to filter out and decide to perform a local jump or buffer jump
---@param isNewer boolean
---@param winId number
---@param filter string "local"|"buffer"
---@return table
M.getJumps = function(isNewer, winId, filter) -- {{{
    -- Get jumps from ex-command :jumps
    local jumpsCmdRaw = jumpUtil.getJumpsTbl()
    local jumpsCmd = vim.tbl_map(function(jumpCmdRaw)
        return jumpUtil.jumplistParse(jumpCmdRaw, M.opts.returnAllJumps)
    end, jumpsCmdRaw)

    -- Get jumps from built-in function
    local jumpsList   = vim.fn.getjumplist(winId)
    local jumpsIdx    = jumpsList[2]
    local jumps       = jumpsList[1]
    local jumpsSliced = {}
    if jumpsIdx == 0 then
        vim.notify("Jumplist is empty", vim.log.levels.INFO)
        return jumpsSliced
    end

    -- Use offset addition to get `CmdIdx` to improve performance even though
    -- it's more intuitive to capture it by looping through `jumpsCmdRaw`
    -- local CmdRawIdx = jumpUtil.getJumpCmdIdx(jumpsCmdRaw)
    local CmdIdx = jumpsIdx + M._CUR_IDX_OFFSET -- Concluded by test results


    -- Get the sliced jumps
    -- Loop through `jumpsCmd` instead of `jumps` because it's more intuitive
    if isNewer then
        if CmdIdx ~= #jumpsCmd then
            for i = CmdIdx + 1, #jumpsCmd - 1, 1 do
                jumps[i - M._ITEM_IDX_OFFSET].count = jumpsCmd[i].count
                jumpsSliced[#jumpsSliced+1] = jumps[i - M._ITEM_IDX_OFFSET]
            end
        else
            overJumpInfo(isNewer, filter)
        end
    else
        if CmdIdx ~= 2 then
            -- Reverse the table so that it's ready to get target jump
            for i = CmdIdx - 1, 2, -1 do
                -- Print("-------------")
                -- print('DEBUGPRINT[1]: jumplist.lua:75: i=' .. vim.inspect(i))
                -- -- HACK: there're some senarios where `i` can be out of scope
                -- if not jumps[i - M._ITEM_IDX_OFFSET] or jumpsCmd[i] then
                --     logBuf('DEBUGPRINT[4]: jumplist.lua:79: i=' .. vim.inspect(i))
                --     logBuf('DEBUGPRINT[1]: jumplist.lua:73: CmdIdx=' .. vim.inspect(CmdIdx))
                --     logBuf('DEBUGPRINT[1]: jumplist.lua:79: jumps[i - M._ITEM_IDX_OFFSET]=' .. vim.inspect(jumps[i - M._ITEM_IDX_OFFSET]))
                --     logBuf('DEBUGPRINT[1]: jumplist.lua:79: jumpsCmd[i]=' .. vim.inspect(jumpsCmd[i]))
                --     logBuf('DEBUGPRINT[1]: jumplist.lua:76: #jumps=' .. vim.inspect(#jumps))
                --     logBuf('DEBUGPRINT[2]: jumplist.lua:77: #jumpsCmd=' .. vim.inspect(#jumpsCmd))
                --     logBuf('DEBUGPRINT[2]: jumplist.lua:79: jumpsCmd=' .. vim.inspect(jumpsCmd))
                --     logBuf('DEBUGPRINT[1]: jumplist.lua:79: jumps=' .. vim.inspect(jumps))
                --     break
                -- end
                if next(jumpsCmd[i]) then
                    jumps[i - M._ITEM_IDX_OFFSET].count = jumpsCmd[i].count
                    if M.opts.returnAllJumps then
                        jumps[i - M._ITEM_IDX_OFFSET].text = jumpsCmd[i].text
                    end
                    jumpsSliced[#jumpsSliced + 1] = jumps[i - M._ITEM_IDX_OFFSET]
                end
            end
        else
            overJumpInfo(isNewer, filter)
        end
    end

    return jumpsSliced
end -- }}}


---@param bufNr number
---@param jumps table
---@param filter string "local"|"buffer"
---@param cursorPos table (1, 0) based. If target and cursor are on the same line in local filter, that target jump will be discard. Set it to empty table to turn off this behavior
---@return table,table
local filterJumps = function(bufNr, jumps, filter, cursorPos)
    -- jumps = M.jumpsDummy
    local filterFunc = function(jump)
        -- Remove redandunt `jumps` that have the same line number as
        -- `cursorPos` does
        if filter == "local" and cursorPos and jump.lnum == cursorPos[1] then
            return false
        end

        -- Filter by buffer number
        if jump.bufnr == bufNr then
            if filter == "local" then
                return true
            else
                return false
            end
        else
            if filter == "local" then
                return false
            else
                return true
            end
        end
    end

    local jumpsFiltered = {}
    local jumpsDiscarded = {}
    for _, jump in ipairs(jumps) do
        if filterFunc(jump) then
            jumpsFiltered[#jumpsFiltered+1] = jump
        else
            if M.opts.returnAllJumps then
                jumpsDiscarded[#jumpsDiscarded+1] = jump
            end
        end

        -- Break the loop here to improve performance
        if not M.opts.returnAllJumps and #jumpsFiltered == vim.v.count1 + 1 then
            break
        end
    end

    if M.opts.returnAllJumps then
        return jumpsDiscarded, jumpsFiltered
    else
        return {}, jumpsFiltered
    end
end


---@param filter string "local"|"buffer"
M.go = function(vimMode, isNewer, filter)
    local bufNr     = vim.api.nvim_get_current_buf()
    local winId     = vim.api.nvim_get_current_win()
    local cursorPos = M.opts.checkCursorRedundancy and vim.api.nvim_win_get_cursor(winId) or {}

    -- Get the jumps table and reordered them
    local jumpsSliced = M.getJumps(isNewer, winId, filter)

    -- Get the parsed and filtered jumps table
    local jumpsDiscarded, jumpsFiltered = filterJumps(bufNr, jumpsSliced, filter, cursorPos)
    if not next(jumpsFiltered) then
        return overJumpInfo(isNewer, filter)
    end

    -- DEBUG: tests only
    if M.opts.returnAllJumps then
        M.opts.returnAllJumps = false
        return jumpsSliced, jumpsDiscarded, jumpsFiltered
    end

    -- Get the target jump, then execute the built-in command
    local count = vim.v.count1 > #jumpsFiltered and #jumpsFiltered or vim.v.count1
    local targetJump = jumpsFiltered[count]
    local exCMD = isNewer and t"<C-i>" or t"<C-o>"
    if vimMode ~= "n" then
        local visualCMD = "v" ~= string.lower(vimMode) and t"<C-q>" or vimMode
        vim.cmd(string.format("norm! %s%s%s", t"<Esc>", targetJump.count, exCMD))
        local posCursor = vim.api.nvim_win_get_cursor(winId)
        vim.api.nvim_win_set_cursor(winId, cursorPos)
        vim.cmd("noa norm! " .. visualCMD)
        vim.api.nvim_win_set_cursor(winId, posCursor)
    else
        vim.cmd(string.format("norm! %s%s", targetJump.count, exCMD))
    end

    -- Post processing
    if filter == "local" then
        local posBufNr = vim.api.nvim_get_current_buf()
        if posBufNr ~= bufNr then
            vim.notify("Failed to perform a correct local jump", vim.log.levels.ERROR)
            vim.print(targetJump)
        end
    end

    -- TODO:echo the next jump?
end


M.setup = function(opts)
    opts = opts or defaultOpts
    M.opts = vim.tbl_deep_extend("keep", opts, defaultOpts)
end

return M
