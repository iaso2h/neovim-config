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
            sn(nil, { t("return "),    rst(1, "value") }),
            sn(nil, { t("do return "), rst(1, "value"), t(" end") }),
        }, {
            stored = {
                ["value"] = i(1, "val"),
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
        fmt(
            [[
            local ok, {1} = pcall({2}, {3})
            if not ok then
                {4}
                {5}
            {6}
            end
            ]],
            {
                ch(1, {
                    i(nil, "msgOrVal"),
                    t "_"
                }),
                i(2, "func"),
                i(3, "args"),
                dy(4, function (nodeRefText, _, _, _)
                    if nodeRefText[1][1] == "_" then
                        return sn(nil, t "")
                    else
                        return sn(nil, {
                            t "vim.notify(msgOrVal, vim.log.levels.",
                            ch(1, {
                                i(nil, "ERROR"),
                                i(nil, "WARN"),
                                i(nil, "INFO"),
                            }),
                            t ")"
                        })
                    end
                end, {1}),
                i(5),
                ch(6, {
                    sn(nil, {
                        t {"else", "    "},
                        i(1, "codeblock"),
                    }),
                    t ""
                }),
            }
        )
    ), -- }}}
    s({ trig = "ll", dscr = "Local variable assignment"}, -- {{{
        ch(1, {
            sn(
                nil,
                {
                    t"local ",
                    rst(1, "identifier"),
                }
            ),
            sn(
                nil,
                {
                    t"local ",
                    rst(1, "identifier"),
                    t" = ",
                    i(2, "val")
                }
            )
        }, {
            stored = {
                ["identifier"] = i(1, "var"),
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
    s({ trig = "whi", dscr = "While loop"}, -- {{{
        ch(1, {
            sn(nil, {
                t "while ",
                rst(1, "condition"),
                t{" do", "    "},
                rst(2, "block"),
                t{"", "end"}
            }),
            sn(nil, {
                t{"repeat", "    "},
                rst(2, "block"),
                t{"", "until "},
                rst(1, "condition"),
            }),
        }, {
            stored = {
                ["condition"] = i(1, "true"),
                ["block"]     = i(2, "codeblock"),
            },
        })
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
            fn({}, function ({2}{3}, {4})
                {5}
            end{6}{7})
            ]],
            {
                i(1, "idx"),
                ch(2, {
                    i(nil, "nodeRefText"),
                    t "_",
                }),
                ch(3, {
                    t ", parent",
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
                end, {2}),
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
    s({ trig = "lsdy", dscr = "Luasnip dynamic node"}, -- {{{
        fmt(
            [[
            dy({1}, function ({2}{3}{4}, {5})
                {6}
            end{7}{8})
            ]],
            {
                i(1, "idx"),
                ch(2, {
                    i(nil, "nodeRefText"),
                    t "_",
                }),
                ch(3, {
                    t ", parent",
                    t ", _",
                }),
                ch(4, {
                    t ", oldState",
                    t ", _",
                }),
                ch(5, {
                    i(nil, "userArgs"),
                    t "_",
                }),
                i(6),
                dy(7, function(nodeRefText, _, _, _)
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
                end, {2}),
                dy(8, function(nodeRefText, _, _, _)
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
                end, {5}),
            }
        )
    ), -- }}}
}

-- vim:ts=4:sts=4:sw=4:ft=lua:fdm=marker
