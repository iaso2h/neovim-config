-- Author: iaso2h
-- File: init.lua
-- Description: lua initialization
-- Version: 0.0.5
-- Last Modified: 2021-03-15
local vim = vim

-- TODO: Migrate to packer.nvim, but it's still unstable yet
vim.api.nvim_exec([[let $configPath = stdpath('config')]], false)
vim.api.nvim_exec([[execute "source " . expand('$configPath/vimPlugList.vim')]], false)

require "plugins"
require "util"
require "options"
require "commands"
require "mappings"
require "debug"
require "replace"

-- Build-in plugin {{{
-- Netrow
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1
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
-- }}} Build-in plugin

