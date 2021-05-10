local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = require("util").map

vim.g.nvim_tree_width = 50 -- 30 by default
vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'} -- empty by default
vim.g.nvim_tree_auto_open = 0 -- 0 by default, opens the tree when typing `vim $DIR` or `vim`
vim.g.nvim_tree_auto_close = 0 -- 0 by default, closes the tree when it's the last window
vim.g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'} -- empty by default, don't auto open tree on specific filetypes.
vim.g.nvim_tree_quit_on_open = 1 -- 0 by default, closes the tree when you open a file
vim.g.nvim_tree_follow = 0 -- 0 by default, this option allows the cursor to be updated when entering a buffer
vim.g.nvim_tree_indent_markers = 1 -- 0 by default, this option shows indent markers when folders are open
vim.g.nvim_tree_hide_dotfiles = 0 -- 0 by default, this option hides files and folders starting with a dot `.`
vim.g.nvim_tree_git_hl = 1 -- 0 by default, will enable file highlight for git attributes (can be used without the icons).
vim.g.nvim_tree_root_folder_modifier = ':~' -- This is the default. See :help filename-modifiers for more options
vim.g.nvim_tree_tab_open = 0 -- 0 by default, will open the tree when entering a new tab and the tree was previously open
vim.g.nvim_tree_width_allow_resize  = 0 -- 0 by default, will not resize the tree when opening a file
vim.g.nvim_tree_disable_netrw = 1 -- 1 by default, disables netrw
vim.g.nvim_tree_hijack_netrw = 1 -- 1 by default, prevents netrw from automatically opening when opening directories (but lets you keep its other utilities)
vim.g.nvim_tree_add_trailing = 1 -- 0 by default, append a trailing slash to folder names
-- vim.o.guifont = "更纱黑体 Mono SC Nerd:h13"
vim.g.nvim_tree_icons = {
    default = '',
    symlink = '',
    git = {
        unstaged = "",
        staged = "",
        unmerged = "",
        renamed = "",
        untracked = ""
    },
    folder = {
        default = "",
        open = "",
        empty = "",
        empty_open = "",
        symlink = "",
    }
}

map("n", [[<C-w>e]], [[:NvimTreeToggle<CR>]], {"noremap", "silent"})
-- map("n", [[<leader>r]], [[:NvimTreeRefresh<CR>]], {"noremap"})
-- map("n", [[<leader>n]], [[:NvimTreeFindFile<CR>]], {"noremap"})


local treeCallback = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
    -- ["<CR>"] = ":YourVimFunction()<cr>",
    -- ["u"] = ":lua require'some_module'.some_function()<cr>",
    -- default mappings
    -- Folder
    ["U"]              = treeCallback("close_node"),
    ["u"]              = treeCallback("dir_up"),
    ["<CR>"]           = treeCallback("cd"),
    ["<2-RightMouse>"] = treeCallback("cd"),
    -- File
    ["o"]              = treeCallback("edit"),
    ["<2-LeftMouse>"]  = treeCallback("edit"),
    ["<C-v>"]          = treeCallback("vsplit"),
    ["<C-x>"]          = treeCallback("split"),
    ["<C-t>"]          = treeCallback("tabnew"),
    -- Toggle
    ["I"]              = treeCallback("toggle_ignored"),
    ["H"]              = treeCallback("toggle_dotfiles"),
    ["R"]              = treeCallback("refresh"),
    ["<Tab>"]          = treeCallback("preview"),

    ["n"]              = treeCallback("create"),
    ["r"]              = treeCallback("rename"),
    ["<C-r>"]          = treeCallback("full_rename"),
    ["df"]             = treeCallback("remove"),
    ["dd"]             = treeCallback("cut"),
    ["c"]              = treeCallback("copy"),
    ["p"]              = treeCallback("paste"),
    ["[c"]             = treeCallback("prev_git_item"),
    ["]c"]             = treeCallback("next_git_item"),
    ["q"]              = treeCallback("close")
}

