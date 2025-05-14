return function()
    require("nvim-treesitter.configs").setup{
        -- Possible highlighter exception for vim ejection:
        -- https://github.com/nvim-treesitter/nvim-treesitter/issues/3317
        ensure_installed = {
            "c",
            "c_sharp",
            "lua",
            "python",
            "query",
            "vim",
            "vimdoc",
            "markdown",
        },
        auto_install = true,
        sync_install = true,
        highlight = {
            enable = true,
            disable = function(lang, buf)
                -- Filetype Exclude
                -- if lang == "python" then return true end

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
                node_incremental  = "gna",
                node_decremental  = "gns",
                scope_incremental = "gnS",
            },
        },
        -- BUG:
        indent = {
            enable = false,
            disable = {"python"}
        }
    }

    map("n",        [[<A-S-a>]], [[gnn]], "Expand selection")
    map("x",        [[<A-S-a>]], [[gra]], "Expand selection")
    map({"n", "x"}, [[<A-S-s>]], [[grs]], "Shrink selection")

    vim.api.nvim_create_user_command("TSGetNodeAtCursor", function()
        local bufNr = vim.api.nvim_get_current_buf()
        if not require("vim.treesitter.highlighter").active[bufNr] then
            return
        end
        local ns = vim.api.nvim_create_namespace("treesitterHighlightUtil")
        local u    = require "nvim-treesitter.ts_utils"
        local util = require("util")
        local node = u.get_node_at_cursor(vim.api.nvim_get_current_win())
        if not node then return end

        vim.api.nvim_buf_clear_namespace(bufNr, ns, 0, -1)
        u.highlight_node(node, bufNr, ns, "Search")
        vim.defer_fn(function()
            vim.api.nvim_buf_clear_namespace(bufNr, ns, 0, -1)
        end, 500)
        Print("Node name: " .. node:type(), "Node range: " .. vim.inspect{node:range()}, "Node text: " .. util.getNodeText(bufNr, {node:range()}))
    end, {})
end
