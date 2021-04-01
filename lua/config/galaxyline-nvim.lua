local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api

local u2char = require("util").u2char
local gl = require("galaxyline")
local gls = gl.section
local condition = require("galaxyline.condition")
local extension = require("galaxyline.provider_extensions")

gl.short_line_list = {
    "LuaTree", "vista", "dbui", "startify", "term", "fugitive", "fugitiveblame",
    "plug", "coc-explorer", "Mundo", "MundoDiff", "vim-plug", "qf", "NvimTree"
}

-- TODO support qf and statify

local colors = {
    bg       = '#4C566A',
    line_bg  = '#3B4252',
    -- fg       = '#D8DEE9',
    fg       = '#81A1C1',
    -- fg       = '#8FBCBB',
    fg_green = '#65a380',

    yellow   = '#EBCB8B',
    cyan     = '#88C0D0',
    darkblue = '#081633',
    green    = '#A3BE8C',
    orange   = '#D08770',
    purple   = '#B48EAD',
    magenta  = '#C678DD',
    blue     = '#5E81AC',
    red      = '#BF616A',
    gray     = '#66738e',
    white    = '#D8DEE9',
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
    help             = ' 📖 ',
    defx             = '  ',
    denite           = '  ',
    ["vim-plug"]     = ' 🔌',
    vista            = ' 🏷️',
    vista_kind       = ' 🏷️',
    dbui             = ' 🏷️',
    magit            = '  ',
    Mundo            = '  ',
    startify         = ' 🏳️',
    NvimTree         = ' 🗂️ ',
    ["coc-explorer"] = ' 🗂️ ',
    terminal         = '  ',
}

function GalaxyLSPStatus(status)
    local shorter_stat = ''
    for match in string.gmatch(status, "[^%s]+") do
        local err_warn = string.find(match, "^[WE]%d+", 0)
        if not err_warn then shorter_stat = shorter_stat .. ' ' .. match end
    end
    return shorter_stat
end

function GalaxyGetFuncInfo()
    if fn.exists('*coc#rpc#start_server') == 1 then
        return GalaxyGetCurFunc()
    end
    return ''
end

function GalaxyGetCurFunc()
    local has_func, func_name = pcall(fn.nvim_buf_get_var, 0,
        'coc_current_function')
    if not has_func then return end
    return func_name
end

function GalaxyGetCOCLSP()
    local status = fn['coc#status']()
    if not status or status == '' then return '' end
    return GalaxyLSPStatus(status)
end

function GalaxyGetCOCDiagnostic()
    if fn.exists('*coc#rpc#start_server') == 1 then return GalaxyGetCOCLSP() end
    return ''
end

CocStatus = GalaxyGetCOCDiagnostic
CocFunc = GalaxyGetCurFunc

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
        highlight = {colors.blue, colors.bg}
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
                local mode = fn.mode()
                api.nvim_command("hi GalaxyViMode guifg=" .. mode_colors[mode])
                return "  " .. alias[mode] .. " "
            end
        end,
        highlight = {colors.blue, colors.bg, 'bold'}
    }
}

gls.left[3] = {
    ViModeEnd = {
        provider = function() return '' end,
        separator = " ",
        separator_highlight = {colors.bg, colors.line_bg},
        highlight = {colors.bg, colors.line_bg},
    }
}

gls.left[4] = {
    FileIcon = {
        provider = "FileIcon",
        condition = condition.buffer_not_empty,
        highlight = {
            require('galaxyline.provider_fileinfo').get_file_icon_color,
            colors.line_bg
        }
    }
}

gls.left[5] = {
    FileName = {
        provider = {'FileName', 'FileSize'},
        condition = condition.buffer_not_empty,
        highlight = {colors.fg, colors.line_bg}
    }
}

-- gls.left[6] = {
    -- GitIcon = {
        -- provider = function() return '  ' end,
        -- condition = condition.check_git_workspace,
        -- separator = ' ',
        -- separator_highlight = {'NONE',colors.line_bg},
        -- highlight = {colors.purple, colors.line_bg,'bold'},
    -- }
-- }

gls.left[7] = {
    GitBranch = {
        provider = require('galaxyline.provider_vcs').get_git_branch,
        condition = condition.check_git_workspace,
        highlight = {'#8FBCBB', colors.line_bg}
    }
}

local checkwidth = function()
    local squeeze_width = fn.winwidth(0) / 2
    if squeeze_width > 40 then return true end
    return false
end

gls.left[8] = {
    DiffAdd = {
        provider = 'DiffAdd',
        condition = checkwidth,
        icon = ' ',
        highlight = {colors.green, colors.line_bg}
    }
}
gls.left[9] = {
    DiffModified = {
        provider = 'DiffModified',
        condition = checkwidth,
        icon = ' ',
        highlight = {colors.orange, colors.line_bg}
    }
}
gls.left[10] = {
    DiffRemove = {
        provider = 'DiffRemove',
        condition = checkwidth,
        icon = ' ',
        highlight = {colors.red, colors.line_bg}
    }
}

gls.left[11] = {
    LeftEnd = {
        provider = function() return '' end,
        separator = '',
        separator_highlight = {colors.bg, colors.line_bg},
        highlight = {colors.line_bg, colors.line_bg},
    }
}

gls.left[12] = {
    DiagnosticHint = {
        provider = function()
            local info = vim.b.coc_diagnostic_info
            local msgs = ""
            if type(info) ~= "table" then return msgs end
            if info.hint ~= 0 then
                msgs = msgs .. ' 💡' .. info['hint']
            end
            return msgs
        end,
        highlight = {colors.yellow, colors.bg}
    }
}

gls.left[13] = {
    DiagnosticInfo = {
        provider = function()
            local info = vim.b.coc_diagnostic_info
            local msgs = ""
            if type(info) ~= "table" then return msgs end
            if info.information ~= 0 then
                msgs = msgs .. '  🔎 ' .. info['information']
            end
            return msgs
        end,
        highlight = {colors.blue, colors.bg}
    }
}

-- gls.left[14] = {
-- DiagnosticWarn = {
-- provider = 'DiagnosticWarn',
-- icon = '  ',
-- highlight = {colors.yellow, colors.bg}
-- }
-- }

gls.left[14] = {
    DiagnosticWarn = {
        provider = function()
            local info = vim.b.coc_diagnostic_info
            local msgs = ""
            if type(info) ~= "table" then return msgs end
            if info.warning ~= 0 then
                msgs = msgs .. '  ⚠️ ' .. info['warning']
            end
            return msgs
        end,
        highlight = {colors.yellow, colors.bg}
    }
}

-- gls.left[15] = {
-- DiagnosticError = {
-- provider = 'DiagnosticError',
-- icon = '  ',
-- highlight = {colors.red, colors.bg}
-- }
-- }

gls.left[15] = {
    DiagnosticError = {
        provider = function()
            local info = vim.b.coc_diagnostic_info
            local msgs = ""
            if type(info) ~= "table" then return msgs end
            if info.error ~= 0 then
                msgs = msgs .. '   ' .. info['error']
            end
            return msgs
        end,
        highlight = {colors.red, colors.bg}
    }
} -- }}}

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
        -- separator_highlight = {colors.purple,colors.bg},
        -- condition = condition.buffer_not_empty,
        -- highlight = {colors.purple, colors.bg, 'bold'}
    -- }
-- }

local checkCOCStart = function()
    if fn.exists('*coc#rpc#start_server') == 1 then
        return true
    end
    return false
end

gls.mid[2] = {
    cocfunc = {
        provider = function()
            local cocFunc = vim.b.coc_current_function
            if not cocFunc then return "" end
            return cocFunc
        end,
        condition = checkCOCStart,
        highlight = {colors.yellow, colors.bg}
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
        separator = '',
        separator_highlight = {colors.bg, colors.line_bg},
        highlight = {colors.fg, colors.line_bg},
        condition = hasFileType
    }
}

gls.right[2] = {
    FileFormatEnd = {
        provider = function() return ' ' end,
        separator = '',
        separator_highlight = {colors.bg, colors.line_bg},
        highlight = {colors.bg, colors.bg},
        condition = hasFileType
    }
}

gls.right[3] = {
    LineInfo = {
        provider = 'LineColumn',
        highlight = {colors.fg, colors.bg}
    }
}

gls.right[5] = {
    PerCent = {
        provider = 'LinePercent',
        separator = ' |',
        separator_highlight = {colors.fg, colors.bg},
        highlight = {colors.fg, colors.bg}
    }
}

-- VistaPlugin = extension.vista_nearest
-- gls.right[3] = {
-- Vista = {
-- provider = VistaPlugin,
-- separator = ' ',
-- separator_highlight = {colors.bg, colors.line_bg},
-- highlight = {colors.fg, colors.line_bg, 'bold'}
-- }
-- } -- }}}

gls.short_line_left[1] = { -- {{{
    ShortStart = {
        provider = function() return ' ' end,
        condition = condition.buffer_not_empty and shortLineFileType,
        highlight = {colors.blue, colors.bg}
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
        highlight = {colors.blue, colors.bg, 'bold'}
    }
}

gls.short_line_left[3] = {
    ShortFileTypeEnd = {
        provider = function() return '' end,
        separator = " ",
        separator_highlight = {colors.bg, colors.line_bg},
        condition = condition.buffer_not_empty and shortLineFileType,
        highlight = {colors.bg, colors.line_bg}
    }
}


gls.short_line_left[4] = {
    ShortFileIconStart = {
        provider = function() return ' ' end,
        highlight = {colors.gray, colors.line_bg}
    }
}

gls.short_line_left[5] = {
    ShortFileIcon = {
        provider = "FileIcon",
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.line_bg}
    }
}

gls.short_line_left[6] = {
    ShortFileName = {
        provider = {'FileName'},
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.line_bg}
    }
}

gls.short_line_left[7] = {
    ShortLeftEnd = {
        provider = function() return ' ' end,
        condition = condition.buffer_not_empty,
        highlight = {colors.blue, colors.line_bg}
    }
} --- }}}


