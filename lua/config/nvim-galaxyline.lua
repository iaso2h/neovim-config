-- TODO: fix terminal mode
-- File: nvim-galaxyline
-- Author: iaso2h
-- Description: Statusline configuration
-- Version: 0.0.8
-- Last Modified: 2021-08-22
local fn  = vim.fn
local api = vim.api

local u2char    = require("util").u2char
local gl        = require("galaxyline")
local gls       = gl.section
local condition = require("galaxyline.condition")
-- local extension = require("galaxyline.provider_extensions")

gl.short_line_list = {
    "LuaTree", "vista", "dbui", "startify", "term", "fugitive", "fugitiveblame",
    "plug", "coc-explorer", "Mundo", "MundoDiff", "vim-plug", "qf", "NvimTree",
    "dap-repl"
}

-- TODO support qf and statify

local colors = {
    bright_bg1 = '#4C566A',
    bright_bg2 = '#616e88',
    bg         = '#3B4252',
    fg         = '#5E81AC',
    fg_green   = '#65a380',
    yellow     = '#EBCB8B',
    cyan       = '#88C0D0',
    darkblue   = '#081633',
    green      = '#A3BE8C',
    orange     = '#D08770',
    purple     = '#B48EAD',
    magenta    = '#C678DD',
    blue       = '#5E81AC',
    red        = '#BF616A',
    gray       = '#66738e',
    white      = '#D8DEE9',
}

local alias = {
    n      = 'NORMAL',
    i      = 'INSERT',
    c      = 'COMMAND',
    V      = 'VISUAL',
    [''] = 'VISUAL',
    v      = 'VISUAL',
    ['r?'] = ':CONFIRM',
    rm     = '--MORE',
    R      = 'REPLACE',
    Rv     = 'VIRTUAL',
    s      = 'SELECT',
    S      = 'SELECT',
    [''] = 'SELECT',
    ['r']  = 'HIT-ENTER',
    t      = 'TERMINAL',
    ['!']  = 'SHELL'
}

local mode_colors = {
    n      = colors.cyan,
    i      = colors.green,
    c      = colors.yellow,
    V      = colors.orange,
    [''] = colors.orange,
    v      = colors.orange,
    ['r?'] = colors.red,
    rm     = colors.red,
    R      = colors.red,
    Rv     = colors.red,
    s      = colors.magenta,
    S      = colors.magenta,
    [''] = colors.magenta,
    ['r']  = colors.purple,
    t      = colors.blue,
    ['!']  = colors.blue
}

local fileFormatIcons = {
    locker    = u2char 'f023',
    unsaved   = u2char 'f693',
    dos       = u2char 'e70f',
    unix      = u2char 'f17c',
    mac       = u2char 'f179',
    lsp_warn  = u2char 'f071',
    lsp_error = u2char 'f46e'
}

-- Based on 更纱黑体 Mono SC Nerd
local bufTypeIcons = {
    help             = '   ',
    defx             = '   ',
    ["vim-plug"]     = '  ',
    vista            = '  ',
    vista_kind       = '  ',
    ["dap-repl"]     = '  ',
    magit            = '   ',
    fugitive         = '   ',
    Mundo            = '  ',
    startify         = '  ',
    NvimTree         = '  ',
    ["coc-explorer"] = '  ',
    qf               = '  ',
}

local separator_left  = ""
local separator_right = ""

local hasFileType = function()
    local fileType = vim.bo.filetype
    if not fileType or fileType == "" then return false end
    return true
end

local shortLineFileType = function ()
    local fileType = vim.bo.filetype
    return vim.tbl_contains(gl.short_line_list, fileType)
end

local noShortLineFileType = function ()
    local fileType = vim.bo.filetype
    return not vim.tbl_contains(gl.short_line_list, fileType)
end

-- First Bubble
local vimMode
gls.left[1] = { -- {{{
    FirstElement = {
        provider  = function()
            vimMode = fn.mode()
            api.nvim_command("hi GalaxyFirstElement guibg=" .. mode_colors[vimMode])
            return " "
        end,
        highlight = {colors.bg, colors.bg}
    }
}

gls.left[2] = {
    -- Show buftype when it's available, otherwise show Vimmode instead
    ViMode = {
        provider = function()
            local fileType = vim.bo.filetype
            if fileType == "help" then
                return bufTypeIcons[fileType] .. fileType:upper() .. " "
            else
                vimMode = fn.mode()

                if vimMode == "c" then
                        api.nvim_command(string.format(
                        "hi GalaxyViMode guibg=%s guifg=%s",
                        mode_colors[vimMode],
                        colors.blue))
                    return "  " .. alias[vimMode]
                elseif vimMode == "t" or vimMode == "!" then
                    api.nvim_command(string.format(
                        "hi GalaxyViMode guibg=%s guifg=%s",
                        mode_colors[vimMode],
                        colors.white))
                    return "  " .. alias[vimMode]
                else
                    api.nvim_command(string.format(
                        "hi GalaxyViMode guibg=%s guifg=%s",
                        mode_colors[vimMode],
                        colors.white))
                    return "  " .. alias[vimMode]
                end
            end
        end,
        highlight = {colors.blue, colors.bg, 'bold'}
    }
}

gls.left[3] = {
    ViModeCap = {
        provider = function()
            vimMode = fn.mode()
            api.nvim_command("hi GalaxyViModeCap guifg=" .. mode_colors[vimMode])
            return separator_left .. " "
        end,
        highlight = {colors.fg, colors.bright_bg2},
    }
}

-- Second bubble
gls.left[4] = {
    FileIcon = {
        provider  = "FileIcon",
        condition = condition.buffer_not_empty,
        highlight = {
            require('galaxyline.provider_fileinfo').get_file_icon_color,
            colors.bright_bg2
        }
    }
}

gls.left[5] = {
    FileName = {
        provider  = 'FileName',
        -- provider  = {'FileName', 'FileSize'},
        condition = condition.buffer_not_empty,
        highlight = {colors.white, colors.bright_bg2}
    }
}

gls.left[6] = {
    FileNameCap = {
        provider = function() return "" end,
        separator           = separator_left,
        highlight           = {colors.bright_bg2, colors.bright_bg1},
        separator_highlight = {colors.bright_bg2, colors.bright_bg1},
    }
}

-- Third Buble
if fn.has("unix") == 1 then
    gls.left[7] = {
        GitIcon = {
            provider  = function() return '  ' end,
            condition = condition.check_git_workspace,
            separator = ' ',
            separator_highlight = {'NONE',colors.bright_bg1},
            highlight = {colors.purple, colors.bright_bg1,'bold'},
        }
    }

    gls.left[8] = {
        GitBranch = {
            provider  = 'GitBranch',
            condition = condition.check_git_workspace,
            highlight = {colors.purple, colors.bright_bg1},
            separator = ' ',
            separator_highlight = {'NONE',colors.bright_bg1},
        }
    }
end

gls.left[9] = {
    DiffAdd = {
        provider  = 'DiffAdd',
        condition = condition.hide_in_width,
        icon      = ' ',
        highlight = {colors.green, colors.bright_bg1}
}
    }
gls.left[10] = {
    DiffModified = {
        provider  = 'DiffModified',
        condition = condition.hide_in_width,
        icon      = ' ',
        highlight = {colors.yellow, colors.bright_bg1}
    }
}

gls.left[11] = {
    DiffRemove = {
        provider  = 'DiffRemove',
        condition = condition.hide_in_width,
        icon      = ' ',
        highlight = {colors.red, colors.bright_bg1}
    }
}

gls.left[12] = {
    GitCap = {
        provider            = function() return "" end,
        separator           = separator_left .. " ",
        separator_highlight = {colors.bright_bg1, colors.bg},
        highlight           = {colors.bright_bg1, colors.bg},
    }
}


-- Fourth Bubble
gls.left[13] = {
    DiagnosticHint = {
        provider  = 'DiagnosticHint',
        icon      = '  ',
        highlight = {colors.yellow,colors.bg},
    }
}

gls.left[14] = {
    DiagnosticInfo = {
        provider  = 'DiagnosticInfo',
        icon      = '  ',
        highlight = {colors.blue,colors.bg},
    }
}

gls.left[15] = {
    DiagnosticWarn = {
        provider  = 'DiagnosticWarn',
        icon      = '  ',
        highlight = {colors.yellow, colors.bg}
    }
}

gls.left[16] = {
    DiagnosticError = {
        provider  = 'DiagnosticError',
        icon      = '  ',
        highlight = {colors.red, colors.bg}
    }
}

-- }}}

-- Mid {{{
-- gls.mid[1] = {
    -- VistaPlugin = {
        -- provider = function()
        -- if (vim.b.vista_nearest_method_or_function == nil) then
            -- return ''
        -- elseif (vim.b.vista_nearest_method_or_function == '') then
            -- return ''
        -- else
            -- return '  -> '..vim.b.vista_nearest_method_or_function
        -- end
        -- end,
        -- separator = ' ',
        -- separator_highlight = {colors.purple,colors.bright_bg1},
        -- condition = condition.buffer_not_empty,
        -- highlight = {colors.purple, colors.bright_bg1, 'bold'}
    -- }
-- }

-- gls.mid[2] = {
    -- neovimLSPFunc = {
        -- provider = function()
            -- -- lspStatus.update_current_function()
            -- local func = vim.b.lsp_current_function
            -- if not func then return "" end
            -- return func ~= "" and " " .. func or ""
        -- end,
        -- -- condition = function()
            -- return vim.lsp.buf.server_ready() and condition.hide_in_width()
        -- end,
        -- highlight = {colors.yellow, colors.bright_bg1}
    -- }
-- }

gls.mid[3] = {
    lspMsg = {
        provider  = require("config.nvim-lsp-status").lspMsg,
        condition = function()
            return vim.lsp.buf.server_ready() and condition.hide_in_width()
        end,
        highlight = {colors.blue, colors.bg}
    }
}
-- }}} Mid

gls.right[1] = { -- {{{
    FileFormat = {
        provider = function()
            if not condition.buffer_not_empty() then return '' end
            local icon = fileFormatIcons[vim.bo.fileformat] or ''
            return string.format(' %s %s ', icon, vim.bo.filetype)
        end,
        separator           = separator_right,
        separator_highlight = {colors.bright_bg1, colors.bg},
        highlight           = {colors.fg, colors.bright_bg1},
        condition           = hasFileType
    }
}


-- TODO: does parse when in visual mode
-- gls.right[2] = {
    -- SelectedLineInfo = {
        -- provider = function()
            -- local selectStart = vim.api.nvim_buf_get_mark(0, "<")
            -- local selectEnd = vim.api.nvim_buf_get_mark(0, ">")
            -- if selectStart[1] == selectEnd[1] then
                -- return "1 line"
            -- else
                -- return tostring(selectEnd[1] - selectStart[1]) .. " lines"
            -- end
        -- end,
        -- highlight = {colors.orange, colors.bright_bg1}
    -- }
-- }

gls.right[3] = {
    LineInfo = {
        provider            = 'LineColumn',
        separator           = '| ',
        separator_highlight = {colors.fg, colors.bright_bg1},
        highlight           = {colors.fg, colors.bright_bg1}
    }
}


gls.right[4] = {
    PerCent = {
        provider            = 'LinePercent',
        separator           = '|',
        separator_highlight = {colors.fg, colors.bright_bg1},
        highlight           = {colors.fg, colors.bright_bg1}
    }
}

-- VistaPlugin = extension.vista_nearest
-- gls.right[3] = {
-- Vista = {
-- provider = VistaPlugin,
-- separator = ' ',
-- separator_highlight = {colors.bright_bg1, colors.bg},
-- highlight = {colors.blue, colors.bg, 'bold'}
-- }
-- } -- }}}

gls.short_line_left[1] = { -- {{{
    ShortStart = {
        provider  = function() return " " end,
        condition = condition.buffer_not_empty and shortLineFileType,
        highlight = {colors.white, colors.cyan}
    }
}


gls.short_line_left[2] = {
    ShortFileType = {
        provider = function()
            local fileType = vim.bo.filetype
            local bufIcon = bufTypeIcons[fileType]
            if vim.tbl_contains(gl.short_line_list, fileType) then
                if bufIcon then
                    return bufIcon .. " " .. vim.bo.filetype:upper() .. " "
                else
                    return " " .. vim.bo.filetype:upper() .. " "
                end
            end
        end,
        -- condition = condition.buffer_not_empty,
        highlight = {colors.white, colors.cyan, 'bold'}
    }
}

gls.short_line_left[3] = {
    ShortFileTypeEnd = {
        provider            = function() return '' end,
        separator           = separator_left,
        separator_highlight = {colors.cyan, colors.bg},
        condition           = condition.buffer_not_empty and shortLineFileType,
        highlight           = {colors.cyan, colors.bg}
    }
}


gls.short_line_left[4] = {
    ShortFileIconStart = {
        provider = function() return " " end,
        highlight = {colors.gray, colors.bg}
    }
}

gls.short_line_left[5] = {
    ShortFileIcon = {
        provider  = "FileIcon",
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg}
    }
}

gls.short_line_left[6] = {
    ShortFileName = {
        provider  = {'FileName'},
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg}
    }
}

gls.short_line_left[7] = {
    ShortLeftEnd = {
        provider  = function() return " " end,
        condition = condition.buffer_not_empty,
        highlight = {colors.blue, colors.bg}
    }
} --- }}}

