local fn  = vim.fn
local api = vim.api
local M   = {}


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
                local convertMap = fn.luaeval([[require("util").convertMap]] .. text:sub(4))
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


-- Match enhance {{{
function M.matchAll(expr, pat)
    -- Based on VimL match(), Always return a list
    local t = {}
    local idx = -1
    while 1 do
        idx = fn.match(expr, pat, idx + 1)
        if idx == -1 then return t end
        table.insert(t, idx)
    end
end

function M.matchAllStrPos(expr, pat)
    -- Based on VimL matchstrpos(), Always return a list
    local t = {}
    local posList = {0, 0, 0}
    while 1 do
        posList = fn.matchstrpos(expr, pat, posList[3])
        if posList[1] == "" then return t end
        table.insert(t, posList)
    end
end
-- }}} Match enhance


--- Function: M.trimSpaces :Trim all trailing white spaces in current buffer
---
--- @param strTbl table of source string need to be trimmed. If no table
---        provided, the whole buffer will be trimmed instead.
--- @param silent boolean Default is true. Set this to true to not show trimming result
--- @param prefix boolean Set to true to trim the suffix as well
--- @return:       return table of trimmed string, otherwise return 0
function M.trimSpaces(strTbl, silent, prefix) -- {{{
    if not _G._trim_space then return end

    if vim.bo.modified == false then return end

    if not strTbl then
        local saveView = fn.winsaveview()
        silent = silent or true
        if silent then
            vim.cmd [[noa keeppatterns %s#\s\+$##e]]
        else
            vim.cmd [[noa keeppatterns %s#\s\+$##e]]
            local result = api.nvim_exec([[g#\s\+$#p]], true)
            local count = #M.matchAll(result, [[\n]])
            vim.cmd [[noa keeppatterns %s#\s\+$##e]]
            api.nvim_echo({{count .. " line[s] trimmed", "Moremsg"}}, false, {})
        end
        fn.winrestview(saveView)
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


--- Save the star registers, plus and unnamed registers - independently,
--- restoreReg can be accessed after saveReg is called
function M.saveReg() -- {{{
    local unnamedContent = fn.getreg('"', 1)
    local unnamedType    = fn.getregtype('"')
    local starContent    = fn.getreg('*', 1)
    local starType       = fn.getregtype('*')
    local plusContent    = fn.getreg('+', 1)
    local plusType       = fn.getregtype('+')
    local nonDefaultName = vim.v.register
    local nonDefaultContent
    local nonDefaultType
    if not vim.tbl_contains({'"', "*", "+"}, nonDefaultName) then
        nonDefaultContent = fn.getreg(nonDefaultName, 1)
        nonDefaultType    = fn.getregtype(nonDefaultName)
    end
    M.restoreReg = function()
        if nonDefaultContent and nonDefaultContent ~= "" then
            fn.setreg(nonDefaultName, nonDefaultContent, nonDefaultType)
        end

        if starContent ~= "" then
            fn.setreg('*', starContent,    starType)
        end
        if plusContent ~= "" then
            fn.setreg('+', plusContent,    plusType)
        end
        if unnamedContent ~= "" then
            fn.setreg('"', unnamedContent, unnamedType)
        end

        vim.defer_fn(function() M.restoreReg = nil end, 1000)
    end
end -- }}}


function M.visualSelection(returnType, returnNormal) -- {{{
    -- Not support blockwise visual mode
    local mode = fn.visualmode()
    if mode == "\22" then return end
    -- Return (1,0)-indexed line,col info
    local selectStart = api.nvim_buf_get_mark(0, "<")
    local selectEnd = api.nvim_buf_get_mark(0, ">")
    local lines = api.nvim_buf_get_lines(0, selectStart[1] - 1, selectEnd[1],
                                         false)

    if #lines == 0 then
        return {""}
    end
    -- Needed to remove the last character to make it match the visual selection
    if vim.o.selection == "exclusive" then selectEnd[2] = selectEnd[2] - 1 end
    if mode == "v" then
        lines[#lines] = lines[#lines]:sub(1, selectEnd[2] + 1)
        lines[1]      = lines[1]:sub(selectStart[2] + 1)
    end

    if returnNormal then vim.cmd("norm! " .. t"<Esc>") end
    if returnType == "list" then
        return lines
    elseif returnType == "string" then
        return table.concat(lines, "\n")
    end
end -- }}}


--- Calculate the distance from pos1 to pos2
---@param pos1       table      {1, 0} based number. Can be retrieved by calling vim.api.nvim_buf_get_mark()
---@param pos2       table      Same as pos1
---@param biasFactor number|nil
---@param biasIdx    number|nil To which value the factor is going to apply
---@return number value of distance from pos1 to pos2
function M.posDist(pos1, pos2, biasFactor, biasIdx)
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
end


--- Compare the distance from a to b by subtracting them
--- @param a table list-liked table
--- @param b table list-liked table
--- @return number
function M.compareDist(a, b)
    for idx, val in ipairs({a, b}) do
        assert(vim.tbl_islist(val), string.format("Argument %s expects list-liked table", idx))
    end
    return a[1] == b[1] and a[2] - b[2] or a[1] - b[1]
end


--- Check if pos is whithin a defined region
--- @param pos table
--- @param regionStart table
--- @param regionEnd table
--- @return boolean
function M.withinRegion(pos, regionStart, regionEnd)
    if M.compareDist(pos, regionStart) < 0 or M.compareDist(regionEnd, pos) < 0 then
        return false
    else
        return true
    end
end


-- Convert UTF-8 hex code to character
function M.u2char(code)
    if type(code) == 'string' then code = tonumber('0x' .. code) end
    local c = string.char
    if code <= 0x7f then return c(code) end
    local t = {}
    if code <= 0x07ff then
        t[1] = c(bit.bor(0xc0, bit.rshift(code, 6)))
        t[2] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    elseif code <= 0xffff then
        t[1] = c(bit.bor(0xe0, bit.rshift(code, 12)))
        t[2] = c(bit.bor(0x80, bit.band(bit.rshift(code, 6), 0x3f)))
        t[3] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    else
        t[1] = c(bit.bor(0xf0, bit.rshift(code, 18)))
        t[2] = c(bit.bor(0x80, bit.band(bit.rshift(code, 12), 0x3f)))
        t[3] = c(bit.bor(0x80, bit.band(bit.rshift(code, 6), 0x3f)))
        t[4] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    end
    return table.concat(t)
end


function M.splitExist()
    local winCount  = fn.winnr("$")
    local ui        = api.nvim_list_uis()[1]
    -- Based on vim.o.guifont = "更纱黑体 Mono SC Nerd:h13"
    if fn.has("win32") == 1 then
        if winCount == 2 and 232/2 < ui["width"] then vim.cmd [[noautocmd wincmd L]] end
    elseif fn.has("unix") == 1 then
        if winCount == 2 and 284/2 < ui["width"] then vim.cmd [[noautocmd wincmd L]] end
    end
end


--- Create highlights for region in a buffer. The region is defined by two
--- tables containing position info represent the start and the end
--- respectively. The region can be multi-lines across in a buffer
--- @param bufNr      number     Buffer number/handler
--- @param posStart   table      (1, 0)-indexed values from vim.api.nvim_buf_get_mark()
--- @param posEnd     table      (1, 0)-indexed values from vim.api.nvim_buf_get_mark()
--- @param regType    string     Register type from vim.fn.getregtype()
--- @param hlGroup    string     Highlight group name
--- @param hlTimeout  number     Determine how long the highlight will be clear
--- after being created
--- @param presNS     number|nil Optional ID of the preserved namespace, in which the
--- preserved extmark will be stored to keep track of highlight content
--- @return number|boolean Return integer or true when successful, which is the
--- ID of the preserved namespace of the content defined by. Return false when
--- failed posStart and posEnd
M.nvimBufAddHl = function(bufNr, posStart, posEnd, regType, hlGroup, hlTimeout, presNS)
    local presExtmark

    -- Change to 0-based for extmark creation
    posStart = {posStart[1] - 1, posStart[2]}
    posEnd = {posEnd[1] - 1, posEnd[2]}

    -- Create extmark to track the position of the highlight content if preserved
    -- namespace is provided
    if presNS then
        local ok, msg = pcall(api.nvim_buf_set_extmark, bufNr, presNS,
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
    local hlNS = api.nvim_create_namespace('myHighlight')
    -- Always clear all namespaced objects
    api.nvim_buf_clear_namespace(bufNr, hlNS, 0, -1)

    -- Add highlight
    local region = vim.region(bufNr, posStart, posEnd, regType,
                    vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(bufNr, hlNS, hlGroup,
                                    lineNr, cols[1], cols[2])
    end

    -- Clear highlight after certain timeout
    vim.defer_fn(function()
        -- In case of buffer being deleted
        if api.nvim_buf_is_valid(bufNr) then
            pcall(api.nvim_buf_clear_namespace, bufNr, hlNS, 0, -1)
        end
    end, hlTimeout)

    if presNS then
        return presExtmark
    else
        return true
    end
end


--- Copy indent of specific line number in current buffer
---@param lineNr number (1, 0) indexed
---@return string Corresponding line indent
M.indentCopy = function(lineNr)
    return string.rep(" ", fn.indent(lineNr))
end


return M
