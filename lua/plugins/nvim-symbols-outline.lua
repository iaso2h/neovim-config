return function()
    local icon = require("icon")
    local args = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Visual',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { icon.ui.ChevronShortRight, icon.ui.ChevronShortDown,},
        wrap = false,
        keymaps = {
                -- These keymaps can be a string or a table for multiple keys
            close          = { "<ESC>", "q" },
            goto_location  = "o",
            focus_location = "<CR>",
            hover_symbol   = "K",
            toggle_preview = "p",
            rename_symbol  = "r",
            code_actions   = "a",
            -- TODO:
            fold           = "<leader><space>",
            unfold         = "u",
            fold_all       = "zm",
            unfold_all     = "zr",
            fold_reset     = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
            File          = { icon = icon.kind.File,          hl = "CmpItemKindFile" },
            Module        = { icon = icon.kind.Module,        hl = "CmpItemKindModule" },
            Namespace     = { icon = icon.kind.Namespace,     hl = "CmpItemKindNamespace" },
            Package       = { icon = icon.kind.Package,       hl = "CmpItemKindPackage" },
            Class         = { icon = icon.kind.Class,         hl = "CmpItemKindClass" },
            Method        = { icon = icon.kind.Method,        hl = "CmpItemKindMethod" },
            Property      = { icon = icon.kind.Property,      hl = "CmpItemKindProperty" },
            Field         = { icon = icon.kind.Field,         hl = "CmpItemKindField" },
            Constructor   = { icon = icon.kind.Constructor,   hl = "CmpItemKindConstructor" },
            Enum          = { icon = icon.kind.Enum,          hl = "CmpItemKindEnum" },
            Interface     = { icon = icon.kind.Interface,     hl = "CmpItemKindInterface" },
            Function      = { icon = icon.kind.Function,      hl = "CmpItemKindfunction" },
            Variable      = { icon = icon.kind.Variable,      hl = "CmpItemKindVariable" },
            Constant      = { icon = icon.kind.Constant,      hl = "CmpItemKindConstant" },
            String        = { icon = icon.kind.String,        hl = "CmpItemKindString" },
            Number        = { icon = icon.kind.Number,        hl = "CmpItemKindNumber" },
            Boolean       = { icon = icon.kind.Boolean,       hl = "CmpItemKindBoolean" },
            Array         = { icon = icon.kind.Array,         hl = "CmpItemKindArray" },
            Object        = { icon = icon.kind.Object,        hl = "CmpItemKindObject" },
            Key           = { icon = icon.kind.Key,           hl = "CmpItemKindKey" },
            Null          = { icon = icon.kind.Null,          hl = "CmpItemKindNull" },
            EnumMember    = { icon = icon.kind.EnumMember,    hl = "CmpItemKindEnumMember" },
            Struct        = { icon = icon.kind.Struct,        hl = "CmpItemKindStruct" },
            Event         = { icon = icon.kind.Event,         hl = "CmpItemKindEvent" },
            Operator      = { icon = icon.kind.Operator,      hl = "CmpItemKindOperator" },
            TypeParameter = { icon = icon.kind.TypeParameter, hl = "CmpItemKindTypeParameter" },
            Component     = { icon = "",                     hl = "@function" },
            Fragment      = { icon = "",                     hl = "@constant" },
        },
    }

    require("symbols-outline").setup(args)
end
