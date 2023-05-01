-- Credit: https://github.com/tjdevries/nlua.nvim/blob/master/lua/nlua/init.lua
return function(word)
    word = word or vim.fn.expand("<cword>")
    local helpTopics = {
        ["vim.api"]        = { prefix = "vim.api.",  suffix = "" },
        ["vim.treesitter"] = { prefix = "vim.api.",  suffix = "" },
        ["vim.lsp"]        = { prefix = "vim.lsp.",  suffix = "" },
        ["vim.loop"]       = { prefix = "vim.loop.", suffix = "" },
        ["vim.fn"]         = { prefix = "vim.fn.",   suffix = "()" }
    }

    -- Construct the keyword to lookup
    local ok, topic
    for k, v in pairs(helpTopics) do
        if word:find(k) then
            topic = v
            break
        end
    end
    local helpPath = topic and (topic.prefix .. word:sub(#topic + 1) .. topic.suffix) or word

    -- Get the current window layout
    local layoutCmd = require("buffer.util").winSplitCmd(true)

    ok = pcall(vim.api.nvim_command, string.format("%s help %s", layoutCmd, helpPath))

    if not ok then
        vim.lsp.buf.hover()
    end
end
