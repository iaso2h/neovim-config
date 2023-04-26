return function()
    require('sibling-swap').setup {
        allowed_separators = {
            ",",
            ";",
            "and",
            "or",
            "&&",
            "&",
            "||",
            "|",
            "==",
            "===",
            "!=",
            "!==",
            "-",
            "+",
            ["<"] = ">",
            ["<="] = ">=",
            [">"] = "<",
            [">="] = "<=",
        },
        use_default_keymaps = true,
        keymaps = {
            ["<A-l>"]   = "swap_with_right",
            ["<A-h>"]   = "swap_with_left",
            ["<A-S-l>"] = "swap_with_right_with_opp",
            ["<A-S-h>"] = "swap_with_left_with_opp",
        },
        allow_interline_swaps = false,
    }
end
