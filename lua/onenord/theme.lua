local p     = require("onenord.pallette")
local theme = {}

-- Syntax highlight {{{
theme.syntax = {
    Comment        = {fg = p.n3b, style = "italic"},

    Conditional    = {fg = p.purple, style = "italic"},
    Keyword        = {fg = p.purple, style = "italic"},
    Repeat         = {fg = p.purple, style = "italic"},
    Function       = {fg = p.blue},
    Identifier     = {fg = p.n4},
    Variable       = {link = "Identifier"},

    Type           = {fg = p.yellow}, -- int, long, char, etc.
    Typedef        = {fg = p.yellow}, -- A typedef
    StorageClass   = {fg = p.yellow}, -- static, register, volatile, etc.
    Structure      = {fg = "#00ffe5"}, -- struct, union, enum, etc.
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
    Operator       = {fg = p.purple}, -- sizeof", "+", "*", etc.
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
    Normal      = {fg = p.n4,  bg = p.n0},
    -- vim.api.nvim_open_win
    NormalFloat = {fg = p.n10, bg = p.n0, style = "bold"},
    TermCursor  = {link = "Normal"},
    -- TermCursorNC

    NonText = {fg = p.n1},
    Conceal = {fg = p.n1},


    Cursor       = {fg = p.w, style = "reverse"},
    CursorIM     = {fg = p.w, style = "reverse"},
    CursorColumn = {bg = p.n1},
    CursorLine   = {bg = p.n1},


    DiffAdd    = {fg = p.n14, bg = p.n1, style = "reverse"},
    DiffChange = {fg = p.n12, bg = p.n1, style = "reverse"},
    DiffDelete = {fg = p.n11, bg = p.n1, style = "reverse"},
    DiffText   = {fg = p.n15, bg = p.n1, style = "reverse"},

    -- Folded       = {fg = p.n8,  bg="#323847", style = "bold"},
    Folded       = {fg = p.n8,  bg = p.n1, style = "bold"},
    FoldColumn   = {fg = p.n3},
    ColorColumn  = {bg = p.n1},
    LineNr       = {fg = p.n3},
    CursorLineNr = {fg = p.n4},


    SignColumn = {fg = p.n1, bg = p.n0},


    IncSearch = {fg = p.w, bg = "#ED427C", style = "bold"},
    Search    = {fg = p.w, bg = p.n8,      style = "bold"},


    MatchParen = {fg = p.n8, bg = p.n3b, style = "bold"},
    MatchWord  = {fg = p.n8, bg = p.n3,  style = "bold"},


    EndOfBuffer = {fg = p.n1},
    ErrorMsg    = {fg = p.n4, bg = p.n11},
    WarningMsg  = {fg = p.b,  bg = p.n13},
    ModeMsg     = {fg = p.n4},
    MoreMsg     = {fg = p.n8, style = "bold"},
    Question    = {fg = p.n8, style = "italic"},


    Pmenu      = {fg = p.n4, bg = p.n2},
    PmenuSel   = {fg = p.w,  bg = p.n8, style = "bold"},
    PmenuSbar  = {fg = p.n4, bg = p.n3},
    PmenuThumb = {fg = p.n4, bg = p.n10},
    WildMenu   = {link = "PmenuSel"},


    QuickFixLine = {link = "Search"},
    qfLineNr     = {link = "LineNr"},


    SpellBad   = {fg = p.n11, style = "italic,undercurl"},
    SpellCap   = {fg = p.n7,  style = "italic,undercurl"},
    SpellLocal = {fg = p.n8,  style = "italic,undercurl"},
    SpellRare  = {fg = p.n9,  style = "italic,undercurl"},


    StatusLine       = {fg = p.n4, bg = p.n2},
    StatusLineNC     = {fg = p.n4, bg = p.n1},
    StatusLineTerm   = {fg = p.n4, bg = p.n2},
    StatusLineTermNC = {fg = p.n4, bg = p.n1},


    Tabline     = {fg = p.n4, bg = p.n1},
    TabLineFill = {fg = p.n4, bg = p.n1},
    TablineSel  = {fg = p.n8, bg = p.n3},


    Title      = {fg = p.n8, style = "bold"},
    SpecialKey = {fg = p.n12},
    Directory  = {fg = p.n7},


    VertSplit = {fg = p.n2, bg = p.n0},


    Visual    = {bg = p.n2, style = "bold"},
    VisualNOS = {bg = p.n2, style = "bold"},


    healthError   = {fg = p.n11, bg = p.n1},
    healthSuccess = {fg = p.n14, bg = p.n1},
    healthWarning = {fg = p.n15, bg = p.n1},


    -- BufferLine
    BufferLineIndicatorSelected = {fg = p.n0},
    BufferLineFill              = {bg = p.n0},
}
-- }}} Editor highlight

-- TreeSitter highlight {{{
theme.treesitter = {
    TSAttribute          = {fg    = p.cyan},
    TSBoolean            = {link  = "Boolean"},
    TSCharacter          = {link  = "String"},
    TSComment            = {link  = "Comment"},
    TSConditional        = {link  = "Conditional"},
    TSConstant           = {link  = "Constant"},
    TSConstBuiltin       = {fg    = p.cyan},
    TSConstMacro         = {link  = "TSConstBuiltin"},
    TSConstructor        = {link  = "Structure"},
    TSError              = {style = "bold"},
    TSException          = {link  = "Exception"},
    TSField              = {fg    = p.n8},
    TSFloat              = {link  = "Float"},
    TSFunction           = {link  = "Function"},
    TSFuncBuiltin        = {fg    = p.cyan},
    TSFuncMacro          = {link  = "TSFuncBuiltin"},
    TSInclude            = {link  = "Keyword"},
    TSKeyword            = {link  = "Keyword"},
    TSKeywordFunction    = {link  = "Keyword"},
    TSKeywordOperator    = {link  = "Keyword"},
    TSKeywordReturn      = {fg    = p.purple, bg = "#564167", style = "italic"},
    TSLabel              = {link  = "Label"},
    TSMethod             = {link  = "Function"},
    TSNamespace          = {link  = "Structure"},
    TSNone               = {fg    = p.n4},
    TSNumber             = {link  = "Number"},
    TSOperator           = {link  = "Operator"},
    TSParameter          = {link  = "Parameter"},
    TSParameterReference = {link  = "TSParameter"},
    TSProperty           = {fg    = "#c4a7e7"},
    TSPunctDelimiter     = {link  = "Delimiter"},
    TSPunctBracket       = {fg    = p.n4},
    TSPunctSpecial       = {link  = "Delimiter"},
    TSRepeat             = {link  = "Repeat"},
    TSString             = {link  = "String"},
    TSStringRegex        = {fg    = p.blue},
    TSStringEscape       = {fg    = "#A1887F"},
    TSSymbol             = {fg    = p.n15},
    TSTag                = {fg    = p.red},
    TSTagDelimiter       = {fg    = p.red},
    TSText               = {link  = "Identifier"},
    TSStrong             = {fg    = p.n4,  style = "bold"},
    TSEmphasis           = {fg    = p.n4,  style = "bold"},
    TSUnderline          = {fg    = p.n4,  style = "underline",     sp = p.n4},
    TSStrike             = {fg    = p.n4,  style = "strikethrough", sp = p.n4},
    TSTitle              = {fg    = p.n10, style = "bold"},
    TSLiteral            = {fg    = p.green},
    TSURI                = {link  = "Underlined"},
    TSMath               = {fg    = p.n15},
    TSTextReference      = {link  = "Identifier"},
    TSEnviroment         = {fg    = p.n15},
    TSEnviromentName     = {link  = "TSEnviroment"},
    TSNote               = {fg    = p.n4},
    TSWarning            = {link  = "WarningMsg"},
    TSDanger             = {link  = "ErrorMsg"},
    TSType               = {fg    = p.yellow},
    TSTypeBuiltin        = {link  = "TSType"},
    TSVariable           = {link  = "Identifier"},
    TSVariableBuiltin    = {fg    = p.cyan},

    -- treeSitter-Context
    TreesitterContext = {bg = p.n1}
}
-- }}} TreeSitter highlight


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

    FloatBorder = {link = "NormalFloat"}
}


theme.plugins = {

    -- LspTrouble
    LspTroubleText   = {fg = p.n4},
    LspTroubleCount  = {fg = p.n9, bg = p.n10},
    LspTroubleNormal = {fg = p.n4, bg = p.sidebar},

    -- Diff
    diffAdded     = {fg = p.n14},
    diffRemoved   = {fg = p.n11},
    diffChanged   = {fg = p.n15},
    diffOldFile   = {fg = p.n13},
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

    -- GitSigns
    GitSignsAdd      = {fg = p.n14}, -- diff mode: Added line |diff.txt|
    GitSignsAddNr    = {fg = p.n14}, -- diff mode: Added line |diff.txt|
    GitSignsAddLn    = {fg = p.n14}, -- diff mode: Added line |diff.txt|
    GitSignsChange   = {fg = p.n13}, -- diff mode: Changed line |diff.txt|
    GitSignsChangeNr = {fg = p.n13}, -- diff mode: Changed line |diff.txt|
    GitSignsChangeLn = {fg = p.n13}, -- diff mode: Changed line |diff.txt|
    GitSignsDelete   = {fg = p.n11}, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteNr = {fg = p.n11}, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteLn = {fg = p.n11}, -- diff mode: Deleted line |diff.txt|

    -- Telescope
    TelescopePromptBorder   = {fg = p.n8, style = "bold"},
    TelescopePromptPrefix   = {fg = p.n14},
    TelescopeResultsBorder  = {fg = p.n8, style = "bold"},
    TelescopePreviewBorder  = {fg = p.n10, style = "bold"},
    TelescopeSelectionCaret = {fg = p.n10},
    TelescopeSelection      = {fg = p.w,  bg = p.n8, style = "bold"},
    TelescopeNormal         = {fg = p.n4, bg = p.n0},
    TelescopeMatching       = {fg = p.n13},

    -- NvimTree
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
    NvimTreeIndentMarker     = {fg    = p.n8},

    LspDiagnosticsError       = {link = "DiagnosticError"},
    LspDiagnosticsWarning     = {link = "DiagnosticWarn"},
    LspDiagnosticsInformation = {link = "DiagnosticInfo"},
    LspDiagnosticsHint        = {link = "DiagnosticHint"},

    -- WhichKey
    -- WhichKey =          {fg = p.n4 , style = "bold"},
    -- WhichKeyGroup =     {fg = p.n4},
    -- WhichKeyDesc =      {fg = p.n7, style = "italic"},
    -- WhichKeySeperator = {fg = p.n4},
    -- WhichKeyFloating =  {bg = p.float},
    -- WhichKeyFloat =     {bg = p.float},

    -- LspSaga
    DiagnosticError            = {fg = p.n11},
    DiagnosticWarning          = {fg = p.n15},
    DiagnosticInformation      = {fg = p.n10},
    DiagnosticHint             = {fg = p.n9},
    DiagnosticTruncateLine     = {fg = p.n4},
    LspFloatWinNormal          = {bg = p.n2},
    LspFloatWinBorder          = {fg = p.n9},
    LspSagaBorderTitle         = {fg = p.n8},
    LspSagaHoverBorder         = {fg = p.n10},
    LspSagaRenameBorder        = {fg = p.n10},
    LspSagaDefPreviewBorder    = {fg = p.n14},
    LspSagaCodeActionBorder    = {fg = p.n7},
    LspSagaFinderSelection     = {fg = p.n14},
    LspSagaCodeActionTitle     = {fg = p.n10},
    LspSagaCodeActionContent   = {fg = p.n9},
    LspSagaSignatureHelpBorder = {fg = p.n13},
    ReferencesCount            = {fg = p.n9},
    DefinitionCount            = {fg = p.n9},
    DefinitionIcon             = {fg = p.n7},
    ReferencesIcon             = {fg = p.n7},
    TargetWord                 = {fg = p.n8},

    -- Indent Blankline
    IndentBlanklineChar        = {link = "SignColumn"},
    IndentBlanklineContextChar = {fg = p.n8},

    -- Illuminate
    illuminatedWord    = {link = "LspReferenceText"},
    illuminatedCurWord = {bg = p.n3},

    -- nvim-dap
    DapBreakpoint = {fg = p.n14},
    DapStopped    = {fg = p.n15},

    -- Hop
    HopNextKey   = {link = "IncSearch"},
    HopNextKey1  = {link = "Search"},
    HopNextKey2  = {link = "Search"},
    HopUnmatched = {fg   = p.n3},

    -- machakann/vim-sandwich
    OperatorSandwichAdd    = {link = "Search"},
    OperatorSandwichAddrcc = {link = "Search"},
    OperatorSandwichBuns   = {link = "Search"},
    OperatorSandwichChange = {link = "Search"},
    OperatorSandwichDelete = {link = "IncSearch"},

    -- Fern
    -- FernBranchText = {fg = p.n3b},

    -- HistoryStartup
    HistoryStartupCreate   = {fg = p.n10, style = "bold"},
    HistoryStartupFileRoot = {fg = p.n8,  style = "italic"},

    -- lightspeed
    -- LightspeedLabel                  = {fg = p.n8,         style = "bold"},
    -- LightspeedLabelOverlapped        = {fg = p.n8,         style = "bold,underline"},
    -- LightspeedLabelDistant           = {fg = p.n15,        style = "bold"},
    -- LightspeedLabelDistantOverlapped = {fg = p.n15,        style = "bold,underline"},
    -- LightspeedShortcut               = {fg = p.n10,        style = "bold"},
    -- LightspeedShortcutOverlapped     = {fg = p.n10,        style = "bold,underline"},
    -- LightspeedMaskedChar             = {fg = p.n4,         bg = p.n2,       style = "bold"},
    -- LightspeedGreyWash               = {fg = p.n3b},
    -- LightspeedUnlabeledMatch         = {fg = p.n4,         bg = p.n1},
    -- LightspeedOneCharMatch           = {fg = p.n8,         style = "bold,   reverse"},
    -- LightspeedUniqueChar             = {style = "bold,     underline"},
    -- LightspeedPendingOpArea          = {style = "strikethrough"},
    -- LightspeedPendingChangeOpArea    = {style = "strikethrough"},
    -- LightspeedCursor                 = {fg = nord.nord7, style = "underline,reverse"},

    -- nvim-lightbulb
    LightBulbVirtualText = {link = "NormalFloat"},
    LightBulbFloatWin    = {link = "NormalFloat"},

    -- nvim-cmp
    CmpItemAbbr           = {fg = p.n4},
    -- CmpItemAbbrDeprecated = {fg = p.n3b, style = "italic"},
    CmpItemAbbrMatch      = {fg = p.n13, style = "bold"},
    CmpItemAbbrMatchFuzzy = {link = "CmpItemAbbrMatch"},
    -- CmpItemAbbrMatchFuzzy = {fg = p.n8, style = "bold"},
    CmpItemKind           = {fg = p.n15},
    CmpItemMenu           = {link = "CmpItemAbbr"},


    SniprunVirtualTextOk  = {bg=p.n8, fg=p.w},
    SniprunFloatingWinOk  = {fg=p.n8},
    SniprunVirtualTextErr = {bg=p.n11,  fg=p.w},
    SniprunFloatingWinErr = {fg=p.n11},
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

