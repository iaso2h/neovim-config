local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local o   = vim.opt

-- let &path.="src/include,/usr/include/AL,"
if ex("rg") then
    o.grepprg = "rg --vimgrep --smart-case --follow --with-filename --line-number"
    -- o.grepformat = "%f:%l:%c:%m"
end

-- Basic settings {{{
o.autoindent = true
o.cindent    = true
o.copyindent = true

o.expandtab   = true
o.shiftround  = true
o.shiftwidth  = 4
o.softtabstop = 4
o.tabstop     = 4

if jit.os == "Windows" then
    -- o.clipboard = "unnamed"
else
    o.clipboard = "unnamed,unnamedplus"
end

o.cmdheight  = 2
o.shortmess  = "cxTIFSs"

o.complete    = ".,w,b,u,t,kspell,i,d,t"
o.completeopt = "menuone,noinsert,noselect"

o.conceallevel  = 0
o.concealcursor = "nc"

o.cpoptions:append"q;"
o.cursorline  = true
-- o.colorcolumn = 80

-- o.diffopt        = "context:10000,filler,closeoff,vertical,algorithm:patience"
o.diffopt    = "context:100,algorithm:histogram,internal,indent-heuristic,filler,closeoff,iwhite,vertical"

o.langmenu      = "en"
o.fileencodings = "utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"
o.modelineexpr  = true

o.fillchars = "fold: ,vert:▏,eob: ,diff:╱"
o.list      = true
o.listchars = "tab:>_,precedes:«,extends:»,nbsp:␣"
-- o.listchars = "tab:>-,precedes:«,extends:»,nbsp:␣,eol:↵,trail:•"
o.showbreak = "⤷ "

o.foldcolumn = "auto:4"
o.signcolumn = "auto:4"
o.foldmethod = "expr"
o.foldexpr   = "EnhanceFoldExpr()"

o.inccommand = "nosplit"
o.gdefault   = true
o.ignorecase = true
o.smartcase  = true
o.lazyredraw = true

o.hidden     = true
o.matchpairs = "[:],{:},(:),《:》,（:）,【:】,“:”,‘:’"
o.joinspaces = false

o.mouse         = "a"
o.number        = true
o.ruler         = false
o.scrolloff     = 7
o.showtabline   = 2
o.showcmd       = false
o.showmode      = false
o.termguicolors = true

o.path:append"**"
o.shada          = "!,'100,/100,:100,<100,s100,h"
o.fileignorecase = true
o.sessionoptions = "buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize"
o.undofile       = true
o.undodir        = fn.expand("$HOME/.cache/nvim/undodir")
o.backup         = false
o.swapfile       = false
o.writebackup    = false


o.wildignore     = vim.o.wildignore .. "*/tmp/*,*.so,*.swp,*.zip,*.db,*.sqlite,*.bak"
o.wildignorecase = true
o.wildoptions    = "pum"

vim.g.winminheight = 2
o.winminwidth      = 3
o.winheight        = 3
o.winhighlight     = "NormalNC:WinNormalNC"
o.splitbelow       = true
o.splitright       = true
-- o.switchbuf        = "split"

-- GUI
-- cmd [[colorscheme onedarknord]]
cmd [[colorscheme onenord]]
GuiFont = "Delugia"
-- GuiFont = "UbuntuMono Nerd Font"
-- GuiFont = "Sarasa Mono SC Nerd"
-- GuiFont = "FiraCode Nerd Font"
GuiFontSize        = 12
GuiFontSizeDefault = GuiFontSize
o.guifont = GuiFont ..":h" .. GuiFontSize

-- if vim.g.neovide ~= nil then
    -- vim.o.guifont = "更纱黑体 Mono SC Nerd:h" .. (GuiFontSizes + 5)
-- else
    -- vim.o.guifont = "更纱黑体 Mono SC Nerd:h" .. GuiFontSizes
-- end
o.guicursor = "n-v-sm:block,i-c-ci:ver25-Cursor,ve-o-r-cr:hor20"
-- }}} Basic settings
-- OS varied settings {{{
if jit.os == "Windows" then
    -- o.shell="powershell"
    -- o.shellquote="shellpipe= shellxquote="
    -- o.shellcmdflag="-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    -- o.shellredir=" Out-File -Encoding UTF8"
    -- Python executable
    local winPython = fn.expand("$HOME/AppData/Local/Programs/Python/Python38/python.exe")
    api.nvim_set_var("python3_host_prog", winPython)
    if fn.executable(winPython) == 0 then
        local pythonPath = (string.gsub(fn.system('python -c "import sys; print(sys.executable)"'),"(\n+$)", ""))
        api.nvim_set_var("python3_host_prog", pythonPath)
        if not fn.executable(api.nvim_get_var("python3_host_prog")) then
            api.nvim_err_write("Python path not found\n")
        end
    end
elseif jit.os == "Linux" then
    local linuxPython = "/usr/bin/python3"
    api.nvim_set_var("python3_host_prog", linuxPython)
    if fn.executable(linuxPython) == 0 then
        linuxPython = (fn.system('which python3')):gsub("\n+$", "")
        api.nvim_set_var("python3_host_prog", linuxPython)
        if not fn.executable(api.nvim_get_var("python3_host_prog")) then
            api.nvim_err_write("Python path not found\n")
        end
    end
end
-- }}} OS varied settings
-- Neovide settings {{{
if vim.g.neovide then
    vim.g.neovide_no_idle                 = true
    vim.g.neovide_cursor_animation_length = 0.04
    vim.g.neovide_cursor_trail_length     = 0.6
    -- vim.g.neovide_cursor_antialiasing     = true
    vim.g.neovide_window_floating_blur    = false
    vim.g.neovide_transparency            = 1.0
    vim.g.neovide_refresh_rate            = 60
    -- vim.g.neovide_cursor_vfx_mode = "pixiedust"
end
-- }}} Neovide settings

