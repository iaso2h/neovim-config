local configPath = vim.fn.stdpath("config")
vim.opt.runtimepath:append(configPath)
-- Add plenary.nvim, vim-repeat, vim-visualrepeat in your runtime path. In my
-- case, I manage them via packer.nvim
local packagePathHead = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(packagePathHead .. "plenary.nvim")

require("global.keymap")
require("util.test")

-- Mapping
-- map("n", [[<C-o>]], function()
--     require("jump.jumplist").go("n", false, "local")
-- end, {"silent"}, "Oldder local jump")
-- map("n", [[<C-i>]], function()
--     require("jump.jumplist").go("n", true, "local")
-- end, {"silent"}, "Newer local jump")

-- map("x", [[<C-o>]], luaRHS[[:lua
--     require("jump.jumplist").visualMode = vim.fn.visualmode();
--     require("jump.jumplist").go(vim.fn.visualmode(), false, "local")<CR>
-- ]], {"silent"}, "Older local jump")
-- map("x", [[<C-i>]], luaRHS[[:lua
--     require("jump.jumplist").visualMode = vim.fn.visualmode();
--     require("jump.jumplist").go(vim.fn.visualmode(), true, "local")<CR>
-- ]], {"silent"}, "Newer local jump")

-- map("n", [[g<C-o>]], function()
--     require("jump.jumplist").go("n", false, "buffer")
-- end, {"silent"}, "Older buffer jump")
-- map("n", [[g<C-i>]], function()
--     require("jump.jumplist").go("n", true, "buffer")
-- end, {"silent"}, "Newer buffer jump")

_G.Print = function(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
    end

    print(table.concat(objects, '\n'))

    return ...
end


_G.logBuf = function(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
        table.insert(objects, "")
        table.insert(objects, "------------------------------------------")
        table.insert(objects, "")
    end

    -- Output the result into a new scratch buffer
    local scratchBuf
    if vim.bo.modifiable and not vim.bo.buflisted and vim.bo.bufhidden ~= "" then
        scratchBuf = vim.api.nvim_get_current_buf()

    else
        -- TODO: how to decide perform a vertical split or a horizontal split
        vim.cmd [[vsplit]]
        scratchBuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(scratchBuf, "bufhidden", "wipe")
        vim.api.nvim_set_current_buf(scratchBuf)
    end

    vim.api.nvim_buf_set_lines(scratchBuf, 0, -1, false, objects)
    vim.cmd [[%s#\\n#\r#e]]

    return ...
end
