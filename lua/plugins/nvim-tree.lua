return function()
    local icon = require("util.icon")


    local function onAttach(bufNr)
        local api = require("nvim-tree.api")
        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufNr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Edit"))
        vim.keymap.set("n", "o",     api.node.open.edit,                opts("Edit"))
        vim.keymap.set("n", "<CR>",  api.node.open.edit,                opts("Edit"))
        vim.keymap.set("n", "<Tab>", api.node.open.preview,             opts("Preview"))
        vim.keymap.set("n", "O",     api.node.open.replace_tree_buffer, opts("Edit in place"))
        vim.keymap.set("n", "go",    api.node.run.system,               opts("Run system"))
        vim.keymap.set("n", "g:",    api.node.run.cmd,                  opts("Run command"))

        vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Vertical split"))
        vim.keymap.set("n", "<C-s>", api.node.open.horizontal, opts("Horizontal split"))
        vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("New tab"))

        vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
        vim.keymap.set("n", ".",  api.tree.change_root_to_node,   opts("CD"))
        vim.keymap.set("n", "u",  api.node.navigate.parent,       opts("Parent dir"))
        vim.keymap.set("n", "U",  api.tree.change_root_to_parent, opts("CD to parent dir"))
        vim.keymap.set("n", "zr", api.tree.expand_all,            opts("Expand all"))
        vim.keymap.set("n", "zm", api.tree.collapse_all,          opts("Collapse all"))
        vim.keymap.set("n", "R",  api.tree.reload,                opts("Refresh"))

        vim.keymap.set("n", "<leader>G", api.tree.toggle_git_clean_filter, opts("Toggle git clean filter"))
        vim.keymap.set("n", "<leader>g", api.tree.toggle_gitignore_filter, opts("Toggle git ignored filter"))
        vim.keymap.set("n", "[g", api.node.navigate.git.prev, opts("Prev git"))
        vim.keymap.set("n", "]g", api.node.navigate.git.next, opts("Next git"))

        vim.keymap.set("n", "K",         api.node.show_info_popup,         opts('Info'))
        vim.keymap.set("n", "<leader>.", api.tree.toggle_hidden_filter,    opts("Toggle dotfiles filter"))
        vim.keymap.set("n", "<leader>b", api.tree.toggle_no_buffer_filter, opts("Toggle no buffer filter"))
        vim.keymap.set("n", "<leader>u", api.tree.toggle_custom_filter,    opts("Toggle custom filter"))

        vim.keymap.set("n", "f", api.live_filter.start, opts("Live filter"))
        vim.keymap.set("n", "F", api.live_filter.clear, opts("Clear live_filter"))

        vim.keymap.set("n", "H", api.node.navigate.sibling.first, opts("First sibling"))
        vim.keymap.set("n", "L", api.node.navigate.sibling.last,  opts("Last sibling"))
        vim.keymap.set("n", "<", api.node.navigate.sibling.prev,  opts("Prev sibling"))
        vim.keymap.set("n", ">", api.node.navigate.sibling.next,  opts("Next sibling"))

        vim.keymap.set("n", "<C-n>", api.fs.create, opts("Create"))
        vim.keymap.set("n", "dF",    api.fs.remove, opts("Remove"))
        if _G._os_uname.sysname == "Linux" then
            vim.keymap.set("n", "df", api.fs.trash,  opts("Trash"))
        else
            vim.keymap.set("n", "df", api.fs.remove, opts("Remove"))
        end

        vim.keymap.set("n", "gr", api.fs.rename_basename, opts("Full rename"))
        vim.keymap.set("n", "r",  api.fs.rename,          opts("Rename"))

        vim.keymap.set("n", "dd", api.fs.cut,                opts("Cut"))
        vim.keymap.set("n", "yy", api.fs.copy.node,          opts("Copy"))
        vim.keymap.set("n", "Y",  api.fs.copy.node,          opts("Copy"))
        vim.keymap.set("n", "p",  api.fs.paste,              opts("Paste"))
        vim.keymap.set("n", "yn", api.fs.copy.filename,      opts("Copy file name"))
        vim.keymap.set("n", "yp", api.fs.copy.relative_path, opts("Copy relative path"))
        vim.keymap.set("n", "yP", api.fs.copy.absolute_path, opts("Copy absolute path"))

        vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle mark"))
        vim.keymap.set("n", "q", api.tree.close, opts("Close"))
        vim.keymap.set("n", "?", api.tree.toggle_help, opts("Toggle help"))
    end

    require("nvim-tree").setup { -- BEGIN_DEFAULT_OPTS
        on_attach = onAttach,
        auto_reload_on_write               = true,
        disable_netrw                      = true,
        hijack_netrw                       = true,
        hijack_cursor                      = false,
        hijack_unnamed_buffer_when_opening = false,
        sort_by = "name",  -- name, case_sensitive, modification_time, extension or a
        root_dirs = {},    -- Only relevant when update_focused_file.update_root is true
        prefer_startup_root = false,  -- Only relevant when update_focused_file.update_root is true
        sync_root_with_cwd  = true,
        reload_on_bufenter  = false,
        respect_buf_cwd     = true,
        remove_keymaps      = false,  -- Remove the default mappings in the tree.
        select_prompts      = false,
        view = {
            centralize_selection        = true,
            cursorline                  = true,
            debounce_delay              = 15,
            width                       = 40,
            hide_root_folder            = false,
            side                        = "left",
            preserve_window_proportions = false,
            number                      = false,
            relativenumber              = false,
            signcolumn                  = "no",
            mappings = {custom_only = true},
            float = {
                enable = false,
                quit_on_focus_loss = true,
                open_win_config = {
                    relative = "editor",
                    border   = "rounded",
                    width    = 30,
                    height   = 30,
                    row      = 1,
                    col      = 1,
                },
            },
        },
        renderer = {
            add_trailing  = true,
            group_empty   = true,
            highlight_git = true,
            full_name     = false,
            highlight_opened_files = "name",
            highlight_modified     = "none",
            root_folder_label      = ":~:s?$?/..?",
            indent_width = 2,
            indent_markers = {
                enable        = true,
                inline_arrows = true,
                icons = {
                    corner = "└",
                    edge   = "│",
                    item   = "│",
                    bottom = "─",
                    none   = " ",
                },
            },
            icons = {
                webdev_colors      = true,
                git_placement      = "before",
                modified_placement = "after",
                padding = " ",
                symlink_arrow = " ➛ ",
                show = {
                    file         = true,
                    folder       = true,
                    folder_arrow = true,
                    git          = true,
                    modified     = true,
                },
                glyphs = {
                    default  = icon.ui.Text,
                    symlink  = icon.ui.FileSymlink,
                    bookmark = icon.ui.BookMark,
                    folder   = {
                        arrow_closed = icon.ui.TriangleShortArrowRight,
                        arrow_open   = icon.ui.TriangleShortArrowDown,
                        default      = icon.ui.Folder,
                        open         = icon.ui.FolderOpen,
                        empty        = icon.ui.EmptyFolder,
                        empty_open   = icon.ui.EmptyFolderOpen,
                        symlink      = icon.ui.FolderSymlink,
                        symlink_open = icon.ui.FolderOpen,
                    },
                    git      = {
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
            enable            = false,
            show_on_dirs      = false,
            show_on_open_dirs = true,
            debounce_delay    = 50,
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
            dotfiles  = false,
            git_clean = false,
            no_buffer = false,
            custom    = {},
            exclude   = {},
        },
        filesystem_watchers = {
            enable         = true,
            debounce_delay = 50,
            ignore_dirs    = {},
        },
        git = {
            enable            = true,
            ignore            = false,
            show_on_dirs      = true,
            show_on_open_dirs = true,
            timeout           = 400,
        },
        modified = {
            enable            = false,
            show_on_dirs      = true,
            show_on_open_dirs = true,
        },
        actions = {
            use_system_clipboard = true,
            change_dir = {
                enable             = true,
                global             = false,
                restrict_above_cwd = false,
            },
            expand_all = {
                max_folder_discovery = 300,
                exclude = {},
            },
            file_popup = {
                open_win_config = {
                    col      = 1,
                    row      = 1,
                    relative = "cursor",
                    border   = "rounded",
                    style    = "minimal",
                },
            },
            open_file = {
                quit_on_open = false,
                resize_window = true,
                window_picker = {
                    enable  = true,
                    picker  = "default",
                    chars   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                    exclude = {
                        filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "dap-repl", "help",
                            "packer" },
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
            prefix              = "[FILTER]: ",
        },
        tab = {
            sync = {
                open   = false,
                close  = false,
                ignore = {},
            },
        },
        notify = {
            threshold = vim.log.levels.INFO,
        },
        ui = {
            confirm = {
                remove = true,
                trash  = true,
            },
        },
        log = {
            enable = false,
            truncate = false,
            types = {
                all         = false,
                config      = false,
                copy_paste  = false,
                dev         = false,
                diagnostics = false,
                git         = false,
                profile     = false,
                watcher     = false,
            },
        },
    }
    local toggleAndFocus = function()
        local api = require("nvim-tree.api")
        if vim.bo.filetype == "NvimTree" then
            api.tree.close()
        else
            if api.tree.is_visible() then
                api.tree.focus()
            else
                api.tree.toggle()
            end
        end
    end

    map("n", [[<C-w>e]], toggleAndFocus, "Toggle Nvim tree")
end
