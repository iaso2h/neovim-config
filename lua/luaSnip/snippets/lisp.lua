-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local luasnip = require("luasnip")
local u       = require("luaSnip.util")

local s             = luasnip.snippet
local sn            = luasnip.snippet_node
local isn           = luasnip.indent_snippet_node
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

return {
s({ trig = "menuinput", dscr = "Prompt user with a menu input"}, -- {{{
    fmt(
        [[
        (if (null defaultValue)
            (setq defaultValue "{1}")
        )
        (initget "{2} {3}")
        (if (null (setq answer
                    (getkword
                      (strcat "\n选择几何图形 [圆弧(A)/圆(C)/多边形(R)/单线(L)/多段线(P)] <" defaultValue ">: ")
                    )
                  )
            )
            (setq answer defaultValue)
            (setq defaultValue answer)
        )
        ]],
        {
            i(1, "Pline"),
            i(2, "Arc Circle Rectangle Line"),
            rep(1)
        }
    )
), -- }}}
}
