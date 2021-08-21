local fn  = vim.fn
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
    '  Keyword',        -- Keyword
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
    resolve_timeout  = 800;
    incomplete_delay = 400,
    max_abbr_width   = 100,
    max_kind_width   = 100,
    max_menu_width   = 100,
    documentation = {
        border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
        winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
        max_width = 120,
        min_width = 60,
        max_height = math.floor(vim.o.lines * 0.3),
        min_height = 1,
    },

    source = {
        tags  = false,
        emoji = false,
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
-- local autoPair = require('nvim-autopairs')
-- _G.Completion= {}
-- vim.g.completion_confirm_key = ""
-- Completion.confirm = function()
    -- if fn.pumvisible() ~= 0 then
        -- if fn.complete_info()["selected"] ~= -1 then
            -- fn["compe#confirm"]()
            -- return autoPair.esc("<c-y>")
        -- else
            -- vim.defer_fn(function()
                -- fn["compe#confirm"]("<cr>")
                -- end, 20)
            -- return autoPair.esc("<c-n>")
        -- end
    -- else
        -- return autoPair.check_break_line_char()
    -- end
-- end
-- }}} Confirm key
-- map('i', [[<CR>]],      [[v:lua.Completion.confirm()]],                     {"silent", "expr"})

map("i", [[<CR>]], [[compe#confirm(luaeval("require 'nvim-autopairs'.autopairs_cr()"))]], {"silent", "expr"})
map("i", [[<C-e>]],     [[pumvisible() ? compe#close('<C-e>') : "\<End>"]], {"silent", "expr"})
map("i", [[<C-Space>]], [[pumvisible() ? compe#close('<C-e>') : "\<C-n>"]], {"silent", "expr"})
map("i", [[<A-e>]],     [[compe#scroll({'delta': +4})]],                    {"silent", "expr"})
map("i", [[<A-d>]],     [[compe#scroll({'delta': -4})]],                    {"silent", "expr"})
-- }}} hrsh7th/nvim-compe

