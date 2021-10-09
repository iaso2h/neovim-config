return function()

local cmd     = vim.cmd
local actions = require("telescope.actions")

-- Gloabl customization
local defaultTheme = {
-- local defaultTheme = require('telescope.themes').get_ivy{
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
    selection_caret    = "  ",
    entry_prefix       = "   ",
    selection_strategy = "follow",

    sorting_strategy = "ascending",
    layout_strategy  = "horizontal",
    layout_config    = {
        prompt_position = "top",
        -- -- horizontal = {
            -- -- mirror = true,
        -- -- },
        -- -- vertical = {
            -- -- mirror = true,
        -- -- },
    },

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

    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,

    mappings = {
        i = {
            ["<C-u>"]     = false,
            ["<C-d>"]     = false,
            ["<C-x>"]     = false,

            ["<C-n>"]     = actions.move_selection_next,
            ["<C-p>"]     = actions.move_selection_previous,
            ["<Down>"]    = actions.move_selection_next,
            ["<Up>"]      = actions.move_selection_previous,

            ["<C-c>"]     = actions.close,

            ["<CR>"]      = actions.select_default + actions.center,
            ["<C-s>"]     = actions.select_horizontal,
            ["<C-v>"]     = actions.select_vertical,
            ["<C-t>"]     = actions.select_tab,

            ["<Tab>"]     = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"]   = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"]     = actions.send_selected_to_qflist + actions.open_qflist,
            ["<M-q>"]     = actions.send_selected_to_qflist + actions.open_qflist,

            ["<C-Space>"] = actions.complete_tag,
            ["<C-j>"]     = actions.cycle_history_next,
            ["<C-k>"]     = actions.cycle_history_prev,

            ["<A-e>"]     = actions.preview_scrolling_up,
            ["<A-d>"]     = actions.preview_scrolling_down,
        },
        n = {
            ["<C-u>"]   = false,
            ["<C-d>"]   = false,
            ["<C-x>"]   = false,
            ["<C-j>"]   = false,
            ["<C-k>"]   = false,
            ["?"]       = false,

            ["<esc>"]   = actions.close,
            ["q"]       = actions.close,

            ["<CR>"]    = actions.select_default + actions.center,
            ["<C-s>"]   = actions.select_horizontal,
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

            ["<A-e>"]   = actions.preview_scrolling_up,
            ["<A-d>"]   = actions.preview_scrolling_down,

            ["g"]       = actions.move_to_top,
            ["z"]       = actions.move_to_middle,
            ["G"]       = actions.move_to_bottom,
        },
    }
}

require('telescope').setup{
    defaults = defaultTheme,
    pickers = {
        find_files = {
            hidden = true,
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
cmd[[
command! -nargs=0 O lua require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy{})
]]
cmd[[
augroup telescopePreview
autocmd!
autocmd User TelescopePreviewerLoaded setlocal number
augroup END
]]
-- Mappings
map("n", [[<C-f>l]], [[:lua require('telescope.builtin').builtin()<CR>]], {"silent"})

map("n", [[<C-f>E]], [[:lua require('telescope.builtin').find_files({no_ignore=true})<CR>]],  {"silent"})
map("n", [[<C-f>e]], [[:lua require('telescope.builtin').find_files({no_ignore=false})<CR>]], {"silent"})

map("n", [[<C-f>f]], [[:lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], {"silent"})
map("n", [[<C-f>F]], [[:lua require('telescope.builtin').live_grep()<CR>]],                 {"silent"})

map("n", [[<C-f>w]], [[:lua require('telescope.builtin').grep_string({word_match=false)<CR>]], {"silent"})
map("n", [[<C-f>W]], [[:lua require('telescope.builtin').grep_string({word_match=true)<CR>]],  {"silent"})

map("c", [[<A-C-j>]], [[<Esc>:lua require('telescope.builtin').command_history()<CR>]], {"silent"})
-- BUG: keymapping conflict
map("c", [[<A-C-k>]], [[<Esc>:lua require('telescope.builtin').command_history()<CR>]], {"silent"})

map("n", [[<C-h>/]], [[:lua require('telescope.builtin').search_history()<CR>]], {"silent"})
map("n", [[<C-h>v]], [[:lua require('telescope.builtin').vim_options()<CR>]],    {"silent"})
map("n", [[<C-h>o]], [[:lua require('telescope.builtin').jumplist()<CR>]],       {"silent"})
map("n", [[<C-h>i]], [[:lua require('telescope.builtin').jumplist()<CR>]],       {"silent"})
map("n", [[<C-h>q]], [[:lua require('telescope.builtin').registers()<CR>]],      {"silent"})
map("n", [[<C-h>m]], [[:lua require('telescope.builtin').marks()<CR>]],          {"silent"})
map("n", [[<C-h>k]], [[:lua require('telescope.builtin').keymaps()<CR>]],        {"silent"})
map("n", [[<C-h>c]], [[:lua require('telescope.builtin').commands()<CR>]],       {"silent"})
map("n", [[<C-h>h]], [[:lua require('telescope.builtin').help_tags()<CR>]],      {"silent"})
map("n", [[<C-h>H]], [[:lua require('telescope.builtin').man_pages()<CR>]],      {"silent"})
map("n", [[<C-h>l]], [[:lua require('telescope.builtin').realoader()<CR>]],      {"silent"})

map("n", [[<C-f>o]], [[:lua require('telescope.builtin').current_buffer_tags()<CR>]], {"silent"})
map("n", [[<C-f>O]], [[:lua require('telescope.builtin').tags()<CR>]],                {"silent"})

map("n", [[<C-f>gc]], [[:lua require('telescope.builtin').git_bcommits()<CR>]], {"silent"})
map("n", [[<C-f>gC]], [[:lua require('telescope.builtin').git_commits()<CR>]],  {"silent"})
map("n", [[<C-f>gs]], [[:lua require('telescope.builtin').git_status()<CR>]],   {"silent"})

map("n", [[<leader>b]], [[:lua require('telescope.builtin').buffers()<CR>]], {"silent"})

end

