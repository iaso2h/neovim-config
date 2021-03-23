local vim     = vim
local fn      = vim.fn
local cmd     = vim.cmd
local api     = vim.api
local map     = require("util").map
local actions = require("telescope.actions")
local M       = {}

-- Gloabl customization
require('telescope').setup{
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case'
        },
        prompt_position    = "bottom",
        prompt_prefix      = ">>> ",
        selection_caret    = "👉 ",
        entry_prefix       = "   ",
        initial_mode       = "insert",
        selection_strategy = "reset",
        sorting_strategy   = "descending",
        layout_strategy    = "horizontal",
        layout_defaults    = {
            horizontal = {
                mirror = false,
            },
            vertical = {
                mirror = true,
            },
        },
        file_sorter          = require'telescope.sorters'.get_fuzzy_file,
        file_ignore_patterns = {'*.sw?','~$*','*.bak','*.o','*.so','*.py[co]'},
        generic_sorter       = require'telescope.sorters'.get_generic_fuzzy_sorter,
        shorten_path         = false,
        winblend             = 0,
        width                = 0.75,
        preview_cutoff       = 120,
        results_height       = 1,
        results_width        = 0.8,
        border               = {},
        borderchars          = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        color_devicons       = true,
        use_less             = true,
        set_env              = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
        file_previewer       = require'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer       = require'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer     = require'telescope.previewers'.vim_buffer_qflist.new,

        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
        extensions = {
            fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
            },
            media_files = {
                -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
                filetypes = {"map4", "png", "webp", "webm", "jpg", "jpeg", "pdf"},
                find_cmd = "rg"
            }
        },
        mapping = {
            i = {
                -- Otherwise, just set the mapping to the function that you want it to be.
                ["<C-d>"]     = actions.add_selection,
                ["<C-u>"]     = actions.remove_selection,
                ["<Tab>"]     = actions.toggle_selection,
                ["<A-d>"]     = actions.preview_scrolling_down,
                ["<A-e>"]     = actions.preview_scrolling_up,
                ["<C-r>"]     = actions.paste_register,
                ["<C-Space>"] = actions.complete_tag,
                -- Add up multiple actions
                ["<CR>"]      = actions.select_default + actions.center,
            },
            n  = {
                ["<esc>"] = actions.close,
                ["q"]     = actions.close,
            }
        }
    }
}

require('telescope').load_extension('fzy_native')
require('telescope').load_extension('media_files')

function TelescopePreStart() -- {{{
    cmd[[setlocal wrap number]]
end -- }}}
-- AutoCommad
api.nvim_exec([[autocmd User TelescopePreviewerLoaded lua TelescopePreStart()]], false)

-- Command
cmd[[command! -nargs=0 O lua require('telescope.builtin').oldfiles(require('telescope.themes').get_dropdown({}))]]

-- Mappings
map("n", [[<C-e>]],   [[:lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({}))<cr>]],                {"novscode", "silent"})
map("n", [[<C-S-e>]], [[:Telescope ]],                                                                                                   {"novscode", "silent"})
map("n", [[<C-f>f]],  [[:lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({}))<cr>]], {"novscode", "silent"})
map("n", [[<C-S-f>]], [[:lua require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({}))<cr>]],                 {"novscode", "silent"})
map("n", [[<C-f>b]],  [[:lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({}))<cr>]],                   {"novscode", "silent"})
map("n", [[<C-S-c>]], [[:lua require('telescope.builtin').commands(require('telescope.themes').get_dropdown({}))<cr>]],                  {"novscode", "silent"})
map("n", [[<C-S-p>]], [[:lua require('telescope.builtin').builtin(require('telescope.themes').get_dropdown({}))<cr>]],                   {"novscode", "silent"})
map("n", [[<C-S-h>]], [[:lua require('telescope.builtin').help_tags(require('telescope.themes').get_dropdown({}))<cr>]],                 {"novscode", "silent"})
map("n", [[<C-S-o>]], [[:lua require('telescope.builtin').current_buffer_tags(require('telescope.themes').get_dropdown({}))<cr>]],       {"novscode", "silent"})
map("n", [[C-']],     [[:lua require('telescope.builtin').registers(require('telescope.themes').get_dropdown({}))<cr>]],                 {"novscode", "silent"})
map("n", [[<C-k>]],   [[:lua require('telescope.builtin').vim_options(require('telescope.themes').get_dropdown({}))<cr>]],               {"novscode", "silent"})

