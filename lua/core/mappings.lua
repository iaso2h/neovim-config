local M    = {}

-- NOTE: Mapping is always recursive unless noremap is specified

-- First thing first
vim.g.mapleader = " "

-- Change font size (GUI client only)
if not isTerm then
    map({"n", "x"}, [[<C-->]], [[:lua GuiFontSize = GuiFontSize - 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]],    {"silent"}, "Increase GUI client font size")
    map({"n", "x"}, [[<C-=>]], [[:lua GuiFontSize = GuiFontSize + 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]],    {"silent"}, "Decrease GUI client font size")
    map({"n", "x"}, [[<C-0>]], [[:lua GuiFontSize = GuiFontSizeDefault; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]], {"silent"}, "Restore GUI client font size")
end
-- Diffmode
map("n", [[[d]], [[[c]], {"noremap", "silent"}, "Go to the previous start of a change")
map("n", [[]d]], [[]c]], {"noremap", "silent"}, "Go to the next start of a change")
-- Colorcolumn
map("n", [[]c]], [[:noa windo set cc=80<CR>]], {"silent"}, "Turn on colorcolumn")
map("n", [[[c]], [[:noa windo set cc&<CR>]],   {"silent"}, "Turn off colorcolumn")
-- Quickfix
map("n", [[<C-q>g]],    [[:cfirst<CR>zzzv]],    {"silent"}, "Go to first item in quickFix")
map("n", [[<C-q>G]],    [[:clast<CR>zzzv]],     {"silent"}, "Go to last item in quickFix")
map("n", [[<C-q>n]],    [[:cnext<CR>zzzv]],     {"silent"}, "Go to next item in quickFix")
map("n", [[<C-q>N]],    [[:cprevious<CR>zzzv]], {"silent"}, "Go to previous item in quickFix")
map("n", [[<C-q>l]],    [[:cnfile<CR>]],        {"silent"}, "Go to next file in quickFix")
map("n", [[<C-q>h]],    [[:cpfile<CR>]],        {"silent"}, "Go to previous file in quickFix")
map("n", [[<leader>q]], [[:lua require("buf").quickfixToggle()<CR>]], {"silent"}, "Quickfix toggle")
-- Spell corretion
map("n", [[\\]], [[z=1<CR><CR>]], {"silent"}, "Quick spell fix")
-- Expand region
map("n", [[<A-a>]], [[:lua require("expandRegion").expandShrink("n", 1)<CR>]],  {"silent"}, "Expand selection")
map("n", [[<A-s>]], [[<Nop>]], "which_key_ignore")
map("x", [[<A-a>]], [[:lua require("expandRegion").expandShrink(vim.fn.visualmode(), 1)<CR>]],  {"silent"}, "Expand selection")
map("x", [[<A-s>]], [[:lua require("expandRegion").expandShrink(vim.fn.visualmode(), -1)<CR>]], {"silent"}, "Shrink selection")
-- Interesting word {{{
map("n", [[<Plug>InterestingWordOperator]], function ()
        return vim.fn.luaeval[[
        require("operator").expr(require("interestingWord").operator,
        false,
        "<Plug>InterestingWordOperator")
        ]]
end, {"expr", "silent"}, "Interesting word operator")

map("x", [[<Plug>InterestingWordVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisual");
    require("interestingWord").operator(vMotion)<CR>]],
{"silent"}, "Mark selected as interesting words")

map("n", [[<Plug>InterestingWordVisual]], function ()
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisual", vim.v.register)
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true)
    table.insert(vMotion, "<Plug>InterestingWordVisual")
    require("interestingWord").operator(vMotion)
end, {"silent"}, "Visual-repeat for interesting words")

map("n", [[gw]],        [[<Plug>InterestingWordOperator]], "Highlight interesting word...")
map("x", [[gw]],        [[<Plug>InterestingWordVisual]],   "Highlight selected as interesting words")
map("n", [[gww]],       [[:lua require("interestingWord").reapplyColor()<CR>]], {"silent"}, "Recolor last interesting word")
map("n", [[<leader>w]], [[:lua require("interestingWord").clearColor()<CR>]],   {"silent"}, "Clear interesting word")
map("n", [[<leader>W]], [[:lua require("interestingWord").restoreColor()<CR>]], {"silent"}, "Restore interesting word")
-- }}} Interesting word
-- Zeal query {{{
map("n", [[<Plug>ZealOperator]], function ()
    return vim.fn.luaeval[[
    require("operator").expr(
        require("zeal").zeal,
        false,
        "<Plug>ZealOperator")
    ]]
end, {"silent", "expr"}, "Zeal look up operator")

map("n", [[<Plug>ZealOperatorGlobal]], function ()
    return vim.fn.luaeval[[
    require("operator").expr{
        require("zeal").zealGlobal,
        false,
        "<Plug>ZealOperatorGlobal"}
    ]]
end, {"silent", "expr"}, "Zeal look up universally operator")

map("x", [[<Plug>ZealVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ZealVisual");
    require("zeal").zeal(vMotion)<CR>]],
{"silent"}, "Zeal look up selected")

map("n", [[<Plug>ZealVisual]], function ()
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register)
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true)
    table.insert(vMotion, "<Plug>ZealVisual")
    require("zeal").zeal(vMotion)
end, {"silent"}, "Zeal look up selected")

map("n", [[gz]], [[<Plug>ZealOperator]],       "Zeal look up...")
map("n", [[gZ]], [[<Plug>ZealOperatorGlobal]], "Zeal look up...universally")
map("x", [[Z]],  [[<Plug>ZealVisual]], "Zeal look up selected")
-- }}} Zeal query
-- Substitue selected
map("x", [[<C-s>]], [[:lua require("selection").visualSub()<CR>]],        {"silent"}, "Substitue selected in command line")
-- HistoryStartup
map("n", [[<C-s>]], [[:lua require("historyStartup").display(true)<CR>]], {"silent"}, "Enter HistoryStartup")
-- Extraction {{{
-- map("n", [[<Plug>RefactorOperator]], function ()
    -- return vim.fn.luaeval [[require("RefactorOperator").expr()]]
-- end, {"silent", "expr"}, "Refactor operator")
map("n", [[<Plug>Extract]], function ()
    return vim.fn.luaeval[[
    require("operator").expr(
        require("extraction").operator,
        false,
        "<Plug>Extract")
    ]]
end, {"silent", "expr"}, "Extract operator")
map("n", [[gf]], [[<Plug>Extract]], "Extract operator")
map("n", [[gF]], [[gf]], {"noremap"}, "Go to file")
-- }}} Extraction
map("n", [[<C-g>]],
[[:lua print(" " .. vim.api.nvim_exec("file!", true) .. " 🖵  CWD: " .. vim.fn.getcwd())<CR>]],
{"silent"}, "Display file info")
map("n", [[<S-Tab>]], [[:lua require("tabSwitcher").main()<CR>]], "Change tab size")
-- Delete & Change & Replace {{{
-- Delete
map("n", [[dj]], [[<Nop>]], "which_key_ignore")
map("n", [[dk]], [[<Nop>]], "which_key_ignore")
map("n", [[<Plug>DeleteUnderForward]],
    [[:lua require("changeUnder").init("diw", 1, "<Plug>DeleteUnderForward")<CR>]],
    {"silent"}, "Delete the whold word under curosr, then highlight it forward")
map("n", [[<Plug>DeleteUnderBackward]],
    [[:lua require("changeUnder").init("diw", 0, "<Plug>DeleteUnderBackward")<CR>]],
    {"silent"}, "Delete the whold word under curosr, then highlight it backward")
map("n", [[dn]], [[<Plug>DeleteUnderForward]], "Delete the whold word under curosr, then highlight it forward")
map("n", [[dN]], [[<Plug>DeleteUnderBackward]], "Delete the whold word under curosr, then highlight it backward")
map("n", [[d<Space>]], [[<CMD>call setline(".", "")<CR>]],  {"silent"}, "Empty current line,")
-- Change under cursor
map("n", [[cn]], [[v:hlsearch? "cgn" : "g*``cgn"]], {"noremap", "expr"}, "Change whole word under cursor, then highlight it forward")
map("n", [[cN]], [[v:hlsearch? "cgN" : "g#``cgN"]], {"noremap", "expr"}, "Change whole word under cursor, then highlight it backward")
-- Replace
map("n", [[<Plug>ReplaceOperatorInplace]], function ()
    return vim.fn.luaeval [[require("replace").expr(true)]]
end, {"silent", "expr"}, "Replace operator and restore the cursor position")

map("n", [[<Plug>ReplaceOperator]], function ()
    return vim.fn.luaeval [[require("replace").expr(false)]]
end, {"silent", "expr"}, "Replace operator")

map("n", [[<Plug>ReplaceExpr]],
    [[<CMD>let g:ReplaceExpr=getreg("=")<Bar>exec "norm!" . v:count1 . "."<CR>]],
    {"silent"}, "Replace expression"
)

map("n", [[<Plug>ReplaceCurLine]], function ()
    require("replace").saveCountReg()

    vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register)

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end

    require("replace").operator{"line", "V", "<Plug>ReplaceCurLine", true}
end, {"noremap", "silent"}, "Replace current line")

-- NOTE: function passed in to arg will ignore current selected region

-- map("x", [[<Plug>ReplaceVisual]], function ()
    -- require("replace").saveCountReg()

    -- vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register)

    -- if require("replace").regType == "=" then
        -- vim.g.ReplaceExpr = vim.fn.getreg("=")
    -- end

    -- local vMotion = require("operator").vMotion(false)
    -- table.insert(vMotion, "<Plug>ReplaceVisual")
    -- require("replace").operator(vMotion)
-- end, {"noremap", "silent"}, "Replace selected")

map("x", [[<Plug>ReplaceVisual]],
    luaRHS[[
    :lua require("replace").saveCountReg();

    vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end;

    local vMotion = require("operator").vMotion(false);
    table.insert(vMotion, "<Plug>ReplaceVisual");
    require("replace").operator(vMotion)<CR>
    ]],
    {"noremap", "silent"}, "Replace selected")

map("n", [[<Plug>ReplaceVisual]], function ()
    require("replace").saveCountReg()

    vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register)

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end

    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(false)
    table.insert(vMotion, "<Plug>ReplaceVisual")
    require("replace").operator(vMotion)
end, {"noremap", "silent"}, "Visual-repeat for replaced selected")

map("n", [[gr]],  [[<Plug>ReplaceOperatorInplace]], "Replace operator and restore the cursor position")
map("n", [[gru]], [[<Plug>ReplaceOperator]],        "Replace operator")
map("n", [[grr]], [[<Plug>ReplaceCurLine]],         "Replace current line")
map("x", [[R]],   [[<Plug>ReplaceVisual]],          "Replace selected")
-- TODO: replaceWordUnderCarret

map("n", [[<Plug>ReplaceUnderForward]],
    [[:lua require("changeUnder").init("gruiw", 1, "<Plug>ReplaceUnderForward")<CR>]],
    {"silent"}, "Replace the whold word under curosr, then highlight it forward")
map("n", [[<Plug>ReplaceUnderBackward]],
    [[:lua require("changeUnder").init("gruiw", 0, "<Plug>ReplaceUnderBackward")<CR>]],
    {"silent"}, "Replace the whold word under curosr, then highlight it backward")
map("n", [[grn]], [[<Plug>ReplaceUnderForward]], "Replace the whold word under curosr, then highlight it forward")
map("n", [[grN]], [[<Plug>ReplaceUnderBackward]], "Replace the whold word under curosr, then highlight it backward")
-- }}} Delete & Change & Replace
-- Search & Jumping {{{
-- In case of mistouching
-- Inquery word
map("n", [[<leader>i]], [=[[I]=], "Inquery word under cursor")
map("x", [[<leader>i]], [[:lua vim.cmd("noa g#\\V" .. string.gsub(require("selection").getSelect("string", false), "\\", "\\\\") .. "#number")<CR>]], {"silent"}, "Inquery selected words")
-- Fast mark resotre
map("n", [[M]], [[<CMD>lua require("searchHop").centerHop("`m", false)<CR>]], "Restore mark M")
-- Changelist/Jumplist jumping
map("n", [[<A-o>]], [[<CMD>lua require("searchHop").centerHop("g;", false, false)<CR>]], {"silent"}, "Older change")
map("n", [[<A-i>]], [[<CMD>lua require("searchHop").centerHop("g,", false, false)<CR>]], {"silent"}, "Newer change")
map("n", [[<C-o>]], [[<CMD>lua require("searchHop").centerHop("<C-o>", true, false)<CR>]], {"silent"}, "Older jump")
map("n", [[<C-i>]], [[<CMD>lua require("searchHop").centerHop("<C-i>", true, false)<CR>]], {"silent"}, "Newer jump")
-- Swap default mapping
map("n", [[*]],  [[g*zv:lua require("searchHop").echoSearch()<CR>]], {"noremap", "silent"}, "Search <cword> forward")
map("n", [[#]],  [[g#zv:lua require("searchHop").echoSearch()<CR>]], {"noremap", "silent"}, "Search <cword> back")
map("n", [[g#]], [[#zv:lua require("searchHop").echoSearch()<CR>]],  {"noremap", "silent"}, "Search <cWORD> forward")
map("n", [[g*]], [[*zv:lua require("searchHop").echoSearch()<CR>]],  {"noremap", "silent"}, "Search <cWORD> forward")
-- Search visual selected
map("x", [[/]], [[:lua require("searchHop").searchSelected("/")<CR>]], {"silent"}, "Search selected forward")
map("x", [[?]], [[:lua require("searchHop").searchSelected("?")<CR>]], {"silent"}, "Search selected backward")
map("x", [[*]], [[/]], "Search selected forward")
map("x", [[#]], [[?]], "Search selected backward")
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"}, "Search forward")
map("n", [[?]], [[?\v]], {"noremap"}, "Search backward")
map("n", [[n]], [[:lua require("searchHop").cycleSearch("n")<CR>]], {"silent"}, "Cycle through search result forward")
map("n", [[N]], [[:lua require("searchHop").cycleSearch("N")<CR>]], {"silent"}, "Cycle through search result backward")
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[<CMD>noh<CR>]], {"silent"}, "Clear highlight")
map("x", [[<leader>h]], [[<CMD>exec "norm! \<lt>Esc>"<CR>]], {"silent"}, "Disable highlight")
-- Visual selection
map("n", [[go]],    [[:lua require("selection").cornerSelection(-1)<CR>]], {"silent"}, "Go to opposite of the selection")
map({"n", "x"}, [[<A-v>]], [[<C-q>]], {"noremap"}, "Visual Block Mode")
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[<CMD>new<CR>]], {"silent"}, "New buffer")
-- Open/Search in browser
map("n", [[gl]], [[:lua require("openLink").main()<CR>]], {"silent"}, "Open link")
map("x", [[gl]], [[:lua require("openLink").main(require("selection").getSelect("string", false))<CR>]], {"silent"}, "Open selected as link")
-- Interrupt
map("n", [[<C-A-c>]], [[<CMD>call interrupt()<CR>]], {"noremap", "silent"}, "Interrupt")
-- Paragraph & Block navigation
-- map("", [[{]], [[:lua require("inclusiveParagraph").main("up")<CR>]],   {"noremap", "silent"})
-- map("", [[}]], [[:lua require("inclusiveParagraph").main("down")<CR>]], {"noremap", "silent"})
-- Line end/start
map("", [[H]], [[^]], "Start of line(non-blank)")
map("", [[L]], [[$]], "End of line")
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"}, "End of line(non-blank)")
-- Trailing character {{{
map("n", [[g.]], [[<CMD>lua require("trailingChar").main("n", ".")<CR>]],  {"silent"}, "Add trailing .")
map("x", [[g.]], [[:lua require("trailingChar").main("v", ".")<CR>]],      {"silent"}, "Add trailing .")
map("n", [[g,]], [[<CMD>lua require("trailingChar").main("n", ",")<CR>]],  {"silent"}, "Add trailing ,")
map("x", [[g,]], [[:lua require("trailingChar").main("v", ",")<CR>]],      {"silent"}, "Add trailing ,")
map("n", [[g;]], [[<CMD>lua require("trailingChar").main("n", ";")<CR>]],  {"silent"}, "Add trailing ;")
map("x", [[g;]], [[:lua require("trailingChar").main("v", ";")<CR>]],      {"silent"}, "Add trailing ;")
map("n", [[g:]], [[<CMD>lua require("trailingChar").main("n", ":")<CR>]],  {"silent"}, "Add trailing :")
map("x", [[g:]], [[:lua require("trailingChar").main("v", ":")<CR>]],      {"silent"}, "Add trailing :")
map("n", [[g"]], [[<CMD>lua require("trailingChar").main("n", "\"")<CR>]], {"silent"}, 'Add trailing "')
map("x", [[g"]], [[:lua require("trailingChar").main("v", "\"")<CR>]],     {"silent"}, 'Add trailing "')
map("n", [[g']], [[<CMD>lua require("trailingChar").main("n", "'")<CR>]],  {"silent"}, "Add trailing '")
map("x", [[g']], [[:lua require("trailingChar").main("v", "'")<CR>]],      {"silent"}, "Add trailing '")
map("n", [[g(]], [[<CMD>lua require("trailingChar").main("n", "(")<CR>]],  {"silent"}, "Add trailing (")
map("x", [[g(]], [[:lua require("trailingChar").main("v", "(")<CR>]],      {"silent"}, "Add trailing (")
map("n", [[g)]], [[<CMD>lua require("trailingChar").main("n", ")")<CR>]],  {"silent"}, "Add trailing )")
map("x", [[g)]], [[:lua require("trailingChar").main("v", ")")<CR>]],      {"silent"}, "Add trailing )")
map("n", [[g<C-CR>]], [[<CMD>call append(line("."),   repeat([""], v:count1))<CR>]], {"silent"}, "Add new line below")
map("n", [[g<S-CR>]], [[<CMD>call append(line(".")-1, repeat([""], v:count1))<CR>]], {"silent"}, "Add new line above")
map("n", [[g<CR>]],   [[<CMD>lua require("breakLine").main()<CR>]], {"silent"}, "Break line at cursor")
-- }}} Trailing character

-- Pageup/Pagedown
map({"n", "x"}, [[<C-f>]], [[<Nop>]], "which_key_ignore")
map("",         [[<C-h>]], [[<Nop>]], "which_key_ignore")
map({"n", "x"}, [[<C-e>]], [[<C-y>]], {"noremap"}, "Scroll up")
map({"n", "x"}, [[<C-d>]], [[<C-e>]], {"noremap"}, "Scroll down")
map("t", [[<C-e>]], [[<C-\><C-n><C-y>]], "Scroll up")
map("t", [[<C-d>]], [[<C-\><C-n><C-d>]], "Scroll down")

map({"n", "x"}, [[%]], [[M]], {"noremap"}, "Jump to the middle of the screen")

map({"n", "x"}, [[<A-e>]], [[<PageUp>]],      "Scroll one window up")
map({"n", "x"}, [[<A-d>]], [[<PageDown>]],    "Scroll one window down")
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]],   "Scroll one window up")
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]], "Scroll one window down")

-- Macro
map("n", [[<A-q>]], [[q]], {"noremap"}, "Macro")

-- Messages
map("n", [[g>]], [[<CMD>messages<CR>]], {"silent"}, "Clear messages")
map("n", [[<leader>,]], [[<CMD>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")
map("n", [[<leader>.]], [[<CMD>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")

-- Register
map({"n", "x"}, [[<leader>']], [[:lua require("register").clear()<CR>]], {"silent"}, "Clear registers")
map({"n", "x"}, [[g']], [[<CMD>reg<CR>]], {"silent"}, "Registers in prompt");
map("i", [[<C-r><C-r>]], [[<C-\><C-o>:lua require("register").insertPrompt()<CR>]], {"silent"}, "Registers in prompt")

-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]],     [[:lua require("buf").close("window")<CR>]],    {"silent"}, "Close window")
map("n", [[Q]],     [[:lua require("buf").close("buffer")<CR>]],    {"silent"}, "Close buffer")
map("n", [[<C-u>]], [[:lua require("buf").restoreClosedBuf()<CR>]], {"silent"}, "Restore last closed buffer")
-- Window
-- TODO:
-- map("n", [[<C-w>s]], [[:lua require("consistantTab").splitCopy("wincmd s")<CR>]], {"silent"})
-- map("n", [[<C-w>v]], [[:lua require("consistantTab").splitCopy("wincmd v")<CR>]], {"silent"})
map("n", [[<C-w>V]], [[<CMD>wincmd o | wincmd v<CR>]], {"silent"}, "Split only current window vertically")
map("n", [[<C-w>S]], [[<CMD>wincmd o | wincmd s<CR>]], {"silent"}, "Split only current window vertically")

map("n",        [[<C-w>t]], [[<CMD>tabnew<CR>]],         {"silent"}, "New tab")
map({"n", "x"}, [[<A-=>]],  [[<CMD>wincmd +<CR>]],       {"silent"}, "Increase window size")
map("i",        [[<A-=>]],  [[<C-\><C-O>:wincmd +<CR>]], {"silent"}, "Increase window size")
map({"n", "x"}, [[<A-->]],  [[<CMD>wincmd -<CR>]],       {"silent"}, "Decrease window size")
map("i",        [[<A-->]],  [[<C-\><C-O>:wincmd -<CR>]], {"silent"}, "Decrease window size")

-- Buffers
map("n", [[<C-w>O]], [[:lua require("buf").closeOther()<CR>]], {"silent"}, "Wipe other buffer")
map("n", [[<C-Tab>]],   [[<CMD>lua require("buf.action.cycle").init(1)<CR>]],  {"silent"}, "Next buffer")
map("n", [[<C-S-Tab>]], [[<CMD>lua require("buf.action.cycle").init(-1)<CR>]], {"silent"}, "Previous buffer")
map("n", [[<A-h>]],     [[<CMD>lua require("buf.action.cycle").init(-1)<CR>]], {"silent"}, "Previous buffer")
map("n", [[<A-l>]],     [[<CMD>lua require("buf.action.cycle").init(1)<CR>]],  {"silent"}, "Next buffer")
-- Tab
map({"n", "x"}, [[<C-t>%]], [[<CMD>tabnew %<CR>]], {"silent"}, "New tab showing current buffer")
map({"n", "x"}, [[<C-t>n]], [[<CMD>tabnew<CR>]],   {"silent"}, "New tab")
map({"n", "x"}, [[<C-t>h]], [[<CMD>tabp<CR>]],     {"silent"}, "Previous tab")
map({"n", "x"}, [[<C-t>l]], [[<CMD>tabn<CR>]],     {"silent"}, "Next tab")
map({"n", "x"}, [[<C-t>o]], [[<CMD>tabonly<CR>]],  {"silent"}, "Tab only")
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[zj]], [[<Nop>]], "which_key_ignore")
map("",  [[zk]], [[<Nop>]], "which_key_ignore")
map("",  [[[Z]], [[zk]], {"noremap"}, "Previous fold(integral)")
map("",  [[]Z]], [[zj]], {"noremap"}, "Next fold(integral)")
-- TODO: record in jumplist
map("",  [[[z]], [[<CMD>call EnhanceFoldJump("previous", 1, 0)<CR>]], {"silent", "noremap"}, "Previous fold")
map("",  [[[z]], [[<CMD>call EnhanceFoldJump("previous", 1, 0)<CR>]], {"silent", "noremap"}, "Previous fold")
map("",  [[]z]], [[<CMD>call EnhanceFoldJump("next",     1, 0)<CR>]], {"silent", "noremap"}, "Next fold")
map("n", [[dz]], [[<CMD>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent"}, "Delete fold")
map("n", [[zd]], [[<CMD>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent"}, "Delete fold")
map("n", [[cz]], [[<CMD>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent"}, "Change fold")
map("n", [[zc]], [[<CMD>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent"}, "Change fold")
map("n", [[g{]], [[<CMD>lua require("trailingChar").main("n", "{")<CR>]], {"silent"}, "Add fold marker start")
map("x", [[g{]], [[:lua require("trailingChar").main("v", "{")<CR>]],     {"silent"}, "Add fold marker start")
map("n", [[g}]], [[<CMD>lua require("trailingChar").main("n", "}")<CR>]], {"silent"}, "Add fold marker end")
map("x", [[g}]], [[:lua require("trailingChar").main("v", "}")<CR>]],     {"silent"}, "Add fold marker end")

map("", [[<leader>z]], [[<CMD>call EnhanceFoldHL("No fold marker found", 500, "")<CR>]], {"silent"}, "Highlight current fold marker")
map("", [[zm]], [[zMzz]], {"noremap"}, "Close all folds recursively")
map("", [[zr]], [[zRzz]], {"noremap"}, "Open all folds recursively")
map("", [[zM]], [[zmzz]], {"noremap"}, "Close folds recursively")
map("", [[zR]], [[zrzz]], {"noremap"}, "Open folds recursively")
map("", [[zA]], [[za]],   {"noremap"}, "Toggle current fold")
map("", [[za]],
    [[:lua require("snapToFold").main("norm! zA", true, 0.5)<CR>]],
    {"silent"}, "Snap to closest fold then toggle it recursively")
map("",  [[<leader><Space>]],
    [[:lua require("snapToFold").main("norm! za", true, 0.5)<CR>]],
    {"silent"}, "Snap to closest fold then toggle it")
for i=0, 9 do
    map({"n", "x"},
        string.format("z%d", i),
        string.format([[:set foldlevel=%d<Bar>echohl Moremsg<Bar>echo 'Foldlevel set to: %d'<Bar>echohl None<CR>]], i, i),
        string.format("Set fold level to %d", i)
    )
end
-- }}} Folding
-- MS behavior {{{
-- Paste mode
map({"i","n"}, [[<F3>]], function ()
    if vim.o.paste then
        vim.api.nvim_echo({{"Paste mode off", "Moremsg"}}, false, {})
        vim.opt.paste = false
    else
        vim.api.nvim_echo({{"Paste mode on", "Moremsg"}}, false, {})
        vim.opt.paste = true
    end
end, "Toogle paste mode")

-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]], "Undo") -- test
map("x", [[<C-z>]], [[<esc>u]], "Undo")
map("i", [[<C-z>]], [[<C-\><C-o>u]], "Undo")

map("n", [[<C-c>]], [[Y]], "Yank")
map("x", [[<C-c>]], [[y]], "Yank")
-- map("i", [[<C-c>]], [[<C-\><C-o>Y]], "Yank")

map("n", [[<C-v>]], [[p]], {"noremap"}, "Put")
map("x", [[<C-v>]], [[<esc>i<C-v><esc>]], "Put")
map("i", [[<C-v>]], [[<C-r>*]], "Put")

-- map("n", [[<C-s>]], [[<CMD>w<CR>]], "Write")
-- map("x", [[<C-s>]], [[<CMD>w<CR>]], "Write")
map("i", [[<C-s>]], [[<C-\><C-o>:w<CR>]], "Write")
-- }}} <C-z/x/v/s>
-- Save as..
vim.cmd [[command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<CR> | e!]]
map("n", [[<C-S-s>]], [[<CMD>Saveas<CR>]],       {"silent"}, "Save as")
map("i", [[<C-S-s>]], [[<C-\><C-o>:Saveas<CR>]], {"silent"}, "Save as")
-- Delete
map("n", [[<C-S-d>]], [[<CMD>d<CR>]],       {"silent"}, "Detele line")
map("x", [[<C-S-d>]], [[:d<CR>]],           {"silent"}, "Detele line")
map("i", [[<C-S-d>]], [[<C-\><C-o>:d<CR>]], {"silent"}, "Detele line")
-- Highlight New Paste Content
map("n", [[gy]], [[:lua require("yankPut").lastYankPut("yank")<CR>]], {"silent"}, "Select last yank")
map("n", [[gY]], [[gy]], "Select last yank")
map("n", [[gp]], [[:lua require("yankPut").lastYankPut("put")<CR>]],  {"silent"}, "Select last put")
map("n", [[gP]], [[gp]], "Select last put")
-- Inplace join
map("n", [[J]], function ()
    vim.cmd("norm! m`" .. vim.v.count1 .. "J``")
end, {"noremap"}, "Join line")
-- Inplace yank
map("", [[<Plug>InplaceYank]], function ()
   return vim.fn.luaeval[[require("operator").expr(require("yankPut").inplaceYank, false, "<Plug>InplaceYank")]]
end, {"expr", "silent"}, "Yank operator")

map("", [[y]], [[<Plug>InplaceYank]], "Yank operator")
map({"n", "x"}, [[Y]], [[yy]], "Yank line")
-- Inplace put
map("n", [[p]], [[:lua require("yankPut").inplacePut("n", "p", false)<CR>]], {"silent"}, "Put after")
map("x", [[p]], [[:lua require("yankPut").inplacePut("v", "p", false)<CR>]], {"silent"}, "Put after")
map("n", [[P]], [[:lua require("yankPut").inplacePut("n", "P", false)<CR>]], {"silent"}, "Put before")
map("x", [[P]], [[:lua require("yankPut").inplacePut("v", "P", false)<CR>]], {"silent"}, "Put before")
-- Convert put
map("n", [[cp]], [[:lua require("yankPut").inplacePut("n", "p", true)<CR>]], {"silent"}, "Convert put after")
map("n", [[cP]], [[:lua require("yankPut").inplacePut("n", "P", true)<CR>]], {"silent"}, "Convert put before")
-- Put from registers 0
map("n", [[<leader>p]],  [["0p]],  "Put after from register 0")
map("n", [[<leader>P]],  [["0P]],  "Put after from register 0")
map("n", [[<leader>cp]], [["0cp]], "Convert put after from register 0")
map("n", [[<leader>cP]], [["0cP]], "Convert put after from register 0")
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
map("i", [[<A-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineMove("n", "down")<CR>]], {"silent"}, "Move line down")
map("i", [[<A-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],   {"silent"}, "Move line up")
map("n", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("n", "down")<CR>]], {"silent"}, "Move line down")
map("n", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],   {"silent"}, "Move line up")
map("x", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<CR>]], {"silent"}, "Move line down")
map("x", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<CR>]],   {"silent"}, "Move line up")
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],       {"silent"}, "Copy line down")
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],         {"silent"}, "Copy line up")
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],                 {"silent"}, "Copy line down")
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],                   {"silent"}, "Copy line up")
map("x", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<CR>]], {"silent"}, "Copy line down")
map("x", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<CR>]],   {"silent"}, "Copy line up")
-- }}} Mimic the VSCode move/copy line up/down behavior

-- }}} MS bebhave

-- Convert \ into /
map("n", [[g/]], [[m`:s#\\#\/#e<CR>:noh<CR>g``]],   {"noremap", "silent"}, [[Convert \ to /]])
map("n", [[g\]], [[m`:s#\/#\\\\#e<CR>:noh<CR>g``]], {"noremap", "silent"}, [[Convert / to \]])
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]], "Enter Normal mode")
map("n", [[<C-`>]],      [[:lua require("terminal").terminalToggle()<CR>]], {"silent"}, "Terminal toggle")
map("n", [[<leader>t]],  [[:lua require("terminal").terminalToggle()<CR>]], {"silent"}, "Terminal toggle")
map("t", [[<C-`>]],      [[<A-n>:lua require("terminal").terminalToggle()<CR>]], {"silent"}, "Toggle Terminal")
map("t", [[<A-h>]],      [[<A-n><A-h>]], "Previous buffer")
map("t", [[<A-l>]],      [[<A-n><A-l>]], "Next buffer")
map("t", [[<A-C-h>]],    [[<A-n><A-C-h>]], "Previous tab")
map("t", [[<A-C-l>]],    [[<A-n><A-C-l>]], "Next tab")
map("t", [[<C-BS>]],     [[<C-w>]], {"noremap"}, "Delete word before")
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], {"expr"}, "Insert from register")
map("t", [[<C-w>k]],     [[<A-n><C-w>k]], "Window above")
map("t", [[<C-w>j]],     [[<A-n><C-w>j]], "Window below")
map("t", [[<C-w>h]],     [[<A-n><C-w>h]], "Window left")
map("t", [[<C-w>l]],     [[<A-n><C-w>l]], "Window right")
map("t", [[<C-w>w]],     [[<A-n><C-w>w]], "Next window")
map("t", [[<C-w>W]],     [[<A-n><C-w>W:startinsert<CR>]], {"silent"}, "Previous window")
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]], "Next window")
map("t", [[<C-w>=]],     [[<A-n><C-w>=:startinsert<CR>]], {"silent"}, "Make all window equal")
map("t", [[<C-w>o]],     [[<A-n><C-w>o:startinsert<CR>]], {"silent"}, "Close other windows")
map("t", [[<C-w>H]],     [[<A-n><C-w>H:startinsert<CR>]], {"silent"}, "Move the current window to the far left")
map("t", [[<C-w>L]],     [[<A-n><C-w>L:startinsert<CR>]], {"silent"}, "Move the current window to the far right")
map("t", [[<C-w>J]],     [[<A-n><C-w>J:startinsert<CR>]], {"silent"}, "Move the current window to the bottommost left")
map("t", [[<C-w>K]],     [[<A-n><C-w>K:startinsert<CR>]], {"silent"}, "Move the current window to the topmost left")
-- TODO: Split terminal in new instance
-- }}} Mode: Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<S-Tab>]], [[<C-d>]], {"noremap"}, "Delete indent")
map("i", [[<A-[>]],   [[<C-d>]], {"noremap"}, "Delete indent")
map("i", [[<A-]>]],   [[<C-t>]], {"noremap"}, "Add indent")
map("i", [[<C-k>]],  [[pumvisible() ? "\<C-e>\<Up>" : "\<Up>"]],     {"noremap", "expr"}, "Move cursor up")
map("i", [[<C-j>]],  [[pumvisible() ? "\<C-e>\<Down>" : "\<Down>"]], {"noremap", "expr"}, "Move cursor down")
map("i", [[<C-CR>]], [[pumvisible() ? "\<C-e>\<CR>" : "\<CR>"]],     {"noremap", "expr"}, "Add new line below")
map("i", [[<S-CR>]], [[<ESC>O]], "Add new line above")
map("i", [[<C-.>]],  [[<C-a>]], "Insert previous insert character")
map("i", [[<C-BS>]], [[<C-w>]], {"noremap"}, "Delete word before")
map("i", [[<C-y>]],  [[pumvisible() ? "\<C-e>\<C-y>" : "\<C-y>"]], {"noremap", "expr"}, "Insert character from above")
map("i", [[<A-y>]],  [[<C-x><C-l>]], {"noremap"}, "Insert from sentence")
map("i", [[,]], [[,<C-g>u]], {"noremap"}, "which_key_ignore")
map("i", [[.]], [[.<C-g>u]], {"noremap"}, "which_key_ignore")
map("i", [[!]], [[!<C-g>u]], {"noremap"}, "which_key_ignore")
map("i", [[*]], [[*<C-g>u]], {"noremap"}, "which_key_ignore")
-- Navigation {{{
map("!", [[<C-a>]], [[<Home>]],    "Move cursor to the start")
map("!", [[<C-e>]], [[<End>]],     "Move cursor to the end")
map("!", [[<C-h>]], [[<Left>]],    "Move cursor to one character left")
map("!", [[<C-l>]], [[<Right>]],   "Move cursor to one character right")
map("!", [[<C-b>]], [[<C-Left>]],  "Move cursor to one word backward")
map("!", [[<C-d>]], [[<Del>]],     "Delete character to the right")
map("!", [[<C-w>]], [[<C-Right>]], "Move cursor to one word forward")
-- }}} Navigation
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<CR>]], "Delete word before")
map("c", [[<C-j>]], [[<Down>]], "Move cursor down")
map("c", [[<C-k>]], [[<Up>]], "Move cursor up")
map("c", [[<A-l>]], [[<C-d>]],  {"noremap"}, "List more commands")
map("c", [[<A-e>]], [[<C-\>e]], {"noremap"}, "Evaluate in Vimscript")
-- }}} Mode: Commandline & Insert

return M

