local cmd  = vim.cmd
local M    = {}

-- NOTE: Mapping is always recursive unless noremap is specified

-- First thing first
vim.g.mapleader = " "

-- Change font size (GUI client only)
if not IsTerm then
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
map("n", [[<leader>q]], require("buffer").quickfixToggle, "Quickfix toggle")
-- Spell corretion
map("n", [[\\]], [[z=1<CR><CR>]], {"silent"}, "Quick spell fix")
-- Expand region
map("n", [[<A-a>]], [[:lua require("expandRegion").expandShrink("n", 1)<CR>]],  {"silent"}, "Expand selection")
map("n", [[<A-s>]], [[<Nop>]])
map("x", [[<A-a>]], [[:lua require("expandRegion").expandShrink(vim.fn.visualmode(), 1)<CR>]],  {"silent"}, "Expand selection")
map("x", [[<A-s>]], [[:lua require("expandRegion").expandShrink(vim.fn.visualmode(), -1)<CR>]], {"silent"}, "Shrink selection")
-- Run selected
map("x", [[gM]], luaRHS[[:lua vim.cmd(
    string.format("lua %s",
        luaRHS(require("selection").getSelect("string"))
    )
)<CR>]],
{"silent"}, "Run selected line in lua")
-- Interesting word {{{
map("n", [[<Plug>InterestingWordOperator]],
luaRHS[[luaeval("
    require('operator').expr(
        require('interestingWord').operator,
        false,
        '<Plug>InterestingWordOperator')
    ")
]], {"expr", "silent"}, "Interesting word operator")
map("x", [[<Plug>InterestingWordVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisual");
    require("interestingWord").operator(vMotion)<CR>]],
{"silent"}, "Mark selected as interesting words")
map("n", [[<Plug>InterestingWordVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisual", vim.v.register);
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0));

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisual");
    require("interestingWord").operator(vMotion)<CR>]],
{"silent"}, "Visual-repeat for interesting words")
map("n", [[gw]],        [[<Plug>InterestingWordOperator]], "Highlight interesting word...")
map("x", [[gw]],        [[<Plug>InterestingWordVisual]],   "Highlight selected as interesting words")
map("n", [[gww]],       require("interestingWord").reapplyColor, "Recolor last interesting word")
map("n", [[<leader>w]], require("interestingWord").clearColor,   "Clear interesting word")
map("n", [[<leader>W]], require("interestingWord").restoreColor, "Restore interesting word")
-- }}} Interesting word
-- Zeal query {{{
map("n", [[<Plug>ZealOperator]],
luaRHS[[luaeval(
    "require('operator').expr(
        require('zeal').zeal,
        false,
        '<Plug>ZealOperator')
    ")
]],
{"silent", "expr"}, "Zeal look up operator")
map("n", [[<Plug>ZealOperatorGlobal]],
luaRHS[[luaeval(
    "require('operator').expr{
        require('zeal').zealGlobal,
        false,
        '<Plug>ZealOperatorGlobal'}
    ")
]],
{"silent", "expr"}, "Zeal look up universally operator")
map("x", [[<Plug>ZealVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ZealVisual");
    require("zeal").zeal(vMotion)<CR>]],
{"silent"}, "Zeal look up selected")
map("n", [[<Plug>ZealVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register);
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0));

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ZealVisual");
    require("zeal").zeal(vMotion)<CR>]],
{"silent"}, "Zeal look up selected")
map("n", [[gz]], [[<Plug>ZealOperator]],       "Zeal look up...")
map("n", [[gZ]], [[<Plug>ZealOperatorGlobal]], "Zeal look up...universally")
map("x", [[Z]],  [[<Plug>ZealVisual]], "Zeal look up selected")
-- }}} Zeal query
-- Substitue selected
map("x", [[<C-s>]], require("selection").visualSub, "Substitue selected in command line")
-- HistoryStartup
map("n", [[<C-s>]], [[:lua require("historyStartup").display(true)<CR>]], {"silent"}, "Enter HistoryStartup")
-- Extraction
map("n", [[<Plug>Extract]],
luaRHS[[luaeval(
    "require('operator').expr(
        require('extraction').operator,
        false,
        '<Plug>Extract')
    ")
]],
{"silent", "expr"}, "Extract operator")
map("x", [[<Plug>ExtractVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ExtractVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ExtractVisual");
    require("extraction").operator(VMotion)<CR>]],
{"silent"}, "Extract selected")
map("n", [[<Plug>ExtractVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ExtractVisual", vim.v.register);
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0));

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ExtractVisual");
    require("extraction").operator(vMotion)<CR>]],
{"silent"}, "Extract selected")
map("n", [[gc]], [[<Plug>Extract]], "Extract operator")
-- TODO: implement with visualreapet?
-- map("x", [[<Plug>fallbackC]], [[<CMD>norm! gvC<CR>]])
map("x", [[C]],  [[visualmode() == "^V" ? "" : "\<Plug>ExtractVisual"]], {"expr"}, "Extract selected")
-- Print file info
map("n", [[<C-g>]],
[[:lua print(" " .. vim.api.nvim_exec("file!", true) .. " 🖵  CWD: " .. vim.fn.getcwd())<CR>]],
{"silent"}, "Display file info")
-- Tab switcher {{{
map("n", [[<S-Tab>]], require("tabSwitcher").main, "Change tab size")
-- }}} Tab switcher
-- Delete
map("n", [[dj]], [[<Nop>]])
map("n", [[dk]], [[<Nop>]])
map("n", [[dn]], [[*``dw]], {"noremap"}, "Delete word under curosr, then highlight it forward")
map("n", [[dN]], [[#``dw]], {"noremap"}, "Delete word under curosr, then highlight it backward")
map("n", [[d<Space>]], [[<CMD>call setline(".", "")<CR>]],  {"silent"}, "Empty current line,")
-- Change under cursor
map("n", [[cn]], [[*``cgn]], {"noremap"}, "Change word under cursor, then highlight it forward")
map("n", [[cN]], [[*``cgN]], {"noremap"}, "Change word under cursor, then highlight it backward")
-- Search & Jumping {{{
-- In case of mistouching
-- Inquery word
map("n", [[<leader>i]], [=[[I]=], "Inquery word under cursor")
map("x", [[<leader>i]], [[:lua Print("noa g#\\V" .. string.gsub(require("selection").getSelect("string"), "\\", "\\\\") .. "#number")<CR>]], {"silent"}, "Inquery selected words")
-- Fast mark & resotre
map("n", [[M]], [[`mzzzv]], "Restore mark M")
-- Changelist jumping
map("n", [[<A-o>]], [[:lua require("historyHop").main("changelist", -1)<CR>]], {"silent"}, "Previous change")
map("n", [[<A-i>]], [[:lua require("historyHop").main("changelist", 1)<CR>]],  {"silent"}, "Next change")
map("n", [[<C-o>]], [[<C-o>zzzv]])
map("n", [[<C-i>]], [[<C-i>zzzv]])
-- Add in jumplist for j/k with count prefix
map("n", [[j]], [[:lua require("util").addJump("j", true)<CR>]], {"silent"})
map("n", [[k]], [[:lua require("util").addJump("k", true)<CR>]], {"silent"})
-- Swap default mapping
map("n", [[*]],  [[g*``]], {"noremap"})
map("n", [[#]],  [[g#``]], {"noremap"})
map("n", [[g#]], [[#``]],  {"noremap"})
map("n", [[g*]], [[*``]],  {"noremap"})
-- Search visual selected
map("x", [[*]], [[m`<CMD>execute "/\\V" . escape(luaeval('require("selection").getSelect("string")'), '\')<CR>]], {"noremap", "silent"})
map("x", [[#]], [[m`<CMD>execute "?\\V" . escape(luaeval('require("selection").getSelect("string")'), '\')<CR>]], {"noremap", "silent"})
map("x", [[/]], [[*]])
map("x", [[?]], [[#]])
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"}, "Search forward")
map("n", [[?]], [[?\v]], {"noremap"}, "Search backward")
-- BUG: failed easily when n is search backward. Possibly fix by utilizing setcharsearch()?
map("n", [[n]], [[nzzzvhn]], {"noremap"})
map("n", [[N]], [[NzzzvlN]], {"noremap"})
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[<CMD>noh<CR>]], {"silent"}, "Clear highlight")
map("x", [[<leader>h]], [[<CMD>exec "norm! \<lt>Esc>"<CR>]], {"silent"}, "Disable highlight")
-- Visual selection
map("n", [[go]],    require("selection").oppoSelection, "Go to opposite of the selection")
map("n", [[<A-v>]], [[<C-q>]], {"noremap"}, "Visual Block Mode")
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[<CMD>new<CR>]], {"silent"}, "New buffer")
-- Open/Search in browser
map("n", [[gl]], require("openLink").main, "Open link")
map("x", [[gl]], [[:lua require("openLink").main(require("selection").getSelect("string"))<CR>]], {"silent"}, "Open selected as link")
-- Interrupt
map("n", [[<C-A-c>]], [[<CMD>call interrupt()<CR>]], {"noremap", "silent"}, "Interrupt")
-- Paragraph & Block navigation
-- map({"n", "x", "o"}, [[{]], [[:lua require("inclusiveParagraph").main("up")<CR>]],   {"noremap", "silent"})
-- map({"n", "x", "o"}, [[}]], [[:lua require("inclusiveParagraph").main("down")<CR>]], {"noremap", "silent"})
-- Line end/start
map({"n", "x", "o"}, [[H]], [[^]], "Start of line(non-blank)")
map({"n", "x", "o"}, [[L]], [[$]], "End of line")
-- Non-blank last character
map({"n", "x", "o"}, [[g$]], [[g_]], {"noremap"}, "End of line(non-blank)")
-- Trailing character {{{
map("n", [[g.]],      [[:lua require("trailingUtil").trailingChar(".")<CR>]],  {"silent"}, "Trail .")
map("n", [[g,]],      [[:lua require("trailingUtil").trailingChar(",")<CR>]],  {"silent"}, "Trail ,")
map("n", [[g;]],      [[:lua require("trailingUtil").trailingChar(";")<CR>]],  {"silent"}, "Trail ;")
map("n", [[g:]],      [[:lua require("trailingUtil").trailingChar(":")<CR>]],  {"silent"}, "Trail :")
map("n", [[g"]],      [[:lua require("trailingUtil").trailingChar("\"")<CR>]], {"silent"}, 'Trail "')
map("n", [[g']],      [[:lua require("trailingUtil").trailingChar("'")<CR>]],  {"silent"}, "Trail '")
map("n", [[g)]],      [[:lua require("trailingUtil").trailingChar(")")<CR>]],  {"silent"}, "Trail )")
map("n", [[g(]],      [[:lua require("trailingUtil").trailingChar("(")<CR>]],  {"silent"}, "Trail (")
map("n", [[g<C-CR>]], [[:call append(line("."),   repeat([""], v:count1))<CR>]], {"silent"}, "Add new line below")
map("n", [[g<S-CR>]], [[:call append(line(".")-1, repeat([""], v:count1))<CR>]], {"silent"}, "Add new line above")
map("n", [[g<CR>]],   require("breakLine").main, "Break line at cursor")
-- }}} Trailing character
-- Messages

map("n", [[<leader>,]], [[<CMD>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")
map("n", [[<leader>.]], [[<CMD>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")
-- Pageup/Pagedown
map({"n", "x"},  [[<C-e>]], [[<C-y>]], {"noremap"})
map({"n", "x"},  [[<C-d>]], [[<C-e>]], {"noremap"})
map("t", [[<C-e>]], [[<C-\><C-n><C-y>]])
map("t", [[<C-d>]], [[<C-\><C-n><C-d>]])

map({"n", "x"},  [[<A-e>]], [[<PageUp>]])
map({"n", "x"},  [[<A-d>]], [[<PageDown>]])
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]])
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]])

-- Macro
map("n", [[<A-q>]], [[q]], {"noremap"}, "Macro")
-- Register
map({"n", "x"}, [[<leader>']], require("register").clear, "Clear registers")
map({"n", "x"}, [[g']],        [[<CMD>reg<CR>]],          {"silent"}, "Registers in prompt")
map("i", [[<C-r><C-r>]], [[<C-\><C-o>:lua require("register").insertPrompt()<CR>]], {"silent"}, "Registers in prompt")

-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]],     [[:lua require("buffer").smartClose("window")<CR>]], {"silent"}, "Close window")
map("n", [[Q]],     [[:lua require("buffer").smartClose("buffer")<CR>]], {"silent"}, "Close buffer")
map("n", [[<C-u>]], require("buffer").restoreClosedBuf, "Restore last closed buffer")
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
map("n", [[<C-w>O]], require("buffer").wipeOtherBuf, "Wipe other buffer")
map("n", [[<A-h>]],  [[<CMD>bp<CR>]], {"silent"},    "Previous buffer")
map("n", [[<A-l>]],  [[<CMD>bn<CR>]], {"silent"},    "Next buffer")
-- Tab
map({"n", "x"}, [[<A-C-h>]],    [[<CMD>tabp<CR>]],    {"silent"}, "Previous tab")
map({"n", "x"}, [[<A-C-l>]],    [[<CMD>tabn<CR>]],    {"silent"}, "Next tab")
map({"n", "x"}, [[<C-W><C-o>]], [[<CMD>tabonly<CR>]], {"silent"}, "Tab only")
-- }}} Buffer & Window & Tab
-- Folding {{{
map({"n", "x", "o"},  [[<leader>z]], [[<CMD>call EnhanceFoldHL("No fold marker found", 500, "")<CR>]], {"silent"})
map({"n", "x", "o"},  [[zj]], [[<Nop>]])
map({"n", "x", "o"},  [[zk]], [[<Nop>]])
map({"n", "x", "o"},  [[[Z]], [[zk]], {"noremap"}, "Previous fold(integral)")
map({"n", "x", "o"},  [[]Z]], [[zj]], {"noremap"}, "Next fold(integral)")
map({"n", "x", "o"},  [[[z]], [[<CMD>call EnhanceFoldJump("previous", 1, 0)<CR>]], {"silent", "noremap"}, "Previous fold")
map({"n", "x", "o"},  [[[z]], [[<CMD>call EnhanceFoldJump("previous", 1, 0)<CR>]], {"silent", "noremap"}, "Previous fold")
map({"n", "x", "o"},  [[]z]], [[<CMD>call EnhanceFoldJump("next",     1, 0)<CR>]], {"silent", "noremap"}, "Next fold")
map("n", [[dz]], [[<CMD>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent"}, "Delete fold")
map("n", [[zd]], [[<CMD>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent"}, "Delete fold")
map("n", [[cz]], [[<CMD>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent"}, "Change fold")
map("n", [[zc]], [[<CMD>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent"}, "Change fold")
-- TODO: Check whether target line is a comment or not
-- api.nvim_echo({{"text", "Normal"}}, true, {})
map("n", [[g{]], [[<CMD>call EnhanceFold(mode(), "{{{")<CR>]],           "Add fold start")
map("n", [[g}]], [[<CMD>call EnhanceFold(mode(), "}}}")<CR>]],           "Add fold end")
map("x", [[g{]], [[m`<CMD>call EnhanceFold(visualmode(), "}}}")<CR>``]], "Add fold for selected")
map("x", [[g}]], [[m`<CMD>call EnhanceFold(visualmode(), "}}}")<CR>``]], "Add fold for selected")
||||||| beab17d
-- api.nvim_echo({{"text", "Normal"}}, true, {})
map("n", [[g{]],              [[:<C-u>call EnhanceFold(mode(), "{{{")<CR>]],           "Add fold start")
map("n", [[g}]],              [[:<C-u>call EnhanceFold(mode(), "}}}")<CR>]],           "Add fold end")
map("x", [[g{]],              [[m`:<C-u>call EnhanceFold(visualmode(), "}}}")<CR>``]])
map("x", [[g}]],              [[m`:<C-u>call EnhanceFold(visualmode(), "}}}")<CR>``]])
map("n", [[<leader><Space>]], [[@=(foldlevel('.') ? 'za' : '\<Space>')<CR>]],          {"noremap", "silent"}, "Open fold")
-- TODO: make <C-Space> snapped to the nearst closed fold even if the cursor
-- is not on a line with closed fold
map("n", [[<C-Space>]],       [[@=(foldlevel('.') ? 'zA' : '\<Space>')<CR>]],          {"noremap", "silent"}, "Open fold recursively")
for i=0, 9 do
    map({"n", "x"},
        string.format("z%d", i),
        string.format([[:set foldlevel=%d<Bar>echohl Moremsg<Bar>echo 'Foldlevel set to: %d'<Bar>echohl None<CR>]], i, i),
        string.format("Set fold level to %d", i)
    )
end
-- }}} Folding
-- MS behavior {{{
-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]], "Undo")
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
cmd [[command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<CR> | e!]]
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
map("n", [[J]], [[m`J``]], {"noremap"})
-- Inplace yank
map({"n", "x", "o"}, [[<Plug>InplaceYank]],
[[luaeval("require('operator').expr(require('yankPut').inplaceYank, false, '<Plug>InplaceYank')")]],
{"expr", "silent"}, "Yank operator")
map({"n", "x", "o"}, [[y]], [[<Plug>InplaceYank]], "Yank operator")
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
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],                 {"silent"}, "Copy line down")
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],                   {"silent"}, "Copy line up")
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],       {"silent"}, "Copy line down")
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],         {"silent"}, "Copy line up")
map("x", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<CR>]], {"silent"}, "Copy line down")
map("x", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<CR>]],   {"silent"}, "Copy line up")

-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[m`:s#\\#\/#e<CR>:noh<CR>g``]],   {"noremap", "silent"}, [[Convert \ to /]])
map("n", [[g\]], [[m`:s#\/#\\\\#e<CR>:noh<CR>g``]], {"noremap", "silent"}, [[Convert / to \]])
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]], "Enter Normal mode")
map("n", [[<C-`>]],      require("terminal").terminalToggle, "Terminal toggle")
map("n", [[<leader>t]],  require("terminal").terminalToggle, "Terminal toggle")
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
map("i", [[,]], [[,<C-g>u]], {"noremap"})
map("i", [[.]], [[.<C-g>u]], {"noremap"})
map("i", [[!]], [[!<C-g>u]], {"noremap"})
map("i", [[*]], [[*<C-g>u]], {"noremap"})
-- Navigation {{{
map("!", [[<C-a>]], [[<Home>]], "Move cursor to the start")
map("!", [[<C-e>]], [[<End>]], "Move cursor to the end")
map("!", [[<C-h>]], [[<Left>]], "Move cursor to one character left")
map("!", [[<C-l>]], [[<Right>]], "Move cursor to one character right")
map("!", [[<C-b>]], [[<C-Left>]], "Move cursor to one word backward")
map("!", [[<C-d>]],  [[<Del>]], "Delete character to the right")
map("!", [[<C-w>]], [[<C-Right>]], "Move cursor to one word forward")
-- }}} Navigation
map("c", [[<C-j>]],   [[<Down>]], "Move cursor down")
map("c", [[<C-k>]],   [[<Up>]], "Move cursor up")
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<CR>]], "Delete word before")
-- }}} Mode: Commandline & Insert

return M

