local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local M   = {}


local lines = {"< New Buffer >"}
local win
local curBuf
local curWin

M.display = function()
    if fn.argc() > 0 or #vim.v.oldfiles == 1 then
        return
    end

    for _, file in pairs(vim.v.oldfiles) do
        if vim.loop.fs_stat(file) then
            table.insert(lines, file)
        end
    end


    if api.nvim_buf_is_valid(1) then
        curBuf = 1
    else
        curBuf = api.nvim_create_buf(false, true)
        if curBuf then
            cmd [[noautocmd enew]]
            curBuf = api.nvim_get_current_buf()
        end
    end
    curWin = api.nvim_get_current_win()

    api.nvim_set_option("showtabline", 0)
    api.nvim_set_option("laststatus", 0)
    api.nvim_buf_set_option(curBuf, "bufhidden",  "wipe")
    api.nvim_buf_set_option(curBuf, "buflisted",  false)
    api.nvim_buf_set_option(curBuf, "modified",   false)
    api.nvim_buf_set_option(curBuf, "filetype",   "HistoryStartup")

    api.nvim_buf_set_lines(curBuf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(curBuf, "modifiable", false)

    for _, key in ipairs({"q", "o", "s", "v", "<cr>"}) do
        api.nvim_buf_set_keymap(
            curBuf,
            "n",
            key,
            string.format([=[:lua require("historyStartup").do_map([[%s]])<cr>]=], key),
            {silent = true}
        )
    end

    win = api.nvim_get_current_win()
    -- vim.wo[win].colorcolumn = ""
    -- vim.wo[win].signcolumn = "no"
    api.nvim_win_set_buf(win, curBuf)
end

M.do_map = function(key)
    local target = lines[api.nvim_win_get_cursor(0)[1]]

    if key == "q" then
        cmd('quit!')
    elseif target == "< New Buffer >" then
        cmd("enew!")
    elseif key == "o" or key == "<cr>" then
        cmd("edit! " .. target)
    elseif key == "s" then
        cmd("split! " .. target)
    elseif key == "v" then
        cmd("vsplit! " .. target)
    end

    -- Delete buffer
    for _, bufNr in ipairs({1, curBuf}) do
        if api.nvim_buf_is_valid(bufNr) then
            vim.api.nvim_buf_delete(bufNr, {force = true})
        end
    end
end

return M

