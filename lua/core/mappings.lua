local cmd  = vim.cmd
local M    = {}

-- First thing first
vim.g.mapleader = " "

-- Change font size (GUI client only)
if not os.getenv("TERM") then
    map("", [[<C-->]], [[:lua GuiFontSize = GuiFontSize - 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]],    {"silent"}, "Increase font size")
    map("", [[<C-=>]], [[:lua GuiFontSize = GuiFontSize + 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]],    {"silent"}, "Decrease font size")
    map("", [[<C-0>]], [[:lua GuiFontSize = GuiFontSizeDefault; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]], {"silent"}, "Restore font size")
end
map("n", [[J]], [[mzJ`z]], {"noremap"})
-- Expand region
map("n", [[<A-a>]], [[:lua require("expandRegion").expandShrink("n", 1)<CR>]], {"silent"}, "Expand selection")
map("n", [[<A-s>]], [[:lua require("expandRegion").expandShrink("n", 0)<CR>]], {"silent"}, "Shrink selection")
-- Run selected
map("x", [[gM]], luaRHS[[:lua vim.cmd(
    string.format("lua %s",
        luaRHS(require("util").visualSelection("string"))
    )
)<CR>]],
{"silent"})
map("n", [[<Plug>InterestingWordOperator]],
luaRHS[[luaeval("
    require('operator').expr(
        require('interestingWord').operator,
        false,
        '<Plug>InterestingWordOperator')
    ")
]], {"expr", "silent"})
-- Interesting word {{{
map("n", [[<Plug>InterestingWordOperator]],
luaRHS[[luaeval("
    require('operator').expr(
        require('interestingWord').operator,
        false,
        '<Plug>InterestingWordOperator')
    ")
]], {"expr", "silent"})
map("x", [[<C-s>]], [[:lua require("selection").visualSub()<CR>]])
map("x", [[<Plug>InterestingWordVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisual")
    require("interestingWord").operator(vMotion)<CR>]],
{"silent"})
map("n", [[<Plug>InterestingWordVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisual", vim.v.register);
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisual")
    require("interestingWord").operator(vMotion)<CR>]],
{"silent"})
map("n", [[gw]],        [[<Plug>InterestingWordOperator]], "Highlight interesting word...")
map("x", [[W]],         [[<Plug>InterestingWordVisual]],   "Highlight selected as interesting word")
map("n", [[gww]],       [[:lua require("interestingWord").reapplyColor()<CR>]], "Recolor last interesting word...")
map("n", [[<leader>w]], [[:lua require("interestingWord").clearColor()<CR>]],   "Clear interesting word...")
map("n", [[<leader>W]], [[:lua require("interestingWord").restoreColor()<CR>]], "Restore interesting word...")
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
{"silent", "expr"}, "Zeal look up...")
map("n", [[<Plug>ZealOperatorGlobal]],
luaRHS[[luaeval(
    "require('operator').expr{
        require('zeal').zealGlobal,
        false,
        '<Plug>ZealOperatorGlobal'}
    ")
]],
{"silent", "expr"}, "Zeal look up... universally")
map("x", [[<Plug>ZealVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ZealVisual")
    require("zeal").zeal(vMotion)<CR>]],
{"silent"}, "Zeal look up selected")
map("n", [[<Plug>ZealVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register);
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ZealVisual")
    require("zeal").zeal(vMotion)<CR>]],
{"silent"}, "Zeal look up selected")
map("n", [[gz]], [[<Plug>ZealOperator]],       "Zeal look up...")
map("n", [[gZ]], [[<Plug>ZealOperatorGlobal]], "Zeal look up...universally")
map("x", [[Z]],  [[<Plug>ZealVisual]])
-- }}} Zeal query
-- HistoryStartup
map("n", [[<C-s>]], [[:lua require("historyStartup").display()<CR>]], {"silent"}, "Enter HistoryStartup")
-- Extraction
map("n", [[<Plug>Extract]],
luaRHS[[luaeval(
    "require('operator').expr(
        require('extraction').operator,
        false,
        '<Plug>Extract')
    ")
]],
{"silent", "expr"}, "Extract...")
map("x", [[<Plug>ExtractVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ExtractVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ExtractVisual")
    require("extraction").operator(vMotion)<CR>]],
{"silent"}, "Extract selected")
map("n", [[<Plug>ExtractVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ExtractVisual", vim.v.register);
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ExtractVisual")
    require("extraction").operator(vMotion)<CR>]],
{"silent"}, "Extract selected")
map("n", [[gc]], [[<Plug>Extract]])
-- TODO: implement with visualreapet?
map("x", [[C]],  [[visualmode() == '^V' ? "Di" : "\<Plug>ExtractVisual"]], {"expr"})
-- Print file info
map("n", [[<C-g>]],
[[:lua print(" " .. vim.api.nvim_exec("file!", true) .. " 🖵  CWD: " .. vim.fn.getcwd())<CR>]],
{"silent"}, "Display file info")
-- Tab switcher {{{
map("n", [[<S-Tab>]], [[:lua require("tabSwitcher").main()<CR>]], {"silent"}, "Change tab size")
-- }}} Tab switcher
-- Search & Jumping {{{
-- Delete
-- In case of mistouching
map("n", [[dj]], [[<Nop>]])
map("n", [[dk]], [[<Nop>]])
map("n", [[d<Space>]], [[:<C-u>call setline(".", "")<CR>]],  {"silent"})
-- Inquery word
map("n", [[<leader>i]], [=[[I]=], "Inquery word under cursor")
map("x", [[<leader>i]], [[:lua vim.cmd("noa g#" .. require("util").visualSelection("string") .. "#nu")<CR>]], {"silent"})
-- Fast mark & resotre
map("n", [[M]], [[`m]], "Restore mark M")
-- Changelist jumping
map("n", [[<A-o>]], [[:lua require("historyHop").main("changelist", -1)<CR>]], {"silent"}, "Previous change")
map("n", [[<A-i>]], [[:lua require("historyHop").main("changelist", 1)<CR>]],  {"silent"}, "Next change")
-- map("n", [[<C-o>]], [[:lua require("historyHop").main("jumplist", -1)<CR>]],   {"silent"})
-- map("n", [[<C-i>]], [[:lua require("historyHop").main("jumplist", 1)<CR>]],    {"silent"})
map("n", [[j]], [[:lua require("util").addJump("j", true)<CR>]], {"silent"})
map("n", [[k]], [[:lua require("util").addJump("k", true)<CR>]], {"silent"})
-- Swap default mapping
map("n", [[*]],  [[g*]], {"noremap"})
map("n", [[#]],  [[g#]], {"noremap"})
map("n", [[g#]], [[#]],  {"noremap"})
map("n", [[g*]], [[*]],  {"noremap"})
-- Add visual mode
map("x", [[*]], [[mz`z:<C-u>execute "/" . escape(luaeval('require("util").visualSelection("string")'), '\')<CR>]], {"noremap", "silent"})
map("x", [[#]], [[mz`z:<C-u>execute "?" . escape(luaeval('require("util").visualSelection("string")'), '\')<CR>]], {"noremap", "silent"})
map("x", [[/]], [[*]])
map("x", [[?]], [[#]])
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"}, "Search forward")
map("n", [[?]], [[?\v]], {"noremap"}, "Search backward")
map("n", [[n]], [[nzzzv]], {"noremap"})
map("n", [[N]], [[Nzzzv]], {"noremap"})
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[:<C-u>noh<CR>]], {"silent"}, "Disable highlight")
map("x", [[<leader>h]], [[<CMD>exec "norm! \<lt>Esc>"<CR>]], {"silent"})
-- Visual selection
map("n", [[go]],    [[:lua require("selection").oppoSelection()<CR>]], {"silent"}, "Go to opposite of selection")
map("n", [[<A-v>]], [[<C-q>]],                                         {"noremap"}, "Visual Block Mode")
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<C-u>new<CR>]], {"silent"}, "New buffer")
-- Open/Search in browser
map("n", [[gl]], [[:lua require("openLink").main()<CR>]], {"silent"}, "Open link")
map("x", [[gl]], [[:lua require("openLink").main(require("util").visualSelection("string"))<CR>]], {"silent"})
-- Interrupt
map("n", [[<C-A-c>]], [[:<C-u>call interrupt()<CR>]], {"noremap", "silent"}, "Interrupt")
-- Paragraph & Block navigation
-- map("", [[{]], [[:lua require("inclusiveParagraph").main("up")<CR>]],   {"noremap", "silent"})
-- map("", [[}]], [[:lua require("inclusiveParagraph").main("down")<CR>]], {"noremap", "silent"})
-- Line end/start
map("", [[H]], [[^]], "Start of line(non-blank)")
map("", [[L]], [[$]], "End of line")
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"}, "End of line(non-blank)")
-- Trailing character {{{
map("n", [[g.]],      [[:lua require("trailingUtil").trailingChar(".")<CR>]],  {"silent"}, "Trail .")
map("n", [[g,]],      [[:lua require("trailingUtil").trailingChar(",")<CR>]],  {"silent"}, "Trail ,")
map("n", [[g;]],      [[:lua require("trailingUtil").trailingChar(";")<CR>]],  {"silent"}, "Trail ;")
map("n", [[g:]],      [[:lua require("trailingUtil").trailingChar(":")<CR>]],  {"silent"}, "Trail :")
map("n", [[g"]],      [[:lua require("trailingUtil").trailingChar("\"")<CR>]], {"silent"}, 'Trail "')
map("n", [[g']],      [[:lua require("trailingUtil").trailingChar("'")<CR>]],  {"silent"}, "Trail '")
map("n", [[g)]],      [[:lua require("trailingUtil").trailingChar(")")<CR>]],  {"silent"}, "Trail )")
map("n", [[g(]],      [[:lua require("trailingUtil").trailingChar("(")<CR>]],  {"silent"}, "Trail (")
map("n", [[g<C-CR>]], [[:lua require("trailingUtil").trailingChar("o")<CR>]],  {"silent"}, "Add new line below")
map("n", [[g<S-CR>]], [[:lua require("trailingUtil").trailingChar("O")<CR>]],  {"silent"}, "Add new line above")
-- }}} Trailing character
-- Messages

map("n", [[g<]],        [[:<C-u>messages<CR>]], {"silent"}, "Messages in prompt")
map("n", [[<leader>,]], [[:<C-u>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]])
map("n", [[<leader>.]], [[:<C-u>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")
-- Pageup/Pagedown
map("",  [[<C-e>]], [[<C-y>]], {"noremap"})
map("",  [[<C-d>]], [[<C-e>]], {"noremap"})
map("t", [[<C-e>]], [[<C-\><C-n><C-y>]])
map("t", [[<C-d>]], [[<C-\><C-n><C-d>]])

map("",  [[<A-e>]], [[<PageUp>]],   "PageUp")
map("",  [[<A-d>]], [[<PageDown>]], "PageDown")
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]])
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]])

-- Macro
map("n", [[<A-q>]], [[q]], {"noremap"}, "Macro")
-- Register
map("",  [[<leader>q]],  [[:lua require("register").clear()<CR>]], {"silent"}, "Clear registers")
map("",  [[<C-q><C-q>]], [[:<C-u>reg<CR>]],                        {"silent"}, "Registers in prompt")
map("",  [[<C-q>q]],     [[:<C-u>reg<CR>]],                        {"silent"}, "Registers in prompt")
map("i", [[<C-r><C-r>]], [[<C-\><C-o>:lua require("register").insertPrompt()<CR>]], {"silent"}, "Registers in prompt")

-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]],     [[:lua require("buffer").smartClose("window")<CR>]], {"silent"}, "Close window")
map("n", [[Q]],     [[:lua require("buffer").smartClose("buffer")<CR>]], {"silent"}, "Close buffer")
map("n", [[<C-u>]], [[:lua require("buffer").restoreClosedBuf()<CR>]],   {"silent"}, "Restore last closed buffer")
-- Window
-- TODO:
-- map("",  [[<C-w>s]], [[:lua require("consistantTab").splitCopy("wincmd s")<CR>]], {"silent"})
-- map("",  [[<C-w>v]], [[:lua require("consistantTab").splitCopy("wincmd v")<CR>]], {"silent"})
map("n", [[<C-w>V]], [[:lua require("buffer").closeOtherWin();vim.cmd("wincmd v")<CR>]], {"silent"}, "Split only current window vertically")
map("n", [[<C-w>S]], [[:lua require("buffer").closeOtherWin();vim.cmd("wincmd s")<CR>]], {"silent"}, "Split only current window vertically")

map("n", [[<C-w>q]], [[:lua require("buffer").quickfixToggle()<CR>]], {"silent"}, "Quickfix toggle")
map("n", [[<C-w>t]], [[:<C-u>tabnew<CR>]],                            {"silent"}, "New tab")
map("",  [[<A-=>]],  [[:<C-u>wincmd +<CR>]],                          {"silent"}, "Increase window size")
map("i", [[<A-=>]],  [[<C-\><C-O>:wincmd +<CR>]],                     {"silent"})
map("",  [[<A-->]],  [[:<C-u>wincmd -<CR>]],                          {"silent"}, "Decrease window size")
map("i", [[<A-->]],  [[<C-\><C-O>:wincmd -<CR>]],                     {"silent"})
map("i", [[<C-w>=]], [[<C-\><C-O>:wincmd =<CR>]],                     {"silent"})
map("n", [[<C-w>o]], [[:lua require("buffer").closeOtherWin()<CR>]],  {"silent"})

-- Buffers
map("",  [[<C-w>O]], [[:lua require("buffer").wipeOtherBuf()<CR>]], {"silent"}, "Wipe other buffer")
map("n", [[<A-h>]],  [[:<C-u>bp<CR>]],                              {"silent"}, "Previous buffer")
map("n", [[<A-l>]],  [[:<C-u>bn<CR>]],                              {"silent"}, "next buffer")
-- Tab
map("", [[<A-C-h>]],    [[:<C-u>tabp<CR>]],    {"silent"}, "Previous tab")
map("", [[<A-C-l>]],    [[:<C-u>tabn<CR>]],    {"silent"}, "Next tab")
map("", [[<C-W><C-o>]], [[:<C-u>tabonly<CR>]], {"silent"}, "Tab only")
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[<leader>z]], [[:<C-u>call EnhanceFoldHL("No fold marker found", 500, "")<CR>]], {"silent"})
map("",  [[zj]], [[<Nop>]])
map("",  [[zk]], [[<Nop>]])
map("",  [[[Z]], [[zk]], {"noremap"}, "Previous fold(integral)")
map("",  [[]Z]], [[zj]], {"noremap"}, "Next fold(integral)")
map("",  [[[z]], [[:<C-u>call EnhanceFoldJump("previous", 1, 0)<CR>]],       {"silent", "noremap"}, "Previous fold")
map("",  [[]z]], [[:<C-u>call EnhanceFoldJump("next",     1, 0)<CR>]],       {"silent", "noremap"}, "Next fold")
map("n", [[dz]], [[:<C-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent"}, "Delete fold")
map("n", [[zd]], [[:<C-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent"}, "Delete fold")
map("n", [[cz]], [[:<C-u>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent"}, "Change fold")
map("n", [[zc]], [[:<C-u>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent"}, "Change fold")
-- TODO: Check whether target line is a comment or not
-- api.nvim_echo({{"text", "Normal"}}, true, {})
map("n", [[g{]],              [[:<C-u>call EnhanceFold(mode(), "{{{")<CR>]],           "Add fold start")
map("n", [[g}]],              [[:<C-u>call EnhanceFold(mode(), "}}}")<CR>]],           "Add fold end")
map("x", [[g{]],              [[mz:<C-u>call EnhanceFold(visualmode(), "}}}")<CR>`z]])
map("x", [[g}]],              [[mz:<C-u>call EnhanceFold(visualmode(), "}}}")<CR>`z]])
map("n", [[<leader><Space>]], [[@=(foldlevel('.') ? 'za' : '\<Space>')<CR>]],          {"noremap", "silent"}, "Open fold")
map("n", [[<C-Space>]],       [[@=(foldlevel('.') ? 'zA' : '\<Space>')<CR>]],          {"noremap", "silent"}, "Open fold recursively")
for i=0, 9 do
    map("",
        string.format("z%d", i),
        string.format([[:set foldlevel=%d<Bar>echohl Moremsg<Bar>echo 'Foldlevel set to: %d'<Bar>echohl None<CR>]], i, i),
        string.format("Set fold level to %d", i)
    )
end
-- }}} Folding
-- MS behavior {{{
-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]], "Undo")
map("x", [[<C-z>]], [[<esc>u]])
map("i", [[<C-z>]], [[<C-\><C-o>u]])

map("n", [[<C-c>]], [[Y]], "Undo")
map("x", [[<C-c>]], [[y]])
-- map("i", [[<C-c>]], [[<C-\><C-o>Y]])

map("n", [[<C-v>]], [[p]], {"noremap"}, "Undo")
map("x", [[<C-v>]], [[<esc>i<C-v><esc>]])
map("i", [[<C-v>]], [[<C-r>*]])

-- map("n", [[<C-s>]], [[:<C-u>w<CR>]])
-- map("x", [[<C-s>]], [[:<C-u>w<CR>]])
map("i", [[<C-s>]], [[<C-\><C-o>:w<CR>]])
-- }}} <C-z/x/v/s>
-- Save as..
cmd [[command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<CR> | e!]]
map("n", [[<C-S-s>]], [[:<C-u>Saveas<CR>]],      {"silent"}, "Save as...")
map("i", [[<C-S-s>]], [[<C-\><C-o>:Saveas<CR>]], {"silent"})
-- Delete
map("n", [[<C-S-d>]], [[:<C-u>d<CR>]],      {"silent"}, "Detele line")
map("x", [[<C-S-d>]], [[:d<CR>]],           {"silent"})
map("i", [[<C-S-d>]], [[<C-\><C-o>:d<CR>]], {"silent"})
-- Highlight New Paste Content
map("n", [[gy]], [[:lua require("yankPut").lastYankPut("yank")<CR>]], {"silent"}, "Select last yank")
map("n", [[gY]], [[gy]], "Select last yank")
map("n", [[gp]], [[:lua require("yankPut").lastYankPut("put")<CR>]],  {"silent"}, "Select last put")
map("n", [[gP]], [[gp]], "Select last put")
-- Put content from registers 0
map("n", [[<leader>p]], [["0p]], "Put after from register 0")
map("n", [[<leader>P]], [["0P]], "Put after from register 0")
-- Inplace yank
map("", [[<Plug>InplaceYank]],
[[luaeval("require('operator').expr(require('yankPut').inplaceYank, false, '<Plug>InplaceYank')")]],
{"expr", "silent"}, "Yank operator")
map("", [[y]], [[<Plug>InplaceYank]], "Yank operator")
map("", [[Y]], [[yy]], "Yank line")
-- Inplace put
map("n", [[p]], [[:lua require("yankPut").inplacePut("n", "p")<CR>]], {"silent"}, "Put after")
map("x", [[p]], [[:lua require("yankPut").inplacePut("v", "p")<CR>]], {"silent"})
map("n", [[P]], [[:lua require("yankPut").inplacePut("n", "P")<CR>]], {"silent"}, "Put before")
map("x", [[P]], [[:lua require("yankPut").inplacePut("v", "P")<CR>]], {"silent"})
-- Inplace replace
-- Convert paste
map("n", [[cP]], [[:lua require("yankPut").convertPut("P")<CR>]], "Convert put")
map("n", [[cp]], [[:lua require("yankPut").convertPut("p")<CR>]], "Convert put")
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
map("i", [[<A-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineMove("n", "down")<CR>]], {"silent"})
map("i", [[<A-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],   {"silent"})
map("n", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("n", "down")<CR>]], {"silent"}, "Move line down")
map("n", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],   {"silent"}, "Move line up")
map("x", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<CR>]], {"silent"})
map("x", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<CR>]],   {"silent"})
-- Copy line
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],                 {"silent"}, "Copy line down")
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],                   {"silent"}, "Copy line up")
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],       {"silent"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],         {"silent"})
map("x", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<CR>]], {"silent"})
map("x", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<CR>]],   {"silent"})

-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[mz:s#\\#\/#e<CR>:noh<CR>g`z]],   {"noremap", "silent"}, [[Convert \ to /]])
map("n", [[g\]], [[mz:s#\/#\\\\#e<CR>:noh<CR>g`z]], {"noremap", "silent"}, [[Convert / to \]])
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]])
map("n", [[<C-`>]],      [[:lua require("terminal").terminalToggle()<CR>]],      {"silent"}, "Terminal toggle")
map("n", [[<leader>t]],  [[:lua require("terminal").terminalToggle()<CR>]],      {"silent"}, "Terminal toggle")
map("t", [[<C-`>]],      [[<A-n>:lua require("terminal").terminalToggle()<CR>]], {"silent"})
map("t", [[<A-h>]],      [[<A-n><A-h>]])
map("t", [[<A-l>]],      [[<A-n><A-l>]])
map("t", [[<A-S-h>]],    [[<A-n><A-S-h>]])
map("t", [[<A-S-l>]],    [[<A-n><A-S-l>]])
map("t", [[<C-BS>]],     [[<C-w>]],                                 {"noremap"})
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], {"expr"})
map("t", [[<C-w>k]],     [[<A-n><C-w>k]])
map("t", [[<C-w>j]],     [[<A-n><C-w>j]])
map("t", [[<C-w>h]],     [[<A-n><C-w>h]])
map("t", [[<C-w>l]],     [[<A-n><C-w>l]])
map("t", [[<C-w>w]],     [[<A-n><C-w>w]])
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]])
map("t", [[<C-w>=]],     [[<A-n><C-w>=:startinsert<CR>]], {"silent"})
map("t", [[<C-w>o]],     [[<A-n><C-w>o:startinsert<CR>]], {"silent"})
map("t", [[<C-w>W]],     [[<A-n><C-w>W:startinsert<CR>]], {"silent"})
map("t", [[<C-w>H]],     [[<A-n><C-w>H:startinsert<CR>]], {"silent"})
map("t", [[<C-w>L]],     [[<A-n><C-w>L:startinsert<CR>]], {"silent"})
map("t", [[<C-w>J]],     [[<A-n><C-w>J:startinsert<CR>]], {"silent"})
map("t", [[<C-w>K]],     [[<A-n><C-w>K:startinsert<CR>]], {"silent"})
-- TODO: Split terminal in new instance
-- }}} Mode: Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<A-[>]],  [[<C-d>]], {"noremap"})
map("i", [[<A-]>]],  [[<C-t>]], {"noremap"})
map("i", [[<C-k>]],  [[pumvisible() ? "\<C-e>\<Up>" : "\<Up>"]],     {"noremap", "expr"})
map("i", [[<C-j>]],  [[pumvisible() ? "\<C-e>\<Down>" : "\<Down>"]], {"noremap", "expr"})
map("i", [[<C-CR>]], [[pumvisible() ? "\<C-e>\<CR>" : "\<CR>"]],     {"noremap", "expr"})
map("i", [[<S-CR>]], [[<ESC>O]])
map("i", [[jj]],     [[<ESC>`^]], {"noremap"})
map("i", [[<C-d>]],  [[<Del>]])
map("i", [[<C-.>]],  [[<C-a>]], {"noremap"})
map("i", [[<C-BS>]], [[<C-w>]], {"noremap"})
map("i", [[<C-y>]],  [[pumvisible() ? "\<C-e>\<C-y>" : "\<C-y>"]], {"noremap", "expr"})
map("i", [[<A-y>]],  [[<C-x><C-l>]], {"noremap"})
map("i", [[<C-i>]],  [[pumvisible() ? "\<C-e>\<C-e>" : "\<C-e>"]], {"noremap", "expr"})
map("i", [[,]], [[,<C-g>u]], {"noremap"})
map("i", [[.]], [[.<C-g>u]], {"noremap"})
map("i", [[!]], [[!<C-g>u]], {"noremap"})
map("i", [[*]], [[*<C-g>u]], {"noremap"})
-- Outdent
map("i", [[<S-Tab>]], [[<C-d>]], {"noremap"})
-- Navigation {{{
map("!", [[<C-a>]], [[<Home>]])
map("!", [[<C-e>]], [[<End>]])
map("!", [[<C-h>]], [[<Left>]])
map("!", [[<C-l>]], [[<Right>]])
map("!", [[<C-b>]], [[<C-Left>]])
map("!", [[<C-w>]], [[<C-Right>]])
map("!", [[<C-h>]], [[<Left>]])
map("!", [[<C-u>]], [[<C-u>]], {"noremap"})
-- }}} Navigation
map("c", [[<C-j>]],   [[<Down>]])
map("c", [[<C-k>]],   [[<Up>]])
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<CR>]])
map("c", [[<C-S-l>]], [[<C-d>]], {"noremap"})
map("c", [[<C-d>]],   [[<Del>]])
map("c", [[<C-S-e>]], [[<C-\>e]])
map("c", [[<C-v>]],   [[<C-R>*]])
-- }}} Mode: Commandline & Insert

return M

