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
        '--smart-case',
        '--follow'
    },
    prompt_prefix      = "$ ",
    selection_caret    = "  ",
    entry_prefix       = "  ",
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
            ["<C-w>"]     = false,

            ["<C-n>"]     = actions.move_selection_next,
            ["<C-p>"]     = actions.move_selection_previous,
            ["<Down>"]    = actions.move_selection_next,
            ["<Up>"]      = actions.move_selection_previous,

            -- https://github.com/nvim-telescope/telescope.nvim/pull/1305
            -- ["<C-u>"] = actions.toggle_preview,
            -- ["<C-d>"] = actions.toggle_results_and_prompt,

            ["<C-c>"]     = actions.close,

            ["<CR>"]      = actions.select_default + actions.center,
            ["<C-s>"]     = actions.select_horizontal,
            ["<C-v>"]     = actions.select_vertical,
            ["<C-t>"]     = actions.select_tab,

            ["<Tab>"]     = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"]   = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"]     = actions.send_to_qflist + actions.open_qflist,

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
            ["<C-q>"]   = actions.send_selected_to_qflist + actions.open_qflist,

            ["j"]       = actions.move_selection_next,
            ["k"]       = actions.move_selection_previous,
            ["<Down>"]  = actions.move_selection_next,
            ["<Up>"]    = actions.move_selection_previous,

            ["<A-e>"]   = actions.preview_scrolling_up,
            ["<A-d>"]   = actions.preview_scrolling_down,

            ["z"]       = actions.move_to_middle,
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
command! -nargs=0 O lua require('telescope.builtin').oldfiles()
]]
-- cmd[[
-- augroup telescopePreview
-- autocmd!
-- autocmd User TelescopePreviewerLoaded setlocal number
-- augroup END
-- ]]
-- Mappings
map("n", [[<C-f>l]], require('telescope.builtin').builtin, "Telescope builtin")

map("n", [[<C-f>E]], [[:lua require('telescope.builtin').find_files({no_ignore=true})<CR>]],
        {"silent"}, "Telescope find files(ignore git file)")
map("n", [[<C-f>e]], [[:lua require('telescope.builtin').find_files({no_ignore=false})<CR>]],
        {"silent"}, "Telescope find all files")

map("n", [[<C-f>f]], require('telescope.builtin').current_buffer_fuzzy_find, "Telescope current buffer fuzzy find")
map("n", [[<C-f>F]], require('telescope.builtin').live_grep,                 "Telescope live grep")

map("n", [[<C-f>w]], [[:lua require('telescope.builtin').grep_string({word_match=false)<CR>]],
        {"silent"}, "Telescope grep word")
map("n", [[<C-f>W]], [[:lua require('telescope.builtin').grep_string({word_match=true)<CR>]],
        {"silent"}, "Telescope grep exact word")

map("c", [[<A-C-j>]], [[<C-u>lua require('telescope.builtin').command_history()<CR>]], {"silent"}, "Telescope command history")
map("c", [[<A-C-k>]], [[<A-C-j]], {"silent"}, "Telescope command history")

map("n", [[<C-h>/]], require('telescope.builtin').search_history, "Telescope search history")
map("n", [[<C-h>v]], require('telescope.builtin').vim_options,    "Telescope vim options")
map("n", [[<C-h>o]], require('telescope.builtin').jumplist,       "Telescope jumplist")
map("n", [[<C-h>i]], require('telescope.builtin').jumplist,       "Telescope jumplist")
map("n", [[<C-h>']], require('telescope.builtin').registers,      "Telescope registers")
map("n", [[<C-h>m]], require('telescope.builtin').marks,          "Telescope marks")
map("n", [[<C-h>k]], require('telescope.builtin').keymaps,        "Telescope keymaps")
map("n", [[<C-h>c]], require('telescope.builtin').commands,       "Telescope commands")
map("n", [[<C-h>h]], require('telescope.builtin').help_tags,      "Telescope help tags")
map("n", [[<C-h>H]], require('telescope.builtin').man_pages,      "Telescope man_pages")
map("n", [[<C-h>l]], require('telescope.builtin').reloader,       "Telescope reloader")

map("n", [[<C-f>o]], require('telescope.builtin').current_buffer_tags, "Telescope current buffer tags")
map("n", [[<C-f>O]], require('telescope.builtin').tags,                "Telescope tags")

map("n", [[<C-f>gc]], require('telescope.builtin').git_bcommits, "Telescope git bcommits")
map("n", [[<C-f>gC]], require('telescope.builtin').git_commits,  "Telescope git commits")
map("n", [[<C-f>gs]], require('telescope.builtin').git_status,   "Telescope git status")

map("n", [[<leader>b]], require('telescope.builtin').buffers, "Telescope buffers")

end

