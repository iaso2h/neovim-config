-- File: all.lua
-- Author: iaso2h
-- Description:
-- Version: 0.0.1
-- Last Modified: 2023 May 11


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

local u = require("luaSnip.util")
local firstLine = function()
    local lineNr = vim.fn.line(".")
    return lineNr == 1
end


return {
    s({ dscr = "Put the date in (Y-m-d) format", trig = "date", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        partial(os.date, "%Y-%m-%d")
    ), -- }}}
    s({ dscr = "Put the date in (Y b d) format", trig = "dateb", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        partial(os.date, "%Y %b %d")
    ), -- }}}
    s({ dscr = "File information", trig = "fi", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt (
            [[
            File: {file}
            Author: iaso2h
            Description: {}
            Version: 0.0.{}
            Last Modified: {date}

            {}
            ]], {
                file = t(vim.fn.expand("%:t")),
                i(1),
                i(2, "1"),
                date = os.date("%Y-%m-%d"),
                i(0),
            }
        ),
        {
            condition = firstLine
        }
    ), -- }}}
    s({ dscr = "Add modeline", trig = "model", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt (
            [[
            vim:ts={}:sts={}:sw={}:ft={}:fdm={}
            ]],
            {
                ch(1, vim.bo.ts == 4 and {t"4", t"2"} or {t"2", t"4"}),
                rep(1),
                rep(1),
                i(2, tostring(vim.bo.ft)),
                i(0, tostring(vim.wo.fdm)),
            }
        )
    ), -- }}}
    s({ dscr = "List current directory", trig = "ls", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fn(u.terminal, {}, { user_args = { "ls" } })
    ), -- }}}
    s({ dscr = "Add separators", trig = "(%d+)%-", -- {{{
            -- BUG:
            regTrig     = true,
            priority    = 1000,
            snippetType = "snippet"
        },
        fn(function(_, snip)
            return string.rep("-" ,tonumber(snip.captures[1]))
        end, {})
    ), -- }}}
}
-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
