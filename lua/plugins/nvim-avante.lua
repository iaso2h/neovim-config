return function()
    require("avante").setup {
        provider = "deepseek",
        auto_suggestions_provider = nil,
        providers = {
            deepseek = {
                __inherited_from = "openai",
                endpoint = "https://api.deepseek.com/v1",
                model = "deepseek-coder",
                api_key_name = "DEEPSEEK_API_KEY",
                extra_request_body = {
                    max_tokens = 8192,
                },
            }
        },
    behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
    },
    mappings = {
        --- @class AvanteConflictMappings
        diff = {
            ours       = "co",
            theirs     = "ct",
            all_theirs = "ca",
            both       = "cb",
            cursor     = "cc",
            next       = "]x",
            prev       = "[x",
        },
        suggestion = {
            accept  = "<M-f>",
            next    = "<M-]>",
            prev    = "<M-[>",
            dismiss = "<C-]>",
        },
        jump = {
            next = "]]",
            prev = "[[",
        },
        submit = {
            normal = "<CR>",
            insert = "<A-s>",
        },
        sidebar = {
            apply_all              = "A",
            apply_cursor           = "a",
            switch_windows         = "<Tab>",
            reverse_switch_windows = "<S-Tab>",
        },
    },
    hints = {
        enabled = false
    },
    windows = {
        ---@type "right" | "left" | "top" | "bottom"
            position = "right", -- the position of the sidebar
            wrap = true, -- similar to vim.o.wrap
            width = 30, -- default % based on available width
            sidebar_header = {
                enabled = true, -- true, false to enable/disable the header
                align = "center", -- left, center, right for title
                rounded = true,
        },
        input = {
        prefix = "> ",
        height = 8, -- Height of the input window in vertical layout
        },
        edit = {
            border = "rounded",
            start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
        floating = false, -- Open the 'AvanteAsk' prompt in a floating window
        start_insert = true, -- Start insert mode when opening the ask window
        border = "rounded",
        ---@type "ours" | "theirs"
        focus_on_apply = "ours", -- which diff to focus after applying
        },
    },
    highlights = {
        ---@type AvanteConflictHighlights
        diff = {
            current = "DiffText",
            incoming = "DiffAdd",
        },
    },
    --- @class AvanteConflictUserConfig
    diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = "copen",
        --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
        --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
        --- Disable by setting to -1.
        override_timeoutlen = 500,
    },
}
end
