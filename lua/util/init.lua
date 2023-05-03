local M   = {}


M.ex = function(exec) return vim.fn.executable(exec) == 1 end


function M.convertMap(mode, lhs, rhs, optsTbl)
    local specArg = ""
    local noremap = ""
    local mapString

    if optsTbl then
        for _, val in ipairs(optsTbl) do
            if val ~= "noremap" then
                specArg = specArg .. " <" .. val .. ">"
            end
        end
        if vim.tbl_contains(optsTbl, "noremap") then
            noremap = "nore"
        end
        specArg = specArg:sub(2)
    end

    mode = mode .. noremap .. "map"
    if specArg ~= "" then
        mapString = string.format("%s %s %s\n",mode, lhs, rhs)
    else
        mapString = string.format("%s %s %s %s\n",mode, specArg, lhs, rhs)
    end
    return mapString
end


function M.readInitLua()
    local targetF = io.open("C:/users/hashub/desktop/convertedmap1.vim", "w")
    local srcF = io.open("C:/Users/Hashub/AppData/Local/nvim/lua/init.lua", "r")
    local keymapcheck = false
    if not targetF or not srcF then return end

    while true do
        local text = srcF:read()
        if not text then break end
        repeat
            if not keymapcheck then
                if vim.startswith(text, "-- Key mapping") then
                    keymapcheck = true
                    targetF:write([[" ]] .. text:sub(3) .. "\n")
                end
                break
            end

            if vim.startswith(text, "--") then
                targetF:write([[" ]] .. text:sub(3) .. "\n")
                break
            end
            if vim.startswith(text, "map(") then
                local convertMap = vim.fn.luaeval([[require("util").convertMap]] .. text:sub(4))
                targetF:write(convertMap)
                break
            end
            targetF:write("\n")
            break
        until true
    end
    targetF:close()
    srcF:close()
end
--- Find all the pat in a string aggressively, based on string.find()
---@param srcStr string
---@param pat string
---@return table
function M.findAll(srcStr, pat) -- {{{
    local lastIdx = { 0 }
    local idxTbl = {}
    repeat
        lastIdx = { string.find(srcStr, pat, lastIdx[1] + 1, false) }
        if next(lastIdx) then
            idxTbl[#idxTbl + 1] = vim.deepcopy(lastIdx)
        end
    until not next(lastIdx)

    return idxTbl
end -- }}}
--- Function: M.trimSpaces :Trim all trailing white spaces in current buffer
---
---@param strTbl table of source string need to be trimmed. If no table
---        provided, the whole buffer will be trimmed instead.
---@param silent boolean Default is true. Set this to true to not show trimming result
---@param prefix boolean Set to true to trim the suffix as well
---@return  table | nil Return table of trimmed string, otherwise return 0
function M.trimSpaces(strTbl, silent, prefix) -- {{{
    if not _G._trim_space then return end

    if vim.bo.modified == false then return end

    if not strTbl then
        local saveView = vim.fn.winsaveview()
        silent = silent or true
        if silent then
            vim.cmd [[noa keeppatterns %s#\s\+$##e]]
        else
            vim.cmd [[noa keeppatterns %s#\s\+$##e]]
            local result = vim.api.nvim_exec2([[g#\s\+$#p]], {output = true}).output
            local count = #M.findAll(result, [[\n]])
            vim.cmd [[noa keeppatterns %s#\s\+$##e]]
            vim.api.nvim_echo({{count .. " line[s] trimmed", "Moremsg"}}, false, {})
        end
        vim.fn.winrestview(saveView)
    elseif next(strTbl) then
        if prefix then
            strTbl = vim.tbl_map(function(str)
                local result = string.gsub(str, "^%s+", "")
                return result
            end, strTbl)
        end
        return vim.tbl_map(function(str)
            local result = string.gsub(str, "^%s+", "")
            return result
        end, strTbl)
    end
end -- }}}
--- Calculate the distance from pos1 to pos2
---@param pos1       table      {1, 0} based number. Can be retrieved by calling vim.api.nvim_buf_get_mark()
---@param pos2       table      Same as pos1
---@param biasFactor number|nil
---@param biasIdx    number|nil To which value the factor is going to apply
---@return number value of distance from pos1 to pos2
function M.posDist(pos1, pos2, biasFactor, biasIdx) -- {{{
    biasFactor = biasFactor or 1
    biasIdx    = biasIdx or 1
    local lineDist
    local colDist
    if biasIdx == 1 then
        lineDist = (pos1[1] - pos2[1])^2 * biasFactor
        colDist  = (pos1[2] - pos2[2])^2
    else
        lineDist = (pos1[1] - pos2[1])^2
        colDist  = (pos1[2] - pos2[2])^2 * biasFactor
    end
    return lineDist + colDist
end -- }}}
--- Compare the distance from a to b by subtracting them
---@param a table list-liked table
---@param b table list-liked table
---@return number
function M.compareDist(a, b) -- {{{
    for idx, val in ipairs({a, b}) do
        assert(vim.tbl_islist(val), string.format("Argument %s expects list-liked table", idx))
    end
    return a[1] == b[1] and a[2] - b[2] or a[1] - b[1]
end -- }}}
--- Check if pos is whithin a defined region. Note that all position have to
--be the same index based. e.g They must be all (0, 0) indexed or all (1, 0)
--indexed etc
---@param pos table
---@param regionStart table
---@param regionEnd table
---@return boolean
function M.withinRegion(pos, regionStart, regionEnd) -- {{{
    if M.compareDist(pos, regionStart) < 0 or M.compareDist(regionEnd, pos) < 0 then
        return false
    else
        return true
    end
end -- }}}
--- Create highlights for region in a buffer. The region is defined by two
--- tables containing position info represent the start and the end
--- respectively. The region can be multi-lines across in a buffer
---@param bufNr      number     Buffer number/handler
---@param posStart   table      (1, 0)-indexed values from vim.api.nvim_buf_get_mark()
---@param posEnd     table      (1, 0)-indexed values from vim.api.nvim_buf_get_mark()
---@param regType    string     Register type from vim.fn.getregtype()
---@param hlGroup    string     Highlight group name
---@param hlTimeout  number     Determine how long the highlight will be clear
--- after being created
---@param presNS     number|nil Optional ID of the preserved namespace, in which the
--- preserved extmark will be stored to keep track of highlight content
---@param zeroBasedChk? boolean Set to true if the posStart and posEnd is (0, 0) based
---@return number|boolean Return integer or true when successful, which is the
--- ID of the preserved namespace of the content defined by. Return false when
--- failed posStart and posEnd
M.nvimBufAddHl = function(bufNr, posStart, posEnd, regType, hlGroup, hlTimeout, presNS, zeroBasedChk) -- {{{
    if zeroBasedChk == nil then zeroBasedChk = false end
    local presExtmark

    -- Change to 0-based for extmark creation
    if not zeroBasedChk then
        posStart = {posStart[1] - 1, posStart[2]}
        posEnd = {posEnd[1] - 1, posEnd[2]}
    end

    -- Create extmark to track the position of the highlight content if preserved
    -- namespace is provided
    if presNS then
        local ok, msg = pcall(vim.api.nvim_buf_set_extmark, bufNr, presNS,
            posStart[1], posStart[2], {end_line = posEnd[1], end_col = posEnd[2]})
        -- End function calling if extmark is out of scope
        if not ok then
            vim.notify(msg, vim.log.levels.WARN)
            return false
        else
            presExtmark = msg
        end
    end

    -- Creates a new namespace or gets an existing one.
    local hlNS = vim.api.nvim_create_namespace('myHighlight')
    -- Always clear all namespaced objects
    vim.api.nvim_buf_clear_namespace(bufNr, hlNS, 0, -1)

    -- Add highlight
    local region = vim.region(bufNr, posStart, posEnd, regType,
                    vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        vim.api.nvim_buf_add_highlight(bufNr, hlNS, hlGroup,
                                    lineNr, cols[1], cols[2])
    end

    -- Clear highlight after certain timeout
    vim.defer_fn(function()
        -- In case of buffer being deleted
        if vim.api.nvim_buf_is_valid(bufNr) then
            pcall(vim.api.nvim_buf_clear_namespace, bufNr, hlNS, 0, -1)
        end
    end, hlTimeout)

    if presNS then
        return presExtmark
    else
        return true
    end
end -- }}}
-- Credit: https://github.com/LunarVim/LunarVim/blob/2d373036493b3a61ef24d98efdeecbe8e74467be/lua/lvim/utils/modules.lua#L68
--- A safer require function
---@param mod string Module name
---@return any|boolean Data returned by require lua module or false to signify
--a failure require
M.requireSafe = function(mod) -- {{{
    local ok, module = pcall(require, mod)
    if not ok then
        local trace = debug.getinfo(2, "SL")
        local shorterSrc = trace.short_src
        local lineInfo = shorterSrc .. ":" .. (trace.currentline or trace.linedefined)
        local msg = string.format("%s : skipped loading [%s]", lineInfo, mod)
        vim.notify(msg, vim.log.levels.WARN)
        return false
    else
        return module
    end
end -- }}}
--- Save the cursor position in current window, also respect the topline and
--the botline of the current window
---@param printFormulaChk boolean Set it to true to debug print the data
M.saveViewCursor = function(printFormulaChk) -- {{{
    -- https://github.com/notomo/neovim/blob/da134270d3e9f8a4824b0e0540bf017f7e59b06e/src/nvim/ex_session.c#L436
    -- https://www.cs.cmu.edu/afs/club/contrib/build/debian8/vim/src/session.c
    local cursorPos = vim.api.nvim_win_get_cursor(0)
    cursorPos = {cursorPos[1], cursorPos[2] + 1} -- (1, 1) indexed
    local curWinID = vim.api.nvim_get_current_win()
    local winInfo  = vim.fn.getwininfo(curWinID)[1]
    if printFormulaChk then
        Print(string.format("%d - ((%d * winheight(0) + %d) / %d)", cursorPos[1], cursorPos[1] - winInfo.topline, math.floor(winInfo.height / 2), winInfo.height))
        Print(cursorPos[1] - ((cursorPos[1] - winInfo.topline) * vim.fn.winheight(0) + math.floor(winInfo.height / 2)) / winInfo.height)
        Print(vim.fn.winheight(0))
        return
    end
    M.restoreViewCursor = function() -- {{{
        local soSave   = vim.o.so
        local sisoSave = vim.o.siso
        vim.o.so    = 0
        vim.o.siso  = 0

        local lineNr = cursorPos[1] - ((cursorPos[1] - winInfo.topline) * vim.fn.winheight(0) + math.floor(winInfo.height / 2)) / winInfo.height
        lineNr = math.ceil(lineNr)
        if lineNr < 1 then lineNr = 1 end
        vim.cmd([[keepjumps ]] .. lineNr)
        vim.cmd [[norm! zt]]
        vim.cmd([[keepjumps]] .. cursorPos[1])
        vim.cmd([[norm! 0]] .. cursorPos[2] .. [[|]])

        vim.o.so   = soSave
        vim.o.siso = sisoSave
        M.restoreViewCursor = nil
    end -- }}}
end -- }}}
--- Get node text at given range
---@param bufNr number
---@param range table Captured indices return by calling tsnode:range() . All
---values are 0 index
---@param xOffset? number Negative number to expand the same unit from column
---start and column end, and positive number to shrink. Default 0
---@param yOffset? number Negative number to expand the same unit from row
---start and column end, and positive number to shrink. Default 0
---@param concatChar? string What character will be used as the separator to
---concatenate table elements. Default ""
M.getNodeText = function(bufNr, range, xOffset, yOffset, concatChar) -- {{{
    xOffset = xOffset or 0
    yOffset = yOffset or 0
    concatChar = concatChar or ""
    local text = vim.api.nvim_buf_get_text(
        bufNr,
        range[1] + yOffset,
        range[2] + xOffset,
        range[3] - yOffset,
        range[4] - xOffset,
        {})
    return table.concat(text, concatChar)
end -- }}}
--- Get nodes from Treesitter query
---@param bufNr number
---@param query string
---@param captureId? number Specific id to be capture when calling query.iter_captures()
---@return table
M.getQueryNodes = function(bufNr, query, captureId) -- {{{
    local lastLine = vim.api.nvim_buf_call(bufNr, function()
        ---@diagnostic disable-next-line: redundant-return-value
        return vim.fn.line("$")
    end)
    local lang = vim.treesitter.language.get_lang(vim.api.nvim_buf_get_option(bufNr, "filetype"))
    local tsParser = vim.treesitter.get_parser(bufNr, lang)
    local tsTree = tsParser:parse()[1]
    local root = tsTree:root()
    local argsQuery = vim.treesitter.query.parse(lang, query)

    local nodeTbl = {}
    local index = 0
    for id, node, _ in argsQuery:iter_captures(root, bufNr, 1, lastLine) do
        index = index + 1
        if captureId then
            if id == captureId then
                nodeTbl[#nodeTbl+1] = node
            end
        else
            nodeTbl[#nodeTbl+1] = node
        end
    end

    return nodeTbl
end -- }}}


return M
