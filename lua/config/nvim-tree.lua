local map = require("util").map
local M   = {}

-- Basic settings {{{
vim.g.nvim_tree_side                   = 'left' -- left by default
vim.g.nvim_tree_width                  = 40 -- 30 by default, can be width_in_columns or 'width_in_percent%'
vim.g.nvim_tree_ignore                 = {'.git', 'node_modules', '.cache'} -- empty by default
vim.g.nvim_tree_gitignore              = 0 -- 0 by default
vim.g.nvim_tree_auto_open              = 0 -- 0 by default, opens the tree when typing `vim $DIR` or `vim`
vim.g.nvim_tree_auto_close             = 0 -- 0 by default, closes the tree when it's the last window
vim.g.nvim_tree_auto_ignore_ft         = {'startify', 'dashboard'} -- empty by default, don't auto open tree on specific filetypes.
vim.g.nvim_tree_quit_on_open           = 0 -- 0 by default, closes the tree when you open a file
vim.g.nvim_tree_follow                 = 1 -- 0 by default, this option allows the cursor to be updated when entering a buffer
vim.g.nvim_tree_indent_markers         = 0 -- 0 by default, this option shows indent markers when folders are open
vim.g.nvim_tree_hide_dotfiles          = 0 -- 0 by default, this option hides files and folders starting with a dot `.`
vim.g.nvim_tree_git_hl                 = 1 -- 0 by default, will enable file highlight for git attributes (can be used without the icons).
vim.g.nvim_tree_highlight_opened_files = 1 -- 0 by default, will enable folder and file icon highlight for opened files/directories.
vim.g.nvim_tree_root_folder_modifier   = ':~' -- This is the default. See :help filename-modifiers for more options
vim.g.nvim_tree_tab_open               = 0 -- 0 by default, will open the tree when entering a new tab and the tree was previously open
vim.g.nvim_tree_auto_resize            = 0 -- 1 by default, will resize the tree to its saved width when opening a file
vim.g.nvim_tree_disable_netrw          = 1 -- 1 by default, disables netrw
vim.g.nvim_tree_hijack_netrw           = 1 -- 1 by default, prevents netrw from automatically opening when opening directories (but lets you keep its other utilities)
vim.g.nvim_tree_add_trailing           = 1 -- 0 by default, append a trailing slash to folder names
vim.g.nvim_tree_group_empty            = 1 --  0 by default, compact folders that only contain a single folder into one node in the file tree
vim.g.nvim_tree_lsp_diagnostics        = 1 -- 0 by default, will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
vim.g.nvim_tree_disable_window_picker  = 0 -- 0 by default, will disable the window picker.
vim.g.nvim_tree_hijack_cursor          = 0 -- 1 by default, when moving cursor in the tree, will position the cursor at the start of the file on the current line
vim.g.nvim_tree_icon_padding           = ' ' -- one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
vim.g.nvim_tree_symlink_arrow          = ' >> ' --  defaults to ' ➛ '. used as a separator between symlinks' source and target.
vim.g.nvim_tree_update_cwd             = 1 -- 0 by default, will update the tree cwd when changing nvim's directory (DirChanged event). Behaves strangely with autochdir set.
vim.g.nvim_tree_respect_buf_cwd        = 1 -- 0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
vim.g.nvim_tree_window_picker_exclude = {
    filetype = {
        'packer',
        'vim-plug',
        'qf'
        },
    buftype = {
        'terminal'
        }
    }
vim.g.nvim_tree_special_files = {["README.md"] = 1, Makefile = 1, MAKEFILE = 1 } -- List of filenames that gets highlighted with NvimTreeSpecialFile
vim.g.nvim_tree_show_icons = {
    git           = 1,
    folders       = 1,
    files         = 1,
    folder_arrows = 1,
    }
-- }}} Basic settings

-- Icon {{{
-- vim.o.guifont = "更纱黑体 Mono SC Nerd:h13"
vim.g.nvim_tree_icons = {
    default = '',
    symlink = '',
    git = {
        unstaged  = "",
        staged    = "",
        unmerged  = "",
        renamed   = "",
        untracked = " ",
        deleted   = "",
        ignored   = "◌"
    },
    folder = {
        arrow_open   = "",
        arrow_closed = "",
        default      = "",
        open         = "",
        empty        = "",
        empty_open   = "",
        symlink      = "",
        symlink_open = "",
        },
        lsp = {
            hint    = "",
            info    = "",
            warning = "",
            error   = "",
    }
}
-- }}} Icon

-- Keymappings {{{
-- Integration with barbar.nvim
local view  = require "nvim-tree.view"
local state = require "bufferline.state"
M.closeNvimTree = function()
    state.set_offset(0)
    view.close()
end
M.toggle = function()
    if view.win_open() then
        state.set_offset(0)
        view.close()
    else
        if vim.g.nvim_tree_follow == 1 then
            require("nvim-tree").find_file(true)
        end
        if not view.win_open() then
            require("nvim-tree.lib").open()
        end

        state.set_offset(40, '')
    end
end

map("n", [[<C-w>e]], [[:lua require("config.nvim-tree").toggle()<cr>]], {"silent"})
-- map("n", [[<C-w>e]], [[:lua require("nvim-tree").toggle()<cr>]], {"silent"})
-- map("n", [[<leader>r]], [[:NvimTreeRefresh<CR>]], {"noremap"})
-- map("n", [[<leader>n]], [[:NvimTreeFindFile<CR>]], {"noremap"})

-- NOTE: Update in shortcut sheet
vim.g.nvim_tree_disable_default_keybindings = 1
local cb = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
    {key = {"<CR>", "o", "<2-LeftMouse>"}, cb = cb("edit")},
    {key = "go",                           cb = cb("system_open")},
    {key = {"<2-RightMouse>", "."},        cb = cb("cd")},
    {key = "<C-v>",                        cb = cb("vsplit")},
    {key = "<C-s>",                        cb = cb("split")},
    {key = "<C-t>",                        cb = cb("tabnew")},
    {key = "<",                            cb = cb("prev_sibling")},
    {key = ">",                            cb = cb("next_sibling")},
    {key = "<BS>",                         cb = cb("close_node")},
    {key = "<Tab>",                        cb = cb("preview")},
    {key = "K",                            cb = cb("first_sibling")},
    {key = "J",                            cb = cb("last_sibling")},
    {key = "I",                            cb = cb("toggle_ignored")},
    {key = "H",                            cb = cb("toggle_dotfiles")},
    {key = "R",                            cb = cb("refresh")},
    {key = "n",                            cb = cb("create")},
    {key = "df",                           cb = cb("remove")},
    {key = "r",                            cb = cb("full_rename")},
    {key = "gr",                           cb = cb("rename")},
    {key = "dd",                           cb = cb("cut")},
    {key = "yy",                           cb = cb("copy")},
    {key = "Y",                            cb = cb("copy")},
    {key = "p",                            cb = cb("paste")},
    {key = "yn",                           cb = cb("copy_name")},
    {key = "yp",                           cb = cb("copy_path")},
    {key = "yP",                           cb = cb("copy_absolute_path")},
    {key = "[g",                           cb = cb("prev_git_item")},
    {key = "]g",                           cb = cb("next_git_item")},
    {key = "u",                            cb = cb("parent_node")},
    {key = "U",                            cb = cb("dir_up")},
    {key = "q",                            cb = [[:lua require("config.nvim-tree").closeNvimTree()<cr>]]},
    {key = "?",                            cb = cb("toggle_help")}
}
-- }}} Keymappings

return M

