local icon = require("icon")

local initHelper = function(initValue, cmdName, globalKey) -- {{{
    if cmdName and globalKey then
        vim.api.nvim_create_user_command("Toggle" .. cmdName, function()
            _G[globalKey] = not _G[globalKey]

            local state = _G[globalKey] and "Enabled" or "Disabled"
            vim.api.nvim_echo({ { string.format("%s has been %s", cmdName, state), "Moremsg" } }, false, {})
        end, {})
    end
    return initValue
end -- }}}

-- e.g. "NVIM v0.9.0-dev-1248+g204a8b17c"
-- local nvimVersion = vim.split(vim.api.nvim_exec2("version", {output = true}).output, "\n", {trimempty = true})[1]
-- _G._nvim_version, _G._is_nightly = select(3, string.find(nvimVersion, [[v(%d%.%d%.%d)%-(dev?)]]))

_G._float_win_border   = initHelper("rounded")
_G._os_uname           = initHelper(vim.loop.os_uname())
_G._is_term            = initHelper(vim.fn.has("gui_running") == 0)
_G._sep                = initHelper(_G._os_uname.sysname == "Windows_NT" and "\\" or "/")
_G._config_path        = initHelper(vim.fn.stdpath("config"))
_G._plugin_root        = initHelper(vim.fn.stdpath("data") .. _G._sep .. "lazy")
_G._format_option      = initHelper("cr/qn2mM1jpl")
_G._trim_space_on_save = initHelper(true, "TrimSpaceOnSave", "_trim_space_on_save")
_G._autoreload         = initHelper(false, "Autoreload", "_autoreload")
_G._enable_plugin      = initHelper(true)
_G._lisp_language      = initHelper {"query", "clojure", "scheme", "lisp", "racket", "hy", "fennel", "janet", "carp", "wast", "yuck"}

_G._treesitter_supported_languages = {} -- {{{
-- Credit: https://github.com/spywhere/detect-language.nvim/blob/2aa314ed46b68d89fe939cf3ecb12933c71ce49f/lua/detect-language/provider/treesitter.lua#L26
local parsers = vim.api.nvim_get_runtime_file('parser/*', true)
for _, parser in ipairs(parsers) do
    local language = string.gsub(parser, '.*[\\/]', '')
    language = string.gsub(language, '[.][^.]*$', '')
    _G._treesitter_supported_languages[language] = true
end -- }}}

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
    lazy = {
        name = "Lazy",
        icon = ""
    },
    LogBuffer = {
        name = "Log Buffer",
        icon = icon.ui.NewFile
    },
    Messages = {
        name = "Messages",
        icon = icon.ui.Dashboard
    },
    Mason = {
        name = "Mason",
        icon = ""
    },
    checkhealth = {
        name = "Checkhealth",
        icon = icon.diagnostics.Doctor
    },
    ["dap-float"] = {
        name = "Dap Float",
        icon = ""
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
    Outline = {
        name = "Outline",
        icon = icon.ui.Outline
    },
    startuptime = {
        name = "Startup Time",
        icon = icon.ui.Dashboard
    },
    tsplayground = {
        name = "Tree-sitter Playground",
        icon = icon.kind.Keyword
    },
    man = {
        name = "Manual",
        icon = icon.ui.Documentation
    },
    help = {
        name = "Help",
        icon = icon.ui.Documentation
    },
    NvimTree = {
        name = "Nvim Tree",
        icon = icon.ui.Flag
    },
    gitcommit = {
        name = "Git commit",
        icon = icon.git.Octocat
    },
    ["gitsigns-blame"] = {
        name = "Git Blame",
        icon = icon.git.Octocat
    },
    git = {
        name = "Git",
        icon = icon.git.Octocat
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
vim.g.loaded_matchit           = 1
vim.g.loaded_matchparen        = 1
vim.g.loaded_netrw             = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_netrwPlugin       = 1
vim.g.loaded_netrwSettings     = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_tar               = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_tutor_mode_plugin = 1
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


--- Print the objects
---@vararg any
_G.Print = function(...) -- {{{
    local objects = {}
    for i = 1, select('#', ...) do
        local obj = select(i, ...)
        table.insert(objects, vim.inspect(obj))
    end

    print(table.concat(objects, '\n'))

    return ...
end -- }}}
--- Print the objects in a scratch buffer
---@vararg any
_G.logBuf = function(...) -- {{{
    local objects = {}
    for i = 1, select('#', ...) do
        local obj = select(i, ...)
        vim.list_extend(objects, vim.split(vim.inspect(obj), "\n", {plain=true}))
    end
    table.insert(objects, 1, os.date("-----" .. vim.fn.bufname() .. ": %Y-%m-%d-%H:%M:%S", os.time()) .. "-----")

    -- Output the result into a new scratch buffer
    _G._log_buf_nr = require("buffer.util").redirScratch(objects, _G._log_buf_nr, true)
    vim.api.nvim_set_option_value("filetype", "LogBuffer", {buf = _G._log_buf_nr})
end -- }}}
--- Remove value from list-liked lua table
---@param tbl table List-like table
---@param srcVal any Source value to be look up and removed
---@param removeAllChk boolean|nil Default is true. Whether to remove the
--all values or not
---@param cnt integer|nil default is 1. Determine how many value
--will be removed when firstOnlyChk is false
---@return integer|table|nil Index of the value. Index of table will be return
--when there are more than one idx to be return. nil will be return when no idx found
local tbl_remove = function(tbl, srcVal, removeAllChk, cnt) -- {{{
    assert(next(tbl), "Empty table is not allowed")
    assert(vim.islist(tbl), "Expect list-liked table")

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
end -- }}}
--- Replace value1 inside list-like table with value2
---@param tbl          table   List-like table of which value to be replaced
---@param repVal       any     Value to replace with
---@param srcVal       any     Source value to be replaced
---@param repAllChk?   boolean Default is true. Whether to replace all value or not
---@param cnt?         integer  Default is 1. Determine how many srcVal will be replaced
---@param alertOnFail? boolean Default is false. Whether to alert when
--replace failed
---@return nil
_G.tbl_replace = function(tbl, repVal, srcVal, repAllChk, cnt, alertOnFail) -- {{{
    repAllChk = repAllChk or true
    cnt = cnt or 1
    alertOnFail = alertOnFail or false

    local idx = tbl_remove(tbl, srcVal, repAllChk, cnt)
    if not idx then
        if alertOnFail then
            return vim.api.nvim_echo({ { "Source value instance not found", "WarningMsg" } }, true, {})
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
end -- }}}
--- Return the 1 based index of specific item in a list-liked table. Only support
--- number and string for now
--- @param tbl    table List-liked table
--- @param item   integer|string Item to look up
--- @param allIdx boolean Whether to return all the indexes as a table
--- @return integer|integer[] # Return table when `returnIdxTbl` is true
_G.tbl_idx = function(tbl, item, allIdx) -- {{{
    assert(vim.islist(tbl), "Expect list-liked table")
    assert(type(item) == "string" or type(item) == "number", "Only support indexing string or number")
    local idxTbl = {}
    for idx, i in ipairs(tbl) do
        if i == item then
            if not allIdx then
                return idx
            else
                idxTbl[#idxTbl+1] = idx
            end
        end
    end

    if not allIdx then
        return -1
    else
        return idxTbl
    end
end -- }}}
--- Unify separators in value returned by vim.api.nvim_buf_get_name()
---@param bufNr? integer Buffer number. Default is 0 (the current buffer)
---@return string # Buffer name
_G.nvim_buf_get_name = function(bufNr) -- {{{
    bufNr = bufNr or 0
    if _G._os_uname.sysname == "Windows_NT" then
        local name = vim.api.nvim_buf_get_name(bufNr)
        local retName = name:gsub("/", _G._sep)
        return retName
    else
        return vim.api.nvim_buf_get_name(bufNr)
    end
end -- }}}
--- Always make separator in a path string unified according to operating system
---@param pathStr string
---@return string
_G.pathStr = function(pathStr) -- {{{
    return _G._os_uname.sysname ~= "Windows_NT" and pathStr or string.gsub(pathStr, "/", _G._sep)
end -- }}}
-- }}} Global function
