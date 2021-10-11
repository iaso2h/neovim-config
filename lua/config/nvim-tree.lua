-- TODO: add filesize
-- TODO: Update in shortcut sheet
return function()

-- Basic settings {{{
vim.g.nvim_tree_gitignore = 0
vim.g.nvim_tree_show_icons = {
    git           = 1,
    folders       = 1,
    files         = 1,
    folder_arrows = 1,
    }
vim.g.nvim_tree_highlight_opened_files = 2
vim.g.nvim_tree_git_hl                 = 1
vim.g.nvim_tree_quit_on_open           = 0
vim.g.nvim_tree_indent_markers         = 0
vim.g.nvim_tree_hide_dotfiles          = 0
vim.g.nvim_tree_root_folder_modifier   = ':~' -- see :help filename-modifiers
vim.g.nvim_tree_add_trailing           = 1
vim.g.nvim_tree_group_empty            = 1
-- vim.g.nvim_tree_special_files = {["README.md"] = 1, Makefile = 1, MAKEFILE = 1 } -- List of filenames that gets highlighted with NvimTreeSpecialFile
vim.g.nvim_tree_special_files = {} -- List of filenames that gets highlighted with NvimTreeSpecialFile

vim.g.nvim_tree_disable_window_picker  = 0
vim.g.nvim_tree_window_picker_exclude = {
    filetype = {
        'packer',
        'qf',
        'help'
        },
    buftype = {
        'terminal'
        }
    }

vim.g.nvim_tree_respect_buf_cwd = 0
vim.g.nvim_tree_create_in_closed_folder = 1
-- }}} Basic settings

-- Icon {{{
vim.g.nvim_tree_icon_padding  = ' '     -- one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
vim.g.nvim_tree_symlink_arrow = ' >> '  -- defaults to ' ➛ '. used as a separator between symlinks' source and target.
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

local cb = require('nvim-tree.config').nvim_tree_callback

require("nvim-tree").setup {
    -- disables netrw completely
    disable_netrw       = true,
    -- hijack netrw window on startup
    hijack_netrw        = true,
    -- open the tree when running this setup function
    open_on_setup       = false,
    -- will not open on setup if the filetype is in this list
    ignore_ft_on_setup  = {'.git', 'node_modules', '.cache'},
    -- closes neovim automatically when the tree is the last **WINDOW** in the view
    auto_close          = false,
    -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
    open_on_tab         = false,
    -- hijack the cursor in the tree to put it at the start of the filename
    hijack_cursor       = false,
    -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
    update_cwd          = true,
    -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
    update_focused_file = {
        -- enables the feature
        enable      = true,
        -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
        -- only relevant when `update_focused_file.enable` is true
        update_cwd  = true,
        -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
        -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
        ignore_list = {}
    },
    -- configuration options for the system open command (`s` in the tree by default)
    system_open = {
        -- the command to run this, leaving nil should work in most cases
        cmd  = nil,
        -- the command arguments as a list
        args = {}
    },

    view = {
        -- width of the window, can be either a number (columns) or a string in `%`
        width = 40,
        -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
        side = 'left',
        -- if true the tree will resize itself after opening a file
        auto_resize = false,
        mappings = {
            -- custom only false will merge the list with the default mappings
            -- if true, it will only use your list to set the mappings
            custom_only = true,
            -- list of mappings to set on the tree manually
            list = {
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
                {key = "q",                            cb = cb("close")},
                {key = "?",                            cb = cb("toggle_help")}
            }
        }
    }
}


map("n", [[<C-w>e]], [[:lua require("nvim-tree").toggle()<CR>]], {"silent"})
-- map("n", [[<leader>r]], [[:NvimTreeRefresh<CR>]], {"noremap"})
-- map("n", [[<leader>n]], [[:NvimTreeFindFile<CR>]], {"noremap"})

-- BUG: Seem to not working
-- require("nvim-tree").find_file(false)
end
