local M = {}

local luasnip = require("luasnip")

local s             = luasnip.snippet
local p             = luasnip.parser.parse_snippet
local node          = luasnip.snippet_node
local t             = luasnip.text_node
local i             = luasnip.insert_node
local fn            = luasnip.function_node
local ch            = luasnip.choice_node
local dy            = luasnip.dynamic_node
local rst           = luasnip.restore_node
local lambda        = require("luasnip.extras").lambda
local rep           = require("luasnip.extras").rep
local partial       = require("luasnip.extras").partial
local match         = require("luasnip.extras").match
local nonempty      = require("luasnip.extras").nonempty
local lambdaDynamic = require("luasnip.extras").dynamic_lambda
local fmt           = require("luasnip.extras.fmt").fmt
local fmta          = require("luasnip.extras.fmt").fmta
local types         = require("luasnip.util.types")
local conds         = require("luasnip.extras.conditions")
local condsExpand   = require("luasnip.extras.conditions.expand")


--- Return output of terminal command
---@param command string
---@return string[]
M.terminal = function(_, _, command) -- {{{
    local file = io.popen(command, "r")
    local res = {}
    if not file then
        vim.api.nvim_echo({ { "No output", "WarningMsg" } }, true, {})
    end
    for line in file:lines() do
        table.insert(res, line)
    end
    return res
end -- }}}
--- Check whether a buffer is in a snippet directory path
---@param line_to_cursor string
---@return boolean
M.inSnippetDir = function(line_to_cursor, _, _) -- {{{
    if not string.match(line_to_cursor, "^%s*dy$") then return false end

    local bufName = nvim_buf_get_name(vim.api.nvim_get_current_buf())
    return string.match(bufName, pathStr(_G._config_path .. "/lua/luaSnip/"))
end -- }}}


return M
