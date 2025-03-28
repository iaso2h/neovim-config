-- File: jumplist
-- Author: iaso2h
-- Description: Enhance <C-i>/<C-o>
-- Version: 0.0.15
-- Last Modified: 2023-10-03

local defaultOpts  = {
    checkCursorRedundancy = true,
    returnAllJumps = false, -- DEBUG: tests only
    jumpBetweenLoadedBuffersOnly = false,
    fileTypeUseBuiltIn = {
        "help",
        "HistoryStartup"
    }
}

local jumpUtil = require("jump.util")

local M = {
    _ITEM_IDX_OFFSET = 1,
    _CMD_THRESHOLD = 50,
    visualMode = "",
    opts = defaultOpts
}


--- Echo info in the cmdline when there's no available jump
---@param isNewer boolean
---@param filter string "local"|"buffer"
local overJumpInfo = function(isNewer, filter) -- {{{
    local directionStr = isNewer and "newer" or "older"
    vim.api.nvim_echo(
        {
            {
                string.format(
                    "Cannot jump to any %s place in the %s jumplist",
                    directionStr,
                    filter
                )
            }
        },
        true
    )
end -- }}}
---@param isNewer boolean Whether jump to newer position
---@param filter string "local"|"buffer"
---@param CmdIdx integer
---@param jumpsCmdRaw table
---@param jumpIdx? integer
---@param jumps? table
---@return table
local getJumpsSliced = function(isNewer, filter, CmdIdx, jumpsCmdRaw, jumpIdx, jumps) -- {{{
    local jumpsSliced = {}
    local cmdStart
    local cmdEnd
    local jumpStart
    local jumpEnd
    local step
    local offset = 0
    if jumpIdx and jumps then
        offset = CmdIdx - jumpIdx
    end

    if isNewer then
        if CmdIdx == #jumpsCmdRaw then
            overJumpInfo(isNewer, filter)
            return jumpsSliced
        end
        cmdStart = CmdIdx + 1
        -- Check the last element in jumpsCmd is properly parsed in previous
        -- stage
        cmdEnd  = jumpsCmdRaw[#jumpsCmdRaw] == "" and #jumpsCmdRaw - 1 or #jumpsCmdRaw
        jumpEnd = #jumps
        step    = 1
    else
        -- Ignoring the header(cmdidx == 1)
        if CmdIdx == 2 then
            overJumpInfo(isNewer, filter)
            return jumpsSliced
        end
        cmdStart = CmdIdx - 1
        cmdEnd   = 2
        jumpEnd  = 1
        step     = -1
    end

    -- Loop through the `jumpsCmd` and align the element with `jumps`, then
    -- reorder and slice the jumps

    -- The starting index, ending index and step varies depending on the `filter`
    -- value, hence looping in different direction to reorder the jumpsCmd
    for i = cmdStart, cmdEnd, step do
        local jumpCmd = jumpUtil.jumpCmdParse(jumpsCmdRaw[i])

        if jumpIdx and jumps then
            -- Loop the jumps in the the same direction to match the the same
            -- value of lnum and col, hence aligning the data
            jumpStart = i - offset + 1
            for x = jumpStart, jumpEnd, step do
                local jump = jumps[x]
                -- UGLY: Sometime `vim.fn.getjumplist()[1]` will contain some
                -- items come with invalid bufnr and insert them for no reason
                -- Probably because the prompt window when invoking the `:jumps`
                -- command?
                -- OPTIM: filter jump table on the fly to improve performance
                if vim.api.nvim_buf_is_valid(jump.bufnr) and
                        jump.col == jumpCmd.col and
                        jump.lnum == jumpCmd.lnum then

                    jump.count = jumpCmd.count
                    jumpsSliced[#jumpsSliced+1] = jump
                    break
                end
            end
        else
            local jump = {}
            jump.lnum  = jumpCmd.lnum
            jump.col   = jumpCmd.col
            jumpsSliced[#jumpsSliced+1] = jump
        end
    end

    if not next(jumpsSliced) then
        vim.api.nvim_echo({{"Failed to get the sliced jumps",}}, true, {err=true})
    end

    return jumpsSliced
end -- }}}
--- Get the filtered out jumplist so that is ready to filter out and decide to perform a local jump or buffer jump
---@param isNewer boolean Whether jump to newer position
---@param winId integer Window ID
---@param filter string "local"|"buffer"
---@return table
local getJumps = function(isNewer, winId, filter) -- {{{
    -- Get jumps from built-in function
    local jumps, jumpIdx = unpack(vim.fn.getjumplist(winId))
    local jumpsSliced = {}
    if #jumps == 0 then
        vim.api.nvim_echo({{"Jumplist is empty"}}, true)
        return jumpsSliced
    end

    -- Get jumps from ex-command :jumps
    local jumpsCmdRaw = jumpUtil.getJumpsCmd("jumps", false)

    local CmdIdx = jumpUtil.getJumpCmdIdx(jumpsCmdRaw)
    if CmdIdx == 0 then
        vim.api.nvim_echo({{"Can't find current index",}}, true, {err=true})
        return jumpsSliced
    end

    -- local jumpCmd = jumpsCmd[CmdIdx] -- Test {{{
    -- local jump    = jumps[jumpIdx]
    -- logBuf('DEBUGPRINT[1]: jumplist.lua:129: jumpsIdx=' .. vim.inspect(jumpIdx))
    -- logBuf('DEBUGPRINT[2]: jumplist.lua:130: CmdIdx=' .. vim.inspect(CmdIdx))
    -- logBuf('DEBUGPRINT[3]: jumplist.lua:128: jump=' .. vim.inspect(jump))
    -- logBuf('DEBUGPRINT[4]: jumplist.lua:127: jumpCmd=' .. vim.inspect(jumpCmd))
    -- logBuf('DEBUGPRINT[5]: jumplist.lua:128: #jumps=' .. vim.inspect(#jumps))
    -- logBuf('DEBUGPRINT[6]: jumplist.lua:127: #jumpsCmd=' .. vim.inspect(#jumpsCmd))
    -- logBuf('DEBUGPRINT[5]: jumplist.lua:128: jumps=' .. vim.inspect(jumps))
    -- logBuf('DEBUGPRINT[6]: jumplist.lua:127: jumpsCmd=' .. vim.inspect(jumpsCmd))
    -- do return jumpsSliced end -- }}} Test

    -- Get the sliced jumps
    -- Loop through `jumpsCmd` instead of `jumps` because it's more intuitive
    jumpsSliced = getJumpsSliced(isNewer, filter, CmdIdx, jumpsCmdRaw, jumpIdx, jumps)

    return jumpsSliced
end -- }}}
---@param bufNr integer Buffer number
---@param jumps table
---@param filter string "local"|"buffer"
---@param cursorPos table (1, 0) based. If target and cursor are on the same line in local filter, that target jump will be discard. Set it to empty table to turn off this behavior
---@return table,table
local filterJumps = function(bufNr, jumps, filter, cursorPos) -- {{{
    -- jumps = M.jumpsDummy
    local filterFunc = function(jump)
        -- Remove redandunt `jumps` that have the same line number as
        -- `cursorPos` does
        if filter == "local" and cursorPos and jump.lnum == cursorPos[1] then
            return false
        end

        if filter == "buffer" and M.opts.jumpBetweenLoadedBuffersOnly and
            not (vim.api.nvim_buf_is_loaded(jump.bufnr)) then
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
end -- }}}
--- Execute the ex-command and start jumping
---@param vimMode string "v" or "n" to indicate Neovim mode
---@param isNewer boolean Whether jump to newer position
---@param winId integer
---@param cursorPos table (1, 0) based
---@param jumpsFiltered? table
---@return integer The count number of target jump
local execute = function(vimMode, isNewer, winId, cursorPos, jumpsFiltered) -- {{{
    -- Get the target jump, then execute the built-in command
    local count
    if type(jumpsFiltered) == "table" then
        count = vim.v.count1 > #jumpsFiltered and #jumpsFiltered or vim.v.count1
        local targetJump = jumpsFiltered[count]
        count = tonumber(targetJump.count)
    else
        count = vim.v.count1
    end
    local exCmd = isNewer and t"<C-i>" or t"<C-o>"
    if type(jumpsFiltered) == "table" and vimMode ~= "n" then
        local visualCMD = "v" ~= string.lower(vimMode) and t"<C-q>" or vimMode
        vim.cmd(string.format("norm! %s%s%s", t"<Esc>", count, exCmd))
        local posCursor = vim.api.nvim_win_get_cursor(winId)
        vim.api.nvim_win_set_cursor(winId, cursorPos)
        vim.cmd("noa norm! " .. visualCMD)
        vim.api.nvim_win_set_cursor(winId, posCursor)
    else
        vim.cmd(string.format("norm! %s%s", count, exCmd))
    end

    return count
end -- }}}
--- Handler of vimMode, direction and filter
---@param vimMode string "v" or "n" to indicate Neovim mode
---@param isNewer boolean Whether jump to newer position
---@param filter string "local"|"buffer"
M.go = function(vimMode, isNewer, filter) -- {{{
    local bufNr     = vim.api.nvim_get_current_buf()
    local winId     = vim.api.nvim_get_current_win()
    local cursorPos = M.opts.checkCursorRedundancy and vim.api.nvim_win_get_cursor(winId) or {}
    -- Buffer that has the filetype matching the patterns in
    -- `M.opts.fileTypeUseBuiltIn` will always execute and built-in command
    if vim.list_contains(M.opts.fileTypeUseBuiltIn, vim.bo.filetype) then
        return execute(vimMode, isNewer, winId, cursorPos)
    end

    -- Get the jumps table and reordered them
    local jumpsSliced = M.getJumps(isNewer, winId, filter)
    if not next(jumpsSliced) then
        return
    end

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

    local targetCount = execute(vimMode, isNewer, winId, cursorPos, jumpsFiltered)

    -- Post processing
    if filter == "local" then
        local posBufNr = vim.api.nvim_get_current_buf()
        if posBufNr ~= bufNr then
            vim.api.nvim_echo({{"Failed to perform a correct local jump",}}, true, {err=true})
            vim.print(jumpsSliced[targetCount])
        end
    end

    -- TODO:echo the next jump?
end -- }}}
--- Set up plug-in configuration
---@param opts table
M.setup = function(opts) -- {{{
    opts = opts or defaultOpts
    M.opts = vim.tbl_deep_extend("keep", opts, defaultOpts)
end -- }}}


-- Exposed API
M.getJumpsSliced = getJumpsSliced
M.getJumps = getJumps


return M
