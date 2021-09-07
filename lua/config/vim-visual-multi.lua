local M   = {}

M.VM_Start = function()
    map("i", [[<C-BS>]],    [[<C-\><C-o>db]])
    map("n", [[S]],         [[ys]])
    map("n", [[<leader>h]], [[<esc>]])
    map("n", [[<C-n>]],     [[,<C-n>]])
    map("n", [[<C-p>]],     [[,<C-p>]])
end

M.VM_Exit = function()
    map("n", [[<leader>h]], [[:noh<cr>]], {"silent"})
    map("n", [[<C-p>]],     [[<C-p>]],    {"noremap"})
end

M.config = function() -- {{{
    local cmd = vim.cmd
    vim.g.VM_default_mappings               = 0
    vim.g.VM_silent_exit                    = 1
    vim.g.VM_quit_after_leaving_insert_mode = 1
    vim.g.VM_use_first_cursor_in_line       = 1
    vim.g.VM_reselect_first                 = 1
    vim.g.VM_verbose_commands               = 1
    vim.g.VM_mouse_mappings                 = 1
    vim.g.VM_skip_shorter_lines             = 0
    vim.g.VM_skip_empty_lines               = 1
    vim.g.VM_insert_special_keys            = {'c-v', 'c-e', 'c-a'}
    -- Settings

    -- vim.g.VM_theme = 'nord'
    -- TODO: Highlight
    vim.g.VM_Mono_hl   = "VMMono"
    vim.g.VM_Extend_hl = "VMExtend"
    vim.g.VM_Cursor_hl = "VMCursor"
    vim.g.VM_Insert_hl = "VMInsert"

    -- NOTE: There are two main modes VM can work in,  cursor-mode  and  extend-mode .
    -- NOTE: They roughly correspond to  normal-mode  and  visual-mode .
    -- Add new mapping while preserving the orginal mapping at the same time
    vim.g.VM_custom_remaps = {["<C-v>"] = "<C-r>", ["s"] = "c"}
    -- To remap any key to normal! commands. Example:
    vim.g.VM_custom_noremaps = {["=="] = "==", ["<<"] = "<<", [">>"] = ">>"}

    cmd [[
    augroup VmStartMapping
        autocmd!
        autocmd User visual_multi_start lua require("config.vim-visual-multi").VM_Start()
        autocmd User visual_multi_exit  lua require("config.vim-visual-multi").VM_Exit()
    augroup END
        ]]

    local VMMaps = {}
    VMMaps['Reselect Last']      = ',m'
    VMMaps['Find Under']         = '<C-d>'
    VMMaps['Visual Add']         = '<C-d>'
    VMMaps["Select Cursor Down"] = ',j'
    VMMaps["Select Cursor Up"]   = ',k'
    VMMaps['Skip Region']        = '<C-k>'
    VMMaps['Remove Region']      = 'u'
    VMMaps['Select All']         = '<leader>d'
    VMMaps['Visual All']         = '<leader>d'

    -- Navigaton
    VMMaps['Invert Direction'] = 'o'
    VMMaps['Find Next']        = 'n'
    VMMaps['Find Prev']        = 'N'
    VMMaps['Goto Next']        = ',<C-n>'  -- Without adding new occurrences
    VMMaps['Goto Prev']        = ',<C-p>'  -- Without adding new occurrences
    -- Modify selection
    VMMaps['Enlarge'] = '<A-a>'
    VMMaps['Shrink']  = '<A-s>'
    -- Number
    -- Align
    VMMaps['Align Char'] = ',>'
    -- Run
    VMMaps['Run Normal']    = ',!'
    VMMaps['Run Macro']     = ',@'
    VMMaps['Show Register'] = ',"'
    vim.g.VM_maps = VMMaps
end -- }}}

return M

