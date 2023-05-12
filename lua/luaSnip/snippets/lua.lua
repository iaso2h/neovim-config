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
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        {
            t "return ",
            i(0, "value")
        }
    ), -- }}}
    s({ dscr = "Do return value", trig = "dor", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        {
            t "do return ",
            i(0, "value")
        }
    ), -- }}}
    s({ dscr = "Vim confirm", trig = "vcon", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
                i(0),
            }
        )
    ), -- }}}
    s({ dscr = "Protect call", trig = "pc", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        {
            t"local ",
            i(1, "var"),
        }
    ), -- }}}
    s({ dscr = "Local variable assignment", trig = "ll", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        {
            t"local ",
            i(1, "var"),
            t" = ",
            i(2, "value")
        }
    ), -- }}}
    s({ dscr = "Locally require a module", trig = "lr", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt([[local {} = require("{}")]], {i(1, "var"), i(2, "module")})
    ), -- }}}
    s({ dscr = "Require a module", trig = "rq", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt([[require("{}")]], {i(1, "module")})
    ), -- }}}
    s({ dscr = "If condition", trig = "if", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt(
            [[
            if {} then
                {}
            end
            ]],
            {
                i(1, "true"),
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "Elseif condition", trig = "elif", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt(
            [[
            elseif {} then
            ]],
            {
                i(0, "true"),
            }
        )
    ), -- }}}
    s({ dscr = "For loop", trig = "for", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "For in iparis() loop", trig = "fori", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "For in paris() loop", trig = "forp", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "While loop", trig = "whi", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt(
            [[
            while {} do
                {}
            end
            ]],
            {
                i(1, "true"),
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "Repeat until", trig = "dow", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
        },
        fmt(
            [[
            repeat
                {}
            until {}
            ]],
            {
                i(1),
                i(0)
            }
        )
    ), -- }}}
    s({ dscr = "Function definition1", trig = "def", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
                i(0, "tbl"),
            }
        )
    ), -- }}}
    s({ dscr = "Function definition2", trig = "def", -- {{{
            regTrig     = false,
            priority    = 1000,
            snippetType = "snippet"
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
                i(0, "tbl"),
            }
        )
    ), -- }}}
}

-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
