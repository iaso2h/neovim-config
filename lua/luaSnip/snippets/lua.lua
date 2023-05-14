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
    s({ trig = "rt", dscr = "Return value" }, -- {{{
        ch(1, {
            sn(nil, { t("return "),    rst(1, "user_text") }),
            sn(nil, { t("do return "), rst(1, "user_text"), t(" end") }),
        }, {
            stored = {
                ["user_text"] = i(1, "val"),
            },
        })
    ), -- }}}
    s({ trig = "vcon", dscr = "Vim confirm"}, -- {{{
        -- TODO:
        fmt(
            [[
            vim.cmd echohl {1},
            local answer = vim.fn.confirm("{2}",
                ">>> {3}", {4}, "Question"),
            vim.cmd echohl None
            ]],
            {
                i(1, "MoreMsg"),
                i(2, "&Save\\n&Discard\\n&Cancel"),
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
                <>
            end)
            ]],
            {
                i(1, "PromptMsg"),
                i(0),
            }
        )
    ), -- }}}
    s({ trig = "pc", dscr = "Protect call"}, -- {{{
        -- TODO:
        fmt(
            [[
            local ok, msgOrVal = pcall({1}, {2})
            if not ok then
                vim.notify(msgOrVal, vim.log.levels.ERROR)
                {3}
            else
                {}
            end
            ]],
            {
                i(1, "func"),
                i(2, "args"),
                i(3),
                i(0)
            }
        )
    ), -- }}}
    s({ trig = "ll", dscr = "Local variable assignment"}, -- {{{
        ch(1, {
            sn(
                nil,
                {
                    t"local ",
                    rst(1, "user_text"),
                }
            ),
            sn(
                nil,
                {
                    t"local ",
                    rst(1, "user_text"),
                    t" = ",
                    i(2, "val")
                }
            )
        }, {
            stored = {
                ["user_text"] = i(1, "var"),
            },
        })
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
                {}
            ]],
            {
                i(1, "true"),
                i(0)
            }
        )
    ), -- }}}
    s({ trig = "else", dscr = "Elseif condition"}, -- {{{
        fmt(
            [[
            else
                {}
            ]],
            {
                i(0)
            }
        )
    ), -- }}}
    s({ trig = "for", dscr = "For loop"}, -- {{{
        fmt(
            [[
            for {1}={2}, {3}, {4} do
                {}
            end
            ]],
            {
                i(1, "i"),
                i(2, "1"),
                i(3, "10"),
                i(4, "1"),
                i(0)
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
                ch(1, {
                    i(nil, "i"),
                    t("_")
                }),
                ch(2, {
                    i(nil, "val"),
                    t("_")
                }),
                i(3, "tbl"),
                i(0)
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
                ch(1, {
                    i(nil, "key"),
                    t("_")
                }),
                ch(1, {
                    i(nil, "val"),
                    t("_")
                }),
                i(3, "tbl"),
                i(0)
            }
        )
    ), -- }}}
    -- TODO: merge while loop with repeat loop
    s({ trig = "whi", dscr = "While loop"}, -- {{{
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
            function{}({})
                {}
            end
            ]],
            {
                ch(1, {
                        sn(1, {
                            t " ",
                            i(1, "id"),
                            t " "
                        }),
                        t ""
                    }
                ),
                i(2, "args"),
                i(3, "tbl"),
            }
        )
    ), -- }}}
    s({ trig = "lsfn", dscr = "Luasnip function node"}, -- {{{
        fmt(
            [[
            fn(function ({1}{2}, {3})
                {4}
            end{5}{6})
            ]],
            {
                ch(1, {
                    i(nil, "nodeRefText"),
                    t "_",
                }),
                ch(2, {
                    t ", parent",
                    t ", _",
                }),
                ch(3, {
                    i(nil, "userArgs"),
                    t "_",
                }),
                i(4),
                dy(5, function(nodeRefText, _, _, _)
                    local text = nodeRefText[1][1]
                    if text == "_" then
                        return sn(nil, {t ", nil"})
                    else
                        return sn(
                            nil,
                            {
                                t ", {",
                                i(1, "nodeRef"),
                                t "}"
                            }
                        )
                    end
                end, {1}),
                dy(6, function(nodeRefText, _, _, _)
                    local text = nodeRefText[1][1]
                    if text == "_" then
                        return sn(nil, {t ""})
                    else
                        return sn(
                            nil,
                            {
                                ch(
                                    1, {
                                        sn(nil, {
                                            t ", ",
                                            i(1, "userParams"),
                                        }),
                                        sn(nil, {
                                            t ", {user_args = ",
                                            i(1),
                                            t "}"
                                        }),
                                    }
                                )
                            }
                        )
                    end
                end, {3}),
            }
        )
    ), -- }}}
    s({ trig = "lsdy", dscr = "Luasnip dynamic node"}, -- {{{
        fmt(
            [[
            dy(function ({1}{2}{3}, {4})
                {5}
            end{6}{7})
            ]],
            {
                ch(1, {
                    i(nil, "nodeRefText"),
                    t "_",
                }),
                ch(2, {
                    t ", parent",
                    t ", _",
                }),
                ch(3, {
                    t ", oldState",
                    t ", _",
                }),
                ch(4, {
                    i(nil, "userArgs"),
                    t "_",
                }),
                i(5),
                dy(6, function(nodeRefText, _, _, _)
                    local text = nodeRefText[1][1]
                    if text == "_" then
                        return sn(nil, {t ", nil"})
                    else
                        return sn(
                            nil,
                            {
                                t ", {",
                                i(1, "nodeRef"),
                                t "}"
                            }
                        )
                    end
                end, {1}),
                dy(7, function(nodeRefText, _, _, _)
                    local text = nodeRefText[1][1]
                    if text == "_" then
                        return sn(nil, {t ""})
                    else
                        return sn(
                            nil,
                            {
                                ch(
                                    1, {
                                        sn(nil, {
                                            t ", ",
                                            i(1, "userParams"),
                                        }),
                                        sn(nil, {
                                            t ", {user_args = ",
                                            i(1),
                                            t "}"
                                        }),
                                    }
                                )
                            }
                        )
                    end
                end, {4}),
            }
        )
    ), -- }}}
}

-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
