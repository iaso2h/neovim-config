local api = vim.api
local M = {
    augroup = {}
}
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
        vim    = [=[\s*".*{{{[^]'",\\;]*$]=],
        python = [=[\s*#.*{{{[^]'",\\;]*$]=],
        c      = [=[\s*//.*{{{[^]'",\\;]*$]=],
        cpp    = [=[\s*//.*{{{[^]'",\\;]*$]=],
        json   = [=[\s*//.*{{{[^]'",\\;]*$]=],
        conf   = [=[\s*//.*{{{[^]'",\\;]*$]=],
        lua    = [=[\s*--.*{{{[^]'",\\;]*$]=],
        sh     = [=[\s*#.*{{{[^]'",\\;]*$]=],
        zsh    = [=[\s*#.*{{{[^]'",\\;]*$]=],
        fish   = [=[\s*#.*{{{[^]'",\\;]*$]=],
    }
    vim.g.enhanceFoldEndPat = {
        vim    = [=[\s*".*}}}[^]'",\\;]*$]=],
        python = [=[\s*#.*}}}[^]'",\\;]*$]=],
        c      = [=[\s*//.*}}}[^]'",\\;]*$]=],
        cpp    = [=[\s*//.*}}}[^]'",\\;]*$]=],
        json   = [=[\s*//.*}}}[^]'",\\;]*$]=],
        conf   = [=[\s*//.*}}}[^]'",\\;]*$]=],
        lua    = [=[\s*--.*}}}[^]'",\\;]*$]=],
        sh     = [=[\s*#.*}}}[^]'",\\;]*$]=],
        zsh    = [=[\s*#.*}}}[^]'",\\;]*$]=],
        fish   = [=[\s*#.*}}}[^]'",\\;]*$]=],
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
au("BufWritePost", {
    group   = augroupWrite,
    desc    = "Avoiding folding after making modification on a buffer for the first time",
    command = "normal! zv"
})
au("BufWritePost", {
    group   = augroupWrite,
    pattern = "*.lua,*.vim",
    desc     = "Autoreload configuration after saving lua/vim configuration files",
    callback = function ()
        -- Similar work: https://github.com/RRethy/nvim-sourcerer
        require("autoreload").reload()
    end
})


au("BufWinEnter", {
    desc     = "Place the cursor on the last position",
    callback = function(arg)
        -- Credit: https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
        require("buf.action.cursorRecall").main(arg)
    end
})

au("FocusGained", {
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

au("BufWinEnter", {
    desc     = "Place the cursor on the last position",
    callback = function ()
        -- Credit: https://github.com/farmergreg/vim-lastplace/blob/master/plugin/vim-lastplace.vim
        require("buf.action.cursorRecall").main()
    end
})


-- autocmd BufAdd               * lua require("consistantTab").adaptBufTab()
-- autocmd BufEnter             *.txt,COMMIT_EDITMSG,index lua require("util").splitExist()

-- autocmd CursorHold            *.c,*.h,*.cpp,*.cc,*.vim :call HLCIOFunc()
-- }}} Auto commands

-- Commands {{{
if _G._os_uname.sysname == "Windows_NT" then
    excmd("PS", [[terminal powershell]], {
        desc     = "Open powershell",
        nargs    = 0,
    })
end

excmd("W", [[noa w]], {
    desc     = "Write without autocmd",
    nargs    = 0,
})

excmd("DeleteEmptyLines", [['<,'>g#^\s*$#d]], {
    desc     = "Delete empty lines from selection",
    nargs    = 0,
    range    = true,
})

excmd("Echo", [[PP strftime('%c') . ": " . <args>]], {
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

-- command! -nargs=0 -range Backward setl revins | execute "norm! gvc\<C-r>\"" | setl norevins
excmd("Reverse", function(opts)
    if opts.range == 0 then return end
    if fn.visualmode() == "V" then
        return vim.notify("Not support visual line mode", vim.log.levels.WARN)
    end
    vim.cmd("norm! gvd")
    local keyStr = "i" .. string.reverse(fn.getreg("-", 1)) .. t"<ESC>"
    api.nvim_feedkeys(keyStr, "tn", true)
end, {
    desc     = "Reverse selection",
    range    = true,
    nargs    = 0,
})

excmd("RunSelection", function(opts)
    if vim.bo.filetype ~= "lua" then
       return vim.notify("Only support in Lua file", vim.log.levels.WARN)
    end

    local vimMode = fn.visualmode()
    if vimMode == "\22" then
        return vim.notify("Blockwise visual mode is not supported", vim.log.levels.WARN)
    end

    local lineStr = require("selection").getSelect("string", false)
    -- TODO: support run multiple lines at the same time
    if vimMode == "V" then
        lineStr = string.gsub(lineStr, "\n", "")
    end

    vim.cmd("lua " .. lineStr)
end, {
    desc     = "Run selection in lua syntax",
    range    = true,
    nargs    = 0,
})

excmd("Cfilter", function(opts)
    require("quickfix.cfilter").main(true, opts.args, opts.bang)
end, {
    desc  = "Filter quickfix window",
    bang  = true,
    nargs = "+",
})

excmd("Lfilter", function(opts)
    require("quickfix.cfilter").main(false, opts.args, opts.bang)
end, {
    desc  = "Filter localfix window",
    bang  = true,
    nargs = "+",
})

excmd("CD", [[execute "lcd " . expand("%:p:h")]], {
    desc  = "Change the current working directory to the current buffer locally",
    nargs = 0,
})

excmd("E", function (opts)
    vim.cmd [[noa mkview]]
    if not opts.bang then
        vim.cmd [[update! | e]]
    else
        vim.cmd [[e!]]
    end
    vim.cmd [[loadview]]
end, {
    desc  = "Reopen the the current file while maintaining the window layout",
    bang  = true,
    nargs = 0,
})

excmd("O", [[browse oldfiles]], {
    desc  = "Browse the oldfiles then prompt",
    nargs = 0,
})

excmd("Q", function (opts)
    local saveCMD = opts.bang and "noa bufdo update | " or "noa "
    local sessionName = opts.args or "01"
    vim.cmd(string.format("mksession! %s/session/%s.vim",
        vim.fn.stdpath("config"), sessionName))
    vim.cmd(saveCMD .. "qa!")
end, {
    desc  = "Quit and save the session",
    nargs = "?",
    bang  = true,
})

excmd("Se", function (opts)
    local sessionName = opts.args or "01"
    vim.cmd(string.format("so %s/session/%s.vim",
        vim.fn.stdpath("config"), sessionName))
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
    elseif ft == "vim" then
    end

    require("autoreload").reload()
end, {
    desc  = "Reload the current file in lua/vim runtime",
    nargs = 0,
    bang  = true
})

excmd("O", [[browse oldfiles]], {
    desc  = "Browse the oldfiles then prompt",
    nargs = 0,
})

excmd("OnSaveTrimSpaces", function ()
    _G._trim_space = _G._trim_space or true
    _G._trim_space = not _G._trim_space
    vim.api.nvim_echo({ { string.format("OnSaveTrimSpaces: %s", _G._trim_space), "Moremsg" } }, false, {})
end, {
    desc  = "Toggle trimming spaces on save",
    nargs = 0,
})

excmd("TrimBufferSpaces", function ()
    require("util").trimSpaces()
end, {
    desc  = "Toggle trimming spaces on save",
    nargs = 0,
})
-- }}} Commands
