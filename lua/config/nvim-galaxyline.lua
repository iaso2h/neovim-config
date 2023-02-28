-- File: nvim-galaxyline
-- Author: iaso2h
-- Description: Statusline configuration
-- Last Modified: 2023-2-27
return function()

local fn  = vim.fn
local api = vim.api

local u2char    = require("util").u2char
local gl        = require("galaxyline")
local gls       = gl.section
local condition = require("galaxyline.condition")

-- Filetype
gl.short_line_list = {
    "LuaTree", "vista", "dbui", "startify", "term", "fugitive", "fugitiveblame",
    "plug", "coc-explorer", "Mundo", "MundoDiff", "vim-plug", "qf", "NvimTree",
    "dap-repl", "HistoryStartup", ""
}

local colors = {
    fg        = "#5E81AC",
    bg1       = "#3B4252",
    bg2       = "#4C566A",
    bg3       = "#616e88",
    yellow    = "#EBCB8B",
    cyan      = "#88C0D0",
    darkblue  = "#081633",
    green     = "#A3BE8C",
    orange    = "#D08770",
    purple    = "#B48EAD",
    magenta   = "#C678DD",
    blue      = "#5E81AC",
    blueLight = "#81A1C1",
    red       = "#BF616A",
    gray      = "#66738e",
    white     = "#D8DEE9",
}

local alias = {
    n      = "NORMAL",
    i      = "INSERT",
    c      = "COMMAND",
    V      = "VISUAL",
    [""] = "VISUAL",
    v      = "VISUAL",
    ["r?"] = ":CONFIRM",
    rm     = "--MORE",
    R      = "REPLACE",
    Rv     = "VIRTUAL",
    s      = "SELECT",
    S      = "SELECT",
    [""] = "SELECT",
    ["r"]  = "HIT-ENTER",
    t      = "TERMINAL",
    ["!"]  = "SHELL"
}

local modeColors = {
    n      = colors.cyan,
    i      = colors.green,
    c      = colors.yellow,
    V      = colors.orange,
    [""] = colors.orange,
    v      = colors.orange,
    ["r?"] = colors.red,
    rm     = colors.red,
    R      = colors.red,
    Rv     = colors.red,
    s      = colors.magenta,
    S      = colors.magenta,
    [""] = colors.magenta,
    ["r"]  = colors.purple,
    t      = colors.blue,
    ["!"]  = colors.blue
}

local fileFormatIcons = {
    locker    = u2char "f023",
    unsaved   = u2char "f693",
    dos       = u2char "e70f",
    unix      = u2char "f17c",
    mac       = u2char "f179",
    lsp_warn  = u2char "f071",
    lsp_error = u2char "f46e"
}

-- Based on 更纱黑体 Mono SC Nerd
local bufTypeIcons = {
    help             = "   ",
    defx             = "   ",
    ["vim-plug"]     = "  ",
    vista            = "  ",
    vista_kind       = "  ",
    ["dap-repl"]     = "  ",
    magit            = "   ",
    fugitive         = "   ",
    Mundo            = "  ",
    startify         = "  ",
    NvimTree         = "  ",
    ["coc-explorer"] = "  ",
    qf               = "  ",
}

local circleHalfRight = ""
local circleHalfLeft  = ""

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


local fileInfo = function()
    local cwd  = vim.fn.getcwd(0)
    local absoPath = vim.api.nvim_buf_get_name(0)
    local isRel = string.match(absoPath, cwd) ~= nil
    local sep = jit.os == "Windows" and "\\" or "/"
    local fileStr = isRel and
        fn.expand("%") or
        string.format("..%s%s", sep, vim.fn.expand("%:t"))

    local isMod = vim.bo.modified and " [+]" or ""
    local isRead = vim.bo.readonly and " []" or ""

    local ext = vim.fn.expand("%:e")
    local fileTypeStr = ext ~= vim.bo.filetype and
        string.format(" | %s ", vim.bo.filetype) or
        " "

    return fileStr .. isMod .. isRead .. fileTypeStr
end


local vimMode
local changeHLColor = function (hlStr)
    local cmdStr
    if vimMode == "c" then
        cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
            hlStr, modeColors[vimMode], colors.blue, "bold")
    elseif vimMode == "n" then
        cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
            hlStr, modeColors[vimMode], colors.bg1, "bold")
    elseif vimMode == "t" or vimMode == "!" then
        cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
            hlStr, modeColors[vimMode], colors.white, "bold")
    else
        cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
            hlStr, modeColors[vimMode], colors.white, "bold")
    end

    vim.cmd(cmdStr)
end


local lineInfo = function()
    local cursorPos = api.nvim_win_get_cursor(0)
    local totalLineNr = fn.line("$")
    local lineColumn = string.format("  %d:%d |", cursorPos[1], cursorPos[2] + 1)
    local percentage
    if cursorPos[1] == 1 then
        percentage = " Top "
    elseif cursorPos[1] == totalLineNr then
        percentage = " Bot "
    else
        percentage = string.format(" %s%% ", math.modf((cursorPos[1]/totalLineNr)*100))
    end

    local lineInfo = lineColumn .. percentage
    return lineInfo
end


gls.left[#gls.left+1] = { -- {{{
    VimMode = {
        provider = function()
            vimMode = vim.fn.mode()

            changeHLColor("GalaxyVimMode")

            if not isTerm then
                return string.format("  %s %s ", require("nvim-nonicons").get("vim"), alias[vimMode])
            else
                if vimMode == "t" or vimMode == "!" then
                    return string.format("  %s %s ", require("nvim-nonicons").get("vim"), alias[vimMode])
                else
                    return string.format("   %s ", alias[vimMode])
                end
            end
        end,
        highlight = {colors.fg, colors.bg1},
    }
}


gls.left[#gls.left+1] = {
    VimModeCap = {
        provider = function()
            local cmdStr = string.format("hi GalaxyVimModeCap guifg=%s", modeColors[vimMode])
            vim.cmd(cmdStr)

            return circleHalfRight .. " "
        end,
        highlight = {colors.fg, colors.bg3},
    }
}

gls.left[#gls.left+1] = {
    FileIcon = {
        provider  = "FileIcon",
        condition = condition.buffer_not_empty,
        highlight = {
            require("galaxyline.provider_fileinfo").get_file_icon_color,
            colors.bg3
        }
    }
}

gls.left[#gls.left+1] = {
    FileInfo = {
        provider  = fileInfo,
        condition = condition.buffer_not_empty,
        highlight = {colors.white, colors.bg3}
    }
}

gls.left[#gls.left+1] = {
    FileInfoCap = {
        provider  = function() return circleHalfRight end,
        highlight = {colors.bg3, colors.bg2},
    }
}

-- if fn.has("unix") == 1 then
    gls.left[#gls.left+1] = {
        GitIcon = {
            provider  = function() return " " end,
            -- condition = condition.check_git_workspace,
            condition = condition.hide_in_width,
            highlight = {colors.purple, colors.bg2},
        }
    }

    -- gls.left[7] = {
        -- GitBranch = {
            -- provider  = "GitBranch",
            -- condition = condition.check_git_workspace,
            -- highlight = {colors.purple, colors.bright_bg1},
            -- separator = " ",
            -- separator_highlight = {"NONE",colors.bright_bg1},
        -- }
    -- }
-- end

gls.left[#gls.left+1] = {
    DiffAdd = {
        provider  = "DiffAdd",
        condition = condition.hide_in_width,
        icon      = isTerm and " " or "",
        highlight = {colors.green, colors.bg2}
    }
}
gls.left[#gls.left+1] = {
    DiffModified = {
        provider  = "DiffModified",
        condition = condition.hide_in_width,
        icon      = isTerm and " " or "",
        highlight = {colors.yellow, colors.bg2}
    }
}

gls.left[#gls.left+1] = {
    DiffRemove = {
        provider  = "DiffRemove",
        condition = condition.hide_in_width,
        icon      = isTerm and " " or "",
        highlight = {colors.red, colors.bg2}
    }
}

gls.left[#gls.left+1] = {
    GitCap = {
        provider  = function() return circleHalfRight .. " " end,
        highlight = {colors.bg2, colors.bg1},
    }
}


gls.left[#gls.left+1] = {
    DiagnosticHint = {
        provider  = "DiagnosticHint",
        icon      = isTerm and "  " or " ",
        highlight = {colors.blueLight,colors.bg1},
    }
}

gls.left[#gls.left+1] = {
    DiagnosticInfo = {
        provider  = "DiagnosticInfo",
        icon      = isTerm and "  " or " ",
        highlight = {colors.blue,colors.bg1},
    }
}

gls.left[#gls.left+1] = {
    DiagnosticWarn = {
        provider  = "DiagnosticWarn",
        icon      = isTerm and "  " or " ",
        highlight = {colors.yellow, colors.bg1}
    }
}

gls.left[#gls.left+1] = {
    DiagnosticError = {
        provider  = "DiagnosticError",
        icon      = isTerm and "  " or " ",
        highlight = {colors.red, colors.bg1}
    }
} -- }}}


-- gls.mid[#gls.mid + 1] = { -- {{{
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
-- } -- }}}


gls.right[#gls.right+1] = { -- {{{
    EncodingCap = {
        provider = function()
            return circleHalfLeft
        end,
        highlight = {colors.bg3, colors.bg1},
    }
}

gls.right[#gls.right+1] = {
    Encoding = {
        provider = function()
            return "  " .. vim.o.encoding .. " "
        end,
        highlight = {colors.white, colors.bg3},
    }
}

gls.right[#gls.right+1] = {
    LineInfoCap = {
        provider = function() return circleHalfLeft end,
        highlight = "GalaxyVimModeCap"
    }
}

gls.right[#gls.right+1] = {
    LineInfo = {
        provider = lineInfo,
        highlight = "GalaxyVimMode"
    }
}

-- -- gls.right[#gls.right+1] = {
    -- -- LineInfo = {
        -- -- provider            = "LineColumn",
        -- -- separator           = "| ",
        -- -- separator_highlight = {colors.white, colors.bright_bg2},
        -- -- highlight           = {colors.white, colors.bright_bg2}
    -- -- }
-- -- }
--
--
-- -- gls.right[#gls.right+1] = {
    -- -- PerCent = {
        -- -- provider            = "LinePercent",
        -- -- separator           = "|",
        -- -- separator_highlight = {colors.white, colors.bright_bg2},
        -- -- highlight           = {colors.white, colors.bright_bg2}
    -- -- }
-- -- } -- }}}


gls.short_line_left[#gls.short_line_left+1] = { -- {{{
    ShortFileType = {
        provider = function()
            vimMode = vim.fn.mode()
            changeHLColor("GalaxyShortFileType")

            local fileType = vim.bo.filetype
            local bufIcon = bufTypeIcons[fileType]
            if vim.tbl_contains(gl.short_line_list, fileType) then
                if bufIcon then
                    return " " .. bufIcon .. " " .. vim.bo.filetype:upper() .. " "
                else
                    return " " .. vim.bo.filetype:upper() .. " "
                end
            end
        end,
        condition = shortLineFileType,
        highlight = {colors.fg, colors.bg},
    }
}

gls.short_line_left[#gls.short_line_left+1] = {
    ShortFileTypeCap = {
        provider = function()
            vim.cmd("hi GalaxyShortFileTypeCap guifg=" .. modeColors[vimMode])
            return circleHalfRight
        end,
        condition = shortLineFileType,
        highlight = {colors.fg, colors.bg},
    }
}


gls.short_line_left[#gls.short_line_left+1] = {
    ShortFileIconStart = {
        provider = function() return " " end,
        highlight = {colors.gray, colors.bg1}
    }
}

gls.short_line_left[#gls.short_line_left+1] = {
    ShortFileIcon = {
        provider  = "FileIcon",
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg1}
    }
}

gls.short_line_left[#gls.short_line_left+1] = {
    ShortFileInfo = {
        provider  = fileInfo,
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg1}
    }
}

gls.short_line_right[#gls.short_line_right+1] = {
    ShortRightLineInfo = {
        provider  = lineInfo,
        condition = condition.buffer_not_empty and noShortLineFileType,
        highlight = {colors.gray, colors.bg1}
    }
} --- }}}

end
