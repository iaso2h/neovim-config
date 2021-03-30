-- Author: iaso2h
-- File: init.lua
-- Description: lua initialization
-- Version: 0.0.5
-- Last Modified: 2021-03-15
local vim = vim

-- TODO: Migrate to packer.nvim, but it's still unstable yet
vim.api.nvim_exec([[let $configPath = stdpath('config')]], false)
vim.api.nvim_exec([[execute "source " . expand('$configPath/vimPlugList.vim')]], false)

vim.g.mapleader = " " -- First thing first

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

-- nvim-web-devicons {{{
require'nvim-web-devicons'.setup {
    -- your personnal icons can go here (to override)
    -- DevIcon will be appended to `name`
    override = {
    html = {
    icon = "",
    color = "#DE8C92",
    name = "html"
    },
    css = {
    icon = "",
    color = "#61afef",
    name = "css"
    },
    js = {
    icon = "",
    color = "#EBCB8B",
    name = "js"
    },
    png = {
    icon = " ",
    color = "#BD77DC",
    name = "png"
    },
    jpg = {
    icon = " ",
    color = "#BD77DC",
    name = "jpg"
    },
    jpeg = {
    icon = " ",
    color = "#BD77DC",
    name = "jpeg"
    },
    mp3 = {
    icon = "",
    color = "#C8CCD4",
    name = "mp3"
    },
    mp4 = {
    icon = "",
    color = "#C8CCD4",
    name = "mp4"
    },
    out = {
    icon = "",
    color = "#C8CCD4",
    name = "out"
    },
    toml = {
    icon = "",
    color = "#61afef",
    name = "toml"
    },
    lock = {
    icon = "",
    color = "#DE6B74",
    name = "lock"
    }
    };
    -- globally enable default icons (default to false)
    -- will get overriden by `get_icons` option
    default = true;
    }
-- }}} nvim-web-devicons

