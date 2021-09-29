return function()

local cmd     = vim.cmd
local actions = require("telescope.actions")

-- Gloabl customization
local defaultTheme = require('telescope.themes').get_ivy{
        -- TODO:
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case'
        },
        prompt_prefix      = "$ ",
        selection_caret    = "",
        entry_prefix       = "    ",
        initial_mode       = "insert",
        selection_strategy = "reset",
        scroll_strategy    = "cycle",

        -- sorting_strategy   = "descending",
        -- layout_strategy    = "horizontal",
        -- layout_config = {
            -- prompt_position = "top",
            -- horizontal = {
                -- mirror = false,
            -- },
            -- vertical = {
                -- mirror = false,
            -- },
        -- },

        file_sorter    = require("telescope.sorters").get_fzy_sorter,
        generic_sorter = require("telescope.sorters").get_fzy_sorter,
        file_ignore_patterns = {"*.sw?","~$*","*.bak", "*.bk", "*.o","*.so","*.py[co]"},

        winblend = 0,
        -- border = {},
        -- borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        color_devicons = true,

        use_less = true,
        path_display = {},
        set_env = {COLORTERM = "truecolor"},

        file_previewer   = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer   = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,

        mappings = {
            i = {
                ["<C-n>"]   = actions.move_selection_next,
                ["<C-p>"]   = actions.move_selection_previous,
                ["<Down>"]  = actions.move_selection_next,
                ["<Up>"]    = actions.move_selection_previous,

                ["<C-c>"]   = actions.close,

                ["<CR>"]    = actions.select_default + actions.center,
                -- ["<C-s>"]   = actions.select_horizontal, -- remap in ftplugin
                ["<C-v>"]   = actions.select_vertical,
                ["<C-t>"]   = actions.select_tab,

                ["<Tab>"]   = actions.toggle_selection + actions.move_selection_worse,
                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                ["<C-q>"]   = actions.send_selected_to_qflist + actions.open_qflist,
                -- ["<C-l>"]   = actions.complete_tag, -- remap in ftplugin
                -- ["<C-j>"]   = actions.cycle_history_next, -- reamap
                -- ["<C-k>"]   = actions.cycle_history_prev, -- reamap

                -- ["<A-e>"]   = actions.preview_scrolling_up, -- remap in ftplugin
                -- ["<A-d>"]   = actions.preview_scrolling_down, -- remap in ftplugin
            },
            n = {
                ["<esc>"]   = actions.close,
                ["q"]       = actions.close,

                ["<CR>"]    = actions.select_default + actions.center,
                -- ["<C-s>"]   = actions.select_horizontal, -- remap in ftplugin
                ["<C-v>"]   = actions.select_vertical,
                ["<C-t>"]   = actions.select_tab,

                ["<Tab>"]   = actions.toggle_selection + actions.move_selection_worse,
                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                ["<C-q>"]   = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"]   = actions.send_selected_to_qflist + actions.open_qflist,

                ["j"]       = actions.move_selection_next,
                ["k"]       = actions.move_selection_previous,
                ["<Down>"]  = actions.move_selection_next,
                ["<Up>"]    = actions.move_selection_previous,

                -- ["g"]       = actions.move_to_top, -- remap in ftplugin
                -- ["z"]       = actions.move_to_middle, -- remap in ftplugin
                -- ["G"]       = actions.move_to_bottom, -- remap in ftplugin

                -- ["<A-u>"]   = actions.preview_scrolling_up, -- remap in ftplugin
                -- ["<A-d>"]   = actions.preview_scrolling_down, -- remap in ftplugin
            },
        }
    }
require('telescope').setup{
    defualts = defaultTheme,
    pickers = {
        -- Your special builtin config goes in here
        buffers = {
            sort_lastused = true,
            theme         = "dropdown",
            previewer     = false,
        },

    },
    extensions = {
        fzy_native = {
            override_generic_sorter = true,
            override_file_sorter    = true,
        }
    }
}

require('telescope').load_extension('fzy_native')

-- Command
cmd[[command! -nargs=0 O lua require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy{})]]

-- Mappings
map("n", [[<C-f>l]],     [[:lua require('telescope.builtin').builtin(require('telescope.themes').get_ivy{previewer = false})<CR>]],  {"silent"})
map("n", [[<C-f>e]],     [[:lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy{})<CR>]],                {"silent"})
map("n", [[<C-f>f]],     [[:lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_ivy{})<CR>]], {"silent"})
map("n", [[<C-f>F]],     [[:lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy{})<CR>]],                 {"silent"})
map("n", [[<C-f>c]],     [[:lua require('telescope.builtin').commands(require('telescope.themes').get_ivy{})<CR>]],                  {"silent"})
map("n", [[<C-f>h]],     [[:lua require('telescope.builtin').help_tags(require('telescope.themes').get_ivy{})<CR>]],                 {"silent"})
map("n", [[<C-f>o]],     [[:lua require('telescope.builtin').current_buffer_tags(require('telescope.themes').get_ivy{})<CR>]],       {"silent"})
map("n", [[<leader>b]],  [[:lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy{})<CR>]],                   {"silent"})

end

