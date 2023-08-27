return function(args)
    local icon = require("icon")

    require("nvim-lightbulb").setup {
        -- Priority of the lightbulb for all handlers except float.
        priority = 10,
        -- Whether or not to hide the lightbulb when the buffer is not focused.
        -- Only works if configured during NvimLightbulb.setup
        hide_in_unfocused_buffer = true,
        -- Whether or not to link the highlight groups automatically.
        -- Default highlight group links:
        --   LightBulbSign -> DiagnosticSignInfo
        --   LightBulbFloatWin -> DiagnosticFloatingInfo
        --   LightBulbVirtualText -> DiagnosticVirtualTextInfo
        --   LightBulbNumber -> DiagnosticSignInfo
        --   LightBulbLine -> CursorLine
        -- Only works if configured during NvimLightbulb.setup
        link_highlights = true,
        -- Perform full validation of configuration.
        -- Available options: "auto", "always", "never"
        --   "auto" only performs full validation in NvimLightbulb.setup.
        --   "always" performs full validation in NvimLightbulb.update_lightbulb as well.
        --   "never" disables config validation.
        validate_config = "auto",
        -- Code action kinds to observe.
        -- To match all code actions, set to `nil`.
        -- Otherwise, set to a table of kinds.
        -- Example: { "quickfix", "refactor.rewrite" }
        -- See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeActionKind
        action_kinds = nil,
        virtual_text = {
            enabled = true,
            -- Text to show in the virt_text.
            text = icon.ui.Lightbulb,
            -- Position of virtual text given to |nvim_buf_set_extmark|.
            -- Can be a number representing a fixed column (see `virt_text_pos`).
            -- Can be a string representing a position (see `virt_text_win_col`).
            pos = "eol",
            -- Highlight group to highlight the virtual text.
            hl = "LightBulbVirtualText",
            -- How to combine other highlights with text highlight.
            -- See `hl_mode` of |nvim_buf_set_extmark|.
            hl_mode = "combine",
        },
        sign        = { enabled = false, },
        float       = { enabled = false, },
        status_text = { enabled = false, },
        number      = { enabled = false, },
        line        = { enabled = false, },
        -- Autocmd configuration.
        -- If enabled, automatically defines an autocmd to show the lightbulb.
        -- If disabled, you will have to manually call |NvimLightbulb.update_lightbulb|.
        -- Only works if configured during NvimLightbulb.setup
        autocmd = {
            -- Whether or not to enable autocmd creation.
            enabled = true,
            -- See |updatetime|.
            -- Set to a negative value to avoid setting the updatetime.
            updatetime = 200,
            -- See |nvim_create_autocmd|.
            events = { "CursorHold", "CursorHoldI" },
            -- See |nvim_create_autocmd| and |autocmd-pattern|.
            pattern = { "*" },
        },
        -- Scenarios to not show a lightbulb.
        ignore = {
            -- LSP client names to ignore.
            -- Example: {"null-ls", "lua_ls"}
            clients = {},
            -- Filetypes to ignore.
            -- Example: {"neo-tree", "lua"}
            ft = {},
            -- Ignore code actions without a `kind` like refactor.rewrite, quickfix.
            actions_without_kind = false,
        },
    }
end
