local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api

local u2char = require("util").u2char
local gl = require("galaxyline")
local gls = gl.section
local condition = require("galaxyline.condition")
-- local extension = require("galaxyline.provider_extensions")
-- local lspStatus = require('lsp-status')

gl.short_line_list = {
    "LuaTree", "vista", "dbui", "startify", "term", "fugitive", "fugitiveblame",
    "plug", "coc-explorer", "Mundo", "MundoDiff", "vim-plug", "qf", "NvimTree"
}

-- TODO support qf and statify

local colors = {
    bright_bg = '#4C566A',
    bg        = '#3B4252',
    fg        = '#5E81AC',
    fg_green  = '#65a380',
    yellow    = '#EBCB8B',
    cyan      = '#88C0D0',
    darkblue  = '#081633',
    green     = '#A3BE8C',
    orange    = '#D08770',
    purple    = '#B48EAD',
    magenta   = '#C678DD',
    blue      = '#5E81AC',
    red       = '#BF616A',
    gray      = '#66738e',
    white     = '#D8DEE9',
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
    denite           = '   ',
    ["vim-plug"]     = ' 🔌 ',
    vista            = ' 🏷️ ',
    vista_kind       = ' 🏷️ ',
    dbui             = ' 🏷️ ',
    magit            = '   ',
    Mundo            = '  ',
    startify         = ' 🏳️ ',
    NvimTree         = ' 🗃️ ',
    ["coc-explorer"] = ' 🗃️ ',
    qf               = '  ',
}

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

gls.left[1] = { -- {{{
    FirstElement = {
        provider = function() return ' ' end,
        highlight = {colors.blue, colors.bright_bg}
    }
}

local vimMode
gls.left[2] = {
    -- Show buftype when it's available, otherwise show Vimmode instead
    ViMode = {
        provider = function()
            local fileType = vim.bo.filetype
            if fileType == "help" then
                return bufTypeIcons[fileType] .. fileType:upper() .. " "
            else
                vimMode = fn.mode()
                api.nvim_command("hi GalaxyViMode guifg=" .. mode_colors[vimMode])
                if vimMode == "t" or vimMode == "!" then
                    return "  " .. alias[vimMode] .. " "
                else
                    return "  " .. alias[vimMode] .. " "
                end
            end
        end,
        highlight = {colors.blue, colors.bright_bg, 'bold'}
    }
}

gls.left[3] = {
    ViModeEnd = {
        provider = function() return '' end,
        separator = " ",
        separator_highlight = {colors.bright_bg, colors.bg},
        highlight = {colors.bright_bg, colors.bg},
    }
}

gls.left[4] = {
    FileIcon = {
        provider = "FileIcon",
        condition = condition.buffer_not_empty,
        highlight = {
            require('galaxyline.provider_fileinfo').get_file_icon_color,
            colors.bg
        }
    }
}

gls.left[5] = {
    FileName = {
        provider = {'FileName', 'FileSize'},
        condition = condition.buffer_not_empty,
        highlight = {colors.fg, colors.bg}
    }
}

-- gls.left[6] = {
    -- GitIcon = {
        -- provider = function() return '  ' end,
        -- condition = condition.check_git_workspace,
        -- separator = ' ',
        -- separator_highlight = {'NONE',colors.bg},
        -- highlight = {colors.purple, colors.bg,'bold'},
    -- }
-- }

gls.left[7] = {
    GitBranch = {
        provider = 'GitBranch',
        condition = condition.check_git_workspace,
        highlight = {'#8FBCBB', colors.bg}
    }
}

gls.left[8] = {
    DiffAdd = {
        provider = 'DiffAdd',
        condition = condition.hide_in_width,
        icon = ' ',
        highlight = {colors.green, colors.bg}
    }
}
gls.left[9] = {
    DiffModified = {
        provider = 'DiffModified',
        condition = condition.hide_in_width,
        icon = ' ',
        highlight = {colors.orange, colors.bg}
    }
}

gls.left[10] = {
    DiffRemove = {
        provider = 'DiffRemove',
        condition = condition.hide_in_width,
        icon = ' ',
        highlight = {colors.red, colors.bg}
    }
}

gls.left[11] = {
    LeftEnd = {
        provider = function() return '' end,
        separator = '',
        separator_highlight = {colors.bright_bg, colors.bg},
        highlight = {colors.bg, colors.bg},
    }
}

gls.left[12] = {
    DiagnosticHint = {
        provider = 'DiagnosticHint',
        icon = ' 💡',
        highlight = {colors.yellow,colors.bright_bg},
    }
}

gls.left[13] = {
    DiagnosticInfo = {
        provider = 'DiagnosticInfo',
        icon = ' 🔎 ',
        highlight = {colors.blue,colors.bright_bg},
    }
}

gls.left[14] = {
    DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow, colors.bright_bg}
    }
}

gls.left[15] = {
    DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red, colors.bright_bg}
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
        -- separator_highlight = {colors.purple,colors.bright_bg},
        -- condition = condition.buffer_not_empty,
        -- highlight = {colors.purple, colors.bright_bg, 'bold'}
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
        -- highlight = {colors.yellow, colors.bright_bg}
    -- }
-- }

-- gls.mid[3] = {
    -- lspMsg = {
        -- provider  = require("config.lsp-status-nvim").lspMsg,
        -- condition = function()
            -- return vim.lsp.buf.server_ready() and condition.hide_in_width()
        -- end,
        -- highlight = {colors.blue, colors.bright_bg}
    -- }
-- }
-- }}} Mid

gls.right[1] = { -- {{{
    FileFormat = {
        provider = function()
            if not condition.buffer_not_empty() then return '' end
            local icon = fileFormatIcons[vim.bo.fileformat] or ''
            return string.format(' %s %s ', icon, vim.bo.filetype)
        end,
        separator = '',
        separator_highlight = {colors.bright_bg, colors.bg},
        highlight = {colors.blue, colors.bg},
        condition = hasFileType
    }
}

gls.right[2] = {
    FileFormatEnd = {
        provider = function() return ' ' end,
        separator = '',
        separator_highlight = {colors.bright_bg, colors.bg},
        highlight = {colors.bright_bg, colors.bright_bg},
        condition = hasFileType
    }
}

-- TODO: does parse when in visual mode
-- gls.right[3] = {
    -- SelectLineInfo = {
        -- provider = function()
            -- local selectStart = api.nvim_buf_get_mark(0, "<")
            -- local selectEnd = api.nvim_buf_get_mark(0, ">")
            -- if selectStart[1] == selectEnd[1] then
                -- return "1"
            -- else
                -- return tostring(selectEnd[1] - selectStart[1])
            -- end
        -- end,
        -- condition = function()
            -- return vimMode == "V" or vimMode == "v" or vimMode == "^V"
        -- end,
        -- separator = ' |',
        -- separator_highlight = {colors.blue, colors.bright_bg},
        -- highlight = {colors.blue, colors.bright_bg}
    -- }
-- }

gls.right[4] = {
    LineInfo = {
        provider = 'LineColumn',
        highlight = {colors.blue, colors.bright_bg}
    }
}


gls.right[5] = {
    PerCent = {
        provider = 'LinePercent',
        separator = ' |',
        separator_highlight = {colors.blue, colors.bright_bg},
        highlight = {colors.blue, colors.bright_bg}
    }
}

-- VistaPlugin = extension.vista_nearest
-- gls.right[3] = {
-- Vista = {
-- provider = VistaPlugin,
-- separator = ' ',
-- separator_highlight = {colors.bright_bg, colors.bg},
-- highlight = {colors.blue, colors.bg, 'bold'}
-- }
-- } -- }}}

gls.short_line_left[1] = { -- {{{
    ShortStart = {
        provider = function() return ' ' end,
        condition = condition.buffer_not_empty and shortLineFileType,
        highlight = {colors.blue, colors.bright_bg}
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
        highlight = {colors.blue, colors.bright_bg, 'bold'}
    }
}

gls.short_line_left[3] = {
    ShortFileTypeEnd = {
        provider = function() return '' end,
        separator = " ",
        separator_highlight = {colors.bright_bg, colors.bg},
        condition = condition.buffer_not_empty and shortLineFileType,
        highlight = {colors.bright_bg, colors.bg}
    }
}


gls.short_line_left[4] = {
    ShortFileIconStart = {
        provider = function() return ' ' end,
        highlight = {colors.gray, colors.bg}
    }
}

gls.short_line_left[5] = {
    ShortFileIcon = {
        provider = "FileIcon",
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg}
    }
}

gls.short_line_left[6] = {
    ShortFileName = {
        provider = {'FileName'},
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg}
    }
}

gls.short_line_left[7] = {
    ShortLeftEnd = {
        provider = function() return ' ' end,
        condition = condition.buffer_not_empty,
        highlight = {colors.blue, colors.bg}
    }
} --- }}}


