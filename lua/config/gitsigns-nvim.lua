require('gitsigns').setup {
    signs = {
        add = {
            hl = 'GitSignsAdd',
            text = '│',
            numhl = 'GitSignsAddNr',
            linehl = 'GitSignsAddLn'
        },
        change = {
            hl = 'GitSignsChange',
            text = '│',
            numhl = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn'
        },
        delete = {
            hl = 'GitSignsDelete',
            text = '_',
            numhl = 'GitSignsDeleteNr',
            linehl = 'GitSignsDeleteLn'
        },
        topdelete = {
            hl = 'GitSignsDelete',
            text = '‾',
            numhl = 'GitSignsDeleteNr',
            linehl = 'GitSignsDeleteLn'
        },
        changedelete = {
            hl = 'GitSignsChange',
            text = '~',
            numhl = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn'
        }
    },
    numhl = false,
    linehl = false,
    keymaps = {
        -- Default keymap options
        noremap = true,
        buffer = true,

        ['n ]h'] = {
            expr = true,
            "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<cr>'"
        },
        ['n [h'] = {
            expr = true,
            "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<cr>'"
        },

        ['n <leader>gs'] = ':lua require"gitsigns".stage_hunk()<cr>',
        ['n <leader>gu'] = ':lua require"gitsigns".undo_stage_hunk()<cr>',
        ['n <leader>gr'] = ':lua require"gitsigns".reset_hunk()<cr>',
        ['n <leader>gR'] = ':lua require"gitsigns".reset_buffer()<cr>',
        ['n <leader>gp'] = ':lua require"gitsigns".preview_hunk()<cr>',
        ['n <leader>gb'] = ':lua require"gitsigns".blame_line()<cr>',

        -- Text objects
        ['o ih'] = ':<C-U>lua require"gitsigns".text_object()<cr>',
        ['x ih'] = ':<C-U>lua require"gitsigns".text_object()<cr>'
    },
    watch_index = {interval = 1000},
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    use_decoration_api = true,
    use_internal_diff = false -- If luajit is present
}

