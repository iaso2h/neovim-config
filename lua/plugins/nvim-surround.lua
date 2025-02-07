return function()
    local M = require("nvim-surround.config")
    require("nvim-surround").setup {
        keymaps =  {
            insert = "<C-g>s",
            insert_line = "<C-g>S",
            normal = "gs",
            normal_cur = "gss",
            normal_line = "gS",
            normal_cur_line = "gSS",
            visual = "S",
            visual_line = "gS",
            delete = "ds",
            change = "cs",
            change_line = "cS",
        },
        aliases     = {},
        highlight   = {duration = 0},
        move_cursor = "begin"
    }
    pcall(function()
        vim.keymap.del("i", "<C-g>s")
        vim.keymap.del("i", "<C-g>S")
    end)
end
