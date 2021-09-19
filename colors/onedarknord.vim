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

let s:bold      = "bold,"
let s:italic    = "italic,"
let s:underline = "underline,"
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
" call s:hi("Error", s:nord4_gui, s:nord11_gui, "", s:nord11_term, "", "")
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
" call s:hi("Folded", s:nord3_gui, s:nord1_gui, s:nord3_term, s:nord1_term, s:bold, "")
call s:hi("Folded", s:nord3_gui, "#323847", s:nord3_term, s:nord1_term, s:bold, "")
call s:hi("FoldColumn", s:nord3_gui, s:nord0_gui, s:nord3_term, "NONE", "", "")
call s:hi("SignColumn", s:nord1_gui, s:nord0_gui, s:nord1_term, "NONE", "", "")

"+--- Navigation ---+
call s:hi("Directory", s:nord8_gui, "", s:nord8_term, "NONE", "", "")

"+--- Prompt/Status ---+
call s:hi("EndOfBuffer", s:nord1_gui, "",           s:nord1_term, "NONE",        "",       "")
call s:hi("ErrorMsg",    s:nord4_gui, s:nord11_gui, "NONE",       s:nord11_term, "",       "")
call s:hi("ModeMsg",     s:nord4_gui, "",           "",           "",            s:bold,   "")
call s:hi("MoreMsg",     s:nord8_gui, "",           s:nord8_term, "",            s:bold,   "")
call s:hi("Question",    s:nord8_gui, "",           s:nord8_term, "",            s:italic, "")
" call s:hi("StatusLine", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")
" call s:hi("StatusLineNC", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
" call s:hi("StatusLineTerm", s:nord8_gui, s:nord3_gui, s:nord8_term, s:nord3_term, "NONE", "")
" call s:hi("StatusLineTermNC", s:nord4_gui, s:nord1_gui, "NONE", s:nord1_term, "NONE", "")
" NOTE: Use a unified statusline bg color
call s:hi("StatusLine", s:nord8_gui, s:nord1_gui, s:nord8_term, s:nord3_term, "NONE", "")
call s:hi("StatusLineNC", s:nord4_gui, s:nord1_gui, "NONE", s:nord3_term, "NONE", "")
call s:hi("StatusLineTerm", s:nord8_gui, s:nord1_gui, s:nord8_term, s:nord3_term, "NONE", "")
call s:hi("StatusLineTermNC", s:nord4_gui, s:nord1_gui, "NONE", s:nord3_term, "NONE", "")
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

" call s:h("Comment", {"fg": s:comment_grey, "gui": "italic", "cterm": "italic" }) " any comment
call s:hi("Comment", s:nord3_gui_bright, "", s:nord1_term, "", s:italic, "") " any comment
call s:hi("Conceal", "", "NONE", "", "NONE", "", "")
call s:h("Constant", {"fg": s:dark_yellow }) " any constant
call s:hi("Decorator", s:nord12_gui, "", s:nord12_term, "", "", "")
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
call s:h("Label", {"fg": s:red }) " case, default, etc.
call s:hi("Operator", s:nord4_gui, "", "NONE", "", "NONE", "") " sizeof", "+", "*", etc.
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
" call s:h("Structure", {"fg": s:cyan }) " struct, union, enum, etc.
call s:hi("Structure", "#00ffe5", "", "NONE", "", "", "")
call s:h("Typedef", {"fg": s:yellow }) " A typedef
call s:h("Special", {"fg": s:blue }) " any special symbol
call s:h("SpecialChar", {"fg": s:dark_yellow }) " special character in a constant
call s:h("Tag", {}) " you can use CTRL-] on this
call s:h("Delimiter", {}) " character that needs attention
call s:h("SpecialComment", {"fg": s:comment_grey }) " special things inside a comment
call s:h("Debug", {}) " debugging statements
call s:h("Underlined", {"gui": "underline", "cterm": "underline" }) " text that stands out, HTML links
call s:h("Ignore", {}) " left blank, hidden
" call s:h("Error", {"fg": s:red }) " any erroneous construct
call s:h("Error", {"fg": s:red, "gui": "bold"}) " any erroneous construct
call s:h("Parameter", {"fg": s:dark_yellow }) " Function parameter
call s:hi("Todo", s:nord13_gui, "NONE", s:nord13_term, "NONE", "", "") " anything that needs extra attention; mostly the keywords TODO FIXME and XXX
hi! link Annotation Decorator
hi! link Variable   Identifier
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

" Fish Shell
call s:h("fishKeyword", { "fg": s:purple })
call s:h("fishConditional", { "fg": s:purple })


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


" XML
call s:h("xmlAttrib", { "fg": s:dark_yellow })
call s:h("xmlEndTag", { "fg": s:red })
call s:h("xmlTag", { "fg": s:red })
call s:h("xmlTagName", { "fg": s:red })

" }}}

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


"+--- Languages ---+
" Haskell
" > neovimhaskell/haskell-vim
call s:hi("haskellPreProc", s:nord10_gui, "", s:nord10_term, "", "", "")
call s:hi("haskellType", s:nord7_gui, "", s:nord7_term, "", "", "")
hi! link haskellPragma haskellPreProc


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

" phaazon/hop.nvim {{{
call s:hi("HopNextKey",   "#000000",   "#FFFFFF", "",           "", s:bold, "")
call s:hi("HopNextKey1",  "#FFFFFF",   "#ED427C", "",           "", s:bold, "")
call s:hi("HopNextKey2",  "#FFFFFF",   "#ED427C", "",           "", s:bold, "")
call s:hi("HopUnmatched", s:nord3_gui, "",        s:nord1_term, "", "",     "")
" }}} phaazon/hop.nvim


" machakann/vim-sandwich {{{
hi! link OperatorSandwichAdd    Search
hi! link OperatorSandwichBuns   Search
hi! link OperatorSandwichChange Search
hi! link OperatorSandwichDelete Search
hi! link OperatorSandwichAddrcc Search
" }}} machakann/vim-sandwich

" mg979/vim-visual-multi-multi {{{
hi! VMExtend      ctermbg=239 guibg=#434C5E
hi! VMCursor      ctermbg=245 ctermfg=24  guibg=#8a8a8a guifg=black
hi! VMInsert      ctermbg=239 guibg=#8a8a8a
hi! VMMono        ctermbg=131 ctermfg=235 guibg=#88c0d0 guifg=white
" }}} mg979/vim-visual-multi-multi

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
call s:hi("BufferCurrent",       s:nord4_gui,  s:nord3_gui, "NONE",        s:nord3_term, "", "")
call s:hi("BufferCurrentIcon",   "",           s:nord3_gui, "",            s:nord3_term, "", "")
call s:hi("BufferCurrentIndex",  s:nord3_gui,  s:nord3_gui, "NONE",        s:nord3_term, "", "")
call s:hi("BufferCurrentMod",    s:nord13_gui, s:nord3_gui, s:nord13_term, s:nord3_term, "", "")
call s:hi("BufferCurrentSign",   s:nord8_gui,  s:nord3_gui, s:nord8_term,  s:nord3_term, "", "")
call s:hi("BufferCurrentTarget", "#FFFFFF",    s:nord3_gui, s:nord10_term, s:nord3_term, "", "")

call s:hi("BufferVisible",       "#66738e",    s:nord1_gui, s:nord3_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleIcon",   "#66738e",    s:nord1_gui, s:nord3_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleIndex",  "#66738e",    s:nord1_gui, s:nord3_term,  s:nord1_term, "", "")
call s:hi("BufferVisibleMod",    "#9B8473",    s:nord1_gui, s:nord13_term, s:nord1_term, "", "")
call s:hi("BufferVisibleSign",   "#66738e",    s:nord1_gui, s:nord8_term,  s:nord1_term, "", "")
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
hi!  link TSAnnotation         Annotation
call s:h("TSAttribute", {"fg": s:cyan})
hi!  link TSBoolean            Boolean
hi!  link TSCharacter          Character
hi!  link TSComment            Comment
hi!  link TSConditional        Conditional
hi!  link TSConstant           Constant
hi!  link TSConstBuiltin       Constant
hi!  link TSConstMacro         Macro

" call s:h("TSConstructor", {"fg": s:yellow})
call s:hi("TSConstructor", "#00ffe5", "", "NONE", "", "", "")
call s:hi("TSEmphasis", s:nord4_gui, "", "NONE", "", s:bold, "")
call s:hi("TSEnviroment", s:nord4_gui, "", "NONE", "", "", "")
call s:hi("TSEnviromentName", s:nord4_gui, "", "NONE", "", "", "")
hi!  link TSException          Exception
call s:hi("TSField", s:nord8_gui, "", "NONE", s:nord8_term, "", "")
hi!  link TSFloat              Float
hi!  link TSFunction           Function
call s:h("TSFuncBuiltin", {"fg": s:cyan})
call s:hi("TSFuncMacro", s:nord4_gui, "", "NONE", "", "NONE", "")
hi!  link TSInclude            Include
hi!  link TSKeyword            Keyword
hi!  link TSKeywordFunction    Keyword
hi!  link TSKeywordOperator    Keyword
hi!  link TSLabel              Label
hi!  link TSLiteral            String
call s:hi("TSMath", s:nord4_gui, "", "NONE", "", "", "")
hi!  link TSMethod             Function
hi!  link TSNamespace          Structure
" call s:hi("TSNamespace", s:nord4_gui, "", "NONE", "", "NONE", "")
call s:hi("TSNone", s:nord4_gui, "", "NONE", "", "NONE", "")
hi!  link TSNumber             Number
call s:hi("TSNote", s:nord4_gui, "", "NONE", "", "", "")
" hi!  link TSOperator           Operator
call s:hi("TSOperator", "#A1887F", "NONE", s:nord12_term, "NONE", "", "")
call s:h("TSParameter", {"fg": s:yellow})
call s:hi("TSParameterReference", s:nord4_gui, "", "NONE", "", "NONE", "")
call s:hi("TSProperty", "#c4a7e7", "", "NONE", "", "NONE", "")
call s:hi("TSPunctDelimiter", "#A1887F", "NONE", s:nord12_term, "NONE", "", "")
call s:hi("TSPunctBracket", s:nord4_gui, "", "NONE", "", "NONE", "")
hi!  link TSPunctSpecial       TSPunctDelimiter
hi!  link TSRepeat             Repeat
hi!  link TSString             String
hi!  link TSStringRegex        SpecialChar
call s:h("TSStringEscape", {"fg": s:cyan})
hi!  link TSStucture           Structure
call s:h("TSSymbol", {"fg": s:cyan})
hi!  link TSTag                Label
hi!  link TSTagDelimiter       Label
call s:hi("TSText", s:nord4_gui, "", "NONE", "", "NONE", "")
call s:hi("TSTextReference", s:nord4_gui, "", "NONE", "", "", "")
hi!  link TSTitle              Title
hi!  link TSType               Type
call s:h("TSTypeBuiltin", {"fg": s:dark_yellow})
hi!  link TSUnderline          Underlined
hi!  link TSURI                Underlined
hi!  link TSVariable           Variable
call s:h("TSVariableBuiltin", {"fg": s:yellow})
hi!  link TSWarning            WarningMsg
" call s:hi("TSError", s:nord4_gui, s:nord11_gui, "", s:nord11_term, s:bold, "")
hi!  link TSError             Error
hi!  link TSDanger             ErrorMsg

" }}} nvim-treesitter/nvim-treesitter

" lukas-reineke/indent-blankline.nvim {{{
hi! link IndentBlanklineChar SignColorm
call s:hi("IndentBlanklineContextChar", s:nord8_gui, "", s:nord8_term, "", "", "")
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
call s:hi("NvimTreeSymlink",    s:nord4_gui, s:nord0_gui, "NONE",       "NONE", "", "")
hi! link NvimTreeFolderName      Normal
call s:hi("NvimTreeRootFolder", s:nord10_gui, "",          s:nord10_term, "",     s:bold, "")
hi! link NvimTreeFolderIcon      Normal
hi! link NvimTreeEmptyFolderName Normal
call s:hi("NvimTreeOpenedFolderName", s:nord6_gui, s:nord8_gui, s:nord6_term, s:nord8_term, "",       "")
call s:hi("NvimTreeExecFile",         s:nord4_gui, s:nord0_gui, "NONE",       "",           s:italic, "")
hi! link NvimTreeOpenedFile   NvimTreeOpenedFolderName
hi! link NvimTreeSpecialFile  Normal
hi! link NvimTreeImageFile    Normal
hi! link NvimTreeMarkdownFile Normal
hi! link NvimTreeIndentMarker NvimTreeRootFolder

hi! link LspDiagnosticsError       LspDiagnosticsDefaultError
hi! link LspDiagnosticsWarning     LspDiagnosticsDefaultWarning
hi! link LspDiagnosticsInformation LspDiagnosticsDefaultInformation
hi! link LspDiagnosticsHint        LspDiagnosticsDefaultHint

call s:hi("NvimTreeGitDirty",   s:nord13_gui, "", s:nord13_term, "", "", "")
call s:hi("NvimTreeGitRenamed", s:nord13_gui, "", s:nord13_term, "", "", "")
call s:hi("NvimTreeGitStaged",  s:nord12_gui, "", s:nord12_term, "", "", "")
call s:hi("NvimTreeGitMerge",   s:nord15_gui, "", s:nord15_term, "", "", "")
call s:hi("NvimTreeGitNew",     s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("NvimTreeGitDeleted", s:nord11_gui, "", s:nord11_term, "", "", "")
hi! link NvimTreeFileDirty   NvimTreeGitDirty
hi! link NvimTreeFileRenamed NvimTreeGitRenamed
hi! link NvimTreeFileStaged  NvimTreeGitStaged
hi! link NvimTreeFileMerge   NvimTreeGitMerge
hi! link NvimTreeFileNew     NvimTreeGitNew
hi! link NvimTreeFileDeleted NvimTreeGitDeleted

" call s:hi("NvimTreeSpecialFile", s:nord3_gui_bright, "", s:nord3_term,  "", s:italicize_comments, "")
" call s:hi("NvimTreePopup",       s:nord4_gui,       "", s:nord4_term, "", "",                   "")
" call s:hi("NvimTreeNormal",      s:nord4_gui,       "", s:nord4_term, "", "",                   "")
" }}} kyazdani42/nvim-tree.lua

" Pandoc {{{
" > vim-pandoc/vim-pandoc-syntax
call s:hi("pandocDefinitionBlockTerm", s:nord7_gui, "", s:nord7_term, "", s:italic, "")
call s:hi("pandocTableDelims", s:nord3_gui, "", s:nord3_term, "", "", "")
hi! link pandocAtxHeader           markdownH1
hi! link pandocBlockQuote          markdownBlockquote
hi! link pandocCiteAnchor          Operator
hi! link pandocCiteKey             pandocReferenceLabel
hi! link pandocDefinitionBlockMark Operator
hi! link pandocEmphasis            markdownItalic
hi! link pandocFootnoteID          pandocReferenceLabel
hi! link pandocFootnoteIDHead      markdownLinkDelimiter
hi! link pandocFootnoteIDTail      pandocFootnoteIDHead
hi! link pandocGridTableDelims     pandocTableDelims
hi! link pandocGridTableHeader     pandocTableDelims
hi! link pandocOperator            Operator
hi! link pandocPipeTableDelims     pandocTableDelims
hi! link pandocReferenceDefinition pandocReferenceLabel
hi! link pandocReferenceLabel      markdownLinkText
hi! link pandocReferenceURL        markdownUrl
hi! link pandocSimpleTableHeader   pandocAtxHeader
hi! link pandocStrong              markdownBold
hi! link pandocTableHeaderWord     pandocAtxHeader
hi! link pandocUListItemBullet     Operator
" }}} Pandoc

" lewis6991/gitsigns.nvim {{{
call s:hi("GitSignsAdd",    s:nord14_gui, "", s:nord14_term, "", "", "")
call s:hi("GitSignsChange", s:nord13_gui, "", s:nord13_term, "", "", "")
call s:hi("GitSignsDelete", s:nord11_gui, "", s:nord11_term, "", "", "")
" }}} lewis6991/gitsigns.nvim

" HistoryStartup {{{
call s:hi("HistoryStartupCreate",   s:nord10_gui, "", s:nord10_term, "", s:bold,   "")
call s:hi("HistoryStartupFileRoot", s:nord8_gui,  "", s:nord8_term,  "", s:italic, "")
" }}} HistoryStartup

hi! link illuminatedWord LspReferenceWrite

