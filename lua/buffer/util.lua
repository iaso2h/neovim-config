local M = {}
local var = require("buffer.var")


--- Gather information about buffers and windows for further processing
M.initBuf = function()
    var.bufNr    = vim.api.nvim_get_current_buf()
    var.bufNrs   = M.bufNrs(true)
    var.bufName  = nvim_buf_get_name(var.bufNr)
    var.bufType  = vim.bo.buftype
    var.fileType = vim.bo.filetype
    var.winId    = vim.api.nvim_get_current_win()
    var.winIds   = M.winIds(false)
end


M.isSpecBuf = function(bufType) -- {{{
    bufType = bufType or var.bufType
    return bufType ~= ""
end -- }}}
M.isScratchBuf = function() -- {{{
    return var.bufName == "" or not vim.tbl_contains(var.bufNrs, var.bufNr)
end -- }}}
--- Force wipe the given buffer, if no bufNr is provided, then current buffer
--- will be wiped
--- @param bufNr boolean Buffer number handler
M.bufClose = function(bufNr) -- {{{
    -- bufNr = bufNr or 0
    -- :bdelete will register in both the jumplist and the changelist
    pcall(vim.api.nvim_command, "bdelete! " .. bufNr)
    -- These two don't register in both the changelist and the changelist
    -- pcall(vim.api.nvim_command, "keepjump bwipe! " .. bufNr)
    -- pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end -- }}}
--- Function wrapped around the vim.api.nvim_list_bufs()
--- @param validLoadedOnly boolean Whether contains loaded buffers only
--- @return table
M.bufNrs = function(validLoadedOnly) -- {{{
    local unListedBufTbl = vim.api.nvim_list_bufs()
    local cond = function(buf)
        if validLoadedOnly then
            return vim.api.nvim_buf_is_loaded(buf) and
                vim.api.nvim_buf_get_option(buf, "buflisted")
        else
            return vim.api.nvim_buf_get_option(buf, "buflisted")
        end
    end

    return vim.tbl_filter(cond, unListedBufTbl)
end -- }}}
--- Switch to alternative buffer or previous buffer before wiping current buffer
--- @param winID number Window ID in which alternative will be set
M.bufSwitchAlter = function(winID) -- {{{
    ---@diagnostic disable-next-line: param-type-mismatch
    local altBufNr = vim.fn.bufnr("#")
    if altBufNr ~= var.bufNr and vim.api.nvim_buf_is_valid(altBufNr) and
            vim.tbl_contains(var.bufNrs, altBufNr) then
        vim.api.nvim_win_set_buf(winID, altBufNr)
        return true
    else
        -- Fallback method
        for _, b in ipairs(var.bufNrs) do
            if b ~= var.bufNr then
                vim.api.nvim_win_set_buf(var.winId, b)
                return true
            end
        end
    end

    vim.notify("Failed to switch alternative buffer in Windows: " .. winID)

    return false
end -- }}}
--- Return valid and loaded buffer count
---@param bufNrTbl? table Use `var.bufNrs` if no bufNrTbl provided
---@return number
M.bufsVisibleOccur = function(bufNrTbl) -- {{{
    bufNrTbl = bufNrTbl or var.bufNrs

    if bufNrTbl then
        local cnt = #vim.tbl_filter(function(bufNr)
            return vim.api.nvim_buf_get_name(bufNr) ~= ""
        end, bufNrTbl)
        return cnt
    else
        return 0
    end
end -- }}}
M.bufOccurInWins = function(buf) -- {{{
    local bufCnt = 0
    for _, w in ipairs(var.winIds) do
        if buf == vim.api.nvim_win_get_buf(w) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end -- }}}
M.bufsOccurInWins = function() -- {{{
    local bufCnt = 0
    for _, w in ipairs(var.winIds) do
        if vim.tbl_contains(var.bufNrs, vim.api.nvim_win_get_buf(w)) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end -- }}}
M.winIds = function(relativeIncludeChk) -- {{{
    if not relativeIncludeChk then
        return vim.tbl_filter(function(i)
            return vim.api.nvim_win_get_config(i).relative == ""
        end, vim.api.nvim_list_wins())
    else
        return vim.api.nvim_list_wins()
    end
end -- }}}
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
M.winClose = function (winID) -- {{{
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
--- Return ex command for spliting Neovim windows
---@param splitPrefixChk boolean If the function resolve to vertical split solution. Whether to return `vertical` form ex command prefix or `vsplit` to split a window first
---@return string Neovim ex command string
M.winSplitCmd = function(splitPrefixChk)
    local layout = require("buffer.util").winLayout()
    if layout ~= "" then
        if layout == "col" then
            if splitPrefixChk then
                return "vertical"
            else
                return "vsplit"
            end
        elseif layout == "row" then
            if splitPrefixChk then
                return "horizontal"
            else
                return "split"
            end
        elseif layout == "leaf" then
            -- TODO: detection in one window screen
        end
    else
        return ""
    end
end


return M
