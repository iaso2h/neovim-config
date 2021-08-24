-- File: nvim-barbar
-- Author: iaso2h
-- Description: barbar.nvim configuration
-- Version: 0.0.8
-- Last Modified: 2021-08-22
local cmd = vim.cmd
local map = require("util").map
local M   = {}

function M.bufferSwitcher(CMD)
    local fileType = vim.bo.filetype
    local bufType  = vim.bo.buftype
    -- call origin vim command "bp/bn" when barbar.nvim does not support
    if vim.tbl_contains(require("galaxyline").short_line_list, fileType) or bufType == "terminal" or bufType == "help" or bufType == "nowrite" then
        cmd(CMD)
    else
        if CMD == "bp" then
            cmd "BufferPrevious"
        else
            cmd "BufferNext"
        end
    end
end
map("n", [[<A-h>]], [[:lua require("config.nvim-barbar").bufferSwitcher("bp")<cr>]], {"silent"})
map("n", [[<A-l>]], [[:lua require("config.nvim-barbar").bufferSwitcher("bn")<cr>]], {"silent"})
-- map("n", [[<A-h>]], [[:BufferPrevious<cr>]], {"silent"})
-- map("n", [[<A-l>]], [[:BufferNext<cr>]],     {"silent"})

map("n", [[<A-S-h>]], [[:BufferMovePrevious<CR>]], {"silent"})
map("n", [[<A-S-l>]], [[:BufferMoveNext<cr>]],     {"silent"})

-- Goto buffer in position...
map("n", [[<A-1>]], [[:BufferGoto 1<cr>]],           {"silent"})
map("n", [[<A-2>]], [[:BufferGoto 2<cr>]],           {"silent"})
map("n", [[<A-3>]], [[:BufferGoto 3<cr>]],           {"silent"})
map("n", [[<A-4>]], [[:BufferGoto 4<cr>]],           {"silent"})
map("n", [[<A-5>]], [[:BufferGoto 5<cr>]],           {"silent"})
map("n", [[<A-6>]], [[:BufferGoto 6<cr>]],           {"silent"})
map("n", [[<A-7>]], [[:BufferGoto 7<cr>]],           {"silent"})
map("n", [[<A-8>]], [[:BufferGoto 8<cr>]],           {"silent"})
map("n", [[<A-9>]], [[:BufferLast<cr>]],             {"silent"})
map("t", [[<A-1>]], [[<C-\><C-n>:BufferGoto 1<cr>]], {"silent"})
map("t", [[<A-2>]], [[<C-\><C-n>:BufferGoto 2<cr>]], {"silent"})
map("t", [[<A-3>]], [[<C-\><C-n>:BufferGoto 3<cr>]], {"silent"})
map("t", [[<A-4>]], [[<C-\><C-n>:BufferGoto 4<cr>]], {"silent"})
map("t", [[<A-5>]], [[<C-\><C-n>:BufferGoto 5<cr>]], {"silent"})
map("t", [[<A-6>]], [[<C-\><C-n>:BufferGoto 6<cr>]], {"silent"})
map("t", [[<A-7>]], [[<C-\><C-n>:BufferGoto 7<cr>]], {"silent"})
map("t", [[<A-8>]], [[<C-\><C-n>:BufferGoto 8<cr>]], {"silent"})
map("t", [[<A-9>]], [[<C-\><C-n>:BufferLast<cr>]],   {"silent"})

-- Magic buffer-picking mode
map("n", [[<leader>b]], [[:BufferPick<cr>]], {"silent"})

-- Sort by...
map("n", [[gbd]], [[:BufferOrderByDirectory<cr>]],    {"silent"})
map("n", [[gbl]], [[:BufferOrderByLanguage<cr>]],     {"silent"})
map("n", [[gbb]], [[:BufferOrderByBufferNumber<cr>]], {"silent"})
map("n", [[gbw]], [[:BufferOrderByWindowNumber<cr>]], {"silent"})
-- Pin buffer
-- map("n", [[<A-p>]], [[:BufferPin<cr>]], {"silent"})

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used

vim.g.bufferline = {
	-- Enables animations.
    animation = true,
    -- Enable/disable auto-hiding the tab bar when there is a single buffer
    auto_hide = false,
    -- Enable/disable current/total tabpages indicator (top right corner).
    tabpages = true,
    -- Enable/disable icons
    -- if set to 'numbers', will show buffer index in the tabline
    -- if set to 'both', will show buffer index and icons in the tabline
    icons = "both",
    -- Sets the icon's highlight group.
    -- If false, will use nvim-web-devicons colors
    icon_custom_colors = false,
    -- Configure icons on the bufferline.
    icon_separator_active   = '▍',
    icon_separator_inactive = '',
    icon_close_tab          = '✕ ',
    icon_close_tab_modified = '●',
    icon_pinned             = '車',
	-- If true, new buffers appear at the end of the list. Default is to
	-- open after the current buffer.
    insert_at_end = false,
    -- Enable/disable close button
    closable = true,
    -- Enables/disable clickable tabs
    --  - left-click: go to buffer
    --  - middle-click: delete buffer
    clickable = true,
	-- If set, the letters for each buffer in buffer-pick mode will be
	-- assigned based on their name. Otherwise or in case all letters are
	-- already assigned, the behavior is to assign letters in order of
	-- usability (see order just below)
    semantic_letters = true,
    -- New buffer letters are assigned in this order. This order is
    -- optimal for the qwerty keyboard layout but might need adjustement
    -- for other layouts.
    letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
    -- Sets the maximum padding width with which to surround each tab
    maximum_padding = 4
}

if os.getenv("TERM") then
    vim.g.bufferline.icon_separator_active = '▎'
end

return M

