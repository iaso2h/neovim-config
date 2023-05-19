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
local ai            = require("luasnip.nodes.absolute_indexer")
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
                library = i(1, "lib"),
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
        fmta(
            [[
            int main(<>) {
                <>
                return EXIT_SUCCESS;
            }
            ]], {
                ch(1, {
                    t "void",
                    t "int argc, char *argv[]",
                }),
                i(2)
            }
        )
    ), -- }}}
s({ trig = "if", dscr = "If block"}, -- {{{
    fmta(
        [[
        if (<>) {
            <>
        }
        ]],
        {
            i(1, "true"),
            ch(2, {
                sn(nil, rst(1, "codeblock1")),
                sn(nil, {
                    rst(1, "codeblock1"),
                    t {"", "} else {", "    "},
                    rst(2, "codeblock2"),
                }),
            }, {
                stored = {
                    codeblock1 = i(1, "codeblock"),
                    codeblock2 = i(1, "codeblock")
                }
            }),
        }
    )
), -- }}}
s({ trig = "elif", dscr = "Elseif block"}, -- {{{
    fmta(
        [[
        elseif (<>) {
            <>
        }
        ]],
        {
            i(1, "true"),
            i(2)
        }
    )
), -- }}}
s({ trig = "el", dscr = "Else block"}, -- {{{
    fmta(
        [[
        else {
            <>
        }
        ]],
        {
            i(0)
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
                rep(2),
                i(4, "10"),
                rep(2),
                i(5, "1"),
                i(6)
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
                rep(2),
                i(4, "0"),
                rep(2),
                i(5, "1"),
                i(6)
            }
        )
    ), -- }}}
    s({ trig = "whi", dscr = "While loop"}, -- {{{
        fmta(
            [[
            while (<1>) {
                <2>
            }
            ]],
            {
                i(1, "true"),
                i(2)
            }
        )
    ), -- }}}
    s({ trig = "dow", dscr = "Do while loop"}, -- {{{
        fmta(
            [[
            do
                <2>
            while (<1>);
            ]],
            {
                i(1, "true"),
                i(2)
            }
        )
    ), -- }}}

    s({ trig = "rt", dscr = "Return value" }, -- {{{
        {
            t "return ",
            i(1, "val"),
            t ";"
        }
    ), -- }}}
    s({ trig = "ex", dscr = "exit()" }, -- {{{
        {
            t "exit(",
            i(1),
            t ");"
        }
    ), -- }}}

    ms({ "def", "fu", common = {dscr = "Function declaration and definition"} }, -- {{{
        fmta(
            [[
            <3> <1>(<2>)<4>
            ]],
            {
                i(1, "id"),
                i(2),
                i(3, "void"), -- ai[3]
                ch(4, {
                    sn(nil, i(1, ";")),
                    sn(nil, {
                        t {" {", "    "},
                        rst(1, "codeblock"),
                        dy(2, function (nodeRefText, _, _, _)
                            if nodeRefText[1][1] == "void" then
                                return sn(nil, t "")
                            else
                                return sn(nil, {
                                    t {"", "    return "},
                                    i(1),
                                    t ";"
                                })
                            end
                        end, ai[3]),
                        t {"", "}"},
                    }, {
                        stored = {
                            codeblock = i(1, "lib"),
                        },
                    })
                }),
            }
        )
    ), -- }}}
}
