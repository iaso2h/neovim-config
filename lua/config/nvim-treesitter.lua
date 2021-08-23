-- TODO: Update in shortcut sheet
local map = require("util").map
local ts  = require 'nvim-treesitter.configs'

-- TODO disable tree-sitter rainbow for floating window

ts.setup{
    -- ensure_installed = "maintained",
    ensure_installed = {"c", "cpp", "lua", "json", "toml", "python", "bash", "fish", "regex", "css", "html", "go", "javascript", "rust", "ruby", "vue", "c_sharp", "typescript"},
    highlight        = {enable = true},
    indent           = {enable = true},
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection    = "gnn",
            node_incremental  = "grn",
            node_decremental  = "grm",
            scope_incremental = "grc",
        },
    },

    -- External module {{{
    autotag = {enable = true},
    rainbow = {
        enable         = true,
        extended_mode  = true,
        max_file_lines = nil,
        colors         = {
            "#ffd700",
            "#7a28a3",
            "#3a5eca",
        }
    },
    matchup = {
        enable = true,
        -- disable = { "c", "ruby" },
    },
    textobjects = { -- {{{
        select = {
            enable = true,
            keymaps = {
                ["nf"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<A-.>"] = "@parameter.inner",
            },
            swap_previous = {
                ["<A-,>"] = "@parameter.inner",
            },
        },
        move = {
            enable = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@function.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@function.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@function.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@function.outer",
            },
        },
    }, -- }}}
    -- }}} External module
}

map("n", [[<A-S-a>]], [[gnn]])
map("v", [[<A-S-a>]], [[grn]])
map("",  [[<A-S-s>]], [[grm]])

