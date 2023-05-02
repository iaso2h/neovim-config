local M = {}
local var = require("buffer.var")


--- Gather information about buffers and windows for further processing
M.initBuf = function()
    var.bufNr    = vim.api.nvim_get_current_buf()
    var.bufNrs   = M.bufNrs(true, false)
    var.bufName  = nvim_buf_get_name(var.bufNr)
    var.bufType  = vim.bo.buftype
    var.fileType = vim.bo.filetype
    var.winId    = vim.api.nvim_get_current_win()
    var.winIds   = M.winIds(false)
end


--- Check if the provided buffer is a special buffer
---@param bufNr? number If it isn't provided, the `var.bufNr` will be used
---@return boolean
M.isSpecialBuf = function(bufNr) -- {{{
    bufNr = bufNr or var.bufNr
    local bufType    = vim.api.nvim_buf_get_option(bufNr, "buftype")
    local modifiable = vim.api.nvim_buf_get_option(bufNr, "modifiable")
    return bufType ~= "" and not modifiable
end -- }}}
--- Check if the provided buffer is a scratch buffer
---@param bufNr? number If it isn't provided, the `var.bufName` will be used instead
---@return boolean
M.isScratchBuf = function(bufNr) -- {{{
    if not bufNr then
        return var.bufName == ""
    else
        return nvim_buf_get_name(bufNr) == ""
    end
end -- }}}
--- Force wipe the given buffer, if no bufNr is provided, then current buffer
--- will be wiped
---@param bufNr? number If it isn't provided, the `var.bufNr` will be used instead
---@param switchBeforeClose? boolean Default is false. Set it to true to
--switch all the buffer instance in all windows to an alternative buffer in
--advance before closing up the buffer entirely
M.bufClose = function(bufNr, switchBeforeClose) -- {{{
    bufNr = bufNr or var.bufNr

    if switchBeforeClose then
        if var.winIds then
            for _, winId in ipairs(var.winIds) do
                if vim.api.nvim_win_get_buf(winId) == bufNr then
                    M.bufSwitchAlter(winId)
                end
            end
        else
            return vim.notify([[`require("buffer.var").winIds` isn't initialized]], vim.log.levels.ERROR)
        end
    end
    local ok, msg = pcall(vim.api.nvim_command, "bdelete! " .. bufNr)
    if not ok then
        vim.notify(msg, vim.log.levels.ERROR)
    end
    -- `:bdelete` will register in both the jumplist and the changelist
    -- These two don't register in both the changelist and the changelist
    -- pcall(vim.api.nvim_command, "keepjump bwipe! " .. bufNr)
    -- pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end -- }}}
--- Function wrapped around the vim.api.nvim_list_bufs(). Produce result just
--like you type `:ls` in Neovim commandline
---@param listedOnly? boolean Whether contains listed buffers only. This
--argument will overide the `loadedOnly` if it's set to true, because listed
--buffer is also loaded
---@param loadedOnly? boolean Whether contains loaded buffers only
---@return table
M.bufNrs = function(listedOnly, loadedOnly) -- {{{
    local rawBufNrs = vim.api.nvim_list_bufs()
    local cond = function(bufNr)
        if listedOnly then
            return vim.api.nvim_buf_is_loaded(bufNr) and
                vim.api.nvim_buf_get_option(bufNr, "buflisted")
        else
            if loadedOnly then
                return vim.api.nvim_buf_is_loaded(bufNr)
            else
                return true
            end
        end
    end

    return vim.tbl_filter(cond, rawBufNrs)
end -- }}}
--- Switch to alternative buffer or previous buffer before wiping current buffer
---@param winId? number Window ID in which the buffer nest will be switch to
--an alternative buffer. Default is var.winId if no window ID provided
M.bufSwitchAlter = function(winId) -- {{{
    winId = winId or var.winId
    ---@diagnostic disable-next-line: param-type-mismatch
    local altBufNr = vim.fn.bufnr("#")
    if altBufNr ~= var.bufNr and
        vim.api.nvim_buf_get_option(altBufNr, "buflisted") and
        M.isSpecialBuf(altBufNr) then

        return vim.api.nvim_win_set_buf(winId, altBufNr)
    else
        -- Fallback method
        local bufNrs = var.bufNrs and var.bufNrs or M.bufNrs(true, false)
        for _, bufNr in ipairs(bufNrs) do
            if bufNr ~= var.bufNr and not M.isSpecialBuf(bufNr) then
                return vim.api.nvim_win_set_buf(winId, bufNr)
            end
        end
    end

    vim.notify("Failed to switch alternative buffer in Windows: " .. winId, vim.log.ERROR)
end -- }}}
--- Check how many times the specified buffer occurs in all windows
---@param bufNr? number If it isn't provided, the `var.bufNr` will be used
--instead
---@param winIds? table If it isn't provided, the `var.bufNr` will be used
--instead
---@return number,table How many same provided buffer instances display in
--other windows and the window IDs that contain the provided buffer Note that
--the function will always take the current window into account
M.bufOccurInWins = function(bufNr, winIds) -- {{{
    bufNr  = bufNr  or var.bufNr
    winIds = winIds or var.winIds
    local bufCnt = 0
    local winIds = {}
    for _, winId in ipairs(var.winIds) do
        if bufNr == vim.api.nvim_win_get_buf(winId) then
            bufCnt = bufCnt + 1
            winIds[#winIds+1] = winId
        end
    end

    return bufCnt, winIds
end -- }}}
--- Check how many buffers in the specified buffer table occur in the
--specified window table
---@param bufNrs? table If it isn't provided, the `var.bufNrs` will be used
--instead
---@param winIds? table If it isn't provided, the `var.bufNr` will be used
--instead
---@return number The occurrence number
M.bufsOccurInWins = function(bufNrs, winIds) -- {{{
    bufNrs = bufNrs or var.bufNrs
    winIds = winIds or var.winIds
    local bufCnt = 0
    for _, winId in ipairs(winIds) do
        if vim.tbl_contains(var.bufNrs, vim.api.nvim_win_get_buf(winId)) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end -- }}}
--- Return valid and loaded buffer count
---@param bufNrs? table Use `var.bufNrs` if no buffer table provided
---@return number The occurrence
M.bufsNonScratchOccurInWins = function(bufNrs) -- {{{
    bufNrs = bufNrs or var.bufNrs

    if bufNrs then
        local cnt = #vim.tbl_filter(function(bufNr)
            return not M.isScratchBuf(bufNr) and nvim_buf_get_name(bufNr) ~= ""
        end, bufNrs)
        return cnt
    else
        return 0
    end
end -- }}}
--- Return all window IDs
---@param relativeIncludeChk? boolean Whether to include the relative window
---@return table
M.winIds = function(relativeIncludeChk) -- {{{
    if not relativeIncludeChk then
        return vim.tbl_filter(function(winId)
            return vim.api.nvim_win_get_config(winId).relative == ""
        end, vim.api.nvim_list_wins())
    else
        return vim.api.nvim_list_wins()
    end
end -- }}}
-- Return window occurrences in Neovim
---@return number The occurrence
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
--- Function wrap around `vim.api.nvim_win_close`
---@param winId? number Use `var.winId` if no window ID provided
M.winClose = function(winID) -- {{{
    local ok, msg = pcall(vim.api.nvim_win_close, winID, false)
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end
end -- }}}
--- Get the layout in which the target window nested in
---@param matchPattern? number|function Specify how to match a target window. Default is current window ID. You can pass in a specific window ID or a function that take window ID as its parameter, they will check against each window ID by calling this function recursively until it finds a match, which means the window IDs are equal or `matchPattern(<window ID>)` is evaluated to be `true`
---@param layout? table Return value of `vim.fn.winlayout()`, contains the layout data of target window. It's used for internal loop only, and should be not passed in any value in the first calling stack. This layout is heavily nested when it's initialized in the first place, so we need to iterating through it over and over again
---@param superiorLayout? string The parent layout the target nested in. It's used for internal loop only as the `layout` argument does
---@return string,table The parent layout string and the table contain sibling data
M.winLayout = function(matchPattern, layout, superiorLayout) -- {{{
    -- Initiation for in the first calling stack
    matchPattern = matchPattern or vim.api.nvim_get_current_win()
    layout = layout or vim.fn.winlayout()

    -- Store siblings in every calling stack
    for i, element in ipairs(layout) do
        if type(element) == "string" then
            if type(layout[i + 1]) == "table" then
                superiorLayout = element
            end
        elseif type(element) == "table" then
            -- Iterating through the table element
            local nextSuperiorLayout, nextLayout = M.winLayout(matchPattern, element, superiorLayout)
            if nextSuperiorLayout ~= "" then
                if not next(nextLayout) then
                    -- When values are returned from topmost calling stack at
                    -- the first time, don't use the `layout` from the nested
                    -- calling stack, use then one in current calling stack,
                    -- which contains the whole siblings.
                    -- e.g: layout == {{"leaf", 1003}, {"leaf", 1003}, {"leaf", 1003}}
                    return nextSuperiorLayout, layout
                else
                    -- When `nextLayout` isn't empty, return it as well
                    -- because it's properly returned from nested calling
                    -- stack
                    return nextSuperiorLayout, nextLayout
                end
            end
        elseif type(element) == "number" then
            if type(matchPattern) == "function" then
                if matchPattern(element) then
                    -- Matched data will be returned from highest calling stack
                    ---@diagnostic disable-next-line: return-type-mismatch
                    return superiorLayout, {}
                end
            else
                if element == matchPattern then
                    -- Matched data will be returned from highest calling stack
                    ---@diagnostic disable-next-line: return-type-mismatch
                    return superiorLayout, {}
                end
            end
        end
    end

    -- Fallback return if no window id match against the `matchPattern`
    return "", {}
end -- }}}
M.getCurWinLayoutTest = function() -- {{{
    local curWinId = vim.api.nvim_get_current_win()
    local superiorLayout, siblings = M.winLayout(curWinId)
    print('DEBUGPRINT[1]: util.lua:195: vim.fn.winlayout()=' .. vim.inspect(vim.fn.winlayout()))
    print('DEBUGPRINT[2]: util.lua:195: siblings=' .. vim.inspect(siblings))
    local layoutDesc = superiorLayout == "row" and "Vertical" or "Horizontally"
    local siblingWinIds = {}
    for _, s in ipairs(siblings) do
        if not(type(s[2]) == "number" and s[2] == curWinId) then
            siblingWinIds[#siblingWinIds+1] = s[2]
        end
    end
    Print(string.format("Current window is %d and it's in a %s split layout.", curWinId, layoutDesc))
    Print("")
    Print("The sibling windows are: ")
    for _, s in ipairs(siblingWinIds) do
        if type(s) == "number" then
            Print("   Window " .. s)
        else
            Print("A compound window contain " .. #s .. " windows")
        end
    end

end -- }}}


return M
