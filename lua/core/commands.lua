-- Auto commands {{{
-- Minimal terminal filetype
local augroupTerm = vim.api.nvim_create_augroup("myTerminal", {clear = true})
vim.api.nvim_create_autocmd("TermOpen", {
    group    = augroupTerm,
    desc     = "Minimal filetype settings for terminal",
    callback = function()
        vim.opt_local.buflisted = false
        vim.opt_local.number = false
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
        require("buffer.cursorRecall").main(arg)
    end
})

-- HACK: https://github.com/neovim/neovim/issues/2127
vim.api.nvim_create_autocmd({"FocusGained", "WinEnter"}, {
    desc    = "Check and file changes after regaining focus",
    command = "checktime"
})
-- }}} Auto commands

-- Commands {{{
if _G._os_uname.sysname == "Windows_NT" then
    vim.api.nvim_create_user_command("PS", [[terminal powershell]], {
        desc  = "Open powershell",
        nargs = 0,
    })
end

vim.api.nvim_create_user_command("DeleteEmptyLines", [['<,'>g#^\s*$#d]], {
    desc  = "Delete empty lines from selection",
    nargs = 0,
    range = true,
})

vim.api.nvim_create_user_command([[PP strftime('%c') . ": " . <args>]], "Echo", {
    desc     = "Echo from Scriptease plug-ins",
    nargs    = "+",
    complete = "command",
})

vim.api.nvim_create_user_command("Redir", function(opts)
    require("buffer.redir").catch(opts.args)
end, {
    desc     = "Echo from Scriptease plug-ins",
    nargs    = "+",
    complete = "command",
})

vim.api.nvim_create_user_command("ExtractToFile", function(opts)
    if opts.range == 0 then
        -- Extract the current line when no range selected
        vim.cmd([[noa norm! V]] .. t"<Esc>")
        require("extraction").main({ nil, vim.fn.visualmode() })
    elseif opts.range == 2 then
        require("extraction").main({ nil, vim.fn.visualmode() })
    end
end, {
    desc  = "Extract selection to a new file",
    range = true,
    nargs = 0,
})

vim.api.nvim_create_user_command("Reverse", function(opts)
    if opts.range == 0 then return end
    if vim.fn.visualmode() == "V" then
        return vim.notify("Not support visual line mode", vim.log.levels.WARN)
    end
    vim.cmd("norm! gvd")
    local keyStr = "i" .. string.reverse(vim.fn.getreg("-", 1)) .. t"<ESC>"
    vim.api.nvim_feedkeys(keyStr, "tn", true)
end, {
    desc  = "Reverse selection",
    range = true,
    nargs = 0,
})

vim.api.nvim_create_user_command("RunSelection", function()
    if vim.bo.filetype ~= "lua" then
       return vim.notify("Only support in Lua file", vim.log.levels.WARN)
    end

    local vimMode = vim.fn.visualmode()
    if vimMode == "\22" then
        return vim.notify("Blockwise visual mode is not supported", vim.log.levels.WARN)
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
})

vim.api.nvim_create_user_command("Cfilter", function(opts)
    require("quickfix.cFilter").main(true, opts.args, opts.bang)
end, {
    desc  = "Filter quickfix window",
    bang  = true,
    nargs = "+",
})

vim.api.nvim_create_user_command("Lfilter", function(opts)
    require("quickfix.cFilter").main(false, opts.args, opts.bang)
end, {
    desc  = "Filter localfix window",
    bang  = true,
    nargs = "+",
})

vim.api.nvim_create_user_command("CD", [[execute "lcd " . expand("%:p:h")]], {
    desc = "Change the current working directory to the current buffer locally",
})

vim.api.nvim_create_user_command("CDConfig", [[execute "lcd " . stdpath("config")]], {
    desc = "Change the current working directory to configuration path",
})

vim.api.nvim_create_user_command("CDRuntime", [[execute "lcd $VIMRUNTIME"]], {
    desc = "Change the current working directory to Neovim runtime path",
})

vim.api.nvim_create_user_command("E", function (opts)
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
})

vim.api.nvim_create_user_command("O", [[browse oldfiles]], { desc = "Browse the oldfiles then prompt", })

vim.api.nvim_create_user_command("Q", function (opts)
    local saveCMD = opts.bang and "noa silent " or "noa silent bufdo update | "
    local sessionName = opts.args == "" and "01" or opts.args
    local sessionDir  = vim.fn.stdpath("state") .. _G._sep .. "my_session" .. _G._sep
    if not vim.loop.fs_stat(sessionDir) then
        vim.fn.mkdir(sessionDir, "p")
    end
    vim.cmd(string.format("mksession! %s%s.vim", sessionDir, sessionName))

    vim.cmd(saveCMD .. "qa!")
end, {
    desc  = "Quit and save the session",
    nargs = "?",
    bang  = true,
})

vim.api.nvim_create_user_command("Se", function (opts)
    local sessionName = opts.args == "" and "01" or opts.args
    local sessionDir  = vim.fn.stdpath("state") .. _G._sep .. "my_session" .. _G._sep
    vim.cmd(string.format("so %s%s%s%s.vim",
        sessionDir, _G._sep, _G._sep, sessionName))

    -- Delete invalid buffers
    local invalidBufNrs = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_get_option(buf, "buflisted") and
            not vim.loop.fs_stat(vim.api.nvim_buf_get_name(buf))
    end, vim.api.nvim_list_bufs())

    for _, bufNr in ipairs(invalidBufNrs) do
        vim.api.nvim_buf_delete(bufNr, {})
    end
end, {
    desc  = "Load session",
    nargs = "?",
})

vim.api.nvim_create_user_command("Dofile", function (opts)
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
            _G._config_path .. _G._sep .. "lua" .. _G._sep)}
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
})

vim.api.nvim_create_user_command("O", [[browse oldfiles]], { desc = "Browse the oldfiles then prompt", })
vim.api.nvim_create_user_command("OnSaveTrimSpaces", function ()
    _G._trim_space = _G._trim_space or true
    _G._trim_space = not _G._trim_space
    vim.api.nvim_echo({ { string.format("OnSaveTrimSpaces: %s", _G._trim_space), "Moremsg" } }, false, {})
end, { desc = "Toggle trimming spaces on save", })

vim.api.nvim_create_user_command("TrimBufferSpaces", function ()
    require("util").trimSpaces()
end, { desc = "Toggle trimming spaces on save", })
-- }}} Commands
