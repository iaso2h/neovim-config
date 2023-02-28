local p     = require("onenord.pallette")
local theme = {}

-- OPTIM:
vim.cmd(string.format("hi! @keyword.return guifg=%s guibg=%s gui=italic", p.purple, "#564167"))

-- Syntax highlight {{{
theme.syntax = {
    Comment        = {fg = p.n3b, style = "italic"},

    Conditional    = {fg = p.purple, style = "italic"},
    Keyword        = {fg = p.purple, style = "italic"},
    Repeat         = {fg = p.purple, style = "italic"},
    Function       = {fg = p.blue},
    Identifier     = {fg = p.white},
    Variable       = {link = "Identifier"},

    Type           = {fg = p.yellow}, -- int, long, char, etc.
    Typedef        = {fg = p.yellow}, -- A typedef
    StorageClass   = {fg = p.yellow}, -- static, register, volatile, etc.
    Structure      = {fg = p.yellow}, -- struct, union, enum, etc.
    Constant       = {fg = p.orange}, -- any constant

    String         = {fg = p.green},
    Character      = {fg = "#A1887F"}, -- any character constant: "c", "\n"
    Number         = {fg = p.orange}, -- a number constant: 5
    Boolean        = {fg = p.orange}, -- a boolean constant: TRUE, false
    Float          = {fg = p.orange}, -- a floating point constant: 2.3e10

    Statement      = {fg = p.purple, style = "italic"}, -- any statement
    Parameter      = {fg = p.orange}, -- function parameter
    Decorator      = {fg = p.orange},
    Annotation     = {link = "Decorator"},
    Label          = {fg = p.red}, -- case, default, etc.
    Operator       = {fg = p.n8}, -- sizeof", "+", "*", etc.
    Exception      = {fg = p.purple}, -- try, catch, throw
    PreProc        = {fg = p.yellow}, -- generic Preprocessor
    Include        = {fg = p.purple}, -- preprocessor #include
    Define         = {fg = p.purple}, -- preprocessor #define
    Macro          = {fg = p.cyan}, -- same as Define
    PreCondit      = {fg = p.yellow}, -- preprocessor #if, #else, #endif, etc.
    Special        = {fg = p.n15}, -- any special symbol
    SpecialChar    = {fg = p.orange}, -- special character in a constant
    Tag            = {fg = p.n15}, -- you can use CTRL-] on this
    Delimiter      = {fg = "#A1887F"}, -- character that needs attention like , or .
    SpecialComment = {fg = p.n8}, -- special things inside a comment

    Debug          = {fg = p.n11}, -- debugging statements
    Underlined     = {fg = p.n10, style = "underline", sp = p.n10}, -- text that stands out, HTML links
    Ignore         = {fg = p.n1}, -- left blank, hidden

    Error          = {fg = p.n11, style = "bold,underline", sp = p.n11}, -- any erroneous construct
    Todo           = {fg = p.n13, style = "bold,italic"}, -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    htmlLink            = {fg = p.n14,  style = "underline", sp = p.n14},
    htmlH1              = {fg = p.n8,   style = "bold"},
    htmlH2              = {fg = p.n11,  style = "bold"},
    htmlH3              = {fg = p.n14,  style = "bold"},
    htmlH4              = {fg = p.n15,  style = "bold"},
    htmlH5              = {fg = p.n9,   style = "bold"},
    markdownH1          = {fg = p.n8,   style = "bold"},
    markdownH2          = {fg = p.n11,  style = "bold"},
    markdownH3          = {fg = p.n14,  style = "bold"},
    markdownH1Delimiter = {fg = p.n8},
    markdownH2Delimiter = {fg = p.n11},
    markdownH3Delimiter = {fg = p.n14},

    -- Vim
    vimUserFunc = {link = "Function"},
    vimFunction = {link = "Function"},
    vimFuncVar  = {link = "Parameter"},

    vimOption   = {fg = p.orange},
    vimEnvvar   = {fg = p.n15},

    vimHiBang             = {link = "Operator"},
    vimHiAttrib           = {link = "Parameter"},
    vimHiAttribKey        = {link = "Parameter"},
    vimUserAttrbCmpltFunc = {link = "Function"},

    vimMapMod    = {link = "vimOption"},
    vimMapModKey = {link = "vimOption"},
    vimNotation  = {link = "Character"},

    vimSynRegPat = {fg = p.blue},
    vimSynRegOpt = {fg = "Parameter"},
    vimSynKeyOpt = {fg = "Parameter"},

    vimAutoCmdSfxList = {fg = p.cyan},

    vimSet      = {link = "Operator"},
    vimSetEqual = {link = "Operator"}
}
-- }}} Syntax highlight

-- Editor highlight {{{
theme.editor =  {
    -- normal text and background color
    Normal      = {fg = p.n4, bg = p.n0},
    -- vim.api.nvim_open_win
    -- NormalFloat = {fg = p.n10, bg = p.n0, style = "bold"},
    NormalFloat = {bg = p.n0},
    TermCursor  = {link = "Normal"},
    -- TermCursorNC

    NonText     = {fg = p.n3},
    Conceal     = {fg = p.n1},
    EndOfBuffer = {link = "NonText"},


    Cursor       = {fg = p.n6, style = "reverse"},
    CursorIM     = {fg = p.n6, style = "reverse"},
    CursorColumn = {bg = p.n1},
    CursorLine   = {bg = p.n1},


    DiffAdd    = {bg = "#43514b"},
    DiffChange = {bg = "#3e4d5a"},
    DiffDelete = {bg = "#4b3d48", fg = p.n3},
    DiffText   = {bg = "#526c7a", style = "bold"},


    IncSearch = {fg = p.w, bg = "#ED427C", style = "bold"},
    Search    = {fg = p.w, bg = p.n8,      style = "bold"},
    CurSearch = {link = "IncSearch"},


    MatchParen = {fg = p.n8, bg = p.n3b, style = "bold"},
    MatchWord  = {fg = p.n8, bg = p.n3,  style = "bold"},


    ErrorMsg    = {fg = p.n4, bg = p.n11},
    WarningMsg  = {fg = p.b,  bg = p.n13},
    ModeMsg     = {fg = p.n4},
    MoreMsg     = {fg = p.n8, style = "bold"},
    Question    = {fg = p.n8, style = "italic"},


    -- 2023-2-16
    -- Pmenu      = {fg = p.n4, bg = p.n2},
    -- PmenuSel   = {fg = p.w,  bg = p.n8, style = "bold"},
    Pmenu      = {fg = p.n4, bg = p.n1},
    PmenuSel   = {fg = p.w,  bg = p.n3, style = "bold"},
    PmenuSbar  = {fg = p.n4, bg = p.n3},
    PmenuThumb = {fg = p.n4, bg = p.n10},
    WildMenu   = {link = "PmenuSel"},


    QuickFixLine = {link = "Search"},
    qfLineNr     = {link = "LineNr"},


    SpellBad   = {fg = p.n11, style = "italic,undercurl"},
    SpellCap   = {fg = p.n7,  style = "italic,undercurl"},
    SpellLocal = {fg = p.n8,  style = "italic,undercurl"},
    SpellRare  = {fg = p.n9,  style = "italic,undercurl"},


    Folded       = {fg = p.n8, style = "bold"},
    FoldColumn   = {fg = p.n3},
    ColorColumn  = {bg = p.n1},
    LineNr       = {fg = p.n3},
    CursorLineNr = {fg = p.n6, style = "bold"},


    SignColumn = {fg = p.n1},


    StatusLine       = {fg = p.n4, bg = p.n2},
    StatusLineNC     = {fg = p.n4, bg = p.n1},
    StatusLineTerm   = {fg = p.n4, bg = p.n2},
    StatusLineTermNC = {fg = p.n4, bg = p.n1},


    MsgSeparator = {link = "FoldColumn"},
    VertSplit    = {fg = p.n3},


    TabLine     = {fg = p.n4, bg = p.n1},
    TabLineFill = {fg = p.n4, bg = p.n0},
    TabLineSel  = {fg = p.n8, bg = p.n3},


    Title      = {fg = p.n8, style = "bold"},
    SpecialKey = {fg = p.n12},
    Directory  = {fg = p.n7},


    Visual    = {bg = p.n2, style = "bold"},
    VisualNOS = {bg = p.n2, style = "bold"},


    healthError   = {fg = p.n11, bg = p.n1},
    healthSuccess = {fg = p.n14, bg = p.n1},
    healthWarning = {fg = p.n13, bg = p.n1},
}
-- }}} Editor highlight

-- TreeSitter highlight {{{

theme.treesitter         = {
    TSNone               = {fg   = p.n4},
    TSStrong             = {fg   = p.n4,  style = "bold"},
    TSStrike             = {fg   = p.n4,  style = "strikethrough"},
    TSMath               = {fg   = p.n15},
    TSEnviroment         = {fg   = p.n15},
    TSEnviromentName     = {link = "TSEnviroment"},
    TSNote               = {fg   = p.n4},
    TSWarning            = {link = "WarningMsg"},
    TSDanger             = {link = "ErrorMsg"},

    TSConstructor        = {link = "Structure"},                 -- For constructor calls and definitions: `= { }` in Lua, and Java constructors.
    TSConstant           = {link = "Constant"},                  -- For constants
    TSFloat              = {link = "Float"},                     -- For floats
    TSNumber             = {link = "Number"},                    -- For all number
    TSAttribute          = {fg   = p.n15 },                      -- (unstable) TODO: docs

    TSError              = {fg   = p.n6, style = "bold"},        -- For syntax/parser errors.
    TSException          = {link = "Exception"},                 -- For exception related keywords.
    TSFuncMacro          = {link = "Marcro"},                    -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
    TSInclude            = {link = "Include"},                   -- For includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
    TSLabel              = {link = "Label"},                     -- For labels: `label:` in C and `:label:` in Lua.
    TSOperator           = {link = "Operator"},                  -- For any operator: `+`, but also `->` and `*` in C.
    TSParameter          = {link = "Parameter"},                 -- For parameters of a function.
    TSParameterReference = {link = "Parameter"},                 -- For references to parameters of a function.
    TSPunctDelimiter     = {link = "Delimiter"},                 -- For delimiters ie: `.`
    TSPunctBracket       = {fg   = p.n8 },                       -- For brackets and parens.
    TSPunctSpecial       = {fg   = p.n8 },                       -- For special punctutation that does not fall in the catagories before.
    TSSymbol             = {fg   = p.n15 },                      -- For identifiers referring to symbols or atoms.
    TSType               = {link = "Type"},                      -- For types.
    TSTypeBuiltin        = {fg = p.yellow, style = "bold"},      -- For builtin types.
    TSTag                = {link = "Tag"},                       -- Tags like html tag names.
    TSTagDelimiter       = {link = "Tag"},                       -- Tag delimiter like `<` `>` `/`
    TSText               = {link = "Identifier"},                -- For strings considen11 text in a markup language.
    TSTextReference      = {fg   = p.n15 },                      -- FIXME
    TSEmphasis           = {fg   = p.n4, style = "bold"},        -- For text to be represented with emphasis.
    TSUnderline          = {fg   = p.n4, style = "underline", sp = p.n4 },  -- For text to be represented with an underline.
    TSLiteral            = {link = "Identifier"},                -- Literal text.
    TSURI                = {fg   = p.n4, style = "underline", sp = p.n4 },  -- Any URI like a link or email.
    TSAnnotation         = {link = "Decorator"},                 -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
    ["@constructor"]           = {link = "Structure"},
    ["@constant"]              = {link = "Constant"},
    ["@float"]                 = {link = "Float"},
    ["@number"]                = {link = "Number"},
    ["@attribute"]             = {fg   = p.n15 },
    ["@error"]                 = {fg   = p.n6, style = "bold"},
    ["@exception"]             = {link = "Exception"},
    ["@funtion.macro"]         = {link = "Marcro"},
    ["@include"]               = {link = "Include"},
    ["@label"]                 = {link = "Label"},
    ["@operator"]              = {link = "Operator"},
    ["@parameter"]             = {link = "Parameter"},
    ["@punctuation.delimiter"] = {link = "Delimiter"},
    ["@punctuation.bracket"]   = {fg   = p.n8 },
    ["@punctuation.special"]   = {fg   = p.n8 },
    ["@symbol"]                = {fg   = p.n15 },
    ["@type"]                  = {link = "Type"},
    ["@type.builtin"]          = {link = "TSTypeBuiltin"},
    ["@tag"]                   = {link = "Tag"},
    ["@tag.delimiter"]         = {link = "Tag"},
    ["@text"]                  = {link = "Identifier"},
    ["@text.reference"]        = {link = "TSTextReference"},
    ["@text.emphasis"]         = {link = "TSEmphasis"},
    ["@text.underline"]        = {link = "TSUnderline"},
    ["@text.literal"]          = {link = "TSLiteral"},
    ["@text.uri"]              = {link = "TSURI"},
    -- @todo Missing highlights
    -- @function.call
    -- @method.call
    -- @type.qualifier
    -- @text.strike
    -- @text.math (e.g. for LaTeX math environments)
    -- @text.environment (e.g. for text environments of markup languages)
    -- @text.environment.name (e.g. for the name/the string indicating the type of text environment)
    -- @text.note
    -- @text.warning
    -- @text.danger
    -- @tag.attribute
    -- @string.special
}
    theme.treesitter.TSVariableBuiltin    = {fg   = p.white, style  = "bold" }
    theme.treesitter.TSBoolean            = {link = "Boolean"}
    theme.treesitter.TSConstBuiltin       = {fg   = p.orange, style = "bold" }
    theme.treesitter.TSConstMacro         = {fg   = p.orange, style = "bold" }
    theme.treesitter.TSVariable           = {link = "Identifier"}
    theme.treesitter.TSTitle              = {fg   = p.n10, bg = p.none, style = "bold" }
    theme.treesitter["@variable"]         = {link = "Identifier"}
    theme.treesitter["@variable.builtin"] = {link = "TSVariableBuiltin"}
    theme.treesitter["@variable.global"]  = {link = "TSVariableBuiltin"}
    theme.treesitter["@boolean"]          = {link = "Boolean"}
    theme.treesitter["@constant.builtin"] = {link = "TSConstBuiltin"}
    theme.treesitter["@constant.macro"]   = {link = "TSConstMacro"}
    theme.treesitter["@text.title"]       = {link = "TSTitle"}
    theme.treesitter["@text.strong"]      = {link = "TSEmphasis"}
    -- Comments
    theme.treesitter.TSComment = {link  = "Comment"}
    -- Conditional
    theme.treesitter.TSConditional = {link  = "Conditional"}  -- For keywords related to conditionnals.
    -- Function names
    theme.treesitter.TSFunction    = {link = "Function"}      -- For fuction (calls and definitions).
    theme.treesitter.TSMethod      = {link = "Function"}      -- For method calls and definitions.
    theme.treesitter.TSFuncBuiltin = {fg   = p.blue, style = "bold"}
    -- Namespaces and property accessors
    theme.treesitter.TSNamespace = {fg   = "#00ffe5"}  -- For identifiers referring to modules and namespaces.
    theme.treesitter.TSField     = {fg   = p.n4 }      -- For fields.
    theme.treesitter.TSProperty  = {link = "TSField"}  -- Same as `TSField`, but when accessing, not declaring.
    -- Language keywords
    theme.treesitter.TSKeyword         = {link = "Keyword"} -- For keywords that don't fall in other categories.
    theme.treesitter.TSKeywordFunction = {link = "Keyword"}
    theme.treesitter.TSKeywordReturn   = {fg   = p.purple, bg = "#564167", style = "italic,bold"}
    theme.treesitter.TSKeyordOperator  = {link = "Keyword"}
    theme.treesitter.TSRepeat          = {link = "Repeat"} -- For keywords related to loops.
    -- Strings
    theme.treesitter.TSString             = {link = "String"}                  -- For strings.
    theme.treesitter.TSStringRegex        = {fg   = p.n7, style  = "italic" }  -- For regexes.
    theme.treesitter.TSStringEscape       = {fg   = p.n15, style = "italic" }  -- For escape characters within a string.
    theme.treesitter.TSCharacter          = {link = "String"}                  -- For characters.
    theme.treesitter["@comment"]          = {link = "Comment"}
    theme.treesitter["@conditional"]      = {link = "Conditional"}
    theme.treesitter["@function"]         = {link = "Function"}
    theme.treesitter["@method"]           = {link = "Function"}
    theme.treesitter["@function.builtin"] = {link = "TSFuncBuiltin"}
    theme.treesitter["@namespace"]        = {link = "TSNamespace"}
    theme.treesitter["@field"]            = {link = "TSField"}
    theme.treesitter["@property"]         = {link = "TSField"}
    theme.treesitter["@keyword"]          = {link = "Keyword"}
    theme.treesitter["@keyword.function"] = {link = "Keyword"}
    theme.treesitter["@keyword.return"]   = {link = "TSKeywordReturn"}
    theme.treesitter["@keyword.operator"] = {link = "Keyword"}
    theme.treesitter["@repeat"]           = {link = "Repeat"}
    theme.treesitter["@string"]           = {link = "String"}
    theme.treesitter["@string.regex"]     = {link = "TSStringRegex"}
    theme.treesitter["@string.escape"]    = {link = "TSStringEscape"}
    theme.treesitter["@character"]        = {link = "String"}
-- }theme.treesitterter highlight


theme.lsp = {
    DiagnosticError                = {fg = p.n11},
    DiagnosticUnderlineError       = {style = "undercurl", sp = p.n11},
    DiagnosticWarn                 = {fg = p.n13},
    DiagnosticUnderlineWarn        = {style = "undercurl", sp = p.n13},
    DiagnosticInfo                 = {fg = p.n10},
    DiagnosticUnderlineInfo        = {style = "undercurl", sp = p.n10},
    DiagnosticHint                 = {fg = p.n9 },
    DiagnosticUnderlineHint        = {style = "undercurl", sp = p.n9},

    LspDiagnosticsDefaultError         = {link = "DiagnosticError"},
    LspDiagnosticsDefaultWarning       = {link = "DiagnosticWarn"},
    LspDiagnosticsDefaultInformation   = {link = "DiagnosticInfo"},
    LspDiagnosticsDefaultHint          = {link = "DiagnosticHint"},
    LspDiagnosticsUnderlineError       = {link = "DiagnosticUnderlineError"},
    LspDiagnosticsUnderlineWarning     = {link = "DiagnosticUnderlineWarn"},
    LspDiagnosticsUnderlineInformation = {link = "DiagnosticUnderlineInfo"},
    LspDiagnosticsUnderlineHint        = {link = "DiagnosticUnderlineHint"},

    LspReferenceText  = {bg = p.n3},
    LspReferenceRead  = {bg = p.n3},
    LspReferenceWrite = {bg = p.n3},

    FloatBorder = {fg = p.n3b, bg = p.n0, style = "bold"},
}


theme.plugins = {

    -- https://github.com/folke/trouble.nvim
    LspTroubleText   = {fg = p.n4},
    LspTroubleCount  = {fg = p.n9, bg = p.n10},
    LspTroubleNormal = {fg = p.n4, bg = p.sidebar},

    -- https://github.com/sindrets/diffview.nvim
    diffAdded     = {fg = p.n14},
    diffChanged   = {fg = p.n13},
    diffRemoved   = {fg = p.n11},
    diffOldFile   = {fg = p.n15},
    diffNewFile   = {fg = p.n12},
    diffFile      = {fg = p.n7},
    diffLine      = {fg = p.n3},
    diffIndexLine = {fg = p.n9},

    -- Neogit
    -- NeogitBranch               = {fg = p.n10},
    -- NeogitRemote               = {fg = p.n9},
    -- NeogitHunkHeader           = {fg = p.n8},
    -- NeogitHunkHeaderHighlight  = {fg = p.n8, bg = p.n1},
    -- NeogitDiffContextHighlight = {bg = p.n1},
    -- NeogitDiffDeleteHighlight  = {fg = p.n11, style="reverse"},
    -- NeogitDiffAddHighlight     = {fg = p.n14, style="reverse"},

    -- https://github.com/lewis6991/gitsigns.nvim
    GitSignsAdd      = {fg = p.n14}, -- diff mode: Added line |diff.txt|
    GitSignsAddNr    = {fg = p.n14}, -- diff mode: Added line |diff.txt|
    GitSignsAddLn    = {fg = p.n14}, -- diff mode: Added line |diff.txt|
    GitSignsChange   = {fg = p.n13}, -- diff mode: Changed line |diff.txt|
    GitSignsChangeNr = {fg = p.n13}, -- diff mode: Changed line |diff.txt|
    GitSignsChangeLn = {fg = p.n13}, -- diff mode: Changed line |diff.txt|
    GitSignsDelete   = {fg = p.n11}, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteNr = {fg = p.n11}, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteLn = {fg = p.n11}, -- diff mode: Deleted line |diff.txt|

    -- https://github.com/nvim-telescope/telescope.nvim
    TelescopePromptBorder   = {fg = p.n8, style = "bold"},
    TelescopePromptPrefix   = {fg = p.n14},
    TelescopeResultsBorder  = {fg = p.n8, style = "bold"},
    TelescopePreviewBorder  = {fg = p.n10, style = "bold"},
    TelescopeSelectionCaret = {fg = p.n10},
    TelescopeSelection      = {fg = p.w,  bg = p.n8, style = "bold"},
    -- https://github.com/shaunsingh/nord.nvim/pull/63/files
    -- TelescopeNormal        = {fg = p.n4, bg = p.n0},
    -- TelescopeResultsNormal = {fg = p.n4, bg = p.n0},
    -- TelescopePromptNormal  = {fg = p.n4, bg = p.n0},
    -- TelescopePreviewNormal = {fg = p.n4, bg = p.n0},
    TelescopeMatching       = {fg = p.n13},
    TelescopePromptCounter  = {link = "TelescopeMatching"},

    -- https://github.com/kyazdani42/nvim-tree.lua
    NvimTreeNormal           = {fg    = p.n4, bg = p.sidebar},
    NvimTreeFolderName       = {fg    = p.n4},
    NvimTreeFolderIcon       = {link  = "NvimTreeFolderName"},
    NvimTreeRootFolder       = {fg    = p.n10, style = "bold"},
    NvimTreeOpenedFolderName = {style = "bold,underline", sp = p.n8},
    NvimTreeOpenedFile       = {link  = "NvimTreeOpenedFolderName"},
    NvimTreeGitNew           = {fg    = p.n14},
    NvimTreeGitDirty         = {fg    = p.n13},
    NvimTreeGitRenamed       = {fg    = p.n13},
    NvimTreeGitStaged        = {fg    = p.n12},
    NvimTreeGitMerge         = {fg    = p.n15},
    NvimTreeGitDeleted       = {fg    = p.n11},
    NvimTreeImageFile        = {fg    = p.n15},
    NvimTreeExecFile         = {fg    = p.n15},
    NvimTreeSpecialFile      = {fg    = p.n9 , style = "underline", sp = p.n9},
    NvimTreeEmptyFolderName  = {fg    = p.n3b},
    NvimTreeIndentMarker     = {link = "FoldColumn"},

    LspDiagnosticsError       = {link = "DiagnosticError"},
    LspDiagnosticsWarning     = {link = "DiagnosticWarn"},
    LspDiagnosticsInformation = {link = "DiagnosticInfo"},
    LspDiagnosticsHint        = {link = "DiagnosticHint"},

    -- https://github.com/folke/which-key.nvim
    -- WhichKey =          {fg = p.n4 , style = "bold"},
    -- WhichKeyGroup =     {fg = p.n4},
    -- WhichKeyDesc =      {fg = p.n7, style = "italic"},
    -- WhichKeySeperator = {fg = p.n4},
    -- WhichKeyFloating =  {bg = p.float},
    -- WhichKeyFloat =     {bg = p.float},

    -- https://github.com/lukas-reineke/indent-blankline.nvim
    IndentBlanklineChar        = {link = "SignColumn"},
    IndentBlanklineContextChar = {fg = p.n8},

    -- https://github.com/RRethy/vim-illuminate
    illuminatedWordText  = {link = "LspReferenceText"},
    IlluminatedWordRead  = {link = "LspReferenceText"},
    IlluminatedWordWrite = {link = "LspReferenceText"},

    -- https://github.com/mfussenegger/nvim-dap
    DapBreakpoint = {fg = p.n14},
    DapStopped    = {fg = p.n15},

    -- https://github.com/phaazon/hop.nvim
    HopNextKey   = {link = "IncSearch"},
    HopNextKey1  = {link = "Search"},
    HopNextKey2  = {link = "Search"},
    HopUnmatched = {fg   = p.n3},

    -- https://github.com/machakann/vim-sandwich
    OperatorSandwichAdd    = {link = "Search"},
    OperatorSandwichAddrcc = {link = "Search"},
    OperatorSandwichBuns   = {link = "Search"},
    OperatorSandwichChange = {link = "Search"},
    OperatorSandwichDelete = {link = "IncSearch"},

    -- HistoryStartup
    HistoryStartupCreate   = {fg = p.n10, style = "bold"},
    HistoryStartupFileRoot = {fg = p.n8,  style = "italic"},

    -- https://github.com/kosayoda/nvim-lightbulb
    LightBulbVirtualText = {link = "NormalFloat"},
    LightBulbFloatWin    = {link = "NormalFloat"},

    -- https://github.com/hrsh7th/nvim-cmp
    CmpItemAbbr           = {fg = p.n4},
    -- CmpItemAbbrDeprecated = {fg = p.n3b, style = "italic"},
    CmpItemAbbrMatch      = {fg = p.n13, style = "bold"},
    CmpItemAbbrMatchFuzzy = {link = "CmpItemAbbrMatch"},
    -- CmpItemAbbrMatchFuzzy = {fg = p.n8, style = "bold"},
    CmpItemKind           = {fg = p.n15},
    CmpItemMenu           = {link = "CmpItemAbbr"},

    -- https://github.com/ray-x/lsp_signature.nvim
    LspSignatureActiveParameter = {link = "CmpItemAbbrMatch"},

    -- https://github.com/michaelb/sniprun
    SniprunVirtualTextOk  = {bg=p.n8, fg=p.w},
    SniprunFloatingWinOk  = {fg=p.n8},
    SniprunVirtualTextErr = {bg=p.n11,  fg=p.w},
    SniprunFloatingWinErr = {fg=p.n11},

    -- https://github.com/mg979/vim-visual-multi
    VMExtend = {link = "Visual"},
    VMCursor = {fg = p.w, bg = p.n8, style = "bold"},
    VMInsert = {fg = p.w, bg = p.n14},
    VMMono   = {fg = p.w, bg = p.n11},

    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    TreesitterContext           = {style = "bold"},
    TreesitterContextLineNumber = {fg = p.n3b, style = "bold"},
    TreesitterContextBottom     = {link  = "TreesitterContextLineNumber"}
}

theme.loadTerminal = function()
    vim.g.terminal_color_0  = p.n1
    vim.g.terminal_color_1  = p.n11
    vim.g.terminal_color_2  = p.n14
    vim.g.terminal_color_3  = p.n13
    vim.g.terminal_color_4  = p.n9
    vim.g.terminal_color_5  = p.n15
    vim.g.terminal_color_6  = p.n8
    vim.g.terminal_color_7  = p.n5
    vim.g.terminal_color_8  = p.n3
    vim.g.terminal_color_9  = p.n11
    vim.g.terminal_color_10 = p.n14
    vim.g.terminal_color_11 = p.n13
    vim.g.terminal_color_12 = p.n9
    vim.g.terminal_color_13 = p.n15
    vim.g.terminal_color_14 = p.n7
    vim.g.terminal_color_15 = p.n6
end


return theme

