-- File: exchange
-- Author: iaso2h
-- Description: exchange operator
-- Version: 0.0.6
-- Last Modified: 2023-05-20
require("operator")
local M = {
    _dev                 = false,
    _suppressMessage     = nil,
    _acrossLineComponent = {},

    cursorPos  = nil, -- (1, 0) indexed
    count      = nil,
    srcExtmark = {},

    -- Options
    highlightChangeChk   = true,
    ns = vim.api.nvim_create_namespace("exchange"),
    option = {RegionHighlightGroup = "IncSearch", timeout = 200}
}


--- Warn when buffer is not modifiable
---@return: return true when buffer is readonly
local warnRead = function() -- {{{
    if not vim.o.modifiable or vim.o.readonly then
        vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
        return false
    end
    return true
end -- }}}
--- Swap the text
---@param motionType string "char" or "line". Determine whether the motion is linewise
---@param bufNr integer Buffer number
local swap = function(motionType, bufNr) -- {{{
    -- (0, 0) index
    local extmark1 = vim.api.nvim_buf_get_extmark_by_id(bufNr, M.ns, M.srcExtmark[1], {details = true})
    local extmark2 = vim.api.nvim_buf_get_extmark_by_id(bufNr, M.ns, M.srcExtmark[2], {details = true})
    -- Convert region 1 and region 2 into human readable table
    local r1 = {
        Start = {extmark1[1], extmark1[2]},
        End   = {extmark1[3].end_row, extmark1[3].end_col}
    }
    local r2 = {
        Start = {extmark2[1], extmark2[2]},
        End   = {extmark2[3].end_row, extmark2[3].end_col}
    }

    if motionType == "char" then -- {{{
        -- Doesn't support overlapping exchange
        if r1.Start[1] == r2.Start[1] and
            ( (r1.Start[2] < r2.Start[2] and r1.End[2] > r2.Start[2]) or
            (r2.Start[2] < r1.Start[2] and r2.End[2] > r1.Start[2]) or
            r1.End[2] == r2.End[2] ) then
            -- Overlapping in the same line
            vim.notify("Doesn't support overlapping exchange in the same line", vim.log.levels.WARN)
            return false
        elseif (r1.Start[1] < r2.Start[1] and
                    ((r1.End[1] == r2.Start[1] and r1.End[2] > r2.Start[2]) or
                    (r1.End[1] > r2.Start[1]))
                ) or
                (r2.Start[1] < r1.Start[1] and
                    ((r2.End[1] == r1.Start[1] and r2.End[2] > r1.Start[2]) or
                    (r2.End[1] > r1.Start[1]))
                ) then
            -- Overlapping in the same line
            vim.notify("Doesn't support overlapping exchange across lines", vim.log.levels.WARN)
            return false
        end

        local srcTbl1 = vim.api.nvim_buf_get_text(bufNr, r1.Start[1], r1.Start[2], r1.End[1], r1.End[2] + 1, {})
        local srcTbl2 = vim.api.nvim_buf_get_text(bufNr, r2.Start[1], r2.Start[2], r2.End[1], r2.End[2] + 1, {})
        -- It's more intuitive to concatenate all element with a space rather than a line break
        local src1 = table.concat(srcTbl1, " ")
        local src2 = table.concat(srcTbl2, " ")

        if r1.End[1] < r2.Start[1] or r1.Start[1] > r2.End[1] then
            -- Region1 isn't across the same line number as region2 is

            local src1Prefix = vim.api.nvim_buf_get_text(bufNr, r1.Start[1], 0, r1.Start[1], r1.Start[2], {})[1]
            local src1Posfix = vim.api.nvim_buf_get_text(bufNr, r1.End[1], r1.End[2] + 1, r1.End[1], -1, {})[1]
            local src2Prefix = vim.api.nvim_buf_get_text(bufNr, r2.Start[1], 0, r2.Start[1], r2.Start[2], {})[1]
            local src2Posfix = vim.api.nvim_buf_get_text(bufNr, r2.End[1], r2.End[2] + 1, r2.End[1], -1, {})[1]
            local saveSrc1 = src1
            local saveSrc2 = src2
            src1 = src1Prefix .. saveSrc2 .. src1Posfix
            src2 = src2Prefix .. saveSrc1 .. src2Posfix
            if M.highlightChangeChk then
                vim.defer_fn(function()
                    vim.api.nvim_buf_set_lines(bufNr, r1.Start[1], r1.End[1] + 1, false, {src1})
                    vim.api.nvim_buf_set_lines(bufNr, r2.Start[1], r2.End[1] + 1, false, {src2})
                end, 500)
            else
                vim.api.nvim_buf_set_lines(bufNr, r1.Start[1], r1.End[1] + 1, false, {src1})
                vim.api.nvim_buf_set_lines(bufNr, r2.Start[1], r2.End[1] + 1, false, {src2})
            end
        else
            if r2.Start[1] < r1.Start[1] or (r1.Start[1] == r2.Start[1] and r2.Start[2] < r1.Start[2]) then
                -- Exchange the region values, so that region1 is always
                -- ahead of region2
                local saveRegion1 = vim.deepcopy(r1)
                local saveRegion2 = vim.deepcopy(r2)
                local saveSrc1 = src1
                local saveSrc2 = src2
                r1 = saveRegion2
                r2 = saveRegion1
                src1 = saveSrc2
                src2 = saveSrc1
            end

            -- Assuming region1 is ahead of region2
            local prefix = vim.api.nvim_buf_get_text(bufNr, r1.Start[1], 0, r1.Start[1], r1.Start[2], {})[1]
            local posfix = vim.api.nvim_buf_get_text(bufNr, r2.End[1], r2.End[2] + 1, r2.End[1], -1, {})[1]
            local middle = vim.api.nvim_buf_get_text(bufNr, r1.End[1], r1.End[2] + 1, r2.Start[1], r2.Start[2], {})[1]
            if M._dev then
                M._acrossLineComponent.srcAhead  = src1
                M._acrossLineComponent.srcBehind = src2
                M._acrossLineComponent.prefix    = prefix
                M._acrossLineComponent.posfix    = posfix
                M._acrossLineComponent.middle    = middle
            end
            -- Print{prefix, src2, middle, src1, posfix}
            local src = prefix .. src2 .. middle .. src1 .. posfix
            if M.highlightChangeChk then
                vim.defer_fn(function()
                    vim.api.nvim_buf_set_lines(bufNr, r1.Start[1], r2.End[1] + 1, false, {src})
                end, 500)
            else
                vim.api.nvim_buf_set_lines(bufNr, r1.Start[1], r2.End[1] + 1, false, {src})
            end
        end
        -- }}}
    else

    end
end -- }}}
--- This function will be called when g@ is evaluated by Neovim
---@class GenericOperatorInfo
---@param args GenericOperatorInfo
function _G._exchangeOperator(args) -- {{{
    if not warnRead() then return end
    -- NOTE: see ":help g@" for details about motionType
    local bufNr = vim.api.nvim_get_current_buf()
    local motionType
    local vimMode
    local plugMap
    local regionMotion
    if type(args) ~= "table" then
        -- For exchange operator exclusively

        motionType = args
        -- TODO: necessity of implementing line motion???
        if motionType == "line" then return end
        vimMode = "n"
        -- Saving cursor part is done inside expr()
        -- Saving motion region
        regionMotion = {
            Start = vim.api.nvim_buf_get_mark(bufNr, "["),
            End   = vim.api.nvim_buf_get_mark(bufNr, "]")
        }
        if vim.deep_equal(regionMotion.Start, regionMotion.End) then
            local endLine = vim.api.nvim_buf_get_lines(bufNr, regionMotion.End[1] - 1, regionMotion.End[1], false)[1]
            if string.len(endLine) ~= vim.fn.strchars(endLine) then

                local saveCursor = vim.api.nvim_win_get_cursor(0)
                vim.cmd[[noa norm! l]]
                local endCharByteIdx = vim.api.nvim_win_get_cursor(0)[2] - 1
                regionMotion.End[2] = endCharByteIdx
                vim.api.nvim_win_set_cursor(0, saveCursor)
            end
        end
        plugMap = "<Plug>exchangeOperatorInplace"
    end
    local regionRegType = motionType:sub(1, 1) == "c" and "v" or "V"

    -- Change to 0-based for extmark creation
    if regionRegType == "V" then
        regionMotion.Start = { regionMotion.Start[1] - 1, 0 }
        local endLine = vim.api.nvim_buf_get_lines(bufNr, regionMotion.End[1] - 1, regionMotion.End[1], false)[1]
        regionMotion.End = {regionMotion.End[1] - 1, #endLine - 1}
    else
        regionMotion.Start = {regionMotion.Start[1] - 1, regionMotion.Start[2]}
        regionMotion.End   = {regionMotion.End[1] - 1, regionMotion.End[2]}
    end

    -- Create extmark
    local ok, valOrMsg = pcall(vim.api.nvim_buf_set_extmark, bufNr, M.ns,
        regionMotion.Start[1], regionMotion.Start[2], {end_line = regionMotion.End[1], end_col = regionMotion.End[2]})
    -- End function calling if extmark is out of scope
    if not ok then
        vim.notify(valOrMsg, vim.log.levels.WARN)
        return
    else
        M.srcExtmark[#M.srcExtmark+1] = valOrMsg
    end

    -- Add highlight
    if M.highlightChangeChk then
        local region = vim.region(bufNr, regionMotion.Start, regionMotion.End, regionRegType,
                vim.o.selection == "inclusive" and true or false)
        for lineNr, cols in pairs(region) do
            vim.api.nvim_buf_add_highlight(bufNr, M.ns, M.option.RegionHighlightGroup, lineNr, cols[1], cols[2])
        end
    end

    if #M.srcExtmark == 2 then
        ok, valOrMsg = pcall(swap, motionType, bufNr)
        if not ok then
            vim.notify(valOrMsg, vim.log.levels.ERROR)
        end

        if M.highlightChangeChk then
            vim.defer_fn(function()
                pcall(vim.api.nvim_buf_clear_namespace, bufNr, M.ns, 0, -1)
            end, 500)
        else
            pcall(vim.api.nvim_buf_clear_namespace, bufNr, M.ns, 0, -1)
        end
        M.srcExtmark = {}
    end

    -- Restoration
    if vimMode == "n" then
        if not M.cursorPos then
            -- TODO: Supported cursor recall in normal mode
        else
            vim.api.nvim_win_set_cursor(0, M.cursorPos)
            -- Reset
            M.cursorPos = nil
        end
    end
    do return end

    -- Mapping repeating
    if vimMode ~= "n" then
        vim.fn["repeat#setreg"](t(plugMap), M.regName)
    end

    if #args == 4 then
        -- ExchangeCurLine
        vim.fn["repeat#set"](t(plugMap), M.count)
    end
end -- }}}
---Callback function of `vim.o.opfunc`
---@param func    function
---@param plugMap string
---@return string "g@" if successful
function M.expr(func, plugMap) -- {{{
    _G._opfunc   = func
    M.plugMap    = plugMap
    M.cursorPos  = vim.api.nvim_win_get_cursor(0)
    vim.o.opfunc = "v:lua._exchangeOperator"
    return "g@"
end -- }}}
--- Clear the highlight
function M.clear() -- {{{
    local bufNr = vim.api.nvim_get_current_buf()
    pcall(vim.api.nvim_buf_clear_namespace, bufNr, M.ns, 0, -1)
    M.srcExtmark = {}
end -- }}}


return M
