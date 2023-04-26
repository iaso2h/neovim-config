local api = vim.api
local augroup = function(...)
    return api.nvim_create_augroup(...)
end
local au = function(...)
    return api.nvim_create_autocmd(...)
end
local excmd = function(...)
    return api.nvim_create_user_command(...)
end

-- Function {{{

vim.g.FiletypeCommentDelimiter = {
    vim    = "\"",
    python = "#",
    sh     = "#",
    zsh    = "#",
    fish   = "#",
    c      = "\\/\\/",
    cpp    = "\\/\\/",
    json   = "\\/\\/",
    conf   = "\\/\\/",
    lua    = "--",
}

if not vim.g.vscode then
    vim.g.enhanceFoldStartPat = {
        vim    = [=[\s*".*{{{.*$]=],
        python = [=[\s*#.*{{{.*$]=],
        c      = [=[\s*//.*{{{.*$]=],
        cpp    = [=[\s*//.*{{{.*$]=],
        json   = [=[\s*//.*{{{.*$]=],
        conf   = [=[\s*//.*{{{.*$]=],
        lua    = [=[\s*--.*{{{.*$]=],
        sh     = [=[\s*#.*{{{.*$]=],
        zsh    = [=[\s*#.*{{{.*$]=],
        fish   = [=[\s*#.*{{{.*$]=],
    }
    vim.g.enhanceFoldEndPat = {
        vim    = [=[\s*".*}}}.*$]=],
        python = [=[\s*#.*}}}.*$]=],
        c      = [=[\s*//.*}}}.*$]=],
        cpp    = [=[\s*//.*}}}.*$]=],
        json   = [=[\s*//.*}}}.*$]=],
        conf   = [=[\s*//.*}}}.*$]=],
        lua    = [=[\s*--.*}}}.*$]=],
        sh     = [=[\s*#.*}}}.*$]=],
        zsh    = [=[\s*#.*}}}.*$]=],
        fish   = [=[\s*#.*}}}.*$]=],
    }

    vim.cmd [[
    function! EnhanceFoldExpr()
        " BUG: let line = nvim_get_current_line()
        let line = getline(v:lnum)
        if match(line, g:enhanceFoldStartPat[&filetype]) > -1
            return "a1"
        elseif match(line, g:enhanceFoldEndPat[&filetype]) > -1
            return "s1"
        else
            return "="
        endif
    endfunction
    ]]
end


if _G._is_term then
    vim.cmd [[
    function! RemoveLastPathComponent()
        let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
        let l:cmdlineAfterCursor  = strpart(getcmdline(), getcmdpos() - 1)
        PP l:cmdlineAfterCursor
        PP l:cmdlineBeforeCursor
        let l:cmdlineRoot         = fnamemodify(cmdlineBeforeCursor, ':r')
        let l:result              = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
        call setcmdpos(strlen(l:result) + 1)
        return l:result . l:cmdlineAfterCursor
    endfunction
    ]]
end

-- }}} Function

-- Auto commands {{{
-- Minimal terminal filetype
local augroupTerm = augroup("myTerminal", {clear = true})
au("TermOpen", {
    group    = augroupTerm,
    desc     = "Minimal filetype settings for terminal",
    callback = function()
        vim.opt_local.buflisted = false
        vim.opt_local.number = false
        vim.cmd[[startinsert]]
    end
})
au("BufEnter", {
    group   = augroupTerm,
    pattern = "term://*",
    desc    = "Start insert on entering terminal",
    command = "startinsert"
})


local augroupWrite = augroup("myWriting", {clear = true})
au("BufWritePre", {
    group   = augroupWrite,
    desc     = "Clean up the code before saving",
    callback = function ()
        require("util").trimSpaces()
    end
})

if _G._autoreload then
    au("BufWritePost", {
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

-- HACK: not working properly https://github.com/fatih/vim-go/issues/502
au("BufWritePost", {
    group   = augroupWrite,
    desc    = "Avoiding folding after making modification on a buffer for the first time",
    callback = function()
        vim.api.nvim_feedkeys("zv", "nt", false)
        -- vim.cmd[[normal! zxzv]]
    end
})

au("BufReadPost", {
    desc     = "Place the cursor on the last position",
    callback = function(arg)
        -- Credit: https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
        require("buf.action.cursorRecall").main(arg)
    end
})

-- HACK: https://github.com/neovim/neovim/issues/2127
au({"FocusGained", "WinEnter"}, {
    desc    = "Check and file changes after regaining focus",
    command = "checktime"
})

if not _G._qf_fallback_open then
    au("BufLeave", {
        desc    = "Record the current window id before leaving the current buffer",
        callback = function ()
            -- if not vim.bo.buflisted then return end
            local bufNr = api.nvim_get_current_buf()
            local bufName = nvim_buf_get_name(bufNr)
            local bufType = vim.bo.buftype
            local winID = api.nvim_get_current_win()
            local winConfig = api.nvim_win_get_config(winID)
            -- Non-float window and non-special buffer type and non-scratch buffer file
            if winConfig.relative == "" and bufType == "" and bufName ~= "" then
                _G._last_win_id = winID
            end
        end
    })
end
-- }}} Auto commands

-- Commands {{{
if _G._os_uname.sysname == "Windows_NT" then
    excmd("PS", [[terminal powershell]], {
        desc     = "Open powershell",
        nargs    = 0,
    })
end

excmd("DeleteEmptyLines", [['<,'>g#^\s*$#d]], {
    desc     = "Delete empty lines from selection",
    nargs    = 0,
    range    = true,
})

excmd([[PP strftime('%c') . ": " . <args>]], "Echo", {
    desc     = "Echo from Scriptease plug-ins",
    nargs    = "+",
    complete = "command",
})

excmd("Redir", function(opts)
    require("buf.action.redir").catch(opts.args)
end, {
    desc     = "Echo from Scriptease plug-ins",
    nargs    = "+",
    complete = "command",
})

excmd("ExtractToFile", function(opts)
    if opts.range == 0 then
        -- Extract the current line when no range selected
        vim.cmd([[noa norm! V]] .. t"<Esc>")
        require("extraction").main({ nil, vim.fn.visualmode() })
    elseif opts.range == 2 then
        require("extraction").main({ nil, vim.fn.visualmode() })
    end
end, {
    desc     = "Extract selection to a new file",
    range    = true,
    nargs    = 0,
})

excmd("Reverse", function(opts)
    if opts.range == 0 then return end
    if vim.fn.visualmode() == "V" then
        return vim.notify("Not support visual line mode", vim.log.levels.WARN)
    end
    vim.cmd("norm! gvd")
    local keyStr = "i" .. string.reverse(vim.fn.getreg("-", 1)) .. t"<ESC>"
    api.nvim_feedkeys(keyStr, "tn", true)
end, {
    desc     = "Reverse selection",
    range    = true,
    nargs    = 0,
})

excmd("RunSelection", function()
    if vim.bo.filetype ~= "lua" then
       return vim.notify("Only support in Lua file", vim.log.levels.WARN)
    end

    local vimMode = vim.fn.visualmode()
    if vimMode == "\22" then
        return vim.notify("Blockwise visual mode is not supported", vim.log.levels.WARN)
    end

    local lineStr = require("selection").getSelect("string", false)
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

excmd("Cfilter", function(opts)
    require("quickfix.cFilter").main(true, opts.args, opts.bang)
end, {
    desc  = "Filter quickfix window",
    bang  = true,
    nargs = "+",
})

excmd("Lfilter", function(opts)
    require("quickfix.cFilter").main(false, opts.args, opts.bang)
end, {
    desc  = "Filter localfix window",
    bang  = true,
    nargs = "+",
})

excmd("CD", [[execute "lcd " . expand("%:p:h")]], {
    desc = "Change the current working directory to the current buffer locally",
})

excmd("CDConfig", [[execute "lcd " . stdpath("config")]], {
    desc = "Change the current working directory to configuration path",
})

excmd("CDRuntime", [[execute "lcd $VIMRUNTIME"]], {
    desc = "Change the current working directory to Neovim runtime path",
})

excmd("E", function (opts)
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

excmd("O", [[browse oldfiles]], { desc = "Browse the oldfiles then prompt", })

excmd("Q", function (opts)
    local saveCMD = opts.bang and "noa " or "noa bufdo update | "
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

excmd("Se", function (opts)
    local sessionName = opts.args == "" and "01" or opts.args
    local sessionDir  = vim.fn.stdpath("state") .. _G._sep .. "my_session" .. _G._sep
    vim.cmd(string.format("so %s%s%s%s.vim",
        sessionDir, _G._sep, _G._sep, sessionName))

    -- Delete invalid buffers
    vim.defer_fn(function()
        local bufTbl = api.nvim_list_bufs()
        local cond = function(buf)
            return api.nvim_buf_get_option(buf, "buflisted") and
                not vim.loop.fs_stat(vim.api.nvim_buf_get_name(buf))
        end
        bufTbl = vim.tbl_filter(cond, bufTbl)
        for _, buf in ipairs(bufTbl) do
            vim.api.nvim_buf_delete(buf, {})
        end
    end, 0)
end, {
    desc  = "Load session",
    nargs = "?",
})

excmd("Dofile", function (opts)
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

excmd("O", [[browse oldfiles]], { desc = "Browse the oldfiles then prompt", })
excmd("OnSaveTrimSpaces", function ()
    _G._trim_space = _G._trim_space or true
    _G._trim_space = not _G._trim_space
    vim.api.nvim_echo({ { string.format("OnSaveTrimSpaces: %s", _G._trim_space), "Moremsg" } }, false, {})
end, { desc = "Toggle trimming spaces on save", })

excmd("TrimBufferSpaces", function ()
    require("util").trimSpaces()
end, { desc = "Toggle trimming spaces on save", })
-- }}} Commands
