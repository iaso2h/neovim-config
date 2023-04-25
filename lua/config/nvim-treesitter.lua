return function()
    require("nvim-treesitter.configs").setup{
        -- Possible highlighter exception for vim ejection:
        -- https://github.com/nvim-treesitter/nvim-treesitter/issues/3317
        ensure_installed = {
            "bash",
            "c",
            "comment",
            "cpp",
            "fish",
            "lua",
            "markdown",
            "python",
            "query",
            "regex",
            "vim",
            "vimdoc",
        },
        auto_install = true,
        sync_install = true,
        highlight = {
            enable = true,
            disable = function(lang, buf)
                -- Filetype Exclude
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
            additional_vim_regex_highlighting = false
        },
        incremental_selection = {
            enable  = true,
            keymaps = {
                init_selection    = "gnn",
                node_incremental  = "grn",
                node_decremental  = "grm",
                scope_incremental = "grc",
            },
        },
        matchup = {
            enable  = true,
            disable = {"help"}
        },
    }

    map("n",        [[<A-S-a>]], [[gnn]], "Expand selection")
    map("x",        [[<A-S-a>]], [[grc]], "Expand selection")
    map({"n", "x"}, [[<A-S-s>]], [[grm]], "Shirnk selection")
end
