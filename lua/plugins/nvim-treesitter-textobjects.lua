return function()
    require("nvim-treesitter.configs").setup{
        textobjects = {
            select = {
                enable    = true,
                lookahead = false,
                keymaps = {
                    ["af"] = {query = "@function.outer", desc = "Select outer part of a function region"},
                    ["if"] = {query = "@function.inner", desc = "Select inner part of a function region"},
                    ["ac"] = {query = "@class.outer", desc = "Select outer part of a class region"},
                    ["ic"] = {query = "@class.inner", desc = "Select inner part of a class region"},

                    ["ap"] = {query = "@parameter.outer", desc = "Select outer part of a parameter region"},
                    ["ip"] = {query = "@parameter.inner", desc = "Select inner part of a parameter region"},
                },
                selection_modes = {
                    ['@function.outer'] = 'v', -- linewise
                },
            },
            swap = {
                enable = false,
                swap_next = {
                    ["<A-l>"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<A-h>"] = "@parameter.inner",
                },
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    ["]f"] = "@function.outer",
                    ["]]"] = "@class.outer",
                    ["]z"] = "@fold_marker_end",
                },
                goto_next_end = {
                    ["]F"] = "@function.outer",
                    ["]["] = "@class.outer",
                },
                goto_previous_start = {
                    ["[f"] = "@function.outer",
                    ["[["] = "@class.outer",
                    ["[z"] = "@fold_marker_start",
                },
                goto_previous_end = {
                    ["[F"] = "@function.outer",
                    ["[]"] = "@class.outer",
                },

                goto_next = {
                    ["]c"] = "@conditional.outer",
                },
                goto_previous = {
                    ["[c"] = "@conditional.outer",
                }
            },
        },
    }


    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    -- Repeat movement with ; and ,
    -- vim way: ; goes to the direction you were moving.
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    -- vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
    -- vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
    -- vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
    -- vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)





    if package.loaded.gitsigns then
        local gs = require("gitsigns")
        -- make sure forward function comes first
        local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        -- Or, use `make_repeatable_move` or `set_last_move` functions for more
        -- control. See the code for instructions.
        vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
        vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
    end
end
