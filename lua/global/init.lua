require("global.keymap")


local fn  = vim.fn
local api = vim.api

local init = function(initValue, optName) -- {{{
    if optName then
        vim.api.nvim_create_user_command("Toggle" .. optName, function()
            vim.g._cspellEnable = not vim.g._cspellEnable
            local state = vim.g._cspellEnable and "Enabled" or "Disabled"
            vim.api.nvim_echo({ { string.format("%s has been %s", optName, state), "Moremsg" } }, false, {})
        end, {})
    end
    return initValue
end -- }}}
_G._os_uname         = init(vim.loop.os_uname())
_G._is_term          = init(vim.fn.has("gui_running") == 0)
_G._sep              = init(_G._os_uname.sysname == "Windows_NT" and "\\" or "/")
_G._config_path      = init(fn.stdpath("config"))
_G._format_option    = init("cr/qn2mM1jpl")
_G._qf_fallback_open = init(true, "QuickFixFallbackOpen")
_G._trim_space       = init(true, "QuickTrimSpace")
_G._autoreload       = init(true, "Autoreload")
_G._enable_plugin    = init(true)
_G._lisp_language    = init {"clojure", "scheme", "lisp", "racket", "hy", "fennel", "janet", "carp", "wast", "yuck"}


_G.Print = function(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
    end
    if #objects == 1 and type(objects[1]) == "table" then
        require("pprint").pprint(objects[1])
    else
        print(table.concat(objects, '\n'))
    end

    return ...
end


--- Remove value from list-liked lua table
---@param tbl table List-like table
---@param srcVal any Source value to be look up and removed
---@param removeAllChk boolean|nil Default is true. Whether to remove the
--all values or not
---@param cnt number|nil default is 1. Determine how many value
--will be removed when firstOnlyChk is false
---@return number|table|nil Index of the value. Index of table will be return
--when there are more than one idx to be return. nil will be return when no idx found
local tbl_remove = function(tbl, srcVal, removeAllChk, cnt)
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


--- Replace value1 inside list-like table with value2
---@param tbl       table   List-like table of which value to be replaced
---@param repVal    any     Value to replace with
---@param srcVal    any     Source value to be replaced
---@param repAllChk boolean Default is true. Whether to replace all value or not
---@param cnt       number  Default is 1. Determine how many srcVal
--will be replaced
---@param alertOnFail boolean Default is false. Whether to alert when
--replace failed
---@return nil
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
        -- Because when table with one element have its very only element
        -- set to nil, the table will also became nil
        if idx == 1 then
            tbl = {repVal}
        else
            tbl[idx] = repVal
        end
    end

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


--- Unify separator in value returned by vim.api.nvim_buf_get_name()
---@vararg any Same as vim.api.nvim_buf_get_name()
_G.nvim_buf_get_name = function(bufNr)
    if _G._os_uname.sysname == "Windows_NT" then
        local name = api.nvim_buf_get_name(bufNr)
        local retName = name:gsub("/", _G._sep)
        return retName
    else
        return api.nvim_buf_get_name(bufNr)
    end
end
