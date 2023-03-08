if vim.fn.has("nvim-0.9.0") ~= 1 then
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify("Neovim with 0.9.0 or higher build version required", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    vim.notify(" ", vim.log.levels.WARN)
    return
end

pcall(vim.cmd, [[language en_US]])

_G._os_uname = vim.loop.os_uname()
_G._isTerm = vim.api.nvim_list_uis()[1].ext_termcolors

-- Disable built-in plugins
vim.g.loaded_2html_plugin      = 1
vim.g.loaded_getscript         = 1
vim.g.loaded_getscriptPlugin   = 1
vim.g.loaded_gzip              = 1
vim.g.loaded_html_plugin       = 1
vim.g.loaded_logiPat           = 1
vim.g.loaded_matchit           = 1
vim.g.loaded_matchparen        = 1
vim.g.loaded_netrw             = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_netrwPlugin       = 1
vim.g.loaded_netrwSettings     = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_tar               = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_vimball           = 1
vim.g.loaded_vimballPlugin     = 1
vim.g.loaded_zip               = 1
vim.g.loaded_zipPlugin         = 1
-- Toggle embed syntax
vim.g.vimsyn_embed = 'lPr'
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

local ok, msg = pcall(require, "util"); if not ok then vim.notify(msg, vim.log.levels.ERROR) end

require "core"
