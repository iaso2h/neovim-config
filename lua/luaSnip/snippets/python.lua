-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local luasnip = require("luasnip")
local u       = require("luaSnip.util")

local s             = luasnip.snippet
local sn            = luasnip.snippet_node
local isn           = luasnip.indent_snippet_node
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
    s({ trig = "#ig", dscr = "pyright ignore current line" }, -- {{{
        t "# pyright: ignore"
    ), -- }}}
    s({ trig = "#", dscr = "multiline string" }, -- {{{
        fmt(
            [[
            """
            {}
            """
            ]],
            {
                i(0)
            }
        )
    ), -- }}}
    s({ trig = "rt", dscr = "return value" }, -- {{{
        t "return "
    ), -- }}}
    s({ trig = "s", dscr = "self attribute" }, -- {{{
        {
            t "self. ",
            i(1, "attr")
        }
    ), -- }}}
    -- BUG: cursor won't jump to last
    s({ trig = "\\<__\\>", dscr = "magic method", -- {{{
        wordTrig = false,
        regTrig  = true,
        trigEngine = "vim"
    },
        fmt(
            [[__{}__{}]],
            {
                i(1, "init"),
                i(0)
            }
        )
    ), -- }}}
    s({ trig = "ifm", dscr = "if __name__ == __main__"}, -- {{{
        fmt(
            [[
            if __name__ == "__main__":
                {}
            ]],
            {
                i(0),
            }
        )
    ), -- }}}
    s({ trig = [[^\s*\zsim]], name = "import module", -- {{{
        dscr       = "import module",
        wordTrig   = false,
        regTrig    = true,
        trigEngine = "vim"
    },
        t "import "
    ), -- }}}
    s({ trig = [[^\s*\zsfim]], name = "from ... import ...", -- {{{
        dscr       = "from ... import ...",
        wordTrig   = false,
        regTrig    = true,
        trigEngine = "vim"
    },
        fmt(
            [[
            from {} import {}
            ]],
            {
                i(1),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "if", dscr = "if statement"}, -- {{{
        fmt(
            [[
            if {}:
                {}
            ]],
            {
                i(1, "cond"),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "ife", dscr = "if else statement"}, -- {{{
        fmt(
            [[
            if {}:
                {}
            else:
                {}
            ]],
            {
                i(1, "cond"),
                i(2),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "elif", dscr = "elif statement"}, -- {{{
        fmt(
            [[
            elif {}:
                {}
            ]],
            {
                i(1, "cond"),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "else", dscr = "else statement"}, -- {{{
        fmt(
            [[
            else:
                {}
            ]],
            {
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "match", dscr = "match statement"}, -- {{{
        fmt(
            [[
            match {}:
                case {}:
                    {}
                case _:
                    {}
            ]],
            {
                i(1, "val"),
                i(2),
                i(3),
                i(4, "pass"),
            }
        )
    ), -- }}}
    s({ trig = "while", dscr = "while loop statement"}, -- {{{
        fmt(
            [[
            while {}:
                {}
            ]],
            {
                i(1),
                i(0, "pass"),
            }
        )
    ), -- }}}
    s({ trig = "for", dscr = "for loop statement"}, -- {{{
        fmt(
            [[
            for {} in {}:
                {}
            ]],
            {
                i(1, "i"),
                i(2),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "foren", dscr = "for in enumerate statement"}, -- {{{
        fmt(
            [[
            for {}, {} in enumerate({}):
                {}
            ]],
            {
                i(1, "idx"),
                i(2, "i"),
                i(3),
                i(4),
            }
        )
    ), -- }}}
    s({ trig = "forr", dscr = "for in range statement"}, -- {{{
        fmt(
            [[
            for {} in range({}):
                {}
            ]],
            {
                i(1, "i"),
                i(2),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "with", dscr = "with statement"}, -- {{{
        fmt(
            [[
            with {} as {}:
                {}
            ]],
            {
                i(1, ""),
                i(2, "val"),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "lambda", dscr = "lambda statement"}, -- {{{
        fmt(
            [[
            lambda {}: {}
            ]],
            {
                i(1, "i"),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "def", dscr = "function definition"}, -- {{{
        fmt(
            [[
            def {}({}):
            ]],
            {
                i(1, "funcName"),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "class", dscr = "class definition"}, -- {{{
        fmt(
            [[
            class {}({}):
                {}
            ]],
            {
                i(1, "className"),
                i(2),
                i(0, "pass"),
            }
        )
    ), -- }}}
    s({ trig = "classi", dscr = "class definition and initialization"}, -- {{{
        fmt(
            [[
            class {}({}):
                def __ini__({}):
                    {}
            ]],
            {
                i(1, "className"),
                i(2),
                i(3),
                i(4),
            }
        )
    ), -- }}}
    s({ trig = "classi", dscr = "class template"}, -- {{{
        fmt(
            [[
            class {}({}):
                def __ini__({}):
                    {}
            ]],
            {
                i(1, "className"),
                i(2),
                i(3),
                i(4),
            }
        )
    ), -- }}}
    s({ trig = "property", dscr = "property template"}, -- {{{
        fmt(
            [[
            @property
            def {}(self):
                return self.{}
            @{}.setter
            def {}(self, val):
                self._{} = val
            ]],
            {
                i(1, "className"),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
            }
        )
    ), -- }}}
    s({ trig = "try", dscr = "try statement"}, -- {{{
        fmt(
            [[
            try:
                {}
            except:
                {}
            else:
                print("No error occured")
            finnaly:
                pass
            ]],
            {
                i(1),
                i(2),
            }
        )
    ), -- }}}
}

-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
