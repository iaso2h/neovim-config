local luasnip = require("luasnip")

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


return {
    s({ trig = "rt", dscr = "Return value"}, -- {{{
        {
            t "return ",
            i(0, "value")
        }
    ), -- }}}
    s({ trig = "dor", dscr = "Do return value"}, -- {{{
        {
            t "do return ",
            i(0, "value")
        }
    ), -- }}}
    s({ trig = "vcon", dscr = "Vim confirm"}, -- {{{
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
    s({ trig = "vecho", dscr = "Vim echo"}, -- {{{
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
    s({ trig = "vnot", dscr = "Vim notify"}, -- {{{
        fmt(
            [[
            vim.notify("{}", vim.log.levels.INFO)
            ]],
            {
                i(1, "msg"),
            }
        )
    ), -- }}}
    s({ trig = "vin", dscr = "Vim input"}, -- {{{
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
    s({ trig = "pc", dscr = "Protect call"}, -- {{{
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
    s({ trig = "l", dscr = "Local variable declaration"}, -- {{{
        {
            t"local ",
            i(0, "var"),
        }
    ), -- }}}
    s({ trig = "ll", dscr = "Local variable assignment"}, -- {{{
        {
            t"local ",
            i(1, "var"),
            t" = ",
            i(2, "value")
        }
    ), -- }}}
    s({ trig = "lr", dscr = "Locally require a module"}, -- {{{
        fmt([[local {} = require("{}")]], {i(1, "var"), i(2, "module")})
    ), -- }}}
    s({ trig = "rq", dscr = "Require a module"}, -- {{{
        fmt([[require("{}")]], {i(1, "module")})
    ), -- }}}
    s({ trig = "if", dscr = "If condition"}, -- {{{
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
    s({ trig = "elif", dscr = "Elseif condition"}, -- {{{
        fmt(
            [[
            elseif {} then
            ]],
            {
                i(1, "true"),
            }
        )
    ), -- }}}
    s({ trig = "for", dscr = "For loop"}, -- {{{
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
    s({ trig = "fori", dscr = "For in iparis() loop"}, -- {{{
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
    s({ trig = "forp", dscr = "For in paris() loop"}, -- {{{
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
    s({ trig = "whi", dscr = "While loop"}, -- {{{
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
    s({ trig = "dow", dscr = "Repeat until"}, -- {{{
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
    s({ trig = "def", dscr = "Function definition1"}, -- {{{
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
    s({ trig = "fnnode", dscr = "Luasnip function node"}, -- {{{
        fmt(
            [[
            f(function (nodeRefText, parent, userArgs)
                {}
            end, {}, {})
            ]],
            {
                i(1),
                i(2, "nodeRefs"),
                ch(3, {
                    t "userParams",
                    t "{user_args = }",
                }),
            }
        )
    ), -- }}}
}

-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
