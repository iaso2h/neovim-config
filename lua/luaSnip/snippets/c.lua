local luasnip = require("luasnip")
local u       = require("luaSnip.util")

local s             = luasnip.snippet
local sn            = luasnip.snippet_node
local ms            = luasnip.multi_snippet
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
    s({ trig = "#inc", dscr = "Include"},  -- {{{
        ch(1, {
            sn(nil, { t "#include <", rst(1, "library"), t ">" }),
            sn(nil, { t '#include "', rst(1, "library"), t '"' }),
        }, {
            stored = {
                ["library"] = i(1, "lib"),
            },
        })
    ), -- }}}
    s({ trig = "#def", dscr = "Textual macro"},  -- {{{
        { t "#define ", i(1, "MACRO") }
    ), -- }}}
    s({ trig = "#deff", dscr = "Function-like macro"},  -- {{{
        fmt(
            [[
            #define {}({}) ({})
            ]], {
                i(1, "MACRO"),
                i(2),
                i(3),
            }
        )
    ), -- }}}
    s({ trig = "mains", dscr = "Standard Starter Template" }, -- {{{
        fmt(
            [[
            #include <stdlib.h>
            #include <stdio.h>



            int main({}) {{
                {}
                return EXIT_SUCCESS;
            }}
            ]], {
                ch(1, {
                    t "void",
                    t "int argc, char *argv[]",
                }),
                i(2)
            }
        )
    ), -- }}}
    s({ trig = "main", dscr = "main() Template" }, -- {{{
        fmt(
            [[
            int main({}) {{
                {}
                return EXIT_SUCCESS;
            }}
            ]], {
                ch(1, {
                    t "void",
                    t "int argc, char *argv[]",
                }),
                i(2)
            }
        )
    ), -- }}}
    s({ trig = "for", dscr = "For loop" }, -- {{{
        fmt(
            [[
            for ({1} {2} = {3}; {4} < {5}; {6} += {7}) {{
                {8}
            }}
            ]], {
                ch(1, {
                    i(nil, "size_t"),
                    i(nil, "int"),
                }),
                i(2, "i"),
                i(3, "1"),
                dy(4, function (nodeRefText, _, _, _)
                    return sn(nil, t(nodeRefText[1][1]))
                end, {2}),
                i(5, "10"),
                dy(6, function (nodeRefText, _, _, _)
                    return sn(nil, t(nodeRefText[1][1]))
                end, {2}),
                i(7, "1"),
                i(8)
            }
        )
    ), -- }}}
    s({ trig = "forr", dscr = "For loop reversely" }, -- {{{
        fmt(
            [[
            for ({1} {2} = {3}; {4} > {5}; {6} -= {7}) {{
                {8}
            }}
            ]], {
                ch(1, {
                    i(nil, "size_t"),
                    i(nil, "int"),
                }),
                i(2, "i"),
                i(3, "1"),
                dy(4, function (nodeRefText, _, _, _)
                    return sn(nil, t(nodeRefText[1][1]))
                end, {2}),
                i(5, "0"),
                dy(6, function (nodeRefText, _, _, _)
                    return sn(nil, t(nodeRefText[1][1]))
                end, {2}),
                i(7, "1"),
                i(8)
            }
        )
    ), -- }}}
}
