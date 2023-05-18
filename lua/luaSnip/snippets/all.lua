local luasnip = require("luasnip")
local u       = require("luaSnip.util")

local s             = luasnip.snippet
local sn            = luasnip.snippet_node
local t             = luasnip.text_node
local i             = luasnip.insert_node
local fn            = luasnip.function_node
local ch            = luasnip.choice_node
local dy            = luasnip.dynamic_node
local rst           = luasnip.restore_node
local p             = luasnip.parser.parse_snippet
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
-- LUARUN: vim.cmd [[h luasnip-snippets]]

local isFirstLine = function()
    return vim.fn.line(".") == 1
end
local isLastLine = function ()
    return vim.fn.line(".") == vim.api.nvim_buf_line_count(0)
end


return {
    s({ trig = "date", dscr = "Put the date in (Y-m-d) format"}, -- {{{
        partial(os.date, "%Y-%m-%d")
    ), -- }}}
    s({ trig = "dateb", dscr = "Put the date in (Y b d) format"}, -- {{{
        partial(os.date, "%Y %b %d")
    ), -- }}}

    s({ trig = "fi", dscr = "File information"}, -- {{{
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
            condition      = isFirstLine,
            show_condition = isFirstLine
        }
    ), -- }}}
    s({ trig = "ml", dscr = "Add modeline", -- {{{
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
        ),
        {
            condition      = isLastLine,
            show_condition = isLastLine
        }
    ), -- }}}
    s({ trig = "ls", dscr = "List current directory", -- {{{
        },
        fn(u.terminal, {}, { user_args = { "ls" } })
    ), -- }}}
    s({ trig = "(%d+)([-=*])", dscr = "Add separators", -- {{{
        regTrig = true },
        fn(function(_, snip)
            return string.rep(snip.captures[2], tonumber(snip.captures[1]))
        end, {}),
        {
            show_condition = function() return false end
        }
    ), -- }}}
}
-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
