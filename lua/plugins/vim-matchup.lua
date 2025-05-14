local M = {}


M.setup = function ()
    vim.g.matchup_mappings_enabled      = 0
    vim.g.matchup_matchparen_enabled    = 0
    vim.g.matchup_mouse_enabled         = 0
    vim.g.matchup_motion_enabled        = 1
    vim.g.matchup_text_obj_enabled      = 1

    vim.g.matchup_delim_start_plaintext = 1
    vim.g.matchup_delim_noskips         = 2

    vim.g.matchup_matchparen_pumvisible = 0
    vim.g.matchup_motion_cursor_end     = 0
    -- vim.g.matchup_matchparen_hi_surround_always = 1
    -- vim.g.matchup_matchparen_hi_background = 1
    -- vim.g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'OffscreenPopup'}
    vim.g.matchup_matchparen_offscreen = {}

    vim.g.matchup_matchparen_nomode    = "i"
    vim.g.matchup_matchparen_deferred            = 1
    vim.g.matchup_matchparen_deferred_show_delay = 400
    vim.g.matchup_matchparen_deferred_hide_delay = 400


    vim.g.matchup_surround_enabled      = 0
end


M.config = function ()
    require("nvim-treesitter.configs").setup{
        matchup = {
            enable  = true,
            disable = {"help"}
        },
    }
end

return M
