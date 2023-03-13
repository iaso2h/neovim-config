local fn  = vim.fn
local api = vim.api

_G._os_uname         = vim.loop.os_uname()
_G._is_term          = vim.api.nvim_list_uis()[1].ext_termcolors
_G._sep              = _G._os_uname.sysname == "Windows_NT" and "\\" or "/"
_G._configPath       = fn.stdpath("config")
_G._qf_fallback_open = true
_G._trim_space       = true


_G.isFloatWin = function(winID)
    return api.nvim_win_get_config(winID and winID or 0).relative ~= ""
end


_G.t = function(str)
    return api.nvim_replace_termcodes(str, true, true, true)
end


_G.ex = function(exec) return fn.executable(exec) == 1 end


----
-- Function: _G.tbl_remove: Remove value from list-liked lua table
--
-- @param tbl:          List-liked table
-- @param srcVal:       Srouce value to be look up and removed
-- @param removeAllChk: Boolean value, default is true. Whether to remove the
--                      all values or not
-- @param cnt:          Integer value, default is 1. Determine how many value
--                      o be removed when firstOnlyChk is false
-- @return: Integer, table or nil. idx of the value. idx of table will be return when there are more
--          than one idx to be return. nil will be return when no idx found
----
 _G.tbl_remove = function(tbl, srcVal, removeAllChk, cnt)
    assert(next(tbl), "Empty table is not allowed")
    assert(vim.tbl_islist(tbl), "Expect list-liked table")

    removeAllChk = removeAllChk or false
    cnt = cnt or 1
    if not removeAllChk then
        for idx, val in ipairs(tbl) do
            if val == srcVal then
                tbl[idx] = nil
                return idx
            end
        end

    else
        local removeCount = 0
        local idxTbl = {}
        for idx, val in ipairs(tbl) do
            if val == srcVal then
                tbl[idx] = nil
                removeCount = removeCount + 1
                idxTbl[#idxTbl+1] = idx
            end
            if removeCount == cnt then return idxTbl end
        end

    end

    -- return nil when not idx found
    return nil
end


----
-- Function: _G.tbl_replace: Replace value1 inside list-liked table with value2
--
-- @param tbl:       List-liked table of which value to be replaced
-- @param repVal:    Value to replace with
-- @param srcVal:    Source value to be replaced
-- @param repAllChk: Boolean value, default is true. Whether to replace all value or not
-- @param cnt:       Integer value, default is 1. Determine how many srcVal
--                   will be replaced
-- @param alertOnFail: Boolean value, default is false. Whether to alert when
-- replace failed
-- @return: nil
----
_G.tbl_replace = function(tbl, repVal, srcVal, repAllChk, cnt, alertOnFail)
    repAllChk = repAllChk or true
    cnt = cnt or 1
    alertOnFail = alertOnFail or false

    local idx = tbl_remove(tbl, srcVal, repAllChk, cnt)
    if not idx then
        if alertOnFail then
            return vim.notify("Source value instance not found", vim.log.levels.WARN)
        else
            return
        end
    end
    local repCnt = 0
    if type(idx) == "table" then
        for _, index in ipairs(idx) do
            tbl[index] = repVal
            if repAllChk then
                repCnt = repCnt + 1
                if repCnt == cnt then return end
            end
        end
    else
        -- Bacause when table with one element have its very only element
        -- set to nil, the table will also became nil
        if idx == 1 then
            tbl = {repVal}
        else
            tbl[idx] = repVal
        end
    end

end


----
-- Function: _G.tbl_merge: Concanate two or more list like table
--
-- @param ...: Table
----
_G.tbl_merge = function(...)
    local tblConcanated = {}
    for i = 1, select('#', ...) do
        local tbl = select(i, ...)
        assert(vim.tbl_islist(tbl), "Only list-liked table allowed")
        if next(tbl) then
            for _, value in ipairs(tbl) do
                tblConcanated[#tblConcanated+1] = value
            end
        end
    end
    return tblConcanated
end


--- Return the index of specific item in a list-liked table. Only support
--- number and string for now
--- @param tbl table list-liked table
--- @param item number or string
--- @param returnIdxTbl? boolean whether to return all the indexes as a table
--- @return number|table return table when returnIdxTbl is true
_G.tbl_idx = function(tbl, item, returnIdxTbl)
    assert(vim.tbl_islist(tbl), "Expect list-liked table")
    assert(type(item) == "string" or type(item) == "number", "Only support indexing string or number")
    local idxTbl = {}
    for idx, i in ipairs(tbl) do
        if i == item then
            if not returnIdxTbl then
                return idx
            else
                idxTbl[#idxTbl+1] = idx
            end
        end
    end

    if not returnIdxTbl then
        return nil
    else
        return idxTbl
    end
end


----
-- Function: _G.luaRHS: Let you write rhs of mapping in a comafortable way

-- Before:
            -- map("n", [[<Plug>ReplaceCurLine]], [[:lua vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register); require("replace").replaceSave(); if require("replace").regType == "=" then vim.g.ReplaceExpr = vim.fn.getreg("=") end; vim.cmd("norm! V" .. vim.v.count1 .. "_" .. "<lt>Esc>"); require("replace").operator({"line", "V", "<Plug>ReplaceCurLine", true})<CR>]], {"silent"})

-- After:
            -- map("n", [[<Plug>ReplaceCurLine]],
                -- luaRHS[[
                -- :lua vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register);

                -- require("replace").replaceSave();
                -- if require("replace").regType == "=" then
                    -- vim.g.ReplaceExpr = vim.fn.getreg("=")
                -- end;

                -- vim.cmd("norm! V" .. vim.v.count1 .. "_" .. "<lt>Esc>");

                -- require("replace").operator({"line", "V", "<Plug>ReplaceCurLine", true})<CR>
                -- ]],
                -- {"silent"})
--
-- @param str: RHS mapping
-- @return: nil
----
_G.luaRHS = function(str)
    assert(type(str) == "string", "Expected string value")

    local strTbl = vim.split(str, "\n", false)
    strTbl = vim.tbl_filter(function(i) return not i:match("^%s*$") end, strTbl)
        local concnStr = string.gsub(table.concat(strTbl, " "), "%s+", " ")

    return tostring(
        concnStr:sub(1, 1) == " " and
        concnStr:sub(2, -1) or concnStr:sub(1, -1))
end


_G.vimRHS = function(str)
    assert(type(str) == "string", "Expected string value")

    local strTbl = vim.split(str, "\n", false)
    strTbl = vim.tbl_filter(function(i) return not i:match("^%s*$") end, strTbl)
        local concnStr = string.gsub(table.concat(strTbl, "<Bar> "), "%s+", " ")

    return tostring(
        concnStr:sub(1, 1) == " " and
        concnStr:sub(2, -1) or concnStr:sub(1, -1))
end


_G.stringCount = function(str, pattern)
    local count = 0
    local init = 0
    while true do
        init = string.find(str, pattern, init + 1)
        if not init then return count end
        count = count + 1
    end
end


--- Unify sepator in value returned by vim.api.nvim_buf_get_name()
---@vararg any Same as vim.api.nvim_buf_get_name()
_G.nvim_buf_get_name = function(bufNr)
    if _G._os_uname.sysname == "Windows_NT" then
        local name = api.nvim_buf_get_name(bufNr)
        local retName = name:gsub("/", _G._sep)
        -- local retName, count = name:gsub("/", _G._sep)
        -- if count ~= 0 then
            -- vim.notify("vim.api.nvim_buf_get_name() just return a ununified sepator", vim.log.levels.ERROR)
            -- Print(name)
        -- end
        return retName
    else
        return api.nvim_buf_get_name(bufNr)
    end
end


