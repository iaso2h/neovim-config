local M = {}
local var = require("buffer.var")


--- Gather information about buffers and windows for further processing
---@param bufNr? integer
M.initBuf = function(bufNr) -- {{{
    var.bufNr    = bufNr or vim.api.nvim_get_current_buf()
    var.bufNrs   = M.bufNrs(true, false)
    var.bufName  = nvim_buf_get_name(var.bufNr)
    var.bufType  = vim.bo.buftype
    var.fileType = vim.bo.filetype
    var.winId    = vim.api.nvim_get_current_win()
    var.winIds   = M.winIds(false)
end -- }}}
--- Check if the provided buffer is a special buffer
---@param bufNr? integer If it isn't provided, the `var.bufNr` will be used
---@return boolean
M.isSpecialBuf = function(bufNr) -- {{{
    bufNr = bufNr or var.bufNr
    local specialBufType = {"nofile", "nowrite", "prompt"}
    local bufType    = vim.api.nvim_get_option_value("buftype", {buf = bufNr})
    local modifiable = vim.api.nvim_get_option_value("modifiable", {buf = bufNr})
    local bufListed  = vim.api.nvim_get_option_value("buflisted", {buf = bufNr})
    return (bufType ~= "" and (not modifiable or not bufListed)) or
        vim.list_contains(specialBufType, bufType)
end -- }}}
--- Check if the provided buffer is a scratch buffer
---@param bufNr? integer If it isn't provided, the `var.bufName` will be used instead
---@return boolean
M.isScratchBuf = function(bufNr) -- {{{
    if not bufNr then
        return var.bufName == ""
    else
        return nvim_buf_get_name(bufNr) == ""
    end
end -- }}}
--- Force wipe the given buffer, if no bufNr is provided, then current buffer will be wiped
---@param bufNr? integer If it isn't provided, the `var.bufNr` will be used instead
---@param switchBeforeClose? boolean Default is false. Set it to true to switch all the buffer instance in all windows to an alternative buffer in advance before closing up the buffer entirely
---@param scheduleWrap? boolean Whether to use `vim.schedule_wrap()` to defer
--the buffer close action
M.bufClose = function(bufNr, switchBeforeClose, scheduleWrap) -- {{{
    bufNr = bufNr or var.bufNr

    if switchBeforeClose then
        if var.winIds then
            for _, winId in ipairs(var.winIds) do
                if vim.api.nvim_win_get_buf(winId) == bufNr then
                    M.bufSwitchAlter(winId, bufNr)
                end
            end
        else
            return vim.api.nvim_echo( { { [[`require("buffer.var").winIds` isn't initialized]]} }, true, {err = true} )
        end
    end
    if scheduleWrap then
        vim.schedule_wrap(function()
            vim.api.nvim_command("bdelete! " .. bufNr)
        end)()
    else
        local ok, msgOrVal = pcall(vim.api.nvim_command, "bdelete! " .. bufNr)
        if not ok then
            if not string.match(msgOrVal, "E516") then
                vim.api.nvim_echo( { { msgOrVal} }, true, {err = true} )
            end
        end
    end
    -- `:bdelete` will register in both the jumplist and the changelist
    -- These two don't register in both the changelist and the changelist
    -- pcall(vim.api.nvim_command, "keepjump bwipe! " .. bufNr)
    -- pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end -- }}}
--- Function wrapped around the `vim.api.nvim_list_bufs().` Produce result just like you type `:ls` in Neovim commandline
---@param listedOnly? boolean Whether to contain listed buffers only. This argument will overide the `loadedOnly` if it's set to true, because listed buffer is also loaded
---@param loadedOnly? boolean Whether to contain loaded buffers only
---@return table
M.bufNrs = function(listedOnly, loadedOnly) -- {{{
    local rawBufNrs = vim.api.nvim_list_bufs()
    local cond = function(bufNr)
        if listedOnly then
            return vim.api.nvim_get_option_value("buflisted", {buf = bufNr})
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
---@param winId? integer Window ID in which the buffer nest will be switch to an alternative buffer. Default is `var.winId` if no window ID provided
---@param bufNr? integer What buffer number will be switch away in the specific
--window. Default is `var.bufNr` if no buffer number provided
M.bufSwitchAlter = function(winId, bufNr) -- {{{
    winId = winId or var.winId
    bufNr = bufNr or var.bufNr
    ---@diagnostic disable-next-line: param-type-mismatch
    local altBufNr = vim.fn.bufnr("#")
    if altBufNr ~= bufNr and vim.api.nvim_buf_is_loaded(altBufNr) and
        -- Switch to alternative buffer whenever possible
        vim.api.nvim_get_option_value("buflisted", {buf = altBufNr}) and
        not M.isSpecialBuf(altBufNr) then

        return vim.api.nvim_win_set_buf(winId, altBufNr)
    else
        -- Fallback method
        if #var.bufNrs ~= 0 then
            local curBufNrIdx = tbl_idx(var.bufNrs, bufNr, false)
            if curBufNrIdx ~= -1 then
                for offset = 1, #var.bufNrs - 1, 1 do
                    local idx = curBufNrIdx - offset
                    idx = idx < 1 and idx + #var.bufNrs or idx
                    local b = var.bufNrs[idx]
                    if not M.isSpecialBuf(b) then
                        return vim.api.nvim_win_set_buf(winId, b)
                    end
                end
            else
                for _, b in ipairs(var.bufNrs) do
                    if b ~= bufNr and not M.isSpecialBuf(b) then
                        return vim.api.nvim_win_set_buf(winId, b)
                    end
                end
            end
            vim.api.nvim_echo({{string.format("Failed to switch alternative buffer for the buffer %d in Windows: %d", bufNr, winId)}}, true, {err=true})
        else
            -- Do nothing
        end
    end

end -- }}}
--- Check how many times the specified buffer occurs in all windows
---@param bufNr? integer If it isn't provided, the `var.bufNr` will be used instead
---@param winIds? table If it isn't provided, the `var.winIds` will be used instead
---@return integer,table # How many same provided buffer instances display in other windows and the window IDs that contain the provided buffer Note that the function will always take the current window into account
M.bufOccurInWins = function(bufNr, winIds) -- {{{
    bufNr  = bufNr  or var.bufNr
    winIds = winIds or var.winIds
    local bufCnt = 0
    local winIds = {}
    for _, winId in ipairs(var.winIds) do
        if vim.api.nvim_win_is_valid(winId) then
            if bufNr == vim.api.nvim_win_get_buf(winId) then
                bufCnt = bufCnt + 1
                winIds[#winIds+1] = winId
            end
        end
    end

    return bufCnt, winIds
end -- }}}
--- Check how many buffers from the specified buffer table occur in the specified window table
---@param bufNrs? table If it isn't provided, the `var.bufNrs` will be used instead
---@param winIds? table If it isn't provided, the `var.winIds` will be used instead
---@return integer # The occurrence time
M.bufsOccurInWins = function(bufNrs, winIds) -- {{{
    bufNrs = bufNrs or var.bufNrs
    winIds = winIds or var.winIds
    local bufCnt = 0
    for _, winId in ipairs(winIds) do
        if vim.list_contains(var.bufNrs, vim.api.nvim_win_get_buf(winId)) then
            bufCnt = bufCnt + 1
        end
    end

    return bufCnt
end -- }}}
--- Return valid and loaded buffer count
---@param bufNrs? table Use `var.bufNrs` if no buffer table provided
---@return integer # The occurrence time
M.bufsNonScratchOccurInWins = function(bufNrs) -- {{{
    bufNrs = bufNrs or var.bufNrs

    if bufNrs then
        local cnt = #vim.tbl_filter(function(bufNr)
            return not M.isScratchBuf(bufNr)
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
--- Get the window ID of previous window
---@return integer
M.winIdPrev = function() -- {{{
    vim.cmd [[noa wincmd p]]
    local winId  = vim.api.nvim_get_current_win()
    vim.cmd [[noa wincmd p]]
end -- }}}
-- Return window occurrences in Neovim
---@param winIds? integer[] If it isn't provided, the `var.winIds` will be used instead
---@return integer The occurrence
M.winsOccur = function(winIds) -- {{{
    -- Take two NNP windows into account
    winIds = winIds or var.winIds
    if package.loaded["no-neck-pain"] and _G.NoNeckPain.state.enabled then

        local totalWinCnts = #winIds
        for _, winId in ipairs(winIds) do
            if vim.api.nvim_win_is_valid(winId) then
                local bufNr    = vim.api.nvim_win_get_buf(winId)
                local filetype = vim.api.nvim_get_option_value("filetype", {buf = bufNr})
                if filetype == "no-neck-pain" then
                    totalWinCnts = totalWinCnts - 1
                end
            else
                totalWinCnts = totalWinCnts - 1
            end
        end
        return totalWinCnts
    else
        return #winIds
    end
end -- }}}
--- Function wrap around `vim.api.nvim_win_close`
---@param winId? integer Use `var.winId` if no window ID provided
---@param scheduleWrap? boolean Wether to use `vim.schedule_wrap()` to defer the window close action
M.winClose = function(winId, scheduleWrap) -- {{{
    winId = winId or var.winId
    if scheduleWrap then
        vim.schedule_wrap(function()
            vim.api.nvim_win_close(winId, false)
        end)()
    else
        local ok, msg = pcall(vim.api.nvim_win_close, winId, false)
        if not ok then vim.api.nvim_echo( { { msg} }, true, {err = true} ) end
    end
end -- }}}
--- Get the layout in which the target window nested in
---@param matchPattern? integer|function Specify how to match a target window. Default is current window ID. You can pass in a specific window ID or a function that take window ID as its parameter, they will check against each window ID by calling this function recursively until it finds a match, which means the window IDs are equal or `matchPattern(<window ID>)` is evaluated to be `true`
---@param layout? table Return value of `vim.fn.winlayout()`, contains the layout data of target window. It's used for internal loop only, and should be not passed in any value in the first calling stack. This layout is heavily nested when it's initialized in the first place, so we need to iterating through it over and over again
---@param superiorLayout? string The parent layout the target nested in. It's used for internal loop only as the `layout` argument does
---@return string,table The parent layout string and the table contain sibling data
M.winLayout = function(matchPattern, layout, superiorLayout) -- {{{
    -- Initiation for in the first calling stack
    matchPattern = matchPattern or vim.api.nvim_get_current_win()
    layout = layout or vim.fn.winlayout()

    -- Return data directly if there's only on window
    if not superiorLayout and layout[1] == "leaf" then return layout[1], layout end

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
---Redirect the lines into a scratch buffer
---@param lines string[] List-like table contains strings that represent
--different lines respectively
---@param scratchBufNr integer|nil The scratch buffer to which the lines will
--be redirect to. If nil provided, a new buffer number will be created
---@param appendChk? boolean Whether to append the new lines at the end if the
--scracth buffer exist
---@param preHook? function Optional function to call before the redirection
---@param postHook? function Optional function to call after the redirection
---@return integer # The scratch bufffer
M.redirScratch = function(lines, scratchBufNr, appendChk, preHook, postHook) -- {{{
    if preHook  and vim.is_callable(preHook)  then preHook()  end
    if postHook and vim.is_callable(postHook) then postHook() end

    local startLine = appendChk and -1 or 0
    local scratchWinId

    -- Output the result into a new scratch buffer
    if scratchBufNr and vim.api.nvim_buf_is_valid(scratchBufNr) then
        -- if scratch buffer is visible, populate the date into it
        local visibleTick = false
        for _, winId in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(winId) == scratchBufNr then
                scratchWinId = winId

                vim.api.nvim_buf_set_lines(scratchBufNr, startLine, -1, false, lines)
                visibleTick = true
                vim.api.nvim_echo({{"Scratch buffer refreshed", "Normal"}}, true, {})
                break
            end
        end
        if not visibleTick then
            local layoutCmd = require("buffer.split").handler(true)
            vim.cmd(layoutCmd .. " new")
            scratchWinId = vim.api.nvim_get_current_win()

            vim.api.nvim_buf_set_lines(scratchBufNr, startLine, -1, false, lines)
            vim.cmd "noa wincmd p"
        end
    elseif vim.api.nvim_buf_get_name(0) == "" and vim.bo.modifiable and
            vim.api.nvim_buf_line_count(0) == 1 and vim.fn.getline(1) == "" then
        -- Use current file as the log buffer
        scratchBufNr = vim.api.nvim_get_current_buf()
        scratchWinId = vim.api.nvim_get_current_win()

        vim.api.nvim_set_option_value("buflisted", false, {buf = scratchBufNr})
        vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = scratchBufNr})
        vim.api.nvim_set_option_value("buftype", "nofile", {buf = scratchBufNr})
        vim.api.nvim_buf_set_lines(scratchBufNr, 0, -1, false, lines)
    else
        local layoutCmd = require("buffer.split").handler(false)
        vim.cmd(layoutCmd)
        scratchWinId = vim.api.nvim_get_current_win()
        scratchBufNr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(scratchBufNr)

        vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = scratchBufNr})
        vim.api.nvim_buf_set_lines(scratchBufNr, 0, -1, false, lines)
        vim.cmd "noa wincmd p"
    end

    local lastLine = vim.api.nvim_buf_call(scratchBufNr, function()
        return vim.api.nvim_buf_line_count(0)
    end)
    vim.api.nvim_win_set_cursor(scratchWinId, {lastLine, 0})

    return scratchBufNr
end -- }}}


return M
