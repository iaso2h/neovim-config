local cmd = vim.cmd

-- TODO: Migrate to packer.nvim, but it's still unstable yet
cmd [[let $configPath = stdpath('config')]]
cmd [[execute "source " . expand('$configPath/vimPlugList.vim')]]

require "core.options"
require "core.mappings"
require "core.plugins"
require "core.commands"
require "debug"
require "replace"

-- Build-in plugin {{{
-- Disable
vim.g.loaded_gzip              = 1
vim.g.loaded_tar               = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_zip               = 1
vim.g.loaded_zipPlugin         = 1
vim.g.loaded_getscript         = 1
vim.g.loaded_getscriptPlugin   = 1
vim.g.loaded_vimball           = 1
vim.g.loaded_vimballPlugin     = 1
vim.g.loaded_matchit           = 1
vim.g.loaded_matchparen        = 1
vim.g.loaded_html_plugin       = 1
vim.g.loaded_2html_plugin      = 1
vim.g.loaded_logiPat           = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_netrw             = 1
vim.g.loaded_netrwPlugin       = 1
vim.g.loaded_netrwSettings     = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_tutor_mode_plugin = 1
if not vim.g.vscode then
    -- c.vim
    vim.g.c_gnu = 1
    vim.g.c_ansi_typedefs = 1
    vim.g.c_ansi_constants = 1
    vim.g.c_no_comment_fold = 1
    vim.g.c_syntax_for_h = 1
    -- doxygen.vim
    vim.g.load_doxygen_syntax= 1
    vim.g.doxygen_enhanced_color = 1
    -- msql.vim
    vim.g.msql_sql_query = 1
end
-- }}} Build-in plugin

