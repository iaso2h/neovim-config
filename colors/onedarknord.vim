" let g:nord_bold = 1
" " One dark
let g:onedark_terminal_italics = 1
" }}} Custom highlight

if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let g:colors_name = "onedarknord"
let s:nord_vim_version="0.15.1"
set background=dark

let s:nord0_gui = "#2E3440"
let s:nord1_gui = "#3B4252"
let s:nord2_gui = "#434C5E"
let s:nord3_gui = "#4C566A"
let s:nord3_gui_bright = "#616E88"
let s:nord4_gui = "#D8DEE9"
let s:nord5_gui = "#E5E9F0"
let s:nord6_gui = "#ECEFF4"
let s:nord7_gui = "#8FBCBB"
let s:nord8_gui = "#88C0D0"
let s:nord9_gui = "#81A1C1"
let s:nord10_gui = "#5E81AC"
let s:nord11_gui = "#BF616A"
let s:nord12_gui = "#D08770"
let s:nord13_gui = "#EBCB8B"
let s:nord14_gui = "#A3BE8C"
let s:nord15_gui = "#B48EAD"

let s:nord1_term = "0"
let s:nord3_term = "8"
let s:nord5_term = "7"
let s:nord6_term = "15"
let s:nord7_term = "14"
let s:nord8_term = "6"
let s:nord9_term = "4"
let s:nord10_term = "12"
let s:nord11_term = "1"
let s:nord12_term = "11"
let s:nord13_term = "3"
let s:nord14_term = "2"
let s:nord15_term = "5"

let s:nord3_gui_brightened = [
            \ s:nord3_gui,
            \ "#4e586d",
            \ "#505b70",
            \ "#525d73",
            \ "#556076",
            \ "#576279",
            \ "#59647c",
            \ "#5b677f",
            \ "#5d6982",
            \ "#5f6c85",
            \ "#616e88",
            \ "#63718b",
            \ "#66738e",
            \ "#687591",
            \ "#6a7894",
            \ "#6d7a96",
            \ "#6f7d98",
            \ "#72809a",
            \ "#75829c",
            \ "#78859e",
            \ "#7b88a1",
            \ ]

let s:bold = "bold,"
" let s:bold = ""

if has('win32')
    let g:nord_italic = 1
    let g:onedark_terminal_italics = 1
    let s:italic = "italic,"
elseif has("gui_running") || $TERM_ITALICS == "true"
    let g:nord_italic = 1
    let g:onedark_terminal_italics = 1
    let s:italic = "italic,"
else
    let g:nord_italic = 0
    let g:onedark_terminal_italics = 0
    let s:italic = ""
endif

let s:underline = "underline,"
" let s:underline = "NONE,"

" let s:italicize_comments = ""
let s:italicize_comments = s:italic

function! s:logWarning(msg)
    echohl WarningMsg
    echomsg 'nord: warning: ' . a:msg
    echohl None
endfunction

if exists("g:nord_comment_brightness")
    call s:logWarning('Variable g:nord_comment_brightness has been deprecated and will be removed in version 1.0.0!' .
                \' The comment color brightness has been increased by 10% by default.' .
                \' Please see https://github.com/arcticicestudio/nord-vim/issues/145 for more details.')
    let g:nord_comment_brightness = 10
endif

if !exists("g:nord_cursor_line_number_background")
    let g:nord_cursor_line_number_background = 0
endif

if !exists("g:nord_bold_vertical_split_line")
    let g:nord_bold_vertical_split_line = 0
endif


if !exists("g:onedark_termcolors")
    let g:onedark_termcolors = 256
endif

" Not all terminals support italics properly. If yours does, opt-in.
" This function is based on one from FlatColor: https://github.com/MaxSt/FlatColor/
" Which in turn was based on one found in hemisu: https://github.com/noahfrederick/vim-hemisu/
function! s:h(group, style, ...)
    let s:highlight = a:style

    if g:onedark_terminal_italics == 0
        " if 1
        if has_key(s:highlight, "cterm") && s:highlight["cterm"] == "italic"
            unlet s:highlight.cterm
        endif
        if has_key(s:highlight, "gui") && s:highlight["gui"] == "italic"
            unlet s:highlight.gui
        endif
    endif

    if g:onedark_termcolors == 16
        let l:ctermfg = (has_key(s:highlight, "fg") ? s:highlight.fg.cterm16 : "NONE")
        let l:ctermbg = (has_key(s:highlight, "bg") ? s:highlight.bg.cterm16 : "NONE")
    else
        let l:ctermfg = (has_key(s:highlight, "fg") ? s:highlight.fg.cterm : "NONE")
        let l:ctermbg = (has_key(s:highlight, "bg") ? s:highlight.bg.cterm : "NONE")
    endif

    execute "highlight" a:group
                \ "guifg="   (has_key(s:highlight, "fg")    ? s:highlight.fg.gui   : "NONE")
                \ "guibg="   (has_key(s:highlight, "bg")    ? s:highlight.bg.gui   : "NONE")
                \ "guisp="   (has_key(s:highlight, "sp")    ? s:highlight.sp.gui   : "NONE")
                \ "gui="     (has_key(s:highlight, "gui")   ? s:highlight.gui      : "NONE")
                \ "ctermfg=" . l:ctermfg
                \ "ctermbg=" . l:ctermbg
                \ "cterm="   (has_key(s:highlight, "cterm") ? s:highlight.cterm    : "NONE")
endfunction

function! s:hi(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
    if a:guifg != ""
        exec "hi " . a:group . " guifg=" . a:guifg
    endif
    if a:guibg != ""
        exec "hi " . a:group . " guibg=" . a:guibg
    endif
    if a:ctermfg != ""
        exec "hi " . a:group . " ctermfg=" . a:ctermfg
    endif
    if a:ctermbg != ""
        exec "hi " . a:group . " ctermbg=" . a:ctermbg
    endif
    if a:attr != ""
        exec "hi " . a:group . " gui=" . a:attr . " cterm=" . substitute(a:attr, "undercurl", s:underline, "")
    endif
    if a:guisp != ""
        exec "hi " . a:group . " guisp=" . a:guisp
    endif
endfunction

let s:overrides = get(g:, "onedark_color_overrides", {})

let s:colors = {
            \ "red": get(s:overrides, "red", { "gui": "#E06C75", "cterm": "204", "cterm16": "1" }),
            \ "dark_red": get(s:overrides, "dark_red", { "gui": "#BE5046", "cterm": "196", "cterm16": "9" }),
            \ "green": get(s:overrides, "green", { "gui": "#98C379", "cterm": "114", "cterm16": "2" }),
            \ "yellow": get(s:overrides, "yellow", { "gui": "#E5C07B", "cterm": "180", "cterm16": "3" }),
            \ "dark_yellow": get(s:overrides, "dark_yellow", { "gui": "#D19A66", "cterm": "173", "cterm16": "11" }),
            \ "blue": get(s:overrides, "blue", { "gui": "#61AFEF", "cterm": "39", "cterm16": "4" }),
            \ "purple": get(s:overrides, "purple", { "gui": "#C678DD", "cterm": "170", "cterm16": "5" }),
            \ "cyan": get(s:overrides, "cyan", { "gui": "#56B6C2", "cterm": "38", "cterm16": "6" }),
            \ "white": get(s:overrides, "white", { "gui": "#ABB2BF", "cterm": "145", "cterm16": "7" }),
            \ "black": get(s:overrides, "black", { "gui": "#282C34", "cterm": "235", "cterm16": "0" }),
            \ "visual_black": get(s:overrides, "visual_black", { "gui": "NONE", "cterm": "NONE", "cterm16": "0" }),
            \ "comment_grey": get(s:overrides, "comment_grey", { "gui": "#5C6370", "cterm": "59", "cterm16": "15" }),
            \ "gutter_fg_grey": get(s:overrides, "gutter_fg_grey", { "gui": "#4B5263", "cterm": "238", "cterm16": "15" }),
            \ "cursor_grey": get(s:overrides, "cursor_grey", { "gui": "#2C323C", "cterm": "236", "cterm16": "8" }),
            \ "visual_grey": get(s:overrides, "visual_grey", { "gui": "#3E4452", "cterm": "237", "cterm16": "15" }),
            \ "menu_grey": get(s:overrides, "menu_grey", { "gui": "#3E4452", "cterm": "237", "cterm16": "8" }),
            \ "special_grey": get(s:overrides, "special_grey", { "gui": "#3B4048", "cterm": "238", "cterm16": "15" }),
            \ "vertsplit": get(s:overrides, "vertsplit", { "gui": "#181A1F", "cterm": "59", "cterm16": "15" }),
            \}

let s:red = s:colors.red
let s:dark_red = s:colors.dark_red
let s:green = s:colors.green
let s:yellow = s:colors.yellow
let s:dark_yellow = s:colors.dark_yellow
let s:blue = s:colors.blue
let s:purple = s:colors.purple
let s:cyan = s:colors.cyan
let s:white = s:colors.white
let s:black = s:colors.black
let s:visual_black = s:colors.visual_black " Black out selected text in 16-color visual mode
let s:comment_grey = s:colors.comment_grey
let s:gutter_fg_grey = s:colors.gutter_fg_grey
let s:cursor_grey = s:colors.cursor_grey
let s:visual_grey = s:colors.visual_grey
let s:menu_grey = s:colors.menu_grey
let s:special_grey = s:colors.special_grey
let s:vertsplit = s:colors.vertsplit

" }}}

" Terminal Colors {{{
let g:terminal_ansi_colors = [
            \ s:black.gui, s:red.gui, s:green.gui, s:yellow.gui,
            \ s:blue.gui, s:purple.gui, s:cyan.gui, s:white.gui,
            \ s:visual_grey.gui, s:dark_red.gui, s:green.gui, s:dark_yellow.gui,
            \ s:blue.gui, s:purple.gui, s:cyan.gui, s:comment_grey.gui
            \]
" }}}

"+---------------+
"+ UI Components +
"+---------------+
"+--- Attributes ---+
call s:hi("Bold", "", "", "", "", s:bold, "")
call s:hi("Italic", "", "", "", "", s:italic, "")
call s:hi("Underline", "", "", "", "", s:underline, "")

"+--- Editor ---+
call s:hi("ColorColumn", "", s:nord1_gui, "NONE", s:nord1_term, "", "")
call s:hi("NonText", s:nord2_gui, "", s:nord3_term, "", "", "")
call s:hi("Cursor", "#000000", "#FFFFFF", "",s:nord6_term, "", "")
call s:hi("CursorLine", "", s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
call s:hi("Error", s:nord4_gui, s:nord11_gui, "", s:nord11_term, "", "")
call s:hi("iCursor", s:nord0_gui, s:nord4_gui, "", "NONE", "", "")
call s:hi("LineNr", s:nord3_gui, "NONE", s:nord3_term, "NONE", "", "")
call s:hi("MatchParen", s:nord8_gui, s:nord3_gui_bright, s:nord8_term, s:nord3_term, "", "")
call s:hi("MatchWord", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "", "")
call s:hi("Normal", s:nord4_gui, s:nord0_gui, "NONE", "NONE", "", "")
call s:hi("Pmenu", s:nord4_gui, s:nord2_gui, "NONE", s:nord1_term, "NONE", "")
call s:hi("PmenuSbar", s:nord4_gui, s:nord2_gui, "NONE", s:nord1_term, "", "")
call s:hi("PmenuSel", "#FFFFFF", s:nord8_gui, s:nord3_term, s:nord8_term, "", "")
call s:hi("OffscreenPopup", "NONE", s:nord8_gui, s:nord3_term, s:nord8_term, "", "")
call s:hi("PmenuThumb", s:nord8_gui, s:nord3_gui, "NONE", s:nord3_term, "", "")
call s:hi("SpecialKey", s:nord3_gui, "", s:nord3_term, "", "", "")
call s:hi("SpellBad", s:nord11_gui, s:nord0_gui, s:nord11_term, "NONE", "undercurl", s:nord11_gui)
call s:hi("SpellCap", s:nord13_gui, s:nord0_gui, s:nord13_term, "NONE", "undercurl", s:nord13_gui)
call s:hi("SpellLocal", s:nord5_gui, s:nord0_gui, s:nord5_term, "NONE", "undercurl", s:nord5_gui)
call s:hi("SpellRare", s:nord6_gui, s:nord0_gui, s:nord6_term, "NONE", "undercurl", s:nord6_gui)
call s:hi("Visual", "", s:nord2_gui, "", s:nord1_term, "", "")
call s:hi("VisualNOS", "", s:nord2_gui, "", s:nord1_term, "", "")
"+- Neovim Support -+
call s:hi("healthError", s:nord11_gui, s:nord1_gui, s:nord11_term, s:nord1_term, "", "")
call s:hi("healthSuccess", s:nord14_gui, s:nord1_gui, s:nord14_term, s:nord1_term, "", "")
call s:hi("healthWarning", s:nord13_gui, s:nord1_gui, s:nord13_term, s:nord1_term, "", "")
call s:hi("TermCursorNC", "", s:nord1_gui, "", s:nord1_term, "", "")

"+- Vim 8 Terminal Colors -+
if has('terminal')
    let g:terminal_ansi_colors = [s:nord1_gui, s:nord11_gui, s:nord14_gui, s:nord13_gui, s:nord9_gui, s:nord15_gui, s:nord8_gui, s:nord5_gui, s:nord3_gui, s:nord11_gui, s:nord14_gui, s:nord13_gui, s:nord9_gui, s:nord15_gui, s:nord7_gui, s:nord6_gui]
endif

"+- Neovim Terminal Colors -+
" Neovim terminal colors {{{
let g:terminal_color_0 =  s:black.gui
let g:terminal_color_1 =  s:red.gui
let g:terminal_color_2 =  s:green.gui
let g:terminal_color_3 =  s:yellow.gui
let g:terminal_color_4 =  s:blue.gui
let g:terminal_color_5 =  s:purple.gui
let g:terminal_color_6 =  s:cyan.gui
let g:terminal_color_7 =  s:white.gui
let g:terminal_color_8 =  s:visual_grey.gui
let g:terminal_color_9 =  s:dark_red.gui
let g:terminal_color_10 = s:green.gui " No dark version
let g:terminal_color_11 = s:dark_yellow.gui
let g:terminal_color_12 = s:blue.gui " No dark version
let g:terminal_color_13 = s:purple.gui " No dark version
let g:terminal_color_14 = s:cyan.gui " No dark version
let g:terminal_color_15 = s:comment_grey.gui
let g:terminal_color_background = g:terminal_color_0
let g:terminal_color_foreground = g:terminal_color_7
" }}}


"+--- Gutter ---+
call s:hi("CursorColumn", "", s:nord1_gui, "NONE", s:nord1_term, "", "")
call s:hi("CursorLineNr", s:nord4_gui, "", "NONE", "", "NONE", "")
" call s:hi("CursorLineNr", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
call s:hi("Folded", s:nord3_gui, s:nord1_gui, s:nord3_term, s:nord1_term, s:bold, "")
call s:hi("FoldColumn", s:nord3_gui, s:nord0_gui, s:nord3_term, "NONE", "", "")
call s:hi("SignColumn", s:nord1_gui, s:nord0_gui, s:nord1_term, "NONE", "", "")

"+--- Navigation ---+
call s:hi("Directory", s:nord8_gui, "", s:nord8_term, "NONE", "", "")

"+--- Prompt/Status ---+
call s:hi("EndOfBuffer", s:nord1_gui, "", s:nord1_term, "NONE", "", "")
call s:hi("ErrorMsg", s:nord4_gui, s:nord11_gui, "NONE", s:nord11_term, "", "")
call s:hi("ModeMsg", s:nord4_gui, "", "", "", "", "")
call s:hi("MoreMsg", s:nord8_gui, "", s:nord8_term, "", "", "")
call s:hi("Question", s:nord4_gui, "", "NONE", "", "", "")
" call s:hi("StatusLine", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")
" call s:hi("StatusLineNC", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
" call s:hi("StatusLineTerm", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")
" call s:hi("StatusLineTermNC", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
call s:hi("StatusLine", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")
call s:hi("StatusLineNC", s:nord4_gui, s:nord3_gui, "NONE", s:nord3_term, "NONE", "")
call s:hi("StatusLineTerm", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")
call s:hi("StatusLineTermNC", s:nord4_gui, s:nord3_gui, "NONE", s:nord3_term, "NONE", "")
call s:hi("WarningMsg", s:nord0_gui, s:nord13_gui, s:nord1_term, s:nord13_term, "", "")
call s:hi("WildMenu", s:nord8_gui, s:nord1_gui, s:nord8_term, s:nord1_term, "", "")

"+--- Search ---+
call s:hi("IncSearch", "#FFFFFF", "#ED427C", s:nord6_term, s:nord10_term, "NONE", "")
call s:hi("Search", s:nord6_gui, s:nord8_gui, s:nord1_term, s:nord8_term, "NONE", "")

"+--- Tabs ---+
call s:hi("TabLine", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
call s:hi("TabLineFill", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
call s:hi("TabLineSel", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")

"+--- Window ---+
call s:hi("Title", s:nord4_gui, "", "NONE", "", "NONE", "")
call s:hi("VertSplit", s:nord2_gui, s:nord0_gui, s:nord3_term, "NONE", "NONE", "")
" call s:hi("VertSplit", s:nord2_gui, s:nord1_gui, s:nord3_term, s:nord1_term, "NONE", "")

"+----------------------+
"+ Language Base Groups +
"+----------------------+
" Syntax Groups (descriptions and ordering from `:h w18`) {{{

call s:h("Comment", {"fg": s:comment_grey, "gui": "italic", "cterm": "italic" }) " any comment
call s:hi("Conceal", "", "NONE", "", "NONE", "", "")
call s:h("Constant", {"fg": s:cyan }) " any constant
call s:h("String", {"fg": s:green }) " a string constant: "this is a string"
call s:h("Character", {"fg": s:green }) " a character constant: 'c', '\n'
call s:h("Number", {"fg": s:dark_yellow }) " a number constant: 234, 0xff
call s:h("Boolean", {"fg": s:dark_yellow }) " a boolean constant: TRUE, false
call s:h("Float", {"fg": s:dark_yellow }) " a floating point constant: 2.3e10
" call s:h("Identifier", {"fg": s:colors.white }) " any variable name
call s:hi("Identifier", s:nord4_gui, "", "NONE", "", "NONE", "") " any variable name
call s:h("Function", {"fg": s:blue }) " function name (also: methods for classes)
call s:h("Statement", {"fg": s:purple, "gui": "italic", "cterm": "italic" }) " any statement
call s:h("Conditional", {"fg": s:purple, "gui": "italic", "cterm": "italic" }) " if, then, else, endif, switch, etc.
call s:h("Repeat", {"fg": s:purple, "gui": "italic", "cterm": "italic" }) " for, do, while, etc.
call s:h("Label", {"fg": s:purple }) " case, default, etc.
call s:h("Operator", {"fg": s:purple }) " sizeof", "+", "*", etc.
call s:h("Keyword", {"fg": s:purple }) " any other keyword
call s:h("Exception", {"fg": s:purple, "gui": "italic", "cterm": "italic" }) " try, catch, throw
call s:h("PreProc", {"fg": s:yellow }) " generic Preprocessor
call s:h("Include", {"fg": s:purple }) " preprocessor #include
" TODO
call s:h("Define", {"fg": s:purple }) " preprocessor #define
" call s:h("Macro", {"fg": s:purple }) " same as Define
call s:hi("Macro", "#7E57C2", "NONE", s:nord15_term, "NONE", "", "")
call s:h("PreCondit", {"fg": s:yellow }) " preprocessor #if, #else, #endif, etc.
call s:h("Type", {"fg": s:yellow }) " int, long, char, etc.
call s:h("StorageClass", {"fg": s:yellow }) " static, register, volatile, etc.
call s:h("Structure", {"fg": s:yellow }) " struct, union, enum, etc.
call s:h("Typedef", {"fg": s:yellow }) " A typedef
call s:h("Special", {"fg": s:blue }) " any special symbol
call s:h("SpecialChar", {"fg": s:dark_yellow }) " special character in a constant
call s:h("Tag", {}) " you can use CTRL-] on this
call s:h("Delimiter", {}) " character that needs attention
call s:h("SpecialComment", {"fg": s:comment_grey }) " special things inside a comment
call s:h("Debug", {}) " debugging statements
call s:h("Underlined", {"gui": "underline", "cterm": "underline" }) " text that stands out, HTML links
call s:h("Ignore", {}) " left blank, hidden
call s:h("Error", {"fg": s:red }) " any erroneous construct
call s:h("Parameter", {"fg": s:dark_yellow }) " Function parameter
call s:hi("Todo", s:nord13_gui, "NONE", s:nord13_term, "NONE", "", "") " anything that needs extra attention; mostly the keywords TODO FIXME and XXX
" }}}

"+-----------+
"+ Languages +
"+-----------+
" Language-Specific Highlighting {{{

" Diff
" call s:hi("DiffAdd", s:nord14_gui, s:nord0_gui, s:nord14_term, "NONE", "inverse", "")
" call s:hi("DiffChange", s:nord13_gui, s:nord0_gui, s:nord13_term, "NONE", "inverse", "")
" call s:hi("DiffDelete", s:nord11_gui, s:nord0_gui, s:nord11_term, "NONE", "inverse", "")
" call s:hi("DiffText", s:nord9_gui, s:nord0_gui, s:nord9_term, "NONE", "inverse", "")
call s:hi("DiffAdd", s:nord14_gui, s:nord1_gui, s:nord14_term, s:nord1_term, "", "")
call s:hi("DiffChange", s:nord13_gui, s:nord1_gui, s:nord13_term, s:nord1_term, "", "")
call s:hi("DiffDelete", s:nord11_gui, s:nord1_gui, s:nord11_term, s:nord1_term, "", "")
call s:hi("DiffText", s:nord9_gui, s:nord1_gui, s:nord9_term, s:nord1_term, "", "")
" Legacy groups for official git.vim and diff.vim syntax
hi! link diffAdded DiffAdd
hi! link diffChanged DiffChange
hi! link diffRemoved DiffDelete

" CSS
call s:h("cssAttrComma", { "fg": s:purple })
call s:h("cssAttributeSelector", { "fg": s:green })
call s:h("cssBraces", { "fg": s:white })
call s:h("cssClassName", { "fg": s:dark_yellow })
call s:h("cssClassNameDot", { "fg": s:dark_yellow })
call s:h("cssDefinition", { "fg": s:purple })
call s:h("cssFontAttr", { "fg": s:dark_yellow })
call s:h("cssFontDescriptor", { "fg": s:purple })
call s:h("cssFunctionName", { "fg": s:blue })
call s:h("cssIdentifier", { "fg": s:blue })
call s:h("cssImportant", { "fg": s:purple })
call s:h("cssInclude", { "fg": s:white })
call s:h("cssIncludeKeyword", { "fg": s:purple })
call s:h("cssMediaType", { "fg": s:dark_yellow })
call s:h("cssProp", { "fg": s:white })
call s:h("cssPseudoClassId", { "fg": s:dark_yellow })
call s:h("cssSelectorOp", { "fg": s:purple })
call s:h("cssSelectorOp2", { "fg": s:purple })
call s:h("cssTagName", { "fg": s:red })

" Fish Shell
call s:h("fishKeyword", { "fg": s:purple })
call s:h("fishConditional", { "fg": s:purple })

" Go
call s:h("goDeclaration", { "fg": s:purple })
call s:h("goBuiltins", { "fg": s:cyan })
call s:h("goFunctionCall", { "fg": s:blue })
call s:h("goVarDefs", { "fg": s:red })
call s:h("goVarAssign", { "fg": s:red })
call s:h("goVar", { "fg": s:purple })
call s:h("goConst", { "fg": s:purple })
call s:h("goType", { "fg": s:yellow })
call s:h("goTypeName", { "fg": s:yellow })
call s:h("goDeclType", { "fg": s:cyan })
call s:h("goTypeDecl", { "fg": s:purple })

" HTML (keep consistent with Markdown, below)
call s:h("htmlArg", { "fg": s:dark_yellow })
call s:h("htmlBold", { "fg": s:dark_yellow, "gui": "bold", "cterm": "bold" })
call s:h("htmlEndTag", { "fg": s:white })
call s:h("htmlH1", { "fg": s:red })
call s:h("htmlH2", { "fg": s:red })
call s:h("htmlH3", { "fg": s:red })
call s:h("htmlH4", { "fg": s:red })
call s:h("htmlH5", { "fg": s:red })
call s:h("htmlH6", { "fg": s:red })
call s:h("htmlItalic", { "fg": s:purple, "gui": "italic", "cterm": "italic" })
call s:h("htmlLink", { "fg": s:cyan, "gui": "underline", "cterm": "underline" })
call s:h("htmlSpecialChar", { "fg": s:dark_yellow })
call s:h("htmlSpecialTagName", { "fg": s:red })
call s:h("htmlTag", { "fg": s:white })
call s:h("htmlTagN", { "fg": s:red })
call s:h("htmlTagName", { "fg": s:red })
call s:h("htmlTitle", { "fg": s:white })

" JavaScript
call s:h("javaScriptBraces", { "fg": s:white })
call s:h("javaScriptFunction", { "fg": s:purple })
call s:h("javaScriptIdentifier", { "fg": s:purple })
call s:h("javaScriptNull", { "fg": s:dark_yellow })
call s:h("javaScriptNumber", { "fg": s:dark_yellow })
call s:h("javaScriptRequire", { "fg": s:cyan })
call s:h("javaScriptReserved", { "fg": s:purple })
" https://github.com/pangloss/vim-javascript
call s:h("jsArrowFunction", { "fg": s:purple })
call s:h("jsClassKeyword", { "fg": s:purple })
call s:h("jsClassMethodType", { "fg": s:purple })
call s:h("jsDocParam", { "fg": s:blue })
call s:h("jsDocTags", { "fg": s:purple })
call s:h("jsExport", { "fg": s:purple })
call s:h("jsExportDefault", { "fg": s:purple })
call s:h("jsExtendsKeyword", { "fg": s:purple })
call s:h("jsFrom", { "fg": s:purple })
call s:h("jsFuncCall", { "fg": s:blue })
call s:h("jsFunction", { "fg": s:purple })
call s:h("jsGenerator", { "fg": s:yellow })
call s:h("jsGlobalObjects", { "fg": s:yellow })
call s:h("jsImport", { "fg": s:purple })
call s:h("jsModuleAs", { "fg": s:purple })
call s:h("jsModuleWords", { "fg": s:purple })
call s:h("jsModules", { "fg": s:purple })
call s:h("jsNull", { "fg": s:dark_yellow })
call s:h("jsOperator", { "fg": s:purple })
call s:h("jsStorageClass", { "fg": s:purple })
call s:h("jsSuper", { "fg": s:red })
call s:h("jsTemplateBraces", { "fg": s:dark_red })
call s:h("jsTemplateVar", { "fg": s:green })
call s:h("jsThis", { "fg": s:red })
call s:h("jsUndefined", { "fg": s:dark_yellow })
" https://github.com/othree/yajs.vim
call s:h("javascriptArrowFunc", { "fg": s:purple })
call s:h("javascriptClassExtends", { "fg": s:purple })
call s:h("javascriptClassKeyword", { "fg": s:purple })
call s:h("javascriptDocNotation", { "fg": s:purple })
call s:h("javascriptDocParamName", { "fg": s:blue })
call s:h("javascriptDocTags", { "fg": s:purple })
call s:h("javascriptEndColons", { "fg": s:white })
call s:h("javascriptExport", { "fg": s:purple })
call s:h("javascriptFuncArg", { "fg": s:white })
call s:h("javascriptFuncKeyword", { "fg": s:purple })
call s:h("javascriptIdentifier", { "fg": s:red })
call s:h("javascriptImport", { "fg": s:purple })
call s:h("javascriptMethodName", { "fg": s:white })
call s:h("javascriptObjectLabel", { "fg": s:white })
call s:h("javascriptOpSymbol", { "fg": s:cyan })
call s:h("javascriptOpSymbols", { "fg": s:cyan })
call s:h("javascriptPropertyName", { "fg": s:green })
call s:h("javascriptTemplateSB", { "fg": s:dark_red })
call s:h("javascriptVariable", { "fg": s:purple })

" JSON
call s:h("jsonCommentError", { "fg": s:white })
call s:h("jsonKeyword", { "fg": s:red })
call s:h("jsonBoolean", { "fg": s:dark_yellow })
call s:h("jsonNumber", { "fg": s:dark_yellow })
call s:h("jsonQuote", { "fg": s:white })
call s:h("jsonMissingCommaError", { "fg": s:red, "gui": "reverse" })
call s:h("jsonNoQuotesError", { "fg": s:red, "gui": "reverse" })
call s:h("jsonNumError", { "fg": s:red, "gui": "reverse" })
call s:h("jsonString", { "fg": s:green })
call s:h("jsonStringSQError", { "fg": s:red, "gui": "reverse" })
call s:h("jsonSemicolonError", { "fg": s:red, "gui": "reverse" })

" LESS
call s:h("lessVariable", { "fg": s:purple })
call s:h("lessAmpersandChar", { "fg": s:white })
call s:h("lessClass", { "fg": s:dark_yellow })

" Markdown (keep consistent with HTML, above)
call s:h("markdownBlockquote", { "fg": s:comment_grey })
call s:h("markdownBold", { "fg": s:dark_yellow, "gui": "bold", "cterm": "bold" })
call s:h("markdownCode", { "fg": s:green })
call s:h("markdownCodeBlock", { "fg": s:green })
call s:h("markdownCodeDelimiter", { "fg": s:green })
call s:h("markdownH1", { "fg": s:red })
call s:h("markdownH2", { "fg": s:red })
call s:h("markdownH3", { "fg": s:red })
call s:h("markdownH4", { "fg": s:red })
call s:h("markdownH5", { "fg": s:red })
call s:h("markdownH6", { "fg": s:red })
call s:h("markdownHeadingDelimiter", { "fg": s:red })
call s:h("markdownHeadingRule", { "fg": s:comment_grey })
call s:h("markdownId", { "fg": s:purple })
call s:h("markdownIdDeclaration", { "fg": s:blue })
call s:h("markdownIdDelimiter", { "fg": s:purple })
call s:h("markdownItalic", { "fg": s:purple, "gui": "italic", "cterm": "italic" })
call s:h("markdownLinkDelimiter", { "fg": s:purple })
call s:h("markdownLinkText", { "fg": s:blue })
call s:h("markdownListMarker", { "fg": s:red })
call s:h("markdownOrderedListMarker", { "fg": s:red })
call s:h("markdownRule", { "fg": s:comment_grey })
call s:h("markdownUrl", { "fg": s:cyan, "gui": "underline", "cterm": "underline" })

" Perl
call s:h("perlFiledescRead", { "fg": s:green })
call s:h("perlFunction", { "fg": s:purple })
call s:h("perlMatchStartEnd",{ "fg": s:blue })
call s:h("perlMethod", { "fg": s:purple })
call s:h("perlPOD", { "fg": s:comment_grey })
call s:h("perlSharpBang", { "fg": s:comment_grey })
call s:h("perlSpecialString",{ "fg": s:dark_yellow })
call s:h("perlStatementFiledesc", { "fg": s:red })
call s:h("perlStatementFlow",{ "fg": s:red })
call s:h("perlStatementInclude", { "fg": s:purple })
call s:h("perlStatementScalar",{ "fg": s:purple })
call s:h("perlStatementStorage", { "fg": s:purple })
call s:h("perlSubName",{ "fg": s:yellow })
call s:h("perlVarPlain",{ "fg": s:blue })

" PHP
call s:h("phpVarSelector", { "fg": s:red })
call s:h("phpOperator", { "fg": s:white })
call s:h("phpParent", { "fg": s:white })
call s:h("phpMemberSelector", { "fg": s:white })
call s:h("phpType", { "fg": s:purple })
call s:h("phpKeyword", { "fg": s:purple })
call s:h("phpClass", { "fg": s:yellow })
call s:h("phpUseClass", { "fg": s:white })
call s:h("phpUseAlias", { "fg": s:white })
call s:h("phpInclude", { "fg": s:purple })
call s:h("phpClassExtends", { "fg": s:green })
call s:h("phpDocTags", { "fg": s:white })
call s:h("phpFunction", { "fg": s:blue })
call s:h("phpFunctions", { "fg": s:cyan })
call s:h("phpMethodsVar", { "fg": s:dark_yellow })
call s:h("phpMagicConstants", { "fg": s:dark_yellow })
call s:h("phpSuperglobals", { "fg": s:red })
call s:h("phpConstants", { "fg": s:dark_yellow })

" Ruby
call s:h("rubyBlockParameter", { "fg": s:red})
call s:h("rubyBlockParameterList", { "fg": s:red })
call s:h("rubyClass", { "fg": s:purple})
call s:h("rubyConstant", { "fg": s:yellow})
call s:h("rubyControl", { "fg": s:purple })
call s:h("rubyEscape", { "fg": s:red})
call s:h("rubyFunction", { "fg": s:blue})
call s:h("rubyGlobalVariable", { "fg": s:red})
call s:h("rubyInclude", { "fg": s:blue})
call s:h("rubyIncluderubyGlobalVariable", { "fg": s:red})
call s:h("rubyInstanceVariable", { "fg": s:red})
call s:h("rubyInterpolation", { "fg": s:cyan })
call s:h("rubyInterpolationDelimiter", { "fg": s:red })
call s:h("rubyInterpolationDelimiter", { "fg": s:red})
call s:h("rubyRegexp", { "fg": s:cyan})
call s:h("rubyRegexpDelimiter", { "fg": s:cyan})
call s:h("rubyStringDelimiter", { "fg": s:green})
call s:h("rubySymbol", { "fg": s:cyan})

" Sass
" https://github.com/tpope/vim-haml
call s:h("sassAmpersand", { "fg": s:red })
call s:h("sassClass", { "fg": s:dark_yellow })
call s:h("sassControl", { "fg": s:purple })
call s:h("sassExtend", { "fg": s:purple })
call s:h("sassFor", { "fg": s:white })
call s:h("sassFunction", { "fg": s:cyan })
call s:h("sassId", { "fg": s:blue })
call s:h("sassInclude", { "fg": s:purple })
call s:h("sassMedia", { "fg": s:purple })
call s:h("sassMediaOperators", { "fg": s:white })
call s:h("sassMixin", { "fg": s:purple })
call s:h("sassMixinName", { "fg": s:blue })
call s:h("sassMixing", { "fg": s:purple })
call s:h("sassVariable", { "fg": s:purple })
" https://github.com/cakebaker/scss-syntax.vim
call s:h("scssExtend", { "fg": s:purple })
call s:h("scssImport", { "fg": s:purple })
call s:h("scssInclude", { "fg": s:purple })
call s:h("scssMixin", { "fg": s:purple })
call s:h("scssSelectorName", { "fg": s:dark_yellow })
call s:h("scssVariable", { "fg": s:purple })

" TeX
call s:h("texStatement", { "fg": s:purple })
call s:h("texSubscripts", { "fg": s:dark_yellow })
call s:h("texSuperscripts", { "fg": s:dark_yellow })
call s:h("texTodo", { "fg": s:dark_red })
call s:h("texBeginEnd", { "fg": s:purple })
call s:h("texBeginEndName", { "fg": s:blue })
call s:h("texMathMatcher", { "fg": s:blue })
call s:h("texMathDelim", { "fg": s:blue })
call s:h("texDelimiter", { "fg": s:dark_yellow })
call s:h("texSpecialChar", { "fg": s:dark_yellow })
call s:h("texCite", { "fg": s:blue })
call s:h("texRefZone", { "fg": s:blue })

" TypeScript
call s:h("typescriptReserved", { "fg": s:purple })
call s:h("typescriptEndColons", { "fg": s:white })
call s:h("typescriptBraces", { "fg": s:white })

" XML
call s:h("xmlAttrib", { "fg": s:dark_yellow })
call s:h("xmlEndTag", { "fg": s:red })
call s:h("xmlTag", { "fg": s:red })
call s:h("xmlTagName", { "fg": s:red })

" }}}

"+----------------+
"+ Plugin Support +
"+----------------+
"+--- UI ---+
" ALE
" > w0rp/ale
" call s:hi("ALEWarningSign", s:nord13_gui, "", s:nord13_term, "", "", "")
" call s:hi("ALEErrorSign" , s:nord11_gui, "", s:nord11_term, "", "", "")
" call s:hi("ALEWarning" , s:nord13_gui, "", s:nord13_term, "", "undercurl", "")
" call s:hi("ALEError" , s:nord11_gui, "", s:nord11_term, "", "undercurl", "")

" Coc
" > neoclide/coc
call s:hi("CocWarningHighlight", s:nord13_gui, "",                 s:nord13_term, "",           "undercurl", "")
call s:hi("CocErrorHighlight",   s:nord11_gui, "",                 s:nord11_term, "",           "undercurl", "")
call s:hi("CocWarningSign",      s:nord13_gui, "",                 s:nord13_term, "",           "",          "")
call s:hi("CocErrorSign",        s:nord11_gui, "",                 s:nord11_term, "",           "",          "")
call s:hi("CocInfoSign",         s:nord8_gui,  "",                 s:nord8_term,  "",           "",          "")
call s:hi("CocHintSign",         s:nord13_gui, "",                 s:nord13_term, "",           "",          "")
call s:hi("CocHighlightText",    "",           s:nord3_gui_bright, "",            s:nord3_term, "",          "")
call s:hi("CocWarningFloat",     s:nord13_gui, s:nord2_gui,        s:nord13_term, s:nord1_term, "",          "")
call s:hi("CocErrorFloat",       s:nord11_gui, s:nord2_gui,        s:nord11_term, s:nord1_term, "",          "")
call s:hi("CocInfoFloat",        s:nord8_gui,  s:nord2_gui,        s:nord8_term,  s:nord1_term, "",          "")
call s:hi("CocHintFloat",        s:nord10_gui, s:nord2_gui,        s:nord10_term, s:nord1_term, "",          "")

" Nvim LSP
" > neovim/nvim-lsp
call s:hi("LspDiagnosticsDefaultWarning",       s:nord13_gui, "",          s:nord13_term, "",           "", "")
call s:hi("LspDiagnosticsDefaultError",         s:nord11_gui, "",          s:nord11_term, "",           "", "")
call s:hi("LspDiagnosticsDefaultInformation",   s:nord8_gui,  "",          s:nord8_term,  "",           "", "")
call s:hi("LspDiagnosticsDefaultHint",          s:nord10_gui, "",          s:nord10_term, "",           "", "")
call s:hi("LspDiagnosticsUnderlineWarning",     "",           "",          "",            "",           "", s:nord13_gui)
call s:hi("LspDiagnosticsUnderlineError",       "",           "",          "",            "",           "", s:nord11_gui)
call s:hi("LspDiagnosticsUnderlineInformation", "",           "",          "",            "",           "", s:nord8_gui)
call s:hi("LspDiagnosticsUnderlineHint",        "",           "",          "",            "",           "", s:nord10_gui)
call s:hi("LspReferenceText",                   "",           s:nord3_gui, "NONE",        s:nord1_term, "", "")
call s:hi("LspReferenceRead",                   "",           s:nord3_gui, "NONE",        s:nord1_term, "", "")
call s:hi("LspReferenceWrite",                  "",           s:nord3_gui, "NONE",        s:nord1_term, "", "")
" LspDiagnosticsVirtualTextError
" LspDiagnosticsVirtualTextWarning
" LspDiagnosticsVirtualTextInformation
" LspDiagnosticsVirtualTextHint

" GitGutter
" > airblade/vim-gitgutter
call s:hi("GitGutterAdd", s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("GitGutterChange", s:nord13_gui, "", s:nord13_term, "", "", "")
call s:hi("GitGutterChangeDelete", s:nord11_gui, "", s:nord11_term, "", "", "")
call s:hi("GitGutterDelete", s:nord11_gui, "", s:nord11_term, "", "", "")

" Signify
" > mhinz/vim-signify
call s:hi("SignifySignAdd", s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("SignifySignChange", s:nord13_gui, "", s:nord13_term, "", "", "")
call s:hi("SignifySignChangeDelete", s:nord11_gui, "", s:nord11_term, "", "", "")
call s:hi("SignifySignDelete", s:nord11_gui, "", s:nord11_term, "", "", "")

" fugitive.vim
" > tpope/vim-fugitive
call s:hi("gitcommitDiscardedFile", s:nord11_gui, "", s:nord11_term, "", "", "")
call s:hi("gitcommitUntrackedFile", s:nord11_gui, "", s:nord11_term, "", "", "")
call s:hi("gitcommitSelectedFile", s:nord14_gui, "", s:nord14_term, "", "", "")

" davidhalter/jedi-vim
" call s:hi("jediFunction", s:nord4_gui, s:nord3_gui, "", s:nord3_term, "", "")
" call s:hi("jediFat", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, s:underline.s:bold, "")

" " NERDTree
" " > scrooloose/nerdtree
" call s:hi("NERDTreeExecFile", s:nord7_gui, "", s:nord7_term, "", "", "")
" hi! link NERDTreeDirSlash Keyword
" hi! link NERDTreeHelp Comment

" " CtrlP
" " > ctrlpvim/ctrlp.vim
" hi! link CtrlPMatch Keyword
" hi! link CtrlPBufferHid Normal

" " vim-clap
" " > liuchengxu/vim-clap
" call s:hi("ClapDir", s:nord4_gui, "", "", "", "", "")
" call s:hi("ClapDisplay", s:nord4_gui, s:nord1_gui, "", s:nord1_term, "", "")
" call s:hi("ClapFile", s:nord4_gui, "", "", "NONE", "", "")
" call s:hi("ClapMatches", s:nord8_gui, "", s:nord8_term, "", "", "")
" call s:hi("ClapNoMatchesFound", s:nord13_gui, "", s:nord13_term, "", "", "")
" call s:hi("ClapSelected", s:nord7_gui, "", s:nord7_term, "", s:bold, "")
" call s:hi("ClapSelectedSign", s:nord9_gui, "", s:nord9_term, "", "", "")

" let s:clap_matches = [
            " \ [s:nord8_gui,  s:nord8_term] ,
            " \ [s:nord9_gui,  s:nord9_term] ,
            " \ [s:nord10_gui, s:nord10_term] ,
            " \ ]
" for s:nord_clap_match_i in range(1,12)
    " let clap_match_color = s:clap_matches[s:nord_clap_match_i % len(s:clap_matches) - 1]
    " call s:hi("ClapMatches" . s:nord_clap_match_i, clap_match_color[0], "", clap_match_color[1], "", "", "")
    " call s:hi("ClapFuzzyMatches" . s:nord_clap_match_i, clap_match_color[0], "", clap_match_color[1], "", "", "")
" endfor
" unlet s:nord_clap_match_i

" hi! link ClapCurrentSelection PmenuSel
" hi! link ClapCurrentSelectionSign ClapSelectedSign
" hi! link ClapInput Pmenu
" hi! link ClapPreview Pmenu
" hi! link ClapProviderAbout ClapDisplay
" hi! link ClapProviderColon Type
" hi! link ClapProviderId Type

" vim-indent-guides
" > nathanaelkane/vim-indent-guides
call s:hi("IndentGuidesEven", "", s:nord1_gui, "", s:nord1_term, "", "")
call s:hi("IndentGuidesOdd", "", s:nord2_gui, "", s:nord3_term, "", "")

" vim-plug
" > junegunn/vim-plug
call s:hi("plugDeleted", s:nord11_gui, "", "", s:nord11_term, "", "")

" vim-signature
" > kshenoy/vim-signature
call s:hi("SignatureMarkText", s:nord8_gui, "", s:nord8_term, "", "", "")

" vim-startify
" > mhinz/vim-startify
call s:hi("StartifyFile", s:nord6_gui, "", s:nord6_term, "", "", "")
call s:hi("StartifyFooter", s:nord7_gui, "", s:nord7_term, "", "", "")
call s:hi("StartifyHeader", s:nord8_gui, "", s:nord8_term, "", "", "")
call s:hi("StartifyNumber", s:nord7_gui, "", s:nord7_term, "", "", "")
call s:hi("StartifyPath", s:nord8_gui, "", s:nord8_term, "", "", "")
call s:hi("StartifyBracket", s:nord6_gui, "", s:nord6_term, "", "", "")
call s:hi("StartifySlash", s:nord15_gui, "", s:nord15_term, "", "", "")
call s:hi("StartifySpecial", s:nord3_gui_bright, "", s:nord3_term, "", s:italicize_comments, "")

"+--- Languages ---+
" Haskell
" > neovimhaskell/haskell-vim
call s:hi("haskellPreProc", s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("haskellType", s:nord7_gui, "", s:nord7_term, "", "", "")
hi! link haskellPragma haskellPreProc

" JavaScript
" > pangloss/vim-javascript
call s:hi("jsGlobalNodeObjects", s:nord8_gui, "", s:nord8_term, "", s:italic, "")
hi! link jsBrackets Delimiter
hi! link jsFuncCall Function
hi! link jsFuncParens Delimiter
hi! link jsThis Keyword
hi! link jsNoise Delimiter
hi! link jsPrototype Keyword
hi! link jsRegexpString SpecialChar

" TypeScript
" > HerringtonDarkholme/yats.vim
call s:hi("typescriptBOMWindowMethod", s:nord8_gui, "", s:nord8_term, "", s:italic, "")
call s:hi("typescriptClassName", s:nord7_gui, "", s:nord7_term, "", "", "")
call s:hi("typescriptDecorator", s:nord12_gui, "", s:nord12_term, "", "", "")
call s:hi("typescriptInterfaceName", s:nord7_gui, "", s:nord7_term, "", s:bold, "")
call s:hi("typescriptRegexpString", s:nord13_gui, "", s:nord13_term, "", "", "")
" TypeScript JSX
call s:hi("tsxAttrib", s:nord7_gui, "", s:nord7_term, "", "", "")
hi! link typescriptOperator Operator
hi! link typescriptBinaryOp Operator
hi! link typescriptAssign Operator
hi! link typescriptMember Identifier
hi! link typescriptDOMStorageMethod Identifier
hi! link typescriptArrowFuncArg Identifier
hi! link typescriptGlobal typescriptClassName
hi! link typescriptBOMWindowProp Function
hi! link typescriptArrowFuncDef Function
hi! link typescriptAliasDeclaration Function
hi! link typescriptPredefinedType Type
hi! link typescriptTypeReference typescriptClassName
hi! link typescriptTypeAnnotation Structure
hi! link typescriptDocNamedParamType SpecialComment
hi! link typescriptDocNotation Keyword
hi! link typescriptDocTags Keyword
hi! link typescriptImport Keyword
hi! link typescriptExport Keyword
hi! link typescriptTry Keyword
hi! link typescriptVariable Keyword
hi! link typescriptBraces Normal
hi! link typescriptObjectLabel Normal
hi! link typescriptCall Normal
hi! link typescriptClassHeritage typescriptClassName
hi! link typescriptFuncTypeArrow Structure
hi! link typescriptMemberOptionality Structure
hi! link typescriptNodeGlobal typescriptGlobal
hi! link typescriptTypeBrackets Structure
hi! link tsxEqual Operator
hi! link tsxIntrinsicTagName htmlTag
hi! link tsxTagName tsxIntrinsicTagName

" Markdown
" > plasticboy/vim-markdown
call s:hi("mkdCode", s:nord7_gui, "", s:nord7_term, "", "", "")
call s:hi("mkdFootnote", s:nord8_gui, "", s:nord8_term, "", "", "")
call s:hi("mkdRule", s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("mkdLineBreak", s:nord9_gui, "", s:nord9_term, "", "", "")
hi! link mkdBold Bold
hi! link mkdItalic Italic
hi! link mkdString Keyword
hi! link mkdCodeStart mkdCode
hi! link mkdCodeEnd mkdCode
hi! link mkdBlockquote Comment
hi! link mkdListItem Keyword
hi! link mkdListItemLine Normal
hi! link mkdFootnotes mkdFootnote
hi! link mkdLink markdownLinkText
hi! link mkdURL markdownUrl
hi! link mkdInlineURL mkdURL
hi! link mkdID Identifier
hi! link mkdLinkDef mkdLink
hi! link mkdLinkDefTarget mkdURL
hi! link mkdLinkTitle mkdInlineURL
hi! link mkdDelimiter Keyword

" Vimwiki
" > vimwiki/vimwiki
if !exists("g:vimwiki_hl_headers") || g:vimwiki_hl_headers == 0
    for s:i in range(1,6)
        call s:hi("VimwikiHeader".s:i, s:nord8_gui, "", s:nord8_term, "", s:bold, "")
    endfor
else
    let s:vimwiki_hcolor_guifg = [s:nord7_gui, s:nord8_gui, s:nord9_gui, s:nord10_gui, s:nord14_gui, s:nord15_gui]
    let s:vimwiki_hcolor_ctermfg = [s:nord7_term, s:nord8_term, s:nord9_term, s:nord10_term, s:nord14_term, s:nord15_term]
    for s:i in range(1,6)
        call s:hi("VimwikiHeader".s:i, s:vimwiki_hcolor_guifg[s:i-1] , "", s:vimwiki_hcolor_ctermfg[s:i-1], "", s:bold, "")
    endfor
endif

call s:hi("VimwikiLink", s:nord8_gui, "", s:nord8_term, "", s:underline, "")
hi! link VimwikiHeaderChar markdownHeadingDelimiter
hi! link VimwikiHR Keyword
hi! link VimwikiList markdownListMarker

" YAML
" > stephpy/vim-yaml
call s:hi("yamlKey", s:nord7_gui, "", s:nord7_term, "", "", "")

" Git Highlighting {{{
call s:h("gitcommitComment", { "fg": s:comment_grey })
call s:h("gitcommitUnmerged", { "fg": s:green })
call s:h("gitcommitOnBranch", {})
call s:h("gitcommitBranch", { "fg": s:purple })
call s:h("gitcommitDiscardedType", { "fg": s:red })
call s:h("gitcommitSelectedType", { "fg": s:green })
call s:h("gitcommitHeader", {})
call s:h("gitcommitUntrackedFile", { "fg": s:cyan })
call s:h("gitcommitDiscardedFile", { "fg": s:red })
call s:h("gitcommitSelectedFile", { "fg": s:green })
call s:h("gitcommitUnmergedFile", { "fg": s:yellow })
call s:h("gitcommitFile", {})
call s:h("gitcommitSummary", { "fg": s:white })
call s:h("gitcommitOverflow", { "fg": s:red })
hi link gitcommitNoBranch gitcommitBranch
hi link gitcommitUntracked gitcommitComment
hi link gitcommitDiscarded gitcommitComment
hi link gitcommitSelected gitcommitComment
hi link gitcommitDiscardedArrow gitcommitDiscardedFile
hi link gitcommitSelectedArrow gitcommitSelectedFile
hi link gitcommitUnmergedArrow gitcommitUnmergedFile
" }}}
"
" EasyMotion {{{
highlight EasyMotionTarget guibg=white guifg=black
highlight link EasyMotionShade  Comment
highlight EasyMotionTarget2First guibg=#ED427C guifg=white
highlight EasyMotionTarget2Second guibg=#ED427C guifg=white
" }}} EasyMotion

" phaazon/hop.nvim {{{
highlight HopNextKey guibg=white guifg=black
highlight HopNextKey1 guibg=#ED427C guifg=white
highlight HopNextKey2 guibg=#ED427C guifg=white
" }}} phaazon/hop.nvim


" " the color of the cursorline
" highlight def Lf_hl_cursorline guifg=Yellow guibg=NONE gui=NONE ctermfg=226 ctermbg=NONE cterm=NONE
call s:hi("Lf_hl_cursorline", s:nord8_gui, "", s:nord8_term, "", "", "")

call s:hi("Lf_hl_match", s:nord9_gui, "", s:nord9_term, "", "", "")
" " the color of matching character
" highlight def Lf_hl_match  guifg=SpringGreen guibg=NONE gui=bold ctermfg=85 ctermbg=NONE cterm=bold

" the color of matching character in `And mode`
call s:hi("Lf_hl_match01", s:nord9_gui, "", s:nord9_term, "", "", "")
call s:hi("Lf_hl_match02", s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("Lf_hl_match03", s:nord11_gui, "", s:nord11_term, "", "", "")
call s:hi("Lf_hl_match04", s:nord15_gui, "", s:nord15_term, "", "", "")
call s:hi("Lf_hl_matchRefine", s:nord13_gui, "", s:nord13_term, "", "", "")

" " the color of matching character in nameOnly mode when ';' is typed
" highlight def Lf_hl_matchRefine gui=bold guifg=Magenta cterm=bold ctermfg=201

" Sandwich {{{
hi! link OperatorSandwichAdd    Search
hi! link OperatorSandwichBuns   Search
hi! link OperatorSandwichChange Search
hi! link OperatorSandwichDelete Search
hi! link OperatorSandwichAddrcc Search
" }}} Sandwich

" mg979/vim-visual-multi-multi {{{
hi! VMExtend      ctermbg=239 guibg=#434C5E
hi! VMCursor      ctermbg=245 ctermfg=24  guibg=#8a8a8a guifg=black
hi! VMInsert      ctermbg=239 guibg=#8a8a8a
hi! VMMono        ctermbg=131 ctermfg=235 guibg=#88c0d0 guifg=white
" }}} mg979/vim-visual-multi-multi

" p00f/nvim-ts-rainbow {{{
hi rainbowcol1 guifg=Gold
hi rainbowcol2 guifg=DarkOrchid3
hi rainbowcol3 guifg=RoyalBlue2
hi rainbowcol4 guifg=Firebrick
hi rainbowcol5 guifg=SeaGreen3
hi rainbowcol6 guifg=DarkOrange3
hi rainbowcol7 guifg=#458588
" }}} p00f/nvim-ts-rainbow

" nvim-telescope/telescope.nvim {{{
" TODO
call s:hi("TelescopeSelection",      s:nord4_gui, s:nord8_gui, "NONE", s:nord8_term, s:bold, "")
hi! link TelescopeSelectionCaret TelescopeSelection
call s:hi("TelescopeMultiSelection", s:nord12_gui, "", s:nord12_term, "", "",     "")

" Border highlight groups.
call s:hi("TelescopeBorder",        s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("TelescopePromptBorder",  s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("TelescopeResultsBorder", s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("TelescopePreviewBorder", s:nord10_gui, "", s:nord10_term, "", "", "")

" Used for highlighting characters that you match.
call s:hi("TelescopeMatching", s:nord13_gui, "", s:nord13_term, "", "", "")

" Used for the prompt prefix
call s:hi("TelescopeNormal",       s:nord4_gui,  "", "NONE",        "", "", "")
call s:hi("TelescopePromptPrefix", s:nord14_gui, "", s:nord14_term, "", "", "")
" }}} nvim-telescope/telescope.nvim

" romgrk/barbar.nvim {{{
call s:hi("BufferCurrent",       s:nord8_gui,  s:nord3_gui, s:nord8_term,  s:nord3_term, "", "")
call s:hi("BufferCurrentIcon",   "",           s:nord3_gui, "",            s:nord3_term, "", "")
call s:hi("BufferCurrentIndex",  s:nord8_gui,  s:nord3_gui, s:nord8_term,  s:nord3_term, "", "")
call s:hi("BufferCurrentMod",    s:nord13_gui, s:nord3_gui, s:nord13_term, s:nord3_term, "", "")
call s:hi("BufferCurrentSign",   s:nord8_gui,  s:nord3_gui, s:nord8_term,  s:nord3_term, "", "")
call s:hi("BufferCurrentTarget", "#FFFFFF",    s:nord3_gui, s:nord10_term, s:nord3_term, "", "")

call s:hi("BufferVisible",       "#66738e",    s:nord1_gui, s:nord3_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleIcon",   "#66738e",    s:nord1_gui, s:nord3_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleIndex",  "#66738e",    s:nord1_gui, s:nord3_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleMod",    "#9B8473",    s:nord1_gui, s:nord13_term, s:nord1_term, "", "")
call s:hi("BufferVisibleSign",   s:nord8_gui,  s:nord1_gui, s:nord8_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleTarget", "#ED427C",    s:nord1_gui, s:nord11_term, s:nord1_term, "", "")

hi! link BufferInactive       BufferVisible
hi! link BufferInactiveIcon   BufferVisibleIcon
hi! link BufferInactiveIndex  BufferVisibleIndex
hi! link BufferInactiveMod    BufferVisibleMod
hi! link BufferInactiveSign   BufferVisibleSign
hi! link BufferInactiveTarget BufferVisibleTarget

call s:hi("BufferTabpages",       s:nord10_gui, s:nord3_gui, s:nord10_term, s:nord3_term, "", "")
call s:hi("BufferInactiveTarget", s:nord5_gui,  s:nord1_gui, s:nord5_term,  s:nord1_term, "", "")
" }}} romgrk/barbar.nvim

" nvim-treesitter/nvim-treesitter {{{
highlight link TSAnnotation         PreProc
highlight link TSAttribute          PreProc
highlight link TSBoolean            Boolean
highlight link TSCharacter          Character
highlight link TSComment            Comment
highlight link TSConditional        Conditional
highlight link TSConstant           Constant
highlight link TSConstBuiltin       Special
highlight link TSConstMacro         Macro
" highlight link TSConstMacro         Define
highlight link TSConstructor        Special
highlight link TSEmphasis           Italic
highlight link TSError              Error
highlight link TSException          Exception
highlight link TSField              Identifier
highlight link TSFloat              Float
highlight link TSFunction           Function
highlight link TSFuncBuiltin        Special
highlight link TSFuncMacro          Macro
highlight link TSInclude            Include
highlight link TSKeyword            Keyword
highlight link TSKeywordFunction    Keyword
highlight link TSKeywordOperator    Operator
highlight link TSLabel              Label
highlight link TSLiteral            String
highlight link TSMethod             Function
call s:hi("TSNamespace", "#00ffe5", "", s:nord8_term, "", "", "")
highlight link TSNumber             Number
highlight link TSOperator           Operator
highlight link TSParameter          Parameter
highlight link TSParameterReference Parameter
highlight link TSProperty           Identifier
highlight link TSPunctBracket       Delimiter
call s:hi("TSPunctDelimiter", "#A1887F", "NONE", s:nord12_term, "NONE", "", "")
highlight link TSPunctSpecial       TSPunctDelimiter
" highlight link TSPunctDelimiter     Delimiter
" highlight link TSPunctSpecial       Delimiter
highlight link TSRepeat             Repeat
highlight link TSString             String
highlight link TSStringEscape       SpecialChar
highlight link TSStringRegex        String
highlight link TSStrong             bold
highlight link TSTag                Label
highlight link TSTagDelimiter       Label
highlight link TSTitle              Title
highlight link TSType               Type
highlight link TSTypeBuiltin        Type
highlight link TSUnderline          Underlined
highlight link TSURI                Underlined
highlight link TSVariableBuiltin    Special
" }}} nvim-treesitter/nvim-treesitter

" lukas-reineke/indent-blankline.nvim {{{
" hi! link indent-blankline SignColorm
" }}} lukas-reineke/indent-blankline.nvim

" glepnir/lspsaga.nvim {{{
call s:hi("LspSagaBorderTitle",         s:nord4_gui,  "", "NONE",        "", s:bold, "")
call s:hi("LspSagaDiagnosticBorder",    s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaRenameBorder",        s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaHoverBorder",         s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaSignatureHelpBorder", s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaLspFinderBorder",     s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaCodeActionBorder",    s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaDefPreviewBorder",    s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaAutoPreview",         s:nord10_gui, "", s:nord10_term, "", "",     "")

call s:hi("LspSagaDiagnosticHeader",       s:nord13_gui, "", s:nord13_term, "", s:bold, "")
call s:hi("LspSagaFinderSelection",        s:nord13_gui, "", s:nord13_term, "", s:bold, "")
call s:hi("LspSagaDiagnosticHeader",       s:nord13_gui, "", s:nord13_term, "", s:bold, "")
call s:hi("LspSagaDiagnosticTruncateLine", s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaShTruncateLine",         s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaDocTruncateLine",        s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaCodeActionContent",      s:nord4_gui,  "", "NONE",        "", "",     "")
call s:hi("LspSagaCodeActionTruncateLine", s:nord10_gui, "", s:nord10_term, "", "",     "")
call s:hi("LspSagaCodeActionTitle",        s:nord13_gui, "", s:nord13_term, "", s:bold, "")
call s:hi("LspSagaRenamePromptPrefix",     s:nord14_gui, "", s:nord14_term, "", "",     "")
call s:hi("LspSagaLightBulb",              s:nord13_gui, "", s:nord13_term, "", "",     "")
" SagaShadow                    xxx guibg=#000000
" }}} glepnir/lspsaga.nvim

" hrsh7th/nvim-compe {{{
call s:hi("CompeDocumentation", s:nord8_gui,  s:nord2_gui, s:nord8_term, s:nord1_term, "", "")
" }}} hrsh7th/nvim-compe

" kyazdani42/nvim-tree.lua {{{
call s:hi("NvimTreeFileNew",     s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("NvimTreeFileDeleted", s:nord11_gui, "", s:nord11_term, "", "", "")
call s:hi("NvimTreeRootFolder",  s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("NvimTreeGitDirty",    s:nord12_gui, "", s:nord12_term, "", "", "")
hi! link NERDTreeDirSlash Keyword
call s:hi("NvimTreeImageFile",  s:nord13_gui, "", s:nord13_term, "", "", "")
call s:hi("NvimTreeFileNew",    s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("NvimTreeGitStaged",  s:nord7_gui,  "", s:nord7_term,  "", "", "")
call s:hi("NvimTreeGitMerge",   s:nord12_gui, "", s:nord12_term, "", "", "")
call s:hi("NvimTreeGitRenamed", s:nord13_gui, "", s:nord13_term, "", "", "")
hi! link NvimTreeIndentMarker NvimTreeRootFolder
call s:hi("NvimTreeSymlink",    s:nord4_gui, s:nord0_gui, "NONE",       "NONE", "", "")
call s:hi("NvimTreeFolderIcon", s:nord8_gui, "",          s:nord8_term, "NONE", "", "")
hi! link NvimTreeExecFile Normal
hi! link NvimTreeFolderName Normal
call s:hi("NvimTreeSpecialFile", s:nord3_gui_bright, "", s:nord3_term,  "", s:italicize_comments, "")
call s:hi("NvimTreePopup",       s:nord15_gui,       "", s:nord15_term, "", "",                   "")
call s:hi("NvimTreeNormal",      s:nord15_gui,       "", s:nord15_term, "", "",                   "")
" }}} kyazdani42/nvim-tree.lua

