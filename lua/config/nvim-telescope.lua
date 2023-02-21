return function()

local actions = require("telescope.actions")

if not ex("rg") then
    vim.notify([["rg" is not an executable]], vim.log.levels.WARN)
end

-- Gloabl customization
local defaultTheme = {
-- local defaultTheme = require('telescope.themes').get_ivy{
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
}

-- Command
vim.cmd[[
command! -nargs=0 O lua require('telescope.builtin').oldfiles()
]]
-- Mappings
map("n", [[<C-f>l]], [[<CMD>lua require('telescope.builtin').builtin()<CR>]], {"silent"}, "Telescope builtin")

map("n", [[<C-f>E]], [[<CMD>lua require('telescope.builtin').find_files({no_ignore=true})<CR>]],
        {"silent"}, "Telescope find files(ignore git file)")
map("n", [[<C-f>e]], [[<CMD>lua require('telescope.builtin').find_files({no_ignore=false})<CR>]],
        {"silent"}, "Telescope find all files")

map("n", [[<C-f>f]], [[<CMD>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], {"silent"}, "Telescope current buffer fuzzy find")
map("n", [[<C-f>F]], [[<CMD>lua require('telescope.builtin').live_grep()<CR>]], {"silent"}, "Telescope live grep")

map("n", [[<C-f>w]], [[<CMD>lua require('telescope.builtin').grep_string{word_match=false}<CR>]],
        {"silent"}, "Telescope grep word")
map("n", [[<C-f>W]], [[<CMD>lua require('telescope.builtin').grep_string{word_match=true}<CR>]],
        {"silent"}, "Telescope grep exact word")

map("c", [[<A-C-j>]], [[<CMD>lua require('telescope.builtin').command_history()<CR>]], {"silent"}, "Telescope command history")
map("c", [[<A-C-k>]], [[<A-C-j]], {"silent"}, "Telescope command history")

map("n", [[<C-h>/]], [[<CMD>lua require('telescope.builtin').search_history()<CR>]], {"silent"}, "Telescope search history")
map("n", [[<C-h>v]], [[<CMD>lua require('telescope.builtin').vim_options()<CR>]],    {"silent"}, "Telescope vim options")
map("n", [[<C-h>o]], [[<CMD>lua require('telescope.builtin').jumplist()<CR>]],       {"silent"}, "Telescope jumplist")
map("n", [[<C-h>i]], [[<CMD>lua require('telescope.builtin').jumplist()<CR>]],       {"silent"}, "Telescope jumplist")
map("n", [[<C-h>']], [[<CMD>lua require('telescope.builtin').registers()<CR>]],      {"silent"}, "Telescope registers")
map("n", [[<C-h>m]], [[<CMD>lua require('telescope.builtin').marks()<CR>]],          {"silent"}, "Telescope marks")
map("n", [[<C-h>k]], [[<CMD>lua require('telescope.builtin').keymaps()<CR>]],        {"silent"}, "Telescope keymaps")
map("n", [[<C-h>c]], [[<CMD>lua require('telescope.builtin').commands()<CR>]],       {"silent"}, "Telescope commands")
map("n", [[<C-h>h]], [[<CMD>lua require('telescope.builtin').help_tags()<CR>]],      {"silent"}, "Telescope help tags")
map("n", [[<C-h>H]], [[<CMD>lua require('telescope.builtin').man_pages()<CR>]],      {"silent"}, "Telescope man_pages")
map("n", [[<C-h>l]], [[<CMD>lua require('telescope.builtin').reloader()<CR>]],       {"silent"}, "Telescope reloader")
map("n", [[<C-h>f]], [[<CMD>lua require('telescope.builtin').filetypes()<CR>]],      {"silent"}, "Telescope filetype")

-- Override in lsp
-- map("n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').current_buffer_tags()<CR>]], {"silent"}, "Telescope current buffer tags")
-- map("n", [[<C-f>O]], [[<CMD>lua require('telescope.builtin').tags()<CR>]], {"silent"}, "Telescope tags")

map("n", [[<C-f>gc]], [[<CMD>lua require('telescope.builtin').git_bcommits()<CR>]], {"silent"}, "Telescope git bcommits")
map("n", [[<C-f>gC]], [[<CMD>lua require('telescope.builtin').git_commits()<CR>]], {"silent"}, "Telescope git commits")
map("n", [[<C-f>gs]], [[<CMD>lua require('telescope.builtin').git_status()<CR>]], {"silent"}, "Telescope git status")

map("n", [[<leader>b]], [[<CMD>lua require('telescope.builtin').buffers()<CR>]], {"silent"}, "Telescope buffers")

end

