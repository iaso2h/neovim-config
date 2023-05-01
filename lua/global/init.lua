local icon = require("icon")

local init = function(initValue, optName) -- {{{
    if optName then
        vim.api.nvim_create_user_command("Toggle" .. optName, function()
            local key = string.format("_%sEnable", optName)
            vim.g[key] = not vim.g[key]
            local state = vim.g[key] and "Enabled" or "Disabled"
            vim.api.nvim_echo({ { string.format("%s has been %s", optName, state), "Moremsg" } }, false, {})
        end, {})
    end
    return initValue
end -- }}}

-- e.g. "NVIM v0.9.0-dev-1248+g204a8b17c"
-- local nvimVersion = vim.split(vim.api.nvim_exec2("version", {output = true}).output, "\n", {trimempty = true})[1]
-- _G._nvim_version, _G._is_nightly = select(3, string.find(nvimVersion, [[v(%d%.%d%.%d)%-(dev?)]]))

_G._os_uname         = init(vim.loop.os_uname())
_G._is_term          = init(vim.fn.has("gui_running") == 0)
_G._sep              = init(_G._os_uname.sysname == "Windows_NT" and "\\" or "/")
_G._config_path      = init(vim.fn.stdpath("config"))
_G._plugin_root      = init(vim.fn.stdpath("data") .. _G._sep .. "lazy")
_G._format_option    = init("cr/qn2mM1jpl")
_G._trim_space       = init(true, "QuickTrimSpace")
_G._autoreload       = init(true, "Autoreload")
_G._enable_plugin    = init(true)
_G._lisp_language    = init {"clojure", "scheme", "lisp", "racket", "hy", "fennel", "janet", "carp", "wast", "yuck"}
_G._short_line_infos = { -- {{{
    qf = {
        name = "Quickfix",
        icon = icon.ui.Quickfix
    },
    Trouble = {
        name = "Trouble",
        icon = icon.ui.Quickfix
    },
    term = {
        name = "Terminal",
        icon = icon.ui.Terminal
    },
    ["dap-repl"] = {
        name = "Repl",
        icon = icon.ui.Terminal
    },
    dapui_watches = {
        name = "Watchs",
        icon = icon.ui.Watches
    },
    dapui_console = {
        name = "Console",
        icon = icon.ui.DebugConsole
    },
    dapui_stacks = {
        name = "Stacks",
        icon = icon.ui.Stacks
    },
    dapui_breakpoints = {
        name = "Breakpoints",
        icon = icon.ui.Breakpoint
    },
    dapui_scopes = {
        name = "Scopes",
        icon = icon.ui.Scopes
    },
    tsplayground = {
        name = "Tree-sitter Playground",
        icon = icon.kind.Keyword
    },
    Outline = {
        name = "Outline",
        icon = icon.ui.Outline
    },
    startuptime = {
        name = "Startup Time",
        icon = icon.ui.Dashboard
    },
    help = {
        name = "Help",
        icon = icon.ui.Documentation
    },
    NvimTree = {
        name = "Nvim Tree",
        icon = icon.ui.Flag
    },
    DiffviewFiles = {
        name = "Diffview Files",
        icon = icon.ui.Flag
    },
    DiffviewFileHistory = {
    name = "Diffview History",
        icon = icon.ui.History
    },
    HistoryStartup = {
        name = "History Startup",
        icon = icon.ui.History
    }
} -- }}}
_G._short_line_list = vim.tbl_keys(_G._short_line_infos)

vim.g.editorconfig = false
-- Disable built-in plugins
vim.g.loaded_2html_plugin      = 1
vim.g.loaded_getscript         = 1
vim.g.loaded_getscriptPlugin   = 1
vim.g.loaded_gzip              = 1
vim.g.loaded_html_plugin       = 1
vim.g.loaded_logiPat           = 1
vim.g.loaded_matchit           = 0
-- vim.g.loaded_matchparen        = 1
vim.g.loaded_netrw             = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_netrwPlugin       = 1
vim.g.loaded_netrwSettings     = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_tar               = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_vimball           = 1
vim.g.loaded_vimballPlugin     = 1
vim.g.loaded_zip               = 1
vim.g.loaded_zipPlugin         = 1
-- Toggle embed syntax
vim.g.vimsyn_embed = 'lPr'
-- c.vim
vim.g.c_gnu = 1
vim.g.c_ansi_typedefs = 1
vim.g.c_ansi_constants = 1
vim.g.c_no_comment_fold = 1
vim.g.c_syntax_for_h = 1
-- doxygen.vim
vim.g.load_doxygen_syntax= 1
vim.g.doxygen_enhanced_color = 1
-- msql.vim
vim.g.msql_sql_query = 1

-- Global function {{{
require("global.keymap")


_G.Print = function(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
    end

    print(table.concat(objects, '\n'))

    return ...
end


_G.logBuf = function(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
    end
    table.insert(objects, 1, os.date("%Y-%m-%d-%H:%M:%S", os.time()) .. "-------------------------------------------")

    -- Output the result into a new scratch buffer
    if _G._log_buf_nr and vim.api.nvim_buf_is_valid(_G._log_buf_nr) then
        -- if scratch buffer is visible, populate the date into it
        local visibleTick = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == _G._log_buf_nr then
                vim.api.nvim_set_current_win(win)
                vim.cmd [[keepjumps norm! G]]
                vim.api.nvim_put(objects, "l", true, true)
                visibleTick = true
                break
            end
        end
        if not visibleTick then
            local layoutCmd = require("buffer.smartSplit").handler(false)
            vim.cmd(layoutCmd)
            vim.api.nvim_set_current_buf(_G._log_buf_nr)
            vim.api.nvim_put(objects, "l", true, true)
            vim.cmd "wincmd p"
        end
    elseif vim.api.nvim_buf_get_name(0) == "" and vim.bo.modifiable and
            vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
        -- Use current file as the log buffer
        _G._log_buf_nr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_option(_G._log_buf_nr, "bufhidden", "wipe")
        vim.api.nvim_buf_set_option(_G._log_buf_nr, "buftype", "nofile")
        vim.api.nvim_put(objects, "l", true, true)
        -- vim.api.nvim_buf_set_lines(_G._logBufNr, 0, -1, false, objects)
    else
        local layoutCmd = require("buffer.smartSplit").handler(false)
        vim.cmd(layoutCmd)
        _G._log_buf_nr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(_G._log_buf_nr, "bufhidden", "wipe")
        vim.api.nvim_set_current_buf(_G._log_buf_nr)
        vim.api.nvim_put(objects, "l", true, true)
        -- vim.api.nvim_buf_set_lines(_G._logBufNr, 0, -1, false, objects)
        vim.cmd "wincmd p"
    end

    vim.defer_fn(function()
        vim.cmd([[%s#\\n#\r#e]])
        vim.cmd("noh")
    end ,0)

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


--- Return the 1 based index of specific item in a list-liked table. Only support
--- number and string for now
--- @param tbl table list-liked table
--- @param item number|string
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
        local name = vim.api.nvim_buf_get_name(bufNr)
        local retName = name:gsub("/", _G._sep)
        return retName
    else
        return vim.api.nvim_buf_get_name(bufNr)
    end
end

-- }}} Global function
