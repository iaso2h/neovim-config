local map = require("util").map
local ts = require 'nvim-treesitter.configs'
ts.setup{
    ensure_installed      = {"c", "cpp", "lua", "json", "bash", "regex", "css", "html", "go", "javascript", "rust", "ruby", "vue", "c_sharp", "typescript"},
    -- ensure_installed      = {"c", "cpp", "lua", "python", "json", "bash", "regex", "css", "html", "go", "javascript", "rust", "ruby", "vue", "c_sharp", "typescript"},
    highlight             = {enable = true},
    indent                = {enable = true},
    rainbow               = {enable = true},
    incremental_selection = { -- {{{
        enable = true,
        keymaps = {
            init_selection    = "gnn",
            node_incremental  = "grn",
            scope_incremental = "grc",
            node_decremental  = "grm",
        },
    }, -- }}}
    textobjects = { -- {{{
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                [",p"] = "@parameter.inner",
            },
            swap_previous = {
                [",P"] = "@parameter.inner",
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
}

map("n", [[<A-S-a>]], [[gnn]])
map("v", [[<A-S-a>]], [[grn]])
map("",  [[<A-S-s>]], [[grm]])

