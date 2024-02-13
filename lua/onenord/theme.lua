local p     = require("onenord.pallette")
local theme = {}

-- Syntax highlight {{{
theme.syntax = {
    Comment        = {fg = p.n3b, italic = true},

    Conditional    = {fg = p.purple, italic = true},
    Keyword        = {fg = p.purple, italic = true},
    Repeat         = {fg = p.purple, italic = true},
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

    Statement      = {fg = p.purple, italic = true}, -- any statement
    Parameter      = {fg = p.orange}, -- function parameter
    Decorator      = {fg = p.orange},
    Annotation     = {link = "Decorator"},
    Label          = {fg = p.red, bold = true}, -- case, default, etc.
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
    Underlined     = {fg = p.n10, underline = true, sp = p.n10}, -- text that stands out, HTML links
    Ignore         = {fg = p.n1}, -- left blank, hidden

    Error          = {fg = p.n11, bold = true, sp = p.n11}, -- any erroneous construct
    Todo           = {fg = p.n13, bold = true, italic = true}, -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    htmlLink            = {fg = p.n14,  underline = true, sp = p.n14},
    htmlH1              = {fg = p.n8,   bold = true},
    htmlH2              = {fg = p.n11,  bold = true},
    htmlH3              = {fg = p.n14,  bold = true},
    htmlH4              = {fg = p.n15,  bold = true},
    htmlH5              = {fg = p.n9,   bold = true},
    markdownH1          = {fg = p.n8,   bold = true},
    markdownH2          = {fg = p.n11,  bold = true},
    markdownH3          = {fg = p.n14,  bold = true},
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
    vimSynRegOpt = {link = "Parameter"},
    vimSynKeyOpt = {link = "Parameter"},

    vimAutoCmdSfxList = {fg = p.cyan},

    vimSet      = {link = "Operator"},
    vimSetEqual = {link = "Operator"}
}
-- }}} Syntax highlight

-- Editor highlight {{{
theme.editor =  {
    -- normal text and background color
    Normal      = {fg = p.n4,  bg = p.n0},
    NormalFloat = {bg = p.n0},
    FloatBorder = {fg = p.n3b, bg = p.n0},
    FloatTitle  = {fg = p.n8,  bg = p.n0, bold = true},


    NonText     = {fg = p.n3},
    Conceal     = {fg = p.n1},
    EndOfBuffer = {link = "NonText"},


    Cursor       = {fg = p.white, reverse = true},
    CursorIM     = {fg = p.white, reverse = true},
    CursorColumn = {bg = p.n1},
    CursorLine   = {bg = p.n1},


    TermCursor  = {link = "Cursor"},


    DiffAdd    = {bg = "#43514b"},
    DiffChange = {bg = "#3e4d5a"},
    DiffDelete = {bg = "#4b3d48", fg = p.n3},
    DiffText   = {bg = "#4a5b6a", bold = true},


    IncSearch = {fg = p.w, bg = "#ED427C", bold = true},
    Search    = {fg = p.w, bg = p.n8,      bold = true},
    CurSearch = {link = "IncSearch"},


    MatchParen = {fg = p.n8, bg = p.n3b, bold = true},
    MatchWord  = {fg = p.n8, bg = p.n3,  bold = true},


    ErrorMsg    = {fg = p.n4, bg = p.n11},
    WarningMsg  = {fg = p.b,  bg = p.n13},
    ModeMsg     = {fg = p.n4},
    MoreMsg     = {fg = p.n8, bold = true},
    Question    = {fg = p.n8, italic = true},


    Pmenu      = {fg = p.n4,   bg = p.n1},
    PmenuSel   = {fg = "", bg = p.n2,   bold = true},
    PmenuSbar  = {fg = p.n4,   bg = p.n3},
    PmenuThumb = {fg = p.n4,   bg = p.n10},
    WildMenu   = {link = "PmenuSel"},


    SpellBad   = {fg = p.n11, italic = true, undercurl = true},
    SpellCap   = {fg = p.n7,  italic = true, undercurl = true},
    SpellLocal = {fg = p.n8,  italic = true, undercurl = true},
    SpellRare  = {fg = p.n9,  italic = true, undercurl = true},


    Folded       = {fg = p.n8, bold = true},
    FoldColumn   = {fg = p.n2},
    ColorColumn  = {bg = p.n1},
    LineNr       = {fg = p.n3},
    CursorLineNr = {fg = p.n6, bold = true},


    SignColumn = {fg = p.n1},


    StatusLine       = {fg = p.n4, bg = p.n2},
    StatusLineNC     = {fg = p.n4, bg = p.n1},
    StatusLineTerm   = {fg = p.n4, bg = p.n2},
    StatusLineTermNC = {fg = p.n4, bg = p.n1},


    MsgSeparator = {link = "FoldColumn"},
    VertSplit    = {fg = p.n3},


    TabLine     = {fg = p.n4, bg = p.n0},
    TabLineFill = {fg = p.n4, bg = p.n0},
    TabLineSel  = {fg = p.n8, bg = p.n3},


    Title      = {fg = p.n8, bold = true},
    SpecialKey = {fg = p.n12},
    Directory  = {fg = p.n7},


    QuickFixLine = {bg = p.n1, bold = true},
    qfLineNr     = {link = "LineNr"},
    qfFileName   = {link = "Directory"},
    qfError      = {fg = p.n11, bold = true},


    Visual    = {bg = p.n2, bold = true},
    VisualNOS = {bg = p.n2, bold = true},


    healthError   = {fg = p.n11, bg = p.n1},
    healthSuccess = {fg = p.n14, bg = p.n1},
    healthWarning = {fg = p.n13, bg = p.n1},

    helpHyperTextEntry = {link = "Label"},
    helpHyperTextJump  = {fg = p.n15},
    helpSpecial        = {fg = p.orange},
    helpHeader         = {fg = p.n10, bold = true}
}
-- }}} Editor highlight

-- TreeSitter highlight {{{

theme.treesitter         = {
    TSNone               = {fg   = p.n4},
    TSStrong             = {fg   = p.n4,  bold = true},
    TSStrike             = {fg   = p.n4,  strikethrough = true},
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

    TSError              = {fg   = p.n6, bold = true},        -- For syntax/parser errors.
    TSException          = {link = "Exception"},                 -- For exception related keywords.
    TSFuncMacro          = {link = "Macro"},                    -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
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
    TSTypeBuiltin        = {fg = p.yellow, bold = true},      -- For builtin types.
    TSTag                = {link = "Tag"},                       -- Tags like html tag names.
    TSTagDelimiter       = {link = "Tag"},                       -- Tag delimiter like `<` `>` `/`
    TSText               = {link = "Identifier"},                -- For strings considen11 text in a markup language.
    TSTextReference      = {link = "helpHyperTextJump"},         -- FIXME
    TSEmphasis           = {fg   = p.n4, bold = true},        -- For text to be represented with emphasis.
    TSUnderline          = {fg   = p.n4, underline = true, sp = p.n4 },  -- For text to be represented with an underline.
    TSLiteral            = {link = "Comment"},                   -- Help document code.
    TSURI                = {fg   = p.n4, underline = true, sp = p.n4 },  -- Any URI like a link or email.
    TSAnnotation         = {link = "Decorator"},                 -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
    ["@constructor"]           = {link = "Structure"},
    ["@constant"]              = {link = "Constant"},
    ["@float"]                 = {link = "Float"},
    ["@number"]                = {link = "Number"},
    ["@attribute"]             = {fg   = p.n15 },
    ["@error"]                 = {fg   = p.n6, bold = true},
    ["@exception"]             = {link = "Exception"},
    ["@funtion.macro"]         = {link = "Macro"},
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
    ["@text.strike"]           = {fg = p.n4, strikethrough = true},
    ["@text.math"]             = {fg = p.n7 },
    -- @ (e.g. for LaTeX math environments)
    -- @todo Missing highlights
    -- @function.call
    -- @method.call
    -- @type.qualifier
    -- @text.environment (e.g. for text environments of markup languages)
    -- @text.environment.name (e.g. for the name/the string indicating the type of text environment)
    -- @text.note
    -- @text.warning
    -- @text.danger
    -- @tag.attribute
    -- @string.special
}
    theme.treesitter.TSVariableBuiltin    = {fg   = p.cyan, bold = true }
    theme.treesitter.TSBoolean            = {link = "Boolean"}
    theme.treesitter.TSConstBuiltin       = {fg   = p.orange, bold = true }
    theme.treesitter.TSConstMacro         = {fg   = p.orange, bold = true }
    theme.treesitter.TSVariable           = {link = "Identifier"}
    theme.treesitter.TSTitle              = {link = "helpHeader"}
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
    theme.treesitter.TSFuncBuiltin = {link = "TSVariableBuiltin"}
    -- Namespaces and property accessors
    theme.treesitter.TSNamespace = {fg = "#00ffe5"}  -- For identifiers referring to modules and namespaces.
    theme.treesitter.TSField     = {fg = p.n4 }      -- For fields.
    theme.treesitter.TSProperty  = {link = "TSField"}  -- Same as `TSField`, but when accessing, not declaring.
    -- Language keywords
    theme.treesitter.TSKeyword         = {link = "Keyword"} -- For keywords that don't fall in other categories.
    theme.treesitter.TSKeywordFunction = {link = "Keyword"}
    theme.treesitter.TSKeywordReturn   = {fg   = p.purple, bg = "#564167", bold = true, italic = true}
    theme.treesitter.TSKeyordOperator  = {link = "Keyword"}
    theme.treesitter.TSRepeat          = {link = "Repeat"} -- For keywords related to loops.
    -- Strings
    theme.treesitter.TSString             = {link = "String"}                  -- For strings.
    theme.treesitter.TSStringRegex        = {fg   = p.n7, italic = true }  -- For regexes.
    theme.treesitter.TSStringEscape       = {fg   = p.n15, italic = true }  -- For escape characters within a string.
    theme.treesitter.TSCharacter           = {link = "String"}                  -- For characters.
    theme.treesitter["@comment"]           = {link = "Comment"}
    theme.treesitter["@conditional"]       = {link = "Conditional"}
    theme.treesitter["@function"]          = {link = "Function"}
    theme.treesitter["@function.builtin"]  = {link = "TSFuncBuiltin"}
    theme.treesitter["@method"]            = {link = "Function"}
    theme.treesitter["@namespace"]         = {link = "TSNamespace"}
    theme.treesitter["@namespace.builtin"] = {fg = "#00ffe5", bold = true}
    theme.treesitter["@field"]             = {link = "TSField"}
    theme.treesitter["@property"]          = {link = "TSField"}
    theme.treesitter["@keyword"]           = {link = "Keyword"}
    theme.treesitter["@keyword.function"]  = {link = "Keyword"}
    theme.treesitter["@keyword.return"]    = {link = "TSKeywordReturn"}
    theme.treesitter["@keyword.operator"]  = {link = "Keyword"}
    theme.treesitter["@keyword.break"]     = {link = "TSKeywordReturn"}
    theme.treesitter["@repeat"]            = {link = "Repeat"}
    theme.treesitter["@string"]            = {link = "String"}
    theme.treesitter["@string.regex"]      = {link = "TSStringRegex"}
    theme.treesitter["@string.escape"]     = {link = "TSStringEscape"}
    theme.treesitter["@character"]         = {link = "String"}
-- }}}

theme.lsp = { -- {{{
    DiagnosticError          = {fg = p.n11, bold = true},
    DiagnosticWarn           = {fg = p.n13, bold = true},
    DiagnosticInfo           = {fg = p.n10, bold = true},
    DiagnosticHint           = {fg = p.n9,  bold = true},
    DiagnosticUnderlineError = {sp = p.n11, undercurl = true},
    DiagnosticUnderlineWarn  = {sp = p.n13, undercurl = true},
    DiagnosticUnderlineInfo  = {sp = p.n10, undercurl = true},
    DiagnosticUnderlineHint  = {sp = p.n9,  undercurl = true},

    LspDiagnosticsError                = {link = "DiagnosticError"},
    LspDiagnosticsWarning              = {link = "DiagnosticWarn"},
    LspDiagnosticsInformation          = {link = "DiagnosticInfo"},
    LspDiagnosticsHint                 = {link = "DiagnosticHint"},
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

} -- }}}

theme.plugins = { -- {{{
    -- https://github.com/folke/lazy.nvim
    LazyDimmed = {fg = p.n3b},

    -- https://github.com/folke/trouble.nvim
    LspTroubleText   = {fg = p.n4},
    LspTroubleCount  = {fg = p.n9, bg = p.n10},
    LspTroubleNormal = {fg = p.n4, bg = p.sidebar},

    -- https://github.com/sindrets/diffview.nvim
    DiffviewFilePanelSelected = {link = "Search"},
    diffAdded     = {fg = p.n14},
    diffChanged   = {fg = p.n13},
    diffRemoved   = {fg = p.n11},
    diffOldFile   = {fg = p.n15},
    diffNewFile   = {fg = p.n12},
    diffFile      = {fg = p.n7},
    diffLine      = {fg = p.n3},
    diffIndexLine = {fg = p.n9},

    -- https://github.com/rhysd/git-messenger.vim
    gitmessengerHeader  = {fg = p.n8, bold = true},
    gitmessengerHistory = {fg = p.n11},

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
    TelescopePromptTitle   = {fg = p.n4, bold = true},
    TelescopePromptBorder  = {link = "FloatBorder"},
    TelescopePromptCounter = {fg = p.n13, bold = true},
    TelescopePromptPrefix  = {fg = p.n13, bold = true},

    TelescopePreviewBorder = {link = "FloatBorder"},
    TelescopePreviewTitle  = {link = "TelescopePromptTitle"},

    TelescopeResultsBorder = {fg = p.n8},
    TelescopeResultsTitle  = {fg = p.n8, bold = true},
    TelescopeSelection     = {bg = p.n2, bold = true},
    TelescopeMatching      = {fg = p.n13},

    -- https://github.com/kyazdani42/nvim-tree.lua
    NvimTreeIndentMarker = {link  = "FoldColumn"},
    NvimTreeWindowPicker = {bg = p.n8, fg = p.w, bold = true},

    NvimTreeModifiedFile     = {fg = p.n13},
    NvimTreeModifiedIcon     = {link = "NvimTreeModifiedFile"},
    NvimTreeModifiedFileHL   = {link = "NvimTreeModifiedFile"},
    NvimTreeModifiedFolderHL = {link = "NvimTreeModifiedFile"},

    NvimTreeFileDeleted   = {fg = p.n11},
    NvimTreeFileDirty     = {fg = p.n13},
    NvimTreeFileIgnored   = {fg = p.n3},
    NvimTreeFileMerge     = {fg = p.n15},
    NvimTreeFileNew       = {fg = p.n14},
    NvimTreeFileRenamed   = {fg = p.n13},
    NvimTreeFileStaged    = {fg = p.n12},
    NvimTreeFolderDeleted = {link = "NvimTreeFileDeleted"},
    NvimTreeFolderDirty   = {link = "NvimTreeFileDirty"},
    NvimTreeFolderIgnored = {link = "NvimTreeFileIgnored"},
    NvimTreeFolderMerge   = {link = "NvimTreeFileMerge"},
    NvimTreeFolderNew     = {link = "NvimTreeFileNew"},
    NvimTreeFolderRenamed = {link = "NvimTreeFileRenamed"},
    NvimTreeFolderStaged  = {link = "NvimTreeFileStaged"},
    -- File Text
    NvimTreeOpenedFile  = {fg = p.w, bold = true, italic = true},
    NvimTreeOpenedHL    = {link = "NvimTreeOpenedFile"},
    NvimTreeExecFile    = {fg = p.n15},
    NvimTreeImageFile   = {fg = p.n15},
    NvimTreeSpecialFile = {fg = p.n9 , underline = true, sp = p.n9},
    NvimTreeSymlink     = {fg = p.purple},
    NvimTreeSymlinkIcon = {link = "NvimTreeSymlink"},
    -- Folder Text
    NvimTreeRootFolder        = {fg   = p.n10, bold = true},
    NvimTreeFolderName        = {fg   = p.white},
    NvimTreeEmptyFolderName   = {fg   = p.n3b},
    NvimTreeFolderIcon        = {link = "NvimTreeFolderName"},
    NvimTreeSymlinkFolderName = {link = "NvimTreeSymlink"},
    NvimTreeOpenedFolderName  = {link = "NvimTreeOpenedHL"},
    NvimTreeOpenedFolderIcon  = {link = "NvimTreeOpenedHL"},
    NvimTreeClosedFolderIcon  = {link = "NvimTreeFolderName"},
    NvimTreeFolderArrowOpen   = {link = "NvimTreeOpenedHL"},
    NvimTreeFolderArrowClosed = {link = "NvimTreeIndentMarker"},


    -- https://github.com/folke/which-key.nvim
    WhichKey =          {fg = p.n4 , bold = true},
    WhichKeyGroup =     {fg = p.n4},
    WhichKeyDesc =      {fg = p.n7, italic = true},
    WhichKeySeperator = {fg = p.n9},
    WhichKeyFloating =  {link = "FloatBorder"},
    WhichKeyFloat =     {link = "FloatBorder"},

    -- https://github.com/lukas-reineke/indent-blankline.nvim
    IblIndent = {fg = p.n2},
    IblScope  = {fg = p.n3b},

    -- https://github.com/RRethy/vim-illuminate
    illuminatedWordText  = {link = "LspReferenceText"},
    IlluminatedWordRead  = {link = "LspReferenceText"},
    IlluminatedWordWrite = {link = "LspReferenceText"},

    -- https://github.com/mfussenegger/nvim-dap
    DapBreakpoint   = {fg = p.n14},
    DapStopped      = {fg = p.n15},
    DapStoppedLine  = {bg = "#615A57"},
    DapLogPointLine = {bg = "#50636E"},

    -- https://github.com/rcarriga/nvim-dap-ui
    DapUINormal                  = {link = "Normal"},
    DapUIVariable                = {fg   = p.n9},
    DapUIScope                   = {fg   = p.n14, bold = true},
    DapUIType                    = {fg   = p.orange},
    DapUIValue                   = {link = "Identifier"},
    DapUIModifiedValue           = {fg   = p.n13, bold = true},
    DapUIDecoration              = {fg   = p.n8},
    DapUIThread                  = {fg   = p.n14},
    DapUIStoppedThread           = {fg   = p.n14, bold = true},
    DapUIFrameName               = {link = "NormalFloat"},
    DapUISource                  = {fg   = p.purple},
    DapUILineNumber              = {fg   = p.n13},
    DapUIFloatNormal             = {link = "NormalFloat"},
    DapUIFloatBorder             = {link = "FloatBorder"},
    DapUIWatchesError            = {link = "DiagnosticError"},
    DapUIWatchesEmpty            = {link = "DiagnosticWarn"},
    DapUIWatchesValue            = {fg   = p.n14},
    DapUIBreakpointsPath         = {link = "DapUIStoppedThread"},
    DapUIBreakpointsInfo         = {fg   = p.n14},
    DapUIBreakpointsCurrentLine  = {fg   = p.n14, bold = true},
    DapUIBreakpointsLine         = {link = "DapUILineNumber"},
    DapUIBreakpointsDisabledLine = {fg   = p.n3b},
    DapUICurrentFrameName        = {link = "DapUIBreakpointsCurrentLine"},
    DapUIStepOver                = {fg   = p.n8},
    DapUIStepInto                = {fg   = p.n8},
    DapUIStepBack                = {fg   = p.n8},
    DapUIStepOut                 = {fg   = p.n8},
    DapUIStop                    = {fg   = p.n11},
    DapUIPlayPause               = {fg   = p.n14},
    DapUIRestart                 = {fg   = p.n14},
    DapUIUnavailable             = {fg   = p.n3b},
    DapUIWinSelect               = {fg   = p.n9},
    DapUIEndofBuffer             = {link = "EndOfBuffer"},
    DapUINormalNC                = {link = "Normal"},
    DapUIPlayPauseNC             = {link = "DapUIPlayPause"},
    DapUIRestartNC               = {link = "DapUIRestart"},
    DapUIStopNC                  = {link = "DapUIStop"},
    DapUIUnavailableNC           = {link = "DapUIUnavailable"},
    DapUIStepOverNC              = {link = "DapUIStepOver"},
    DapUIStepIntoNC              = {link = "DapUIStepInto"},
    DapUIStepBackNC              = {link = "DapUIStepBack"},
    DapUIStepOutNC               = {link = "DapUIStepOut"},

    -- https://github.com/theHamsta/nvim-dap-virtual-text
    NvimDapVirtualText        = {fg = p.n9, bg = p.n1, italic = true},
    NvimDapVirtualTextChanged = {link = "DapUIModifiedValue"},

    -- https://github.com/phaazon/hop.nvim
    HopNextKey   = {link = "IncSearch"},
    HopNextKey1  = {link = "Search"},
    HopNextKey2  = {link = "Search"},
    HopUnmatched = {fg   = p.n3},

    -- https://github.com/kylechui/nvim-surround
    NvimSurroundHighlight = {link = "Search"},

    -- HistoryStartup
    HistoryStartupCreate   = {fg = p.n10, bold = true},
    HistoryStartupFileRoot = {fg = p.n8,  bold = true},

    -- https://github.com/kosayoda/nvim-lightbulb
    -- LightBulbVirtualText = {link = "DiagnosticHint"},

    -- https://github.com/hrsh7th/nvim-cmp
    CmpItemAbbr           = {fg = p.white},
    CmpItemAbbrDeprecated = {fg = p.white, bg = "", strikethrough = true },
    CmpItemAbbrMatch      = {fg = p.w,     bg = "", bold = true},
    CmpItemAbbrMatchFuzzy = {link = "CmpItemAbbrMatch"},
    CmpItemKind           = {fg = p.n15},
    CmpItemMenu           = {fg = p.n3b,  bg = "", italic = true },
    -- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-add-visual-studio-code-codicons-to-the-menu
    CmpItemKindField         = {fg = p.cyan},
    CmpItemKindProperty      = {link = "CmpItemKindField"},
    CmpItemKindEvent         = {fg = p.dark_red},
    CmpItemKindText          = {fg = p.green},
    CmpItemKindEnum          = {fg = p.yellow},
    CmpItemKindKeyword       = {fg = p.purple},
    CmpItemKindConstant      = {fg = p.orange},
    CmpItemKindConstructor   = {fg = p.yellow},
    CmpItemKindReference     = {fg = p.n13},
    CmpItemKindFunction      = {fg = p.blue},
    CmpItemKindStruct        = {fg = p.purple},
    CmpItemKindClass         = {fg = p.blue},
    CmpItemKindModule        = {link = "TSNamespace"},
    CmpItemKindOperator      = {link = "Operator"},
    CmpItemKindVariable      = {fg = p.n8},
    CmpItemKindFile          = {fg = p.n4},
    CmpItemKindUnit          = {fg = "#D4A959"},
    CmpItemKindSnippet       = {fg = p.n12},
    CmpItemKindFolder        = {link = "CmpItemKindFile"},
    CmpItemKindMethod        = {fg = p.blue},
    CmpItemKindValue         = {fg = p.n9},
    CmpItemKindEnumMember    = {fg = p.yellow},
    CmpItemKindInterface     = {fg = "#58B5A8"},
    CmpItemKindColor         = {fg = "#58B5A8"},
    CmpItemKindTypeParameter = {fg = p.orange},
    -- Misc
    CmpItemKindTabnine = {fg = p.n10},
    CmpItemKindEmoji   = {fg = p.n13},

    -- https://github.com/ray-x/lsp_signature.nvim
    LspSignatureActiveParameter = {bg = p.n1, bold = true},

    -- https://github.com/michaelb/sniprun
    SniprunVirtualTextOk  = {bg=p.n8, fg=p.w},
    SniprunFloatingWinOk  = {fg=p.n8},
    SniprunVirtualTextErr = {bg=p.n11,  fg=p.w},
    SniprunFloatingWinErr = {fg=p.n11},

    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    TreesitterContext           = {bold = true},
    TreesitterContextLineNumber = {fg = p.n3b, bold = true},
    TreesitterContextBottom     = {link  = "TreesitterContextLineNumber"},

    -- https://github.com/simrat39/symbols-outline.nvim
    FocusedSymbol           = {fg = p.n10, bold = true, italic = true},
    SymbolsOutlineConnector = {fg = p.n2},

    -- https://github.com/L3MON4D3/LuaSnip
    -- LuasnipSnippetNodeActive         = {bold = true},
    -- LuasnipSnippetNodePassive        = {},
    -- LuasnipSnippetNodeSnippetPassive = {},
} -- }}}

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

