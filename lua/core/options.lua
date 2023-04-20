local opt = vim.opt
local ex  = require("util").ex

-- let &path.="src/include,/usr/include/AL,"
if ex("rg") then
    opt.grepprg = "rg --vimgrep --smart-case --follow --with-filename --line-number"
    -- o.grepformat = "%f:%l:%c:%m"
end

opt.cindent    = true
opt.copyindent = true

opt.expandtab   = true
opt.shiftround  = true
opt.shiftwidth  = 4
opt.softtabstop = 4
opt.tabstop     = 4

if _G._os_uname.sysname == "Windows_NT" then
    opt.clipboard = "unnamed"
    opt.keywordprg = ":help"
elseif _G._os_uname.machine ~= "aarch64" then
    opt.clipboard = "unnamed,unnamedplus"
    opt.keywordprg = ":Man"
end

opt.cmdheight = 2
opt.shortmess = "cxTIFSs"

opt.complete    = ".,w,b,u,t,kspell,i,d,t"
opt.completeopt = "menuone,noinsert,noselect"

opt.conceallevel  = 0
opt.concealcursor = "nc"

opt.cpoptions:append"q;"
opt.cursorline = true
opt.guicursor  = "n-v-sm:block,i-c-ci-ve:ver25,r-cr:hor20,o:hor50"

opt.diffopt = "context:100,linematch:60,algorithm:histogram,filler,closeoff,hiddenoff,iwhite,vertical"

if _G._os_uname.machine == "aarch64" then
    vim.cmd [[language en_US]]
end
opt.langmenu      = "en"
opt.fileencodings = "utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"
opt.modelineexpr  = true

opt.fillchars = "msgsep:─,fold:-,eob: ,diff:╱,foldopen:,foldclose:"
opt.list      = true
opt.listchars = "tab:>_,precedes:«,extends:»,nbsp:␣"
-- o.listchars = "tab:>-,precedes:«,extends:»,nbsp:␣,eol:↵,trail:•"
opt.showbreak = "⤷ "

opt.foldcolumn = "auto:4"
opt.signcolumn = "yes:1"
opt.foldmethod = "expr"
opt.foldexpr   = "EnhanceFoldExpr()"
opt.formatoptions = _G._format_option -- NOTE: Might change on loading different types of ftplugins

opt.inccommand = "nosplit"
opt.gdefault   = true
opt.ignorecase = true
opt.smartcase  = true
opt.lazyredraw = true

opt.matchpairs = "[:],{:},(:),《:》,（:）,【:】,“:”,‘:’"

opt.jumpoptions = "stack"
opt.scrolloff   = 10

opt.number        = true
opt.ruler         = false
opt.showtabline   = 2
opt.showcmd       = false
opt.showmode      = false
opt.termguicolors = true

opt.shada          = "!,'100,/100,:100,<100,s100,h"
opt.fileignorecase = true
opt.sessionoptions = "buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize"
opt.backup         = false
opt.swapfile       = false

opt.wildignore     = vim.o.wildignore .. "*/tmp/*,*.so,*.swp,*.zip,*.db,*.sqlite,*.bak"
opt.wildignorecase = true

opt.winminwidth  = 3
opt.winheight    = 3
opt.winhighlight = "NormalNC:WinNormalNC"
opt.splitbelow   = true
opt.splitright   = true
opt.switchbuf    = "uselast"

-- GUI
vim.cmd [[colorscheme onenord]]
local guiFont
local guiFallbackFont
local guiFontSize
local guiFontSizeDefault
-- guiFont = "VictorMono NFM"
guiFont = "Cascadia Code"
-- guiFallbackFont = ""
-- guiFallbackFont = ",codicon"
guiFallbackFont = ",nonicons"
-- guiFont = "UbuntuMono Nerd Font"
-- guiFont = "Sarasa Mono SC Nerd"
-- guiFont = "FiraCode Nerd Font"
if vim.g.neovide then
    guiFontSize = 14
else
    guiFontSize = 12
end
guiFontSizeDefault = guiFontSize
opt.guifont = string.format("%s%s:h%s", guiFont, guiFallbackFont, guiFontSize)
-- Change font size (GUI client only)
if not _G._is_term then
    map({"n", "x"}, [[<C-->]], function()
        guiFontSize = guiFontSize - 1
        vim.o.guifont = guiFont ..":h" .. guiFontSize
    end, {"silent"}, "Increase GUI client font size")
    map({"n", "x"}, [[<C-=>]], function()
        guiFontSize = guiFontSize + 1
        vim.o.guifont = guiFont ..":h" .. guiFontSize
    end, {"silent"}, "Decrease GUI client font size")
    map({"n", "x"}, [[<C-0>]], function()
        vim.o.guifont = guiFont ..":h" .. guiFontSizeDefault
    end, {"silent"}, "Restore GUI client font size")
end

if vim.g.neovide then
    vim.g.neovide_confirm_quit                = false
    vim.g.neovide_cursor_animate_command_line = true
    vim.g.neovide_cursor_animation_length     = 0.04
    vim.g.neovide_cursor_antialiasing         = false
    vim.g.neovide_cursor_trail_length         = 0.6
    -- vim.g.neovide_cursor_vfx_mode             = "pixiedust"
    vim.g.neovide_hide_mouse_when_typing      = true
    vim.g.neovide_no_idle                     = true
    vim.g.neovide_refresh_rate                = 60
    vim.g.neovide_refresh_rate_idle           = 5
    vim.g.neovide_remember_previous_window    = true
    vim.g.neovide_transparency                = 1.0
    vim.g.neovide_window_floating_blur        = false
end
