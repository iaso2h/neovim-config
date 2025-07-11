-- Auto commands {{{
-- Minimal terminal filetype
local augroupTerm = vim.api.nvim_create_augroup("myTerminal", {clear = true})
vim.api.nvim_create_autocmd("TermOpen", {
    group    = augroupTerm,
    desc     = "Minimal filetype settings for terminal",
    callback = function()
        vim.opt_local.buflisted = false
        vim.cmd[[startinsert]]
    end
})
vim.api.nvim_create_autocmd("BufEnter", {
    group   = augroupTerm,
    pattern = "term://*",
    desc    = "Start insert on entering terminal",
    command = "startinsert"
})


local augroupWrite = vim.api.nvim_create_augroup("myWriting", {clear = true})
vim.api.nvim_create_autocmd("BufWritePre", {
    group   = augroupWrite,
    desc     = "Clean up the code before saving",
    callback = function ()
        require("util").trimSpaces()
    end
})

if _G._autoreload then
    vim.api.nvim_create_autocmd("BufWritePost", {
        group   = augroupWrite,
        pattern = "*.lua,*.vim",
        desc     = "Autoreload configuration after saving lua/vim configuration files",
        callback = function ()
            -- Similar work: https://github.com/RRethy/nvim-sourcerer
            if _G._enable_plugin and _G._autoreload then
                require("autoreload").reload()
            end
        end
    })
end


vim.api.nvim_create_autocmd("BufReadPost", {
    desc     = "Place the cursor on the last position",
    callback = function(arg)
        -- Credit: https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
        require("buffer.cursorRecall")(arg)
    end
})

-- }}} Auto commands

-- Commands {{{
if _G._os_uname.sysname == "Windows_NT" then
    vim.api.nvim_create_user_command("PS", [[terminal powershell]], { -- {{{
        desc  = "Open powershell",
        nargs = 0,
    }) -- }}}
end

vim.api.nvim_create_user_command("DeleteEmptyLines", [['<,'>g#^\s*$#d]], { -- {{{
    desc  = "Delete empty lines from selection",
    nargs = 0,
    range = true,
}) -- }}}

vim.api.nvim_create_user_command("Redir", function(opts) -- {{{
    local output = vim.api.nvim_exec2(opts.args, {output = true}).output
    local lines = vim.split(output, "\n", {plain = true, trimempty = true})
    require("buffer.util").redirScratch(lines, nil)
end, {
    desc     = "Echo from Scriptease plug-ins",
    nargs    = 1,
    complete = "command",
}) -- }}}

vim.api.nvim_create_user_command("ExtractToFile", function(opts) -- {{{
    local argPath = string.match(opts.args, "^%s*$") and "" or opts.args
    if opts.range == 0 then
        -- Extract the current line when no range selected
        vim.cmd([[noa norm! V]] .. t"<Esc>")
    end

    require("extraction").operator { vimMode = vim.fn.visualmode(), path = argPath }
end, {
    desc  = "Extract selection to a new file",
    range = true,
    nargs = "?",
    complete = function(ArgLead, CmdLine, CursorPos)
        local targetFile
        if ArgLead == "" then
            targetFile = vim.loop.cwd() .. _G._sep .. ArgLead
        else
            targetFile = ArgLead
        end
        if not vim.loop.fs_stat(targetFile) then return {} end

        local targetFilePaths = vim.fn.globpath(targetFile, "*")
        return vim.split(targetFilePaths, "\n", { plain = true, trimempty = false })
    end
}) -- }}}

vim.api.nvim_create_user_command("Reverse", function(opts) -- {{{
    if opts.range == 0 then return end
    if vim.fn.visualmode() == "V" then
        return vim.api.nvim_echo({ { "Not support visual line mode", "WarningMsg" } }, true, {})
    end
    vim.cmd("norm! gvd")
    local keyStr = "i" .. string.reverse(vim.fn.getreg("-", 1)) .. t"<ESC>"
    vim.api.nvim_feedkeys(keyStr, "tn", true)
end, {
    desc  = "Reverse selection",
    range = true,
    nargs = 0,
}) -- }}}

vim.api.nvim_create_user_command("CompileCode", -- {{{
    function() require("compileRun").compileCode(true) end,
    { desc = "Compile code",  }
) -- }}}

vim.api.nvim_create_user_command("RunCode", -- {{{
    require("compileRun").runCode,
    { desc = "Run code",  }
) -- }}}

vim.api.nvim_create_user_command("RunSelection", function() -- {{{
    if vim.bo.filetype ~= "lua" then
       return vim.api.nvim_echo({ { "Only support in Lua file", "WarningMsg" } }, true, {})
    end

    local vimMode = vim.fn.visualmode()
    if vimMode == "\22" then
        return vim.api.nvim_echo({ { "Blockwise visual mode is not supported", "WarningMsg" } }, true, {})
    end

    local lineStr = require("selection").get("string", false)
    -- TODO: support run multiple lines at the same time
    -- Similar work lua-dev
    if vimMode == "V" then
        lineStr = string.gsub(lineStr, "\n", "")
    end

    vim.cmd("lua " .. lineStr)
end, {
    desc  = "Run selection in lua syntax",
    range = true,
}) -- }}}

vim.api.nvim_create_user_command("Cfilter", function(opts) -- {{{
    require("quickfix.cFilter")(true, opts.args, opts.bang)
end, {
    desc  = "Filter quickfix window",
    bang  = true,
    nargs = 1,
}) -- }}}

vim.api.nvim_create_user_command("Lfilter", function(opts) -- {{{
    require("quickfix.cFilter")(false, opts.args, opts.bang)
end, {
    desc  = "Filter localfix window",
    bang  = true,
    nargs = 1,
}) -- }}}

vim.api.nvim_create_user_command("CD", -- {{{
    [[execute "lcd " . expand("%:p:h")]],
    { desc = "Change the current working directory to the current buffer locally",
}) -- }}}

vim.api.nvim_create_user_command("CDConfig", -- {{{
    [[execute "lcd " . stdpath("config")]],
    { desc = "Change the current working directory to configuration path",
}) -- }}}

vim.api.nvim_create_user_command("CDRuntime", -- {{{
    [[execute "lcd $VIMRUNTIME"]],
    { desc = "Change the current working directory to Neovim runtime path",
}) -- }}}

vim.api.nvim_create_user_command("E", function (opts) -- {{{
    if require("buffer.util").isSpecialBuf(vim.api.nvim_get_current_buf()) then
        return
    end
    vim.cmd [[noa mkview]]
    if not opts.bang then
        vim.cmd [[update! | e]]
    else
        vim.cmd [[e!]]
    end

    vim.cmd [[loadview | norm! zv]]
end, {
    desc = "Reopen the the current file while maintaining the window layout",
    bang = true,
}) -- }}}

vim.api.nvim_create_user_command("O", -- {{{
    [[browse oldfiles]],
    { desc = "Browse the oldfiles then prompt",
}) -- }}}

local sessionDir  = vim.fn.stdpath "state" .. pathStr "/my_session/"
local sessionComp = function(ArgLead, CmdLine, CursorPos) -- {{{
    local filePaths = vim.fn.globpath(sessionDir .. ArgLead, "*.vim")
    if filePaths == "" then return {} end

    local sessionDirPlain = string.gsub(sessionDir, "%-", "%%-")
    local filePathsTail = string.gsub(filePaths, sessionDirPlain, "")
    return vim.split(filePathsTail, "\n", { plain = true, trimempty = false })
end -- }}}
vim.api.nvim_create_user_command("Q", function (opts) -- {{{
    local saveCMD = opts.bang and "noa silent " or "noa silent bufdo update | "
    local sessionName = opts.args == "" and "01.vim" or opts.args
    if not vim.loop.fs_stat(sessionDir) then
        vim.fn.mkdir(sessionDir, "p")
    end
    vim.cmd(string.format("mksession! %s%s", sessionDir, sessionName))

    vim.cmd(saveCMD .. "qa!")
end, {
    desc  = "Quit and save the session",
    nargs = "?",
    bang  = true,
    complete = sessionComp
}) -- }}}

local purge = function(slientChk) -- {{{
    -- Delete invalid buffers
    local cond = function(bufNr)
        local bufName = nvim_buf_get_name(bufNr)
        return vim.api.nvim_get_option_value("buflisted", {buf = bufNr}) and
            not vim.loop.fs_stat(bufName)
    end
    local inValidBufNrs = vim.tbl_filter(cond, vim.api.nvim_list_bufs())
    if not next(inValidBufNrs) then
        if not slientChk then
            return vim.api.nvim_echo({ { "No buffer has been purged", "WarningMsg" } }, true, {})
        else
            return
        end
    end
    for _, bufNr in ipairs(inValidBufNrs) do
        vim.schedule_wrap(function()
            require("buffer.util").initBuf(bufNr)
            require("buffer.util").bufClose(bufNr, true, true)
        end)()
    end
end -- }}}
vim.api.nvim_create_user_command("Purge", function() purge(false) end, { -- {{{
    desc  = "Purge invalid buffers",
    nargs = 0,
}) -- }}}

vim.api.nvim_create_user_command("Se", function (opts) -- {{{
    local sessionName = opts.args == "" and "01.vim" or opts.args
    local sessionPath = sessionDir .. sessionName
    if not vim.loop.fs_stat(sessionPath) then return vim.api.nvim_echo({ { "Session file doesn't exist.", "WarningMsg" } }, true, {}) end

    local ok, msgOrVal = pcall(vim.cmd, "source " .. sessionPath)
    if not ok and
        -- not string.find(msgOrVal, "E592: ", 1, true) and
        not string.find(msgOrVal, "E490: ", 1, true) then

        vim.api.nvim_echo(
            {{"Error occurred while soucing " .. sessionPath}},
            true,
            {}
        )
        vim.api.nvim_echo({{msgOrVal,}}, true, {err=true})
    end
    -- purge(true)
end, {
    desc  = "Load session",
    nargs = "?",
    complete = sessionComp
}) -- }}}

vim.api.nvim_create_user_command("Dofile", function (opts) -- {{{
    local ft = vim.bo.filetype
    if ft == "lua" then
        if opts.bang then
            local moduleName = vim.fn.expand("%:t:r")
            if package.loaded[moduleName] then
                package.loaded[moduleName] = nil
            elseif package.loaded[moduleName .. ".lua"] then
                package.loaded[moduleName .. ".lua"] = nil
            end
        end

        local filePath = nvim_buf_get_name(0)
        local idx = {string.find(
            filePath,
            _G._config_path .. pathStr "/lua/")}
        if next(idx) then
            local tail = filePath:sub(idx[2] + 1, -1)
            local root = tail:sub(1, -5)
            local moduleName = root:gsub(_G._sep, ".")
            require(moduleName)
        else
            vim.cmd("luafile " .. filePath)
        end

        if _G._enable_plugin and _G._autoreload then
            require("autoreload").reload()
        end
    elseif ft == "vim" then
        vim.cmd [[source %]]
    end
end, {
    desc = "Reload the current file in lua/vim runtime",
    bang = true
}) -- }}}

vim.api.nvim_create_user_command("O", [[browse oldfiles]], { desc = "Browse the oldfiles then prompt", })

vim.api.nvim_create_user_command("TrimBufferSpaces", -- {{{
    function()require("util").trimSpaces()end,
    { desc = "Toggle trimming spaces on save",  }
) -- }}}

vim.api.nvim_create_user_command("RandomTheme", function (opts) -- {{{
    require("randomTheme").apply()
end, {
    desc = "Randomize all highlight groups",
}) -- }}}

vim.api.nvim_create_user_command("TSLoaded", function (opts) -- {{{
    if require("vim.treesitter.highlighter").active[vim.api.nvim_get_current_buf()] then
        vim.api.nvim_echo({{"Treesitter is loaded in current buffer", "MoreMsg"}}, false, {})
    else
        vim.api.nvim_echo({{"Treesitter isn't loaded in current buffer", "DiagnosticWarn"}}, false, {})
    end
end, {
    desc = "Check if treesitter is loaded in current buffer",
}) -- }}}
-- }}} Commands
