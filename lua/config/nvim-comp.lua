local fn = vim.fn
local api = vim.api
local map = require("util").map

-- LSP completion icon {{{
require('vim.lsp.protocol').CompletionItemKind = {
    '  Text',           -- Text
    '  Function',       -- Function
    '  Method',         -- Method
    '  Constructor',    -- Constructor
    '  Field',          -- Field
    '  Variable',       -- Variable
    '  Class',          -- Class
    '  Interface',      -- Interface
    '  Module',         -- Module
    '  Property',       -- Property
    '  Unit',           -- Unit
    '  Value',          -- Value
    '  Enum',           -- Enum
    '🚩 Keyword',        -- Keyword
    '  Snippet',        -- Snippet
    '  Color',          -- Color
    '  File',           -- File
    '  Reference',      -- Reference
    '  Folder',         -- Folder
    '  EnumMember',     -- EnumMember
    '  Constant',       -- Constant
    '  Struct',         -- Struct
    '  Event',          -- Event
    '⨋  Operator',       -- Operator
    '  TypeParameter',  -- TypeParameter
}
-- }}} LSP completion icon

-- Snippet {{{
vim.g.vsnip_snippet_dir = fn.expand("$configPath/snippets")
vim.g.vsnip_filetypes = {
    javascriptreact = {"javascript"},
    typescriptreact = {"typescript"}
}

-- Key mapping {{{
local t = function(str)
    return api.nvim_replace_termcodes(str, true, true, true)
end

local checkBackSpace = function()
    local col = api.nvim_win_get_cursor(0)[2]
    if col == 0 or api.nvim_get_current_line():sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tabComplete = function()
    -- if vim.fn.pumvisible() == 1 then
        -- return t "<C-n>"
    if vim.fn.call("vsnip#available", {1}) == 1 then
        return t "<Plug>(vsnip-expand-or-jump)"
    elseif checkBackSpace() then
        return t "<C-S-]>"
    else
        return vim.fn['compe#complete']()
    end
end
_G.sTabComplete = function()
    -- if vim.fn.pumvisible() == 1 then
        -- return t "<C-p>"
    if vim.fn.call("vsnip#jumpable", {-1}) == 1 then
        return t "<Plug>(vsnip-jump-prev)"
    else
        return t "<C-S-[>"
    end
end


map("i", [[<Tab>]], [[v:lua.tabComplete()]],    {"silent", "expr"})
map("s", [[<Tab>]], [[v:lua.tabComplete()]],    {"silent", "expr"})
map("i", [[<S-Tab>]], [[v:lua.sTabComplete()]], {"silent", "expr"})
map("s", [[<S-Tab>]], [[v:lua.sTabComplete()]], {"silent", "expr"})
-- }}} Key mapping
-- }}} Snippet

-- hrsh7th/nvim-compe {{{
require("compe").setup {
    enabled          = true,
    autocomplete     = true,
    debug            = false,
    min_length       = 3,
    preselect        = 'always',
    throttle_time    = 80,
    source_timeout   = 200,
    incomplete_delay = 400,
    max_abbr_width   = 100,
    max_kind_width   = 100,
    max_menu_width   = 100,
    documentation    = true,

    source = {
        omni = false,
        tags = true,
        emoji = true,
        path = {
            kind = '  Path',
        },
        buffer = {
            kind = '  Buffer',
        },
        calc     = {
            kind = '  Calc',
        },
        nvim_lsp = true,
        nvim_lua = true,
        tabnine  = {
            kind = '  Tabnine',
            max_line                 = 1000,
            max_num_results          = 6,
            priority                 = 5000,
            sort                     = true,
            show_prediction_strength = true
        },
        vsnip    = {
            kind = '  VSnip'
        },
    },
}
-- Confirm key {{{
local autoPair = require('nvim-autopairs')
_G.Completion= {}
vim.g.completion_confirm_key = ""
Completion.confirm = function()
    if fn.pumvisible() ~= 0 then
        if fn.complete_info()["selected"] ~= -1 then
            fn["compe#confirm"]()
            return autoPair.esc("<c-y>")
        else
            vim.defer_fn(function()
                fn["compe#confirm"]("<cr>")
                end, 20)
            return autoPair.esc("<c-n>")
        end
    else
        return autoPair.check_break_line_char()
    end
end
-- }}} Confirm key

map('i', [[<CR>]],      [[v:lua.Completion.confirm()]],                     {"silent", "expr"})
map("i", [[<C-e>]],     [[pumvisible() ? compe#close('<C-e>') : "\<End>"]], {"silent", "expr"})
map("i", [[<A-e>]],     [[compe#scroll({'delta': +4})]],                    {"silent", "expr"})
map("i", [[<A-d>]],     [[compe#scroll({'delta': -4})]],                    {"silent", "expr"})
map("i", [[<C-Space>]], [[pumvisible() ? compe#close('<C-e>') : "\<C-n>"]], {"silent", "expr"})
-- }}} hrsh7th/nvim-compe

