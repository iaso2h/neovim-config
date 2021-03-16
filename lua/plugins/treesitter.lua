local map = require("util").map
local ts = require 'nvim-treesitter.configs'
ts.setup{
    ensure_installed      = {"c", "cpp", "lua", "python", "json", "bash", "regex", "css", "html", "go", "javascript", "rust", "ruby", "vue", "c_sharp", "typescript"},
    highlight             = {enable = true},
    indent                = {enable = true},
    rainbow               = {enable = true},
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    }
}

map("n", [[<A-S-a>]], [[gnn]])
map("v", [[<A-S-a>]], [[grn]])
map("",  [[<A-S-s>]], [[grm]])

