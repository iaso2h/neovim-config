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


M.terminal = function(_, _, command)
    local file = io.popen(command, "r")
    local res = {}
    if not file then
        vim.notify("No output", vim.log.levels.WARN)
    end
    for line in file:lines() do
        table.insert(res, line)
    end
    return res
end


return M
