return function()
local icon = require("util.icon")

require("nvim-tree").setup { -- BEGIN_DEFAULT_OPTS
    auto_reload_on_write = true,
    disable_netrw = true,
    hijack_netrw = true,
    hijack_cursor = false,
    hijack_unnamed_buffer_when_opening = false,
    sort_by = "name", -- name, case_sensitive, modification_time, extension or a
    root_dirs = {}, -- Only relevant when update_focused_file.update_root is true
    prefer_startup_root = false, -- Only relevant when update_focused_file.update_root is true
    sync_root_with_cwd = false,
    reload_on_bufenter = false,
    respect_buf_cwd = true,
    on_attach = "disable", -- Function ran when creating the nvim-tree buffer.
    remove_keymaps = false, -- Remove the default mappings in the tree.
    select_prompts = false,
    view = {
        centralize_selection = true,
        cursorline = true,
        debounce_delay = 15,
        width = 40,
        hide_root_folder = false,
        side = "left",
        preserve_window_proportions = false,
        number = false,
        relativenumber = false,
        signcolumn = "no",
        mappings = {
            custom_only = true,
            list = {
                {key = {"<CR>", "o", "<2-LeftMouse>"}, action = "edit"},
                {key = "O",                            action = "edit_in_place" },
                {key = "go",                           action = "system_open"},
                {key = "p",                            action = "preview"},
                {key = "<C-v>",                        action = "vsplit"},
                {key = "<C-s>",                        action = "split"},
                {key = "<C-t>",                        action = "tabnew"},

                {key = {"<2-RightMouse>", "."}, action = "cd"},
                {key = "u",                     action = "parent_node"},
                {key = "U",                     action = "dir_up"},

                {key = "gc", action = "toggle_git_clean"},
                {key = "gi", action = "toggle_git_ignored"},

                {key = "I", action = "toggle_ignored"},
                {key = "H", action = "toggle_dotfiles"},
                {key = "B", action = "toggle_no_buffer"},
                {key = "U", action = "toggle_custom"},

                {key = "f", action = "live_filter"},
                {key = "F", action = "clear_live_filter"},

                {key = "K", action = "first_sibling"},
                {key = "J", action = "last_sibling"},
                {key = "<", action = "prev_sibling"},
                {key = ">", action = "next_sibling"},
                {key = "E", action = "expand_all"},

                {key = "R",     action = "refresh"},
                {key = "<C-n>", action = "create"},
                {key = "df",    action = "remove"},
                {key = "r",     action = "full_rename"},
                {key = "gr",    action = "rename"},
                {key = "dd",    action = "cut"},
                {key = "yy",    action = "copy"},
                {key = "Y",     action = "copy"},
                {key = "p",     action = "paste"},
                {key = "yn",    action = "copy_name"},
                {key = "yp",    action = "copy_path"},
                {key = "yP",    action = "copy_absolute_path"},

                {key = "[g", action = "prev_git_item"},
                {key = "]g", action = "next_git_item"},

                {key = "m", action = "toggle_mark"},
                {key = "q", action = "close"},
                {key = "?", action = "toggle_help"}

            },
        },
        float = {
            enable = false,
            quit_on_focus_loss = true,
            open_win_config = {
                relative = "editor",
                border = "rounded",
                width = 30,
                height = 30,
                row = 1,
                col = 1,
            },
        },
    },
    renderer = {
        add_trailing = true,
        group_empty = true,
        highlight_git = true,
        full_name = false,
        highlight_opened_files = "name",
        highlight_modified = "none",
        root_folder_label = ":~:s?$?/..?",
        indent_width = 2,
        indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
                corner = "└",
                edge = "│",
                item = "│",
                bottom = "─",
                none = " ",
            },
        },
        icons = {
            webdev_colors = true,
            git_placement = "before",
            modified_placement = "after",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
                modified = true,
            },
            glyphs = {
                    default  = icon.ui.Text,
                    symlink  = icon.ui.FileSymlink,
                    bookmark = icon.ui.BookMark,
                folder = {
                    arrow_closed = icon.ui.TriangleShortArrowRight,
                    arrow_open   = icon.ui.TriangleShortArrowDown,
                    default      = icon.ui.Folder,
                    open         = icon.ui.FolderOpen,
                    empty        = icon.ui.EmptyFolder,
                    empty_open   = icon.ui.EmptyFolderOpen,
                    symlink      = icon.ui.FolderSymlink,
                    symlink_open = icon.ui.FolderOpen,
                },
                git = {
                    unstaged  = icon.git.FileUnstaged,
                    staged    = icon.git.FileStaged,
                    unmerged  = icon.git.FileUnmerged,
                    renamed   = icon.git.FileRenamed,
                    untracked = icon.git.FileUntracked,
                    deleted   = icon.git.FileDeleted,
                    ignored   = icon.git.FileIgnored,
                },
            },
        },
        special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
        symlink_destination = true,
    },
    hijack_directories = {
        enable = true,
        auto_open = true,
    },
    update_focused_file = {
        enable = true,
        update_root = false,
        ignore_list = {},
    },
    system_open = {
        cmd = "",
        args = {},
    },
    diagnostics = {
        enable = false,
        show_on_dirs = false,
        show_on_open_dirs = true,
        debounce_delay = 50,
        severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
        },
        icons = {
            hint    = "",
            info    = "",
            warning = "",
            error   = "",
        },
    },
    filters = {
        dotfiles = false,
        git_clean = false,
        no_buffer = false,
        custom = {},
        exclude = {},
    },
    filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        ignore_dirs = {},
    },
    git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
        timeout = 400,
    },
    modified = {
        enable = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
    },
    actions = {
        use_system_clipboard = true,
        change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
        },
        expand_all = {
            max_folder_discovery = 300,
            exclude = {},
        },
        file_popup = {
            open_win_config = {
                col = 1,
                row = 1,
                relative = "cursor",
                border = "shadow",
                style = "minimal",
            },
        },
        open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
                enable = true,
                picker = "default",
                chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                exclude = {
                    filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "dap-repl", "help", "packer"},
                    buftype = { "nofile", "terminal", "help" },
                },
            },
        },
        remove_file = {
            close_window = true,
        },
    },
    trash = {
        cmd = "gio trash",
    },
    live_filter = {
        always_show_folders = true,
        prefix = "[FILTER]: ",
    },
    tab = {
        sync = {
            open = false,
            close = false,
            ignore = {},
        },
    },
    notify = {
        threshold = vim.log.levels.INFO,
    },
    ui = {
        confirm = {
            remove = true,
            trash = true,
        },
    },
    log = {
        enable = false,
        truncate = false,
        types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
        },
    },
} -- END_DEFAULT_OPTS

map("n", [[<C-w>e]], [[:lua require("nvim-tree").toggle()<CR>]], {"silent"}, "Toggle Nvim tree")
-- map("n", [[<leader>r]], [[:NvimTreeRefresh<CR>]], {"noremap"})
-- map("n", [[<leader>n]], [[:NvimTreeFindFile<CR>]], {"noremap"})

end
