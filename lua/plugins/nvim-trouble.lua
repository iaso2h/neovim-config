-- https://github.com/folke/trouble.nvim
return function()
    local icon = require("icon")

    require("trouble").setup {
        position    = "bottom",  -- position of the list can be: bottom, top, left, right
        height      = 15,        -- height of the trouble list when position is top or bottom
        width       = 50,        -- width of the list when position is left or right
        icons       = true,      -- use devicons for filenames
        mode        = "workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open   = icon.ui.TriangleShortArrowDown,
        fold_closed = icon.ui.TriangleShortArrowRight,
        group = true,       -- group results by file
        padding = false,    -- add an extra new line on top of the list
        action_keys = {
            -- key mappings for actions in the trouble list
            -- map to {} to remove a mapping, for example:
            -- close = {},
            close          = "q",                 -- close the list
            cancel         = {"<esc>", "<C-o>"},  -- cancel the preview and get back to your last window / buffer / cursor
            refresh        = "r",                 -- manually refresh

            jump           = "<CR>",   -- jump to the diagnostic or open / close folds
            jump_close     = "o",      -- jump to the diagnostic and close the list
            open_split     = "<C-s>",  -- open buffer in new split
            open_vsplit    = "<C-v>",  -- open buffer in new vsplit
            open_tab       = "<C-t>",  -- open buffer in new tab

            toggle_mode    = "<Tab>",  -- toggle between "workspace" and "document" diagnostics mode
            toggle_preview = "P",      -- toggle auto_preview

            hover          = "K",  -- opens a small popup with the full multiline message
            preview        = "p",  -- preview the diagnostic location

            close_folds    = "zm",  -- close all folds
            open_folds     = "zr",  -- open all folds
            toggle_fold    = "u",   -- toggle fold of current file

            previous       = "k",  -- preview item
            next           = "j"   -- next item
        },

        indent_lines = true,              -- add an indent guide below the fold icons
        win_config = { border = "rounded" },
        auto_open    = false,             -- automatically open the list when you have diagnostics
        auto_close   = false,             -- automatically close the list when you have no diagnostics
        auto_preview = false,             -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold    = true,              -- automatically fold a file trouble list at creation
        auto_jump = {"lsp_definitions"},  -- for the given modes, automatically jump if there is only a single result
        include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions"  }, -- for the given modes, include the declaration of the current symbol in the results
        signs        = {
        -- icons / text used for a diagnostic
            error       = icon.diagnostics.Error,
            warning     = icon.diagnostics.Warning,
            hint        = icon.diagnostics.Hint,
            information = icon.diagnostics.Information,
            other       = icon.diagnostics.BoxChecked
        },
        use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
    }
    -- BUG:
    -- map("n", "<leader>D", [[<CMD>TroubleToggle quickfix<CR>]],
    --     { "silent", "noremap" }, "Toggle trouble quickfix")
end
