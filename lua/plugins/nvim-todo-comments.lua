return function()
    local icon = require("icon")
    require("todo-comments").setup {
        signs = false, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        keywords = {
            FIX    = {
                icon  = icon.diagnostics.DebugBold .. " ",            -- icon used for the sign, and in search results
                color = "error",                                      -- can be a hex color, or a named color (see below)
                alt   = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" },  -- a set of other keywords that all map to this FIX keywords
            },
            TODO   = {
                icon = icon.ui.Comment .. " ",
                color = "warning"
            },
            HACK   = {
                icon = icon.ui.Fire .. " ",
                color = "error",
                alt = { "UGLY" }
            },
            WARN   = {
                icon = icon.diagnostics.WarningBold .. " ",
                color = "warning",
                alt = { "WARNING", "XXX" }
            },
            NOTE   = {
                icon = icon.ui.Note .. " ",
                color = "hint",
                alt = { "INFO", "DEBUG" }
            },
            TEST   = {
                icon = icon.ui.Test .. " ",
                color = "test",
                alt = { "TESTING", "PASSED", "FAILED" }
            },
            PERF   = {
                icon = icon.ui.Dashboard .. " ",
                alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" }
            },
            LUARUN = {
                icon = icon.ui.Lua .. " ",
                color = "hint"
            },
            VIMRUN = {
                icon = icon.ui.Vim .. " ",
                color = "hint"
            }
        },
        gui_style = {
            fg = "NONE",  -- The gui style to use for the fg highlight group.
            bg = "BOLD",  -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
            multiline         = true,          -- enable multiline todo comments
            multiline_pattern = "^.",          -- lua pattern to match the next multiline from the start of the matched keyword
            multiline_context = 10,            -- extra lines that will be re-evaluated when changing a linekeyword       = "wide",                 -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
            before            = "",            -- "fg" or "bg" or empty
            keyword           = "wide",        -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
            after             = "fg",          -- "fg" or "bg" or empty
            pattern           = [[.*<(KEYWORDS)\s*:]], -- pattern used for highlighting (vim regex)
            comments_only     = true,          -- uses treesitter to match keywords in comments only
            max_line_len      = 400,           -- ignore lines longer than this
            exclude           = {},            -- list of file types to exclude highlighting
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of highlight groups or use the hex color if hl not found as a fallback
        colors = {
            error   = { "DiagnosticError", "ErrorMsg", "#DC2626" },
            warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
            info    = { "DiagnosticInfo", "#2563EB" },
            hint    = { "DiagnosticHint", "#10B981" },
            default = { "Identifier", "#7C3AED" },
            test    = { "Identifier", "#FF00FF" }
        },
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
            -- regex that will be used to match keywords.
            -- don't replace the (KEYWORDS) placeholder
            pattern = [[\b(KEYWORDS):]], -- ripgrep regex
            -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
        },
    }

    vim.api.nvim_create_user_command("TodoTelescope", "Telescope todo-comments todo theme=ivy",
        { desc = "Telescope todo" })
    map("n", [[<C-f>t]], [[<CMD>TodoTelescope<CR>]], { "silent" }, "Todo")
    map("n", [[<C-q>t]], [[<CMD>TodoQuickFix<CR>]], { "silent" }, "Toggle todo in quickfix")

    vim.keymap.set("n", "]t", function()
        require("todo-comments").jump_next()
    end, { desc = "Next todo comment" })

    vim.keymap.set("n", "[t", function()
        require("todo-comments").jump_prev()
    end, { desc = "Previous todo comment" })

    -- You can also specify a list of valid jump keywords
    -- vim.keymap.set("n", "]t", function() require("todo-comments").jump_next({keywords = { "ERROR", "WARNING" }}) end, { desc = "Next error/warning todo comment" })
end
