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
local getCommentStr = function()
    if vim.bo.commentstring == "" then return "" end

    local ok, msgOrVal = pcall(string.gsub, vim.bo.commentstring, "%s*%%s$", "")
    if not ok then
        vim.api.nvim_echo({{"Failed at retrieving comment string",}}, true, {err=true})
        vim.api.nvim_echo({{msgOrVal,}}, true, {err=true})
        return ""
    else
        return msgOrVal .. " "
    end
end


return {
    s({ trig = "date", dscr = "Put the date in (d/m/Y) format"}, -- {{{
        partial(os.date, "%d/%m/%Y")
    ), -- }}}
    s({ trig = "dateb", dscr = "Put the date in (b d, Y) format"}, -- {{{
        partial(os.date, "%b %d, %Y")
    ), -- }}}
    s({ trig = "fi", dscr = "File information"}, -- {{{
        fmt (
            [[
            {1}File: {file}
            {2}Author: iaso2h
            {3}Description: {6}
            {4}Version: 0.0.{7}
            {5}Last Modified: {date}
            {}]],
            {
                sn(1, partial(getCommentStr)),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                i(2),
                i(3, "1"),
                -- file = partial(function() return vim.fn.expand("%:t") end),
                -- date = partial(function() return os.date("%d/%m/%Y") end),
                file = t(vim.fn.expand("%:t")),
                date = os.date("%Y-%m-%d"),
            }),
        {
            condition      = isFirstLine,
            show_condition = isFirstLine,
        }
    ), -- }}}
    s({ trig = "ml", dscr = "Add modeline", -- {{{
        },
        fmt (
            [[
            {1}vim:ts={2}:sts={3}:sw={4}:ft={5}:fdm={6}
            ]],
            {
                sn(1, partial(getCommentStr)),
                ch(2, vim.bo.ts == 4 and {t"4", t"2"} or {t"2", t"4"}),
                rep(2),
                rep(2),
                i(3, vim.bo.ft),
                i(4, vim.wo.fdm),
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
