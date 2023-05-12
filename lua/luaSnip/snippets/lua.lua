local luasnip = require("luasnip")

local s             = luasnip.snippet
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
return {
    s({ dscr = "Return value", trig = "rt", -- {{{
            priority    = 1000,
        },
        {
            t "return ",
            i(0, "value")
        }
    ), -- }}}
    s({ dscr = "Do return value", trig = "dor", -- {{{
            priority    = 1000,
        },
        {
            t "do return ",
            i(0, "value")
        }
    ), -- }}}
    s({ dscr = "Vim confirm", trig = "vcon", -- {{{
            priority    = 1000,
        },
        -- TODO:
        fmt(
            [[
            vim.cmd echohl {1},
            local answer = vim.fn.confirm("{2}",
            {indent}">>> {3}", {4}, "Question"),
            vim.cmd echohl None
            ]],
            {
                i(1, "MoreMsg"),
                i(2, "&Save\\n&Discard\\n&Cancel"),
                indent = t(string.rep(" ", vim.bo.ts)),
                i(3, "PromptMsg"),
                i(4, "0"),
            }
        )
    ), -- }}}
    s({ dscr = "Vim echo", trig = "vecho", -- {{{
            priority    = 1000,
        },
        fmta(
            [[
            vim.api.nvim_echo({{"<>", "<>"}}, <>, {})
            ]],
            {
                i(1, "msg"),
                i(2, "Normal"),
                i(3, "true")
            }
        )
    ), -- }}}
    s({ dscr = "Vim notify", trig = "vnot", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            vim.notify("{}", vim.log.levels.INFO)
            ]],
            {
                i(1, "msg"),
            }
        )
    ), -- }}}
    s({ dscr = "Vim input", trig = "vin", -- {{{
            priority    = 1000,
        },
        fmta(
            [[
            vim.ui.input({prompt = "<>: "}, function(input),
            <indent><>
            end)
            ]],
            {
                i(1, "PromptMsg"),
                indent = t(string.rep(" ", vim.bo.ts)),
                i(2),
            }
        )
    ), -- }}}
    s({ dscr = "Protect call", trig = "pc", -- {{{
            priority    = 1000,
        },
        -- TODO:
        fmt(
            [[
            local ok, msgOrVal = pcall({1}, {2})
            if not ok then
            {indent}vim.notify(msgOrVal, vim.log.levels.ERROR)
            {indent}{3}
            else
            {indent}{}
            end
            ]],
            {
                i(1, "func"),
                i(2, "args"),
                indent = t(string.rep(" ", vim.bo.ts)),
                i(3),
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "Local variable declaration", trig = "l", -- {{{
            priority    = 1000,
        },
        {
            t"local ",
            i(0, "var"),
        }
    ), -- }}}
    s({ dscr = "Local variable assignment", trig = "ll", -- {{{
            priority    = 1000,
        },
        {
            t"local ",
            i(1, "var"),
            t" = ",
            i(2, "value")
        }
    ), -- }}}
    s({ dscr = "Locally require a module", trig = "lr", -- {{{
            priority    = 1000,
        },
        fmt([[local {} = require("{}")]], {i(1, "var"), i(2, "module")})
    ), -- }}}
    s({ dscr = "Require a module", trig = "rq", -- {{{
            priority    = 1000,
        },
        fmt([[require("{}")]], {i(1, "module")})
    ), -- }}}
    s({ dscr = "If condition", trig = "if", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            if {} then
                {}
            end
            ]],
            {
                i(1, "true"),
                i(2)
            }
        )
    ), -- }}}
    s({ dscr = "Elseif condition", trig = "elif", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            elseif {} then
            ]],
            {
                i(1, "true"),
            }
        )
    ), -- }}}
    s({ dscr = "For loop", trig = "for", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            for i={}, {}, {} do
                {}
            end
            ]],
            {
                i(1, "1"),
                i(2, "10"),
                i(3, "1"),
                i(4)
            }
        )
    ), -- }}}
    s({ dscr = "For in iparis() loop", trig = "fori", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            for {}, {} in ipairs({}) do
                {}
            end
            ]],
            {
                i(1, "i"),
                i(2, "val"),
                i(3, "tbl"),
                i(4)
            }
        )
    ), -- }}}
    s({ dscr = "For in paris() loop", trig = "forp", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            for {}, {} in pairs({}) do
                {}
            end
            ]],
            {
                i(1, "key"),
                i(2, "val"),
                i(3, "tbl"),
                i(4)
            }
        )
    ), -- }}}
    s({ dscr = "While loop", trig = "whi", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            while {} do
                {}
            end
            ]],
            {
                i(1, "true"),
                i(2)
            }
        )
    ), -- }}}
    s({ dscr = "Repeat until", trig = "dow", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            repeat
                {}
            until {}
            ]],
            {
                i(1),
                i(0),
            }
        )
    ), -- }}}
    s({ dscr = "Function definition1", trig = "def", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            function{} ({})
            {indent}{}
            end
            ]],
            {
                i(1, "id"),
                i(2, "args"),
                indent = string.rep(" ", vim.bo.tabstop),
                i(3, "tbl"),
            }
        )
    ), -- }}}
    s({ dscr = "Function definition2", trig = "def", -- {{{
            priority    = 1000,
        },
        fmt(
            [[
            function{} ({})
            {indent}{}
            end
            ]],
            {
                i(1, "id"),
                i(2, "args"),
                indent = string.rep(" ", vim.bo.tabstop),
                i(3, "tbl"),
            }
        )
    ), -- }}}
}

-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
