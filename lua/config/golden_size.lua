local vim = vim
local api = vim.api
local function ignore_by_buftype(types)
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    for _, type in pairs(types) do
        if type == buftype then
            return 1
        end
    end
end

local goldenSize = require("golden_size")
-- set the callbacks, preserve the defaults
goldenSize.set_ignore_callbacks({
    {ignore_by_buftype, {'terminal', 'nofile', 'quickfix', 'nowrite'}},
    {goldenSize.ignore_float_windows},   -- default one, ignore float windows
    {goldenSize.ignore_by_window_flag},  -- default one, ignore windows with w:ignore_gold_size=1
})

api.nvim_exec([[
augroup ignoreGoldenSize
autocmd!
autocmd FileType coc-explorer let w:ignore_gold_size=1
augroup END
]], false)

