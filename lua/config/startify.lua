local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api

vim.g.startify_session_dir  = os.getenv("HOME") .. '/.nvimcache/session'
vim.g.startify_padding_left = 20
vim.g.startify_lists = {
    {type = 'files',     header = {string.rep(" ", vim.g.startify_padding_left) .. 'MRU'}            },
    {type = 'dir',       header = {string.rep(" ", vim.g.startify_padding_left) .. 'MRU ' .. fn.getcwd()}},
    {type = 'sessions',  header = {string.rep(" ", vim.g.startify_padding_left) .. 'Sessions'}       },
    {type = 'bookmarks', header = {string.rep(" ", vim.g.startify_padding_left) .. 'Bookmarks'}      },
}
vim.g.startify_update_oldfiles        = 1
vim.g.startify_session_autoload       = 1
if fn.has("win32") == 1 then
    vim.g.startify_bookmarks = {{v = os.getenv("HOME") .. '/AppData/Local/nvim'}, {c = "H:/code"}}
else
    vim.g.startify_bookmarks = {{v = os.getenv("HOME") .. '/AppData/Local/nvim'}}
end
vim.g.startify_session_before_save    = {'echo "Cleaning up before saving.."' }
vim.g.startify_session_persistence    = 1
vim.g.startify_session_delete_buffers = 1
vim.g.startify_change_to_vcs_root     = 1
vim.g.startify_fortune_use_unicode    = 1
vim.g.startify_relative_path          = 1
vim.g.startify_use_env                = 1
if fn.has("win32") == 1 then table.insert(vim.g.startify_bookmarks, 'H:/code') end

