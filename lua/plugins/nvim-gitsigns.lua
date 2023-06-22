return function()
    local onAttach = function()
        local gs = package.loaded.gitsigns
        map("n", [[<C-h>s]], gs.stage_hunk, "Gitsigns stage hunk")
        map(
            "x",
            [[<C-h>s]],
            function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
            "Gitsigns stage hunk"
        )
        map("n", [[<C-h>S]], gs.stage_buffer, "Gitsigns stage buffer")

        map("n", [[<C-h>r]], gs.reset_hunk, "Gitsigns reset hunk")
        map(
            "x",
            [[<C-h>r]],
            function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
            "Gitsigns stage hunk"
        )
        map("n", [[<C-h>R]], gs.reset_buffer, "Gitsigns reset buffer")

        map("n", [[<C-h>u]], gs.undo_stage_hunk, "Gitsigns undo stage hunk")

        map("n", [[<C-h>p]], gs.preview_hunk, "Gitsigns preview hunk")

        -- Navigation
        map("n", "]h", function()
            if vim.wo.diff then return "]h" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
        end, { expr = true }, "Gitsigns next hunk")
        map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
        end, { expr = true }, "Gitsigns previous hunk")

        -- Text objects
        map( { "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", { "silent" }, "Gitsigns hunk text object")
    end

    require("gitsigns").setup {
        on_attach = onAttach,
        signs = {
            add = {
                hl = "GitSignsAdd",
                text = "┃",
                numhl = "GitSignsAddNr",
                linehl = "GitSignsAddLn",
            },
            change = {
                hl = "GitSignsChange",
                text = "┃",
                numhl = "GitSignsChangeNr",
                linehl = "GitSignsChangeLn",
            },
            delete = {
                hl = "GitSignsDelete",
                text = "┃",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
            topdelete = {
                hl = "GitSignsDelete",
                text = "┃",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
            changedelete = {
                hl = "GitSignsDelete",
                text = "┃",
                numhl = "GitSignsDeleteNr",
                linehl = "GitSignsDeleteLn",
            },
        },
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
            interval = 1000,
            follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
        },
        current_line_blame_formatter_opts = {
            relative_time = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000,
        preview_config = {
            -- Options passed to nvim_open_win
            border = "rounded",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
        },
        yadm = {
            enable = false,
        },
    }
end
