return function ()
require('gitsigns').setup{
    signs = {
        add          = {hl = 'GitSignsAdd'   , text = '▕', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
        change       = {hl = 'GitSignsChange', text = '▕', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        delete       = {hl = 'GitSignsDelete', text = '▕', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        topdelete    = {hl = 'GitSignsDelete', text = '▕', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        changedelete = {hl = 'GitSignsChange', text = '▕', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    keymaps    = {
        -- Default keymap options
        noremap = true,

        ['n ]h'] = {expr = true, "&diff ? ']h' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},
        ['n [h'] = {expr = true, "&diff ? '[h' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},

        ['n <C-h>s'] = '<cmd>Gitsigns stage_hunk<CR>',
        ['v <C-h>s'] = ':Gitsigns stage_hunk<CR>',
        ['n <C-h>S'] = '<cmd>Gitsigns stage_buffer<CR>',
        ['n <C-h>u'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
        ['n <C-h>U'] = '<cmd>Gitsigns reset_buffer_index<CR>',
        ['n <C-h>r'] = '<cmd>Gitsigns reset_hunk<CR>',
        ['v <C-h>r'] = ':Gitsigns reset_hunk<CR>',
        ['n <C-h>R'] = '<cmd>Gitsigns reset_buffer<CR>',
        ['n <C-h>p'] = '<cmd>Gitsigns preview_hunk<CR>',
        ['n <C-h>b'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',

        -- Text objects
        ['o ih'] = ':<C-u>lua require"gitsigns.actions".select_hunk()<CR>',
        ['x ih'] = ':<C-u>lua require"gitsigns.actions".select_hunk()<CR>'
    },
    watch_gitdir = {
        interval     = 1000,
        follow_files = true
    },
    attach_to_untracked     = true,
    current_line_blame      = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text     = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay         = 1000,
    },
    current_line_blame_formatter_opts = {
        relative_time = false
    },
    sign_priority    = 6,
    update_debounce  = 100,
    status_formatter = nil, -- Use default
    max_file_length  = 40000,
    preview_config   = {
        -- Options passed to nvim_open_win
        border   = 'rounded',
        style    = 'minimal',
        relative = 'cursor',
        row      = 0,
        col      = 1
    },
    yadm              = {
        enable = false
    },
}

end

