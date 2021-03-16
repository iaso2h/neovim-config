local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
-- mg979/vim-visual-multi-multi {{{
vim.g.VM_default_mappings               = 0
vim.g.VM_silent_exit                    = 1
vim.g.VM_quit_after_leaving_insert_mode = 1
vim.g.VM_use_first_cursor_in_line       = 1
vim.g.VM_reselect_first                 = 1
vim.g.VM_verbose_commands               = 1
vim.g.VM_skip_shorter_lines             = 0
vim.g.VM_skip_empty_lines               = 1
vim.g.VM_insert_special_keys            = {'c-v', 'c-e', 'c-a'}
-- Settings

-- vim.g.VM_theme = 'nord'

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
function M.VM_Start()
    -- TODO remap coc enter
    map("i", [[<C-BS>]],    [[<C-\><C-o>db]])
    map("n", [[S]],         [[ys]])
    map("n", [[<leader>h]], [[<esc>]])
    map("n", [[<C-n>]],     [[,<C-n>]])
    map("n", [[<C-p>]],     [[,<C-p>]])
end

function M.VM_Exit()
    map("n", [[<leader>h]], [[:noh<cr>]], {"silent"})
    map("n", [[<C-p>]],     [[<C-p>]],    {"noremap"})
end

api.nvim_exec([[
augroup VmStartMapping
autocmd!
autocmd User visual_multi_start lua require("plugins.vim-visual-multi").VM_Start()
autocmd User visual_multi_exit  lua require("plugins.vim-visual-multi").VM_Exit()
augroup END
    ]], false)

vim.g.VM_mouse_mappings             = 1

local VMMaps = {}
VMMaps['Reselect Last']      = 'gm'
VMMaps['Find Under']         = '<C-d>'
VMMaps['Visual Add']         = '<C-d>'
VMMaps["Select Cursor Down"] = ',j'
VMMaps["Select Cursor Up"]   = ',k'
VMMaps['Skip Region']        = '<C-k>'
VMMaps['Remove Region']      = 'u'
VMMaps['Select All']         = '<C-S-a>'
VMMaps['Visual All']         = '<C-S-a>'

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
-- }}} mg979/vim-visual-multi-multi

return M

