return function()
    require("nvim-autopairs").setup {
        disable_filetype          = vim.list_extend(
            { "TelescopePrompt", "dap-repl" }, _G._lisp_language),
        disable_in_macro          = true,
        disable_in_visualblock    = true,
        disable_in_replace_mode   = true,
        ignored_next_char         = [=[[%w%%%'%[%"%.%`%$]]=],
        enable_moveright          = true,
        enable_afterquote         = true, -- add bracket pairs after quote
        enable_check_bracket_line = true, -- check bracket in same line
        enable_bracket_in_quote   = false,
        enable_abbr               = false, -- trigger abbreviation
        break_undo                = true, -- switch for basic rule break undo sequence
        check_ts                  = true,
        map_cr                    = true,
        map_bs                    = true,
        map_c_h                   = false,
        map_c_w                   = false,
        fast_wrap                 = {
            map = "<C-f>",
            chars = { '{', '[', '(', '"', "'" },
            pattern = [=[[%'%"%>%]%)%}%,]]=],
            end_key = '$',
            keys = 'qwertyuiopzxcvbnmasdfghjkl',
            check_comma = true,
            highlight = 'Search',
            highlight_grey = 'Comment'
        },
    }
end
