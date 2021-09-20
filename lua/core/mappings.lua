local cmd  = vim.cmd
local M    = {}

-- First thing first
vim.g.mapleader = " "

-- Change font size (GUI client only)
if not os.getenv("TERM") then
    map("", [[<C-->]], [[:lua GuiFontSize = GuiFontSize - 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]],    {"silent", "novscode"}, "Increase font size")
    map("", [[<C-=>]], [[:lua GuiFontSize = GuiFontSize + 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]],    {"silent", "novscode"}, "Decrease font size")
    map("", [[<C-0>]], [[:lua GuiFontSize = GuiFontSizeDefault; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<CR>]], {"silent", "novscode"}, "Restore font size")
end
-- InterestingWord
map("n", [[gw]],        [[luaeval("require('operator').expression(require('interestingWord').colorWord, false)")]], {"expr"}, "Highlight interesting word...")
map("x", [[W]],         [[:lua require("interestingWord").colorWord(require("operator").vMotion())<CR>]],           {},       "Highlight selected as interesting word")
map("n", [[gww]],       [[:lua require("interestingWord").reapplyColor()<CR>]], {}, "Recolor last interesting word...")
map("n", [[<leader>w]], [[:lua require("interestingWord").clearColor()<CR>]],   {}, "Clear interesting word...")
map("n", [[<leader>W]], [[:lua require("interestingWord").restoreColor()<CR>]], {}, "Restore interesting word...")
-- HistoryStartup
map("n", [[<C-s>]], [[:lua require("historyStartup").display()<CR>]], {"silent"}, "Enter HistoryStartup")
-- Extraction
map("n", [[gc]], [[luaeval("require('operator').expression(require('extraction').operator, true)")]], {"silent", "expr"}, "Extract...")
map("x", [[C]],  [[:lua require("extraction").operator(require("operator").vMotion())<CR>]],          {"silent"})
-- Zeal query
map("n", [[gz]], [[luaeval("require('operator').expression(require('zeal').zeal,       false)")]], {"silent", "expr"}, "Zeal look up...")
map("n", [[gZ]], [[luaeval("require('operator').expression(require('zeal').zealGlobal, false)")]], {"silent", "expr"}, "Zeal look up... universally")
map("x", [[Z]],  [[:lua require("zeal").zealGlobal(require("operator").vMotion())<CR>]],           {"silent"})
-- Print file name
map("", [[<C-g>]], [[:lua print(" " .. vim.api.nvim_exec("file!", true) .. " 🖵  CWD: " .. vim.fn.getcwd())<CR>]], {"silent", "novscode"}, "Display file info")
-- Tab switcher {{{
map("n", [[<S-Tab>]], [[:lua require("tabSwitcher").main()<CR>]], {"silent", "novscode"}, "Change tab size")
-- }}} Tab switcher
-- Search & Jumping {{{
-- Delete
-- In case of mistouching
map("n", [[dj]], [[<Nop>]])
map("n", [[dk]], [[<Nop>]])
map("n", [[d<Space>]], [[:<C-u>call setline(".", "")<CR>]],  {"silent"})
map("n", [[dd]],       [[:d<CR>]],                           {"silent",  "nowait"})
-- Inquery word
map("n", [[<leader>i]], [=[[I]=], "Inquery word under cursor")
map("x", [[<leader>i]], [[:lua vim.cmd("g#" .. require("util").visualSelection("string") .. "#nu")<CR>]], {"silent"})
-- Fast mark & resotre
map("n", [[M]], [[`m]], "Restore mark M")
-- Changelist jumping
map("n", [[<A-o>]], [[:lua require("historyHop").main("changelist", -1)<CR>]], {"silent"}, "Previous change")
map("n", [[<A-i>]], [[:lua require("historyHop").main("changelist", 1)<CR>]],  {"silent"}, "Next change")
-- map("n", [[<C-o>]], [[:lua require("historyHop").main("jumplist", -1)<CR>]],   {"silent"})
-- map("n", [[<C-i>]], [[:lua require("historyHop").main("jumplist", 1)<CR>]],    {"silent"})
map("n", [[j]], [[:lua require("util").addJump("j", true)<CR>]], {"silent"})
map("n", [[k]], [[:lua require("util").addJump("k", true)<CR>]], {"silent"})
map("x", [[*]], [[mz`z:<C-u>execute "/" . escape(luaeval('require("util").visualSelection("string")'), '\')<CR>]], {"noremap", "silent"})
map("x", [[#]], [[mz`z:<C-u>execute "?" . escape(luaeval('require("util").visualSelection("string")'), '\')<CR>]], {"noremap", "silent"})
map("x", [[/]], [[*]])
map("x", [[?]], [[#]])
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"}, "Search forward")
map("n", [[?]], [[?\v]], {"noremap"}, "Search backward")
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[:<C-u>noh<CR>]],               {"silent"}, "Disable highlight")
map("x", [[<leader>h]], [[:<C-u>call ExitVisual()<CR>]], {"silent"})
-- Visual selection
map("n", [[go]],    [[:lua require("selection").oppoSelection()<CR>]], {"silent"}, "Go to opposite of selection")
map("n", [[<A-v>]], [[<C-q>]],                                         {"noremap"}, "Visual Block Mode")
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<C-u>new<CR>]], {"silent", "novscode"}, "New buffer")
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
vmap("n", [[g>]], [[:<C-u>messages<CR>]])

map("n", [[g<]],        [[:<C-u>messages<CR>]], {"silent"}, "Messages in prompt")
map("n", [[<leader>,]], [[:<C-u>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]])
map("n", [[<leader>.]], [[:<C-u>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")
-- Pageup/Pagedown
map("t", [[<C-e>]], [[<C-\><C-n><C-y>]])
map("t", [[<C-d>]], [[<C-\><C-n><C-d>]])

map("",  [[<A-e>]], [[<PageUp>]],   {"novscode"}, "PageUp")
map("",  [[<A-d>]], [[<PageDown>]], {"novscode"}, "PageDown")
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]])
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]])

vmap("n", [[<A-e>]], [[:<C-u>call VSCodeCall("cursorPageUp")<CR>]])
vmap("n", [[<A-d>]], [[:<C-u>call VSCodeCall("cursorPageDown")<CR>]])
vmap("i", [[<A-e>]], [[<C-o>:call VSCodeCall("cursorPageUp")<CR>]])
vmap("i", [[<A-d>]], [[<C-o>:call VSCodeCall("cursorPageDown")<CR>]])
vmap("x", [[<A-e>]], [[<C-b>]])
vmap("x", [[<A-d>]], [[<C-f>]])
-- Macro
map("n", [[<A-q>]], [[q]], {"noremap"}, "Macro")
-- Register
map("",  [[<leader>q]],  [[:lua require("register").clear()<CR>]], {"silent"}, "Clear registers")
map("",  [[<C-q>]],      [[:<C-u>reg<CR>]],                        {"silent"}, "Registers in prompt")
map("i", [[<C-r><C-r>]], [[<C-\><C-o>:lua require("register").insertPrompt()<CR>]], {"silent"}, "Registers in prompt")

-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]],     [[:lua require("buffer").smartClose("window")<CR>]], {"silent"}, "Close window")
map("n", [[Q]],     [[:lua require("buffer").smartClose("buffer")<CR>]], {"silent"}, "Close buffer")
map("n", [[<C-u>]], [[:lua require("buffer").restoreClosedBuf()<CR>]],   {"silent"}, "Restore last closed buffer")
-- Window
-- TODO:
-- map("",  [[<C-w>v]], [[:lua require("consistantTab").splitCopy("wincmd v")<CR>]], {"silent", "novscode"})
-- map("",  [[<C-w>s]], [[:lua require("consistantTab").splitCopy("wincmd s")<CR>]], {"silent", "novscode"})
map("n", [[<C-w>V]], [[:lua require("buffer").closeOtherWin();vim.cmd("wincmd v")<CR>]], {"silent", "novscode"}, "Split only current window vertically")
map("n", [[<C-w>S]], [[:lua require("buffer").closeOtherWin();vim.cmd("wincmd s")<CR>]], {"silent", "novscode"}, "Split only current window vertically")

map("n", [[<C-w>q]], [[:lua require("buffer").quickfixToggle()<CR>]], {"silent", "novscode"}, "Quickfix toggle")
map("n", [[<C-w>t]], [[:<C-u>tabnew<CR>]],                            {"silent", "novscode"}, "New tab")
map("",  [[<A-=>]],  [[:<C-u>wincmd +<CR>]],                          {"silent", "novscode"}, "Increase window size")
map("i", [[<A-=>]],  [[<C-\><C-O>:wincmd +<CR>]],                     {"silent", "novscode"})
map("",  [[<A-->]],  [[:<C-u>wincmd -<CR>]],                          {"silent", "novscode"}, "Decrease window size")
map("i", [[<A-->]],  [[<C-\><C-O>:wincmd -<CR>]],                     {"silent", "novscode"})
map("i", [[<C-w>=]], [[<C-\><C-O>:wincmd =<CR>]],                     {"silent", "novscode"})
map("n", [[<C-w>o]], [[:lua require("buffer").closeOtherWin()<CR>]],  {"silent", "novscode"})

-- Buffers
map("",  [[<C-w>O]], [[:lua require("buffer").wipeOtherBuf()<CR>]], {"silent", "novscode"}, "Wipe other buffer")
map("n", [[<A-h>]],  [[:<C-u>bp<CR>]],                              {"silent"}, "Previous buffer")
map("n", [[<A-l>]],  [[:<C-u>bn<CR>]],                              {"silent"}, "next buffer")
-- Tab
map("", [[<A-C-h>]],    [[:<C-u>tabp<CR>]],    {"silent", "novscode"}, "Previous tab")
map("", [[<A-C-l>]],    [[:<C-u>tabn<CR>]],    {"silent", "novscode"}, "Next tab")
map("", [[<C-W><C-o>]], [[:<C-u>tabonly<CR>]], {"silent", "novscode"}, "Tab only")
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[<leader>z]], [[:<C-u>call EnhanceFoldHL("No fold marker found", 500, "")<CR>]], {"silent", "novscode"})
map("",  [[zj]], [[<Nop>]])
map("",  [[zk]], [[<Nop>]])
map("",  [[[Z]], [[zk]], {"noremap"}, "Previous fold(integral)")
map("",  [[]Z]], [[zj]], {"noremap"}, "Next fold(integral)")
map("",  [[[z]], [[:<C-u>call EnhanceFoldJump("previous", 1, 0)<CR>]],       {"noremap", "silent", "novscode"}, "Previous fold")
map("",  [[]z]], [[:<C-u>call EnhanceFoldJump("next",     1, 0)<CR>]],       {"noremap", "silent", "novscode"}, "Next fold")
map("n", [[dz]], [[:<C-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent", "novscode"}, "Delete fold")
map("n", [[zd]], [[:<C-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<CR>]], {"silent", "novscode"}, "Delete fold")
map("n", [[cz]], [[:<C-u>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent", "novscode"}, "Change fold")
map("n", [[zc]], [[:<C-u>call EnhanceFoldHL("", 0, "EnhanceChange")<CR>]],   {"silent", "novscode"}, "Change fold")
-- TODO: Check whether target line is a comment or not
-- api.nvim_echo({{"text", "Normal"}}, true, {})
map("n", [[g{]],              [[:<C-u>call EnhanceFold(mode(), "{{{")<CR>]],           {"novscode"}, "Add fold start")
map("n", [[g}]],              [[:<C-u>call EnhanceFold(mode(), "}}}")<CR>]],           {"novscode"}, "Add fold end")
map("x", [[g{]],              [[mz:<C-u>call EnhanceFold(visualmode(), "}}}")<CR>`z]], {"novscode"})
map("x", [[g}]],              [[mz:<C-u>call EnhanceFold(visualmode(), "}}}")<CR>`z]], {"novscode"})
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
map("n", [[<C-z>]], [[u]],           {"novscode"}, "Undo")
map("x", [[<C-z>]], [[<esc>u]],      {"novscode"})
map("i", [[<C-z>]], [[<C-\><C-o>u]], {"novscode"})

map("n", [[<C-c>]], [[Y]], {"novscode"}, "Undo")
map("x", [[<C-c>]], [[y]], {"novscode"})
-- map("i", [[<C-c>]], [[<C-\><C-o>Y]])

map("n", [[<C-v>]], [[p]],                {"noremap", "novscode"}, "Undo")
map("x", [[<C-v>]], [[<esc>i<C-v><esc>]], {"novscode"})
map("i", [[<C-v>]], [[<C-r>*]],           {"novscode"})

-- map("n", [[<C-s>]], [[:<C-u>w<CR>]],      {"novscode"})
-- map("x", [[<C-s>]], [[:<C-u>w<CR>]],      {"novscode"})
map("i", [[<C-s>]], [[<C-\><C-o>:w<CR>]], {"novscode"})
-- }}} <C-z/x/v/s>
-- Save as..
cmd [[command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<CR> | e!]]
map("",  [[<C-S-s>]], [[:<C-u>Saveas<CR>]],      {"silent", "novscode"}, "Save as...")
map("i", [[<C-S-s>]], [[<C-\><C-o>:Saveas<CR>]], {"silent", "novscode"})
-- Delete
map("n", [[<C-S-d>]], [[:<C-u>d<CR>]],      {"silent", "novscode"}, "Detele line")
map("x", [[<C-S-d>]], [[:d<CR>]],           {"silent", "novscode"})
map("i", [[<C-S-d>]], [[<C-\><C-o>:d<CR>]], {"silent", "novscode"})
-- Highlight New Paste Content
map("n", [[gy]], [[:lua require("yankPut").lastYankPut("yank")<CR>]], {"silent"}, "Select last yank")
map("n", [[gY]], [[gy]], "Select last yank")
map("n", [[gp]], [[:lua require("yankPut").lastYankPut("put")<CR>]],  {"silent"}, "Select last put")
map("n", [[gP]], [[gp]], "Select last put")
-- Put content from registers 0
map("n", [[<leader>p]], [["0p]], "Put after from register 0")
map("n", [[<leader>P]], [["0P]], "Put after from register 0")
-- Inplace yank
map("", [[Y]], [[yy]], "Yank line")
map("", [[y]], [[luaeval("require('operator').expression(require('yankPut').inplaceYank, false)")]], {"silent", "expr"}, "Yank operator")
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
map("i", [[<A-j>]], [[<C-\><C-o>:VSCodeLineMoveDownInsert<CR>]],                 {"silent", "novscode"})
map("i", [[<A-k>]], [[<C-\><C-o>:VSCodeLineMoveUpInsert<CR>]],                   {"silent", "novscode"})
map("n", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("n", "down")<CR>]], {"silent", "novscode"}, "Move line down")
map("n", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],   {"silent", "novscode"}, "Move line up")
map("x", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<CR>]], {"silent", "novscode"})
map("x", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<CR>]],   {"silent", "novscode"})
-- Copy line
-- BUG: Suppoert in insert mode
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],       {"silent"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],         {"silent"})
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],                 {"silent"}, "Copy line down")
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],                   {"silent"}, "Copy line up")
map("x", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<CR>]], {"silent"})
map("x", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<CR>]],   {"silent"})

vmap("n", [[<A-j>]],   [[:<C-u>call VSCodeCall("editor.action.moveLinesDownAction")<CR>]])
vmap("n", [[<A-k>]],   [[:<C-u>call VSCodeCall("editor.action.moveLinesUpAction")<CR>]])
vmap("i", [[<A-j>]],   [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesDownAction")<CR>]])
vmap("i", [[<A-k>]],   [[<C-\><C-o>::call VSCodeCall("editor.action.moveLinesUpAction")<CR>]])
vmap("i", [[<A-S-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("i", [[<A-S-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("n", [[<A-S-j>]], [[:<C-u>call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("n", [[<A-S-k>]], [[:<C-u>call VSCodeCall("editor.action.copyLinesUpAction")]])
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
map("i", [[<C-CR>]], [[pumvisible() ? "\<C-e>\<CR>" : "\<CR>"]],     {"noremap", "expr", "novscode"})
map("i", [[<S-CR>]], [[<ESC>O]],  {"novscode"})
map("i", [[jj]],     [[<ESC>`^]], {"noremap", "novscode"})
map("i", [[<C-d>]],  [[<Del>]],   {"novscode"})
map("i", [[<C-.>]],  [[<C-a>]],   {"noremap"})
map("i", [[<C-BS>]], [[<C-w>]],   {"noremap"})
map("i", [[<C-y>]],  [[pumvisible() ? "\<C-e>\<C-y>" : "\<C-y>"]], {"noremap", "expr", "novscode"})
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
-- RemoveLastPathComponent() {{{
cmd [[
function! RemoveLastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor  = strpart(getcmdline(), getcmdpos() - 1)
    let l:cmdlineRoot         = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result              = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction
]]
-- }}} RemoveLastPathComponent()
map("c", [[<C-j>]],   [[<Down>]])
map("c", [[<C-k>]],   [[<Up>]])
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<CR>]])
map("c", [[<C-S-l>]], [[<C-d>]], {"noremap"})
map("c", [[<C-d>]],   [[<Del>]])
map("c", [[<C-S-e>]], [[<C-\>e]])
map("c", [[<C-v>]],   [[<C-R>*]])
-- }}} Mode: Commandline & Insert

return M

