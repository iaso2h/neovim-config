local M = {}


M.setup = function ()
    vim.g.matchup_mappings_enabled      = 0
    vim.g.matchup_matchparen_deferred   = 1
    vim.g.matchup_matchparen_pumvisible = 0
    vim.g.matchup_motion_cursor_end     = 0
    -- vim.g.matchup_matchparen_hi_surround_always = 1
    -- vim.g.matchup_matchparen_hi_background = 1
    -- vim.g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'OffscreenPopup'}
    vim.g.matchup_matchparen_offscreen  = {}
    vim.g.matchup_matchparen_nomode     = "i"
    vim.g.matchup_delim_start_plaintext = 0
    vim.g.matchup_delim_noskips         = 2
    vim.g.matchup_surround_enabled      = 0
end


M.configure = function ()
    -- Text obeject
    map("x", [[am]],      [[<Plug>(matchup-a%)]], "Matchup a% text object")
    map("x", [[im]],      [[<Plug>(matchup-i%)]], "Matchup i% text object")
    map("o", [[am]],      [[<Plug>(matchup-a%)]], "Matchup a% text object")
    map("o", [[im]],      [[<Plug>(matchup-i%)]], "Matchup i% text object")
    -- Inclusive
    map({"n", "x", "o"},  [[<C-m>]],   [[<Plug>(matchup-%)]], "Matchup forward inclusive")
    map({"n", "x", "o"},  [[<C-S-m>]], [[<Plug>(matchup-g%)]], "Matchup backward inclusive")
    -- Exclusive
    map("n", [[<A-m>]],   [[<Plug>(matchup-]%)]], "Matchup forward exclusive")
    map("x", [[<A-m>]],   [[<Plug>(matchup-]%)]], "Matchup forward exclusive")
    map("n", [[<A-S-m>]], [[<Plug>(matchup-[%)]], "Matchup backward exclusive")
    map("x", [[<A-S-m>]], [[<Plug>(matchup-[%)]], "Matchup backward exclusive")
    -- Highlight
    map("n", [[<leader>m]], [[<Plug>(matchup-hi-surround)]], "Highlight Matchup")
end

return M
