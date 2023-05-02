return function()

local actions = require("telescope.actions")

if not require("util").ex("rg") then
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
        '--follow',
        -- '-u'
    },
    prompt_prefix      = "$ ",
    selection_caret    = "  ",
    entry_prefix       = "  ",
    selection_strategy = "follow",

    sorting_strategy = "ascending",
    layout_strategy  = "vertical",
    layout_config    = {
        prompt_position = "top",
        mirror = true
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

    -- Ation list: https: //github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/init.lua
    mappings = {
        i = {
            ["<C-u>"]     = false,
            ["<C-d>"]     = false,
            ["<C-x>"]     = false,
            ["<C-w>"]     = false,
            ["<C-l>"]     = false,

            ["<C-n>"]  = actions.move_selection_next,
            ["<C-p>"]  = actions.move_selection_previous,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"]   = actions.move_selection_previous,
            ["<C-g>"]  = actions.move_to_top,

            -- https://github.com/nvim-telescope/telescope.nvim/pull/1305
            -- ["<C-u>"] = actions.toggle_preview,
            -- ["<C-d>"] = actions.toggle_results_and_prompt,

            ["<C-c>"]     = actions.close,

            ["<CR>"]      = actions.select_default + actions.center,
            ["<C-s>"]     = actions.select_horizontal,
            ["<C-v>"]     = actions.select_vertical,
            ["<C-t>"]     = actions.select_tab,

            ["<C-q>"]     = actions.send_to_qflist + actions.open_qflist,

            ["<C-Space>"] = actions.complete_tag,
            ["<C-j>"]     = actions.cycle_history_next,
            ["<C-k>"]     = actions.cycle_history_prev,

            ["<C-f>"]     = actions.results_scrolling_up,
            ["<C-b>"]     = actions.results_scrolling_down,

            ["<A-e>"]     = actions.preview_scrolling_up,
            ["<A-d>"]     = actions.preview_scrolling_down,
        },
        n = {
            ["<C-u>"]   = false,
            ["<C-d>"]   = false,
            ["<C-x>"]   = false,
            ["<C-j>"]   = false,
            ["<C-k>"]   = false,
            ["?"] = actions.which_key,

            ["<esc>"]   = actions.close,
            ["q"]       = actions.close,

            ["<CR>"]    = actions.select_default + actions.center,
            ["<C-s>"]   = actions.select_horizontal,
            ["<C-v>"]   = actions.select_vertical,
            ["<C-t>"]   = actions.select_tab,

            ["v"]         = actions.toggle_selection,
            ["<Tab>"]     = actions.add_selection,
            ["<S-Tab>"]   = actions.remove_selection,
            ["<A-S-Tab>"] = actions.drop_all,
            ["<C-q>"]     = actions.send_selected_to_qflist + actions.open_qflist,

            ["j"]      = actions.move_selection_next,
            ["k"]      = actions.move_selection_previous,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"]   = actions.move_selection_previous,
            ["gg"]     = actions.move_to_top,
            ["G"]      = actions.move_to_bottom,

            ["<C-f>"] = actions.results_scrolling_up,
            ["<C-b>"] = actions.results_scrolling_down,
            ["<A-e>"] = actions.preview_scrolling_up,
            ["<A-d>"] = actions.preview_scrolling_down,

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
        undo = {

        }
    }
}

-- Command
vim.api.nvim_create_user_command("O", function()
    require('telescope.builtin').oldfiles()
end, {desc = "Browse the oldfiles then prompt"} )
-- Mappings
map("n", [[<C-f>a]], [[<CMD>lua require('telescope.builtin').builtin()<CR>]], {"silent"}, "All builtins")

map("n", [[<C-f>E]], [[<CMD>lua require('telescope.builtin').find_files({no_ignore=true})<CR>]],
        {"silent"}, "Find files(ignore git file)")
map("n", [[<C-f>e]], [[<CMD>lua require('telescope.builtin').find_files({no_ignore=false})<CR>]],
        {"silent"}, "Find all files")

map("n", [[<C-f>f]], [[<CMD>lua require('telescope.builtin').live_grep()<CR>]], {"silent"}, "Live grep")
map("n", [[<C-f>F]], [[<CMD>lua require('telescope.builtin').live_grep()<CR>]], {"silent"}, "Live grep")

map("n", [[<C-f>w]], [[<CMD>lua require('telescope.builtin').grep_string{word_match=false}<CR>]],
        {"silent"}, "Grep word")
map("n", [[<C-f>W]], [[<CMD>lua require('telescope.builtin').grep_string{word_match=true}<CR>]],
        {"silent"}, "Grep exact word")


map("n", [[<C-f>/]], [[<CMD>lua require('telescope.builtin').search_history()<CR>]],  {"silent"}, "Search history")
map("n", [[<C-f>?]], [[<C-h>/]],                                                      {"silent"}, "Search history")
map("n", [[<C-f>c]], [[<CMD>lua require('telescope.builtin').commands()<CR>]],        {"silent"}, "Commands")
map("n", [[<C-f>:]], [[<CMD>lua require('telescope.builtin').command_history()<CR>]], {"silent"}, "Command history")
map("n", [[<C-f>v]], [[<CMD>lua require('telescope.builtin').vim_options()<CR>]],     {"silent"}, "Vim options")
map("n", [[<C-f>j]], [[<CMD>lua require('telescope.builtin').jumplist()<CR>]],        {"silent"}, "Jumplist")
map("n", [[<C-f>m]], [[<CMD>lua require('telescope.builtin').marks()<CR>]],           {"silent"}, "Marks")
map("n", [[<C-f>k]], [[<CMD>lua require('telescope.builtin').keymaps()<CR>]],         {"silent"}, "Keymaps")
map("n", [[<C-f>h]], [[<CMD>lua require('telescope.builtin').help_tags()<CR>]],       {"silent"}, "Help tags")
map("n", [[<C-f>H]], [[<CMD>lua require('telescope.builtin').man_pages()<CR>]],       {"silent"}, "Man pages")
map("n", [[<C-f>r]], [[<CMD>lua require('telescope.builtin').reloader()<CR>]],        {"silent"}, "Reloader")

-- NOTE: Already configured in lsp setup
-- map("n", [[<C-f>o]], [[<CMD>lua require('telescope.builtin').current_buffer_tags()<CR>]], {"silent"}, "Current buffer tags")
-- map("n", [[<C-f>O]], [[<CMD>lua require('telescope.builtin').tags()<CR>]], {"silent"}, "Tags")

map("n", [[<C-f>gc]], [[<CMD>lua require('telescope.builtin').git_bcommits()<CR>]], {"silent"}, "Git bcommits")
map("n", [[<C-f>gC]], [[<CMD>lua require('telescope.builtin').git_commits()<CR>]],  {"silent"}, "Git commits")
map("n", [[<C-f>gs]], [[<CMD>lua require('telescope.builtin').git_status()<CR>]],   {"silent"}, "Git status")

map("n", [[<C-f>b]], [[<CMD>lua require('telescope.builtin').buffers()<CR>]], {"silent"}, "Buffers")
map("n", [[<C-f>d]], [[<CMD>lua require('telescope.builtin').diagnostics{bufnr=0}<CR>]],
    {"silent"}, "Telescope LSP document diagnostics")
map("n", [[<C-f>D]], [[<CMD>lua require('telescope.builtin').diagnostics{bufnr=nil}<CR>]],
    {"silent"}, "Telescope LSP workspace diagnostics")

end
