return function()

local cb = require("diffview.config").diffview_callback

require("diffview").setup {
    diff_binaries    = false,  -- Show diffs for binaries
    use_icons        = true,   -- Requires nvim-web-devicons
    enhanced_diff_hl = false,  -- See ':h diffview-config-enhanced_diff_hl'
    signs = {
        fold_closed = "",
        fold_open = "",
    },
    file_panel = {
        position = "left",  -- One of 'left', 'right', 'top', 'bottom'
        width    = 35,      -- Only applies when position is 'left' or 'right'
        height   = 10,      -- Only applies when position is 'top' or 'bottom'
    },
    file_history_panel = {
        position = "bottom",
        width    = 35,
        height   = 16,
        log_options = {
            max_count = 256,    -- Limit the number of commits
            follow    = false,  -- Follow renames (only for single file)
            all       = false,  -- Include all refs under 'refs/' including HEAD
            merges    = false,  -- List only merge commits
            no_merges = false,  -- List no merge commits
            reverse   = false,  -- List commits in reverse order
        },
    },
    key_bindings = {
        disable_defaults = false,                   -- Disable the default key bindings
        -- The `view` bindings are active in the diff buffers, only when the current
        -- tabpage is a Diffview.
        view = {
            ["<C-j>"]      = cb("select_next_entry"),  -- Open the diff for the next file
            ["<C-k>"]      = cb("select_prev_entry"),  -- Open the diff for the previous file
            ["gf"]         = cb("goto_file"),          -- Open the file in a new split in previous tabpage
            ["<C-w><C-f>"] = cb("goto_file_split"),    -- Open the file in a new split
            ["<C-w>gF"]    = cb("goto_file_tab"),      -- Open the file in a new tabpage
            ["<Tab>"]      = cb("focus_files"),        -- Bring focus to the files panel
            ["<C-w>F"]     = cb("toggle_files"),       -- Toggle the files panel.
        },
        file_panel = {
            ["<C-n>"]  = cb("next_entry"),              -- Bring the cursor to the next file entry
            ["<down>"] = cb("next_entry"),
            ["<C-p>"]  = cb("prev_entry"),              -- Bring the cursor to the previous file entry.
            ["<up>"]   = cb("prev_entry"),
            ["<C-j>"]  = cb("select_next_entry"),
            ["<C-k>"]  = cb("select_prev_entry"),

            ["<cr>"]          = cb("select_entry"),     -- Open the diff for the selected entry.
            ["o"]             = cb("select_entry"),
            ["<2-LeftMouse>"] = cb("select_entry"),

            ["-"]          = cb("toggle_stage_entry"),  -- Stage / unstage the selected entry.
            ["S"]          = cb("stage_all"),           -- Stage all entries.
            ["U"]          = cb("unstage_all"),         -- Unstage all entries.
            ["X"]          = cb("restore_entry"),       -- Restore entry to the state on the left side.
            ["R"]          = cb("refresh_files"),       -- Update stats and entries in the file list.
            ["gF"]         = cb("goto_file"),
            ["<C-w><C-f>"] = cb("goto_file_split"),
            ["<C-w>gF"]    = cb("goto_file_tab"),
            ["<Tab>"]      = cb("focus_files"),
            ["<C-w>f"]     = cb("toggle_files"),
        },
        file_history_panel = {
            ["g!"] = cb("options"),                  -- Open the option panel
            ["gd"] = cb("open_in_diffview"),         -- Open the entry under the cursor in a diffview
            ["zR"] = cb("open_all_folds"),
            ["zM"] = cb("close_all_folds"),

            ["<C-n>"]  = cb("next_entry"),           -- Bring the cursor to the next file entry
            ["<down>"] = cb("next_entry"),
            ["<C-p>"]  = cb("prev_entry"),           -- Bring the cursor to the previous file entry.
            ["<up>"]   = cb("prev_entry"),
            ["<C-j>"]  = cb("select_next_entry"),
            ["<C-k>"]  = cb("select_prev_entry"),

            ["<cr>"]          = cb("select_entry"),  -- Open the diff for the selected entry.
            ["o"]             = cb("select_entry"),
            ["<2-LeftMouse>"] = cb("select_entry"),

            ["gf"]         = cb("goto_file"),
            ["<C-w><C-f>"] = cb("goto_file_split"),
            ["<C-w>gf"]    = cb("goto_file_tab"),
            ["<Tab>"]      = cb("focus_files"),
            ["<C-w>f"]     = cb("toggle_files"),
        },
        option_panel = {
            ["<tab>"] = cb("select"),
            ["q"]     = cb("close"),
        },
    }
}

end
