local cmd  = vim.cmd
local M    = {}

-- First thing first
vim.g.mapleader = " "

-- Change font size (GUI client only)
if not os.getenv("TERM") then
    map("", [[<C-->]], [[:lua GuiFontSize = GuiFontSize - 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]],    {"silent", "novscode"}, "Increase font size")
    map("", [[<C-=>]], [[:lua GuiFontSize = GuiFontSize + 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]],    {"silent", "novscode"}, "Decrease font size")
    map("", [[<C-0>]], [[:lua GuiFontSize = GuiFontSizeDefault; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]], {"silent", "novscode"}, "Restore font size")
end
-- HistoryStartup
map("n", [[<C-s>]], [[:lua require("historyStartup").display()<cr>]], {"silent"}, "Enter HistoryStartup")
-- Extraction
map("",  [[gc]], [[luaeval("require('operator').main(require('extraction').main, false)")]], {"silent", "expr"}, "Extract...")
map("v", [[C]],  [[:lua require("extraction").main({nil, vim.fn.visualmode()})<cr>]],        {"silent"})
-- Zeal query
-- TODO: refactor operator
map("",  [[gz]], [[luaeval("require('operator').main(require('zeal').nonglobalQuery, false)")]], {"silent", "expr"}, "Zeal look up...")
map("",  [[gZ]], [[luaeval("require('operator').main(require('zeal').globalQuery, false)")]],    {"silent", "expr"}, "Zeal look up... universally")
map("v", [[Z]],  [[:lua require("zeal").globalQuery({nil, "v"})<cr>]],                           {"silent"})
-- Print file name
map("", [[<C-g>]], [[:lua print(" " .. vim.api.nvim_exec("file!", true) .. " 🖵  CWD: " .. vim.fn.getcwd())<cr>]], {"silent", "novscode"}, "Display file info")
-- Tab switcher {{{
map("n", [[<S-Tab>]], [[:lua require("tabSwitcher").main()<cr>]], {"silent", "novscode"}, "Change tab size")
-- }}} Tab switcher
-- Search & Jumping {{{
-- Disable dj/dk
map("n", [[dj]], [[<Nop>]])
map("n", [[dk]], [[<Nop>]])
-- Inquery word
map("n", [[<leader>i]], [=[[I]=], "Inquery word under cursor")
map("v", [[<leader>i]], [[:lua vim.cmd("g#" .. require("util").visualSelection("string") .. "#nu")<cr>]], {"silent"})
-- Fast mark & resotre
map("n", [[M]], [[`m]], "Restore mark M")
-- Changelist jumping
map("n", [[<A-o>]], [[:lua require("historyHop").main("changelist", -1)<cr>]], {"silent"}, "Previous change")
map("n", [[<A-i>]], [[:lua require("historyHop").main("changelist", 1)<cr>]],  {"silent"}, "Next change")
-- map("n", [[<C-o>]], [[:lua require("historyHop").main("jumplist", -1)<cr>]],   {"silent"})
-- map("n", [[<C-i>]], [[:lua require("historyHop").main("jumplist", 1)<cr>]],    {"silent"})
map("n", [[j]], [[:lua require("util").addJumpMotion("j", true)<cr>]], {"silent"})
map("n", [[k]], [[:lua require("util").addJumpMotion("k", true)<cr>]], {"silent"})
map("v", [[*]], [[mz`z:<c-u>execute "/" . luaeval('require("util").visualSelection("string")')<cr>]], {"noremap", "silent"})
map("v", [[#]], [[mz`z:<c-u>execute "?" . luaeval('require("util").visualSelection("string")')<cr>]], {"noremap", "silent"})
map("v", [[/]], [[*]])
map("v", [[?]], [[#]])
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"}, "Search forward")
map("n", [[?]], [[?\v]], {"noremap"}, "Search backward")
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[:<c-u>noh<cr>]],               {"silent"}, "Disable highlight")
map("v", [[<leader>h]], [[:<c-u>call ExitVisual()<cr>]], {"silent"})
-- Visual selection
map("n", [[go]],    [[:lua require("selection").oppoSelection()<cr>]], {"silent"}, "Go to opposite of selection")
map("n", [[<A-v>]], [[<C-q>]],                                         {"noremap"}, "Visual Block Mode")
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<c-u>new<cr>]], {"silent", "novscode"}, "New buffer")
-- Open/Search in browser
map("n", [[gl]], [[:lua require("openBrowser").openUrl()<cr>]], {"silent"}, "Open link")
map("v", [[gl]], [[:lua require("openBrowser").openUrl(require("util").visualSelection("string"))<cr>]], {"silent"})
-- Interrupt
map("n", [[<C-A-c>]], [[:<c-u>call interrupt()<cr>]], {"noremap", "silent"}, "Interrupt")
-- Paragraph & Block navigation
-- map("", [[{]], [[:lua require("inclusiveParagraph").main("up")<cr>]],   {"noremap", "silent"})
-- map("", [[}]], [[:lua require("inclusiveParagraph").main("down")<cr>]], {"noremap", "silent"})
-- Line end/start
map("", [[H]], [[^]], "Start of line(non-blank)")
map("", [[L]], [[$]], "End of line")
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"}, "End of line(non-blank)")
-- Trailing character {{{
map("n", [[g.]],      [[:lua require("trailingUtil").trailingChar(".")<cr>]],  {"silent"}, "Trail .")
map("n", [[g,]],      [[:lua require("trailingUtil").trailingChar(",")<cr>]],  {"silent"}, "Trail ,")
map("n", [[g;]],      [[:lua require("trailingUtil").trailingChar(";")<cr>]],  {"silent"}, "Trail ;")
map("n", [[g:]],      [[:lua require("trailingUtil").trailingChar(":")<cr>]],  {"silent"}, "Trail :")
map("n", [[g"]],      [[:lua require("trailingUtil").trailingChar("\"")<cr>]], {"silent"}, 'Trail "')
map("n", [[g']],      [[:lua require("trailingUtil").trailingChar("'")<cr>]],  {"silent"}, "Trail '")
map("n", [[g)]],      [[:lua require("trailingUtil").trailingChar(")")<cr>]],  {"silent"}, "Trail )")
map("n", [[g(]],      [[:lua require("trailingUtil").trailingChar("(")<cr>]],  {"silent"}, "Trail (")
map("n", [[g<CR>]],   [[:lua require("trailingUtil").trailingChar("o")<cr>]],  {"silent"}, "Add new line below")
map("n", [[g<S-CR>]], [[:lua require("trailingUtil").trailingChar("O")<cr>]],  {"silent"}, "Add new line above")
-- }}} Trailing character
-- Messages
vmap("n", [[g>]], [[:<c-u>messages<cr>]])

map("n", [[g<]],        [[:<c-u>messages<cr>]], {"silent"}, "Messages in prompt")
map("n", [[<leader>,]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
map("n", [[<leader>.]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]], "Clear messages")
-- Pageup/Pagedown
map("", [[<C-e>]], [[<C-y>]],      {"noremap",   "novscode"}, "Scroll Up")
map("", [[<C-d>]], [[<C-e>]],      {"noremap",   "novscode"}, "Scroll Down")
map("", [[<A-e>]], [[<PageUp>]],   {"novscode"}, "PageUp")
map("", [[<A-d>]], [[<PageDown>]], {"novscode"}, "PageDown")
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]])
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]])
map("t", [[<C-e>]], [[<C-\><C-n><C-y>]])
map("t", [[<C-d>]], [[<C-\><C-n><C-d>]])

vmap("n", [[<A-e>]], [[:<c-u>call VSCodeCall("cursorPageUp")<cr>]])
vmap("n", [[<A-d>]], [[:<c-u>call VSCodeCall("cursorPageDown")<cr>]])
vmap("i", [[<A-e>]], [[<C-o>:call VSCodeCall("cursorPageUp")<cr>]])
vmap("i", [[<A-d>]], [[<C-o>:call VSCodeCall("cursorPageDown")<cr>]])
vmap("v", [[<A-e>]], [[<C-b>]])
vmap("v", [[<A-d>]], [[<C-f>]])
-- Macro
map("n", [[<A-q>]], [[q]], {"noremap"}, "Macro")
-- Register
-- ClearReg() {{{
cmd [[
function! ClearReg()
    for i in range(34,122) | silent! call setreg(nr2char(i), "") | endfor
    echohl Moremsg | echo "Register clear" | echohl None
endfunction
]]
-- }}} ClearReg()
map("",  [[<C-q>]],     [[:<c-u>reg<cr>]],             {"silent"}, "Registers in prompt")
map("",  [[<leader>']], [[:<c-u>call ClearReg()<cr>]], {"silent"}, "Clear registers")
-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]],     [[:lua require("buffer").smartClose("window")<cr>]], {"silent"}, "Close window")
map("n", [[Q]],     [[:lua require("buffer").smartClose("buffer")<cr>]], {"silent"}, "Close buffer")
map("n", [[<C-u>]], [[:lua require("buffer").restoreClosedBuf()<cr>]],   {"silent"}, "Restore last closed buffer")
-- Window
map("",  [[<C-w>v]], [[:lua require("consistantTab").splitCopy("wincmd v")<cr>]], {"silent", "novscode"})
map("",  [[<C-w>s]], [[:lua require("consistantTab").splitCopy("wincmd s")<cr>]], {"silent", "novscode"})
map("n", [[<C-w>V]], [[:<c-u>only<cr><C-w>v]],                                    {"silent", "novscode"}, "Split only current window vertically")
map("n", [[<C-w>S]], [[:<c-u>only<cr><C-w>s]],                                    {"silent", "novscode"}, "Split only current window")
map("n", [[<C-w>q]], [[:lua require("buffer").quickfixToggle()<cr>]],             {"silent", "novscode"}, "Quickfix toggle")
map("n", [[<C-w>t]], [[:<c-u>tabnew<cr>]],                                        {"silent", "novscode"}, "New tab")
map("",  [[<A-=>]],  [[:<c-u>wincmd +<cr>]],                                      {"silent", "novscode"}, "Increase window size")
map("i", [[<A-=>]],  [[<C-\><C-O>:wincmd +<cr>]],                                 {"silent", "novscode"})
map("",  [[<A-->]],  [[:<c-u>wincmd -<cr>]],                                      {"silent", "novscode"}, "Decrease window size")
map("i", [[<A-->]],  [[<C-\><C-O>:wincmd -<cr>]],                                 {"silent", "novscode"})
map("i", [[<C-w>=]], [[<C-\><C-O>:wincmd =<cr>]],                                 {"silent", "novscode"})
map("n", [[<C-w>o]], [[:lua require("buffer").closeOtherWin()<cr>]],              {"silent", "novscode"})

-- Buffers
map("",  [[<C-w>O]], [[:lua require("buffer").wipeOtherBuf()<cr>]], {"silent", "novscode"}, "Wipe other buffer")
map("n", [[<A-h>]],  [[:<c-u>bp<cr>]],                              {"silent"}, "Previous buffer")
map("n", [[<A-l>]],  [[:<c-u>bn<cr>]],                              {"silent"}, "next buffer")
-- Tab
map("", [[<A-C-h>]],    [[:<c-u>tabp<cr>]],    {"silent", "novscode"}, "Previous tab")
map("", [[<A-C-l>]],    [[:<c-u>tabn<cr>]],    {"silent", "novscode"}, "Next tab")
map("", [[<C-W><C-o>]], [[:<c-u>tabonly<cr>]], {"silent", "novscode"}, "Tab only")
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[<leader>z]], [[:<c-u>call EnhanceFoldHL("No fold marker found", 500, "")<cr>]], {"silent", "novscode"})
map("",  [[zj]], [[<Nop>]])
map("",  [[zk]], [[<Nop>]])
map("",  [[[Z]], [[zk]], {"noremap"}, "Previous fold(integral)")
map("",  [[]Z]], [[zj]], {"noremap"}, "Next fold(integral)")
map("",  [[[z]], [[:<c-u>call EnhanceFoldJump("previous", 1, 0)<cr>]],       {"noremap", "silent", "novscode"}, "Previous fold")
map("",  [[]z]], [[:<c-u>call EnhanceFoldJump("next",     1, 0)<cr>]],       {"noremap", "silent", "novscode"}, "Next fold")
map("n", [[dz]], [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]], {"silent", "novscode"}, "Delete fold")
map("n", [[zd]], [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]], {"silent", "novscode"}, "Delete fold")
map("n", [[cz]], [[:<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>]],   {"silent", "novscode"}, "Change fold")
map("n", [[zc]], [[:<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>]],   {"silent", "novscode"}, "Change fold")
-- TODO: Check whether target line is a comment or not
-- api.nvim_echo({{"text", "Normal"}}, true, {})
map("n", [[g{]],              [[:<c-u>call EnhanceFold(mode(), "{{{")<cr>]],           {"novscode"}, "Add fold start")
map("n", [[g}]],              [[:<c-u>call EnhanceFold(mode(), "}}}")<cr>]],           {"novscode"}, "Add fold end")
map("v", [[g{]],              [[mz:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]], {"novscode"})
map("v", [[g}]],              [[mz:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]], {"novscode"})
map("n", [[<leader><Space>]], [[@=(foldlevel('.') ? 'za' : '\<Space>')<cr>]],          {"noremap", "silent"}, "Open fold")
map("n", [[<C-Space>]],       [[@=(foldlevel('.') ? 'zA' : '\<Space>')<cr>]],          {"noremap", "silent"}, "Open fold recursively")
for i=0, 9 do
    map("",
        string.format("z%d", i),
        string.format([[:set foldlevel=%d<bar>echohl Moremsg<bar>echo 'Foldlevel set to: %d'<bar>echohl None<cr>]], i, i),
        string.format("Set fold level to %d", i)
    )
end
-- }}} Folding
-- MS behavior {{{
-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]],           {"novscode"}, "Undo")
map("v", [[<C-z>]], [[<esc>u]],      {"novscode"})
map("i", [[<C-z>]], [[<C-\><C-o>u]], {"novscode"})

map("n", [[<C-c>]], [[Y]], {"novscode"}, "Undo")
map("v", [[<C-c>]], [[y]], {"novscode"})
-- map("i", [[<C-c>]], [[<C-\><C-o>Y]])

map("n", [[<C-v>]], [[p]],                {"noremap", "novscode"}, "Undo")
map("v", [[<C-v>]], [[<esc>i<C-v><esc>]], {"novscode"})
map("i", [[<C-v>]], [[<C-r>*]],           {"novscode"})

-- map("n", [[<C-s>]], [[:<c-u>w<cr>]],      {"novscode"})
-- map("v", [[<C-s>]], [[:<c-u>w<cr>]],      {"novscode"})
map("i", [[<C-s>]], [[<C-\><C-o>:w<cr>]], {"novscode"})
-- }}} <C-z/x/v/s>
-- Save as..
cmd [[command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<cr> | e!]]
map("",  [[<C-S-s>]], [[:<c-u>Saveas<cr>]],      {"silent", "novscode"}, "Save as...")
map("i", [[<C-S-s>]], [[<C-\><C-o>:Saveas<cr>]], {"silent", "novscode"})
-- Delete
map("n", [[<C-S-d>]], [[:<c-u>d<cr>]],      {"silent", "novscode"}, "Detele line")
map("v", [[<C-S-d>]], [[:d<cr>]],           {"silent", "novscode"})
map("i", [[<C-S-d>]], [[<C-\><C-o>:d<cr>]], {"silent", "novscode"})
-- Highlight New Paste Content
map("n", [[gy]], [[:lua require("yankPut").lastYankPut("yank")<cr>]], {"silent"}, "Select last yank")
map("n", [[gY]], [[gy]], "Select last yank")
map("n", [[gp]], [[:lua require("yankPut").lastYankPut("put")<cr>]],  {"silent"}, "Select last put")
map("n", [[gP]], [[gp]], "Select last put")
-- Put content from registers 0
map("n", [[<leader>p]], [["0p]], "Put after from register 0")
map("n", [[<leader>P]], [["0P]], "Put after from register 0")
-- Inplace yank
map("", [[Y]], [[yy]], "Yank line")
map("", [[y]], [[luaeval("require('operator').main(require('yankPut').inplaceYank, false, nil)")]], {"silent", "expr"}, "Yank operator")
-- Inplace put
map("n", [[p]], [[:lua require("yankPut").inplacePut("n", "p")<cr>]], {"silent"}, "Put after")
map("v", [[p]], [[:lua require("yankPut").inplacePut("v", "p")<cr>]], {"silent"})
map("n", [[P]], [[:lua require("yankPut").inplacePut("n", "P")<cr>]], {"silent"}, "Put before")
map("v", [[P]], [[:lua require("yankPut").inplacePut("v", "P")<cr>]], {"silent"})
-- Inplace replace
-- Convert paste
map("n", [[cP]], [[:lua require("yankPut").convertPut("P")<cr>]], "Convert put")
map("n", [[cp]], [[:lua require("yankPut").convertPut("p")<cr>]], "Convert put")
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
map("i", [[<A-j>]], [[<C-\><C-o>:VSCodeLineMoveDownInsert<cr>]],                 {"silent", "novscode"})
map("i", [[<A-k>]], [[<C-\><C-o>:VSCodeLineMoveUpInsert<cr>]],                   {"silent", "novscode"})
map("n", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("n", "down")<cr>]], {"silent", "novscode"}, "Move line down")
map("n", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("n", "up")<cr>]],   {"silent", "novscode"}, "Move line up")
map("v", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<cr>]], {"silent", "novscode"})
map("v", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<cr>]],   {"silent", "novscode"})
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<cr>]],       {"silent"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<cr>]],         {"silent"})
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<cr>]],                 {"silent"}, "Copy line down")
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<cr>]],                   {"silent"}, "Copy line up")
map("v", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<cr>]], {"silent"})
map("v", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<cr>]],   {"silent"})

vmap("n", [[<A-j>]],   [[:<c-u>call VSCodeCall("editor.action.moveLinesDownAction")<cr>]])
vmap("n", [[<A-k>]],   [[:<c-u>call VSCodeCall("editor.action.moveLinesUpAction")<cr>]])
vmap("i", [[<A-j>]],   [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]])
vmap("i", [[<A-k>]],   [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]])
vmap("i", [[<A-S-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("i", [[<A-S-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("n", [[<A-S-j>]], [[:<c-u>call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("n", [[<A-S-k>]], [[:<c-u>call VSCodeCall("editor.action.copyLinesUpAction")]])
-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[mz:s#\\#\/#e<cr>:noh<cr>g`z]],   {"noremap", "silent"}, [[Convert \ to /]])
map("n", [[g\]], [[mz:s#\/#\\\\#e<cr>:noh<cr>g`z]], {"noremap", "silent"}, [[Convert / to \]])
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]])
map("n", [[<C-`>]],      [[:lua require("terminal").terminalToggle()<cr>]],      {"silent"}, "Terminal toggle")
map("t", [[<C-`>]],      [[<A-n>:lua require("terminal").terminalToggle()<cr>]], {"silent"})
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
map("t", [[<C-w>=]],     [[<A-n><C-w>=:startinsert<cr>]], {"silent"})
map("t", [[<C-w>o]],     [[<A-n><C-w>o:startinsert<cr>]], {"silent"})
map("t", [[<C-w>W]],     [[<A-n><C-w>W:startinsert<cr>]], {"silent"})
map("t", [[<C-w>H]],     [[<A-n><C-w>H:startinsert<cr>]], {"silent"})
map("t", [[<C-w>L]],     [[<A-n><C-w>L:startinsert<cr>]], {"silent"})
map("t", [[<C-w>J]],     [[<A-n><C-w>J:startinsert<cr>]], {"silent"})
map("t", [[<C-w>K]],     [[<A-n><C-w>K:startinsert<cr>]], {"silent"})
-- TODO: Split terminal in new instance
-- }}} Mode: Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<C-k>]], [[pumvisible() ? "\<C-e>\<Up>" : "\<Up>"]],     {"expr"})
map("i", [[<C-j>]], [[pumvisible() ? "\<C-e>\<Down>" : "\<Down>"]], {"expr"})
map("i", [[<C-cr>]],  [[<esc>o]],  {"novscode"})
map("i", [[<S-cr>]],  [[<esc>O]],  {"novscode"})
map("i", [[jj]],      [[<esc>`^]], {"noremap", "novscode"})
map("i", [[<C-d>]],   [[<Del>]],   {"novscode"})
map("i", [[<C-.>]],   [[<C-a>]],   {"noremap"})
map("i", [[<C-BS>]],  [[<C-w>]],   {"noremap"})
map("i", [[<C-y>]],   [[pumvisible() ? "\<C-e>\<C-y>" : "\<C-y>"]], {"noremap", "expr", "novscode"})
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
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<cr>]])
map("c", [[<C-S-l>]], [[<C-d>]], {"noremap"})
map("c", [[<C-d>]],   [[<Del>]])
map("c", [[<C-S-e>]], [[<C-\>e]])
map("c", [[<C-v>]],   [[<C-R>*]])
-- }}} Mode: Commandline & Insert

return M

