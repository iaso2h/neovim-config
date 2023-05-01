-- File: nvim-galaxyline
-- Author: iaso2h
-- Description: Statusline configuration
-- Last Modified: 2023-4-30
return function() -- {{{
    local icon = require("icon")
    local gl        = require("galaxyline")
    local gls       = gl.section
    local condition = require("galaxyline.condition")
    local pallette  = require("onenord.pallette")

    -- Filetypes contained in this list will be consider inactive all the time
    gl.short_line_list = _G._short_line_list

    local colors = { -- {{{
        fg        = pallette.n10,
        bg1       = pallette.n1,
        bg2       = "#4C566A",
        bg3       = "#616e88",
        yellow    = pallette.n13,
        cyan      = pallette.n8,
        darkblue  = "#081633",
        green     = pallette.n14,
        orange    = pallette.orange,
        purple    = pallette.n15,
        magenta   = pallette.purple,
        blue      = pallette.n10,
        blueLight = pallette.n9,
        red       = pallette.n11,
        gray      = "#66738e",
        white     = pallette.n4,
    } -- }}}
    local alias        = { -- {{{
        n      = "NORMAL",
        i      = "INSERT",
        c      = "COMMAND",
        V      = "VISUAL",
        [""]  = "VISUAL",
        v      = "VISUAL",
        ["r?"] = ":CONFIRM",
        rm     = "--MORE",
        R      = "REPLACE",
        Rv     = "VIRTUAL",
        s      = "SELECT",
        S      = "SELECT",
        [""]  = "SELECT",
        ["r"]  = "HIT-ENTER",
        t      = "TERMINAL",
        ["!"]  = "SHELL"
    } -- }}}
    local modeColors   = { -- {{{
        n      = colors.cyan,
        i      = colors.green,
        c      = colors.yellow,
        V      = colors.orange,
        [""]  = colors.orange,
        v      = colors.orange,
        ["r?"] = colors.red,
        rm     = colors.red,
        R      = colors.red,
        Rv     = colors.red,
        s      = colors.magenta,
        S      = colors.magenta,
        [""]  = colors.magenta,
        ["r"]  = colors.purple,
        t      = colors.blue,
        ["!"]  = colors.blue
    } -- }}}

    local vimMode
    local tightWinChk = false
    local padding = _G._os_uname.machine ~= "aarch64" and " " or ""
    local isSpecialFileType = function() -- {{{
        return vim.tbl_contains(_G._short_line_list, vim.bo.filetype)
    end -- }}}
    local isNoNeckPain = function() -- {{{
        if vim.bo.filetype == "no-neck-pain" then
            return true
        else
            return false
        end
    end -- }}}
    local fileInfo = function() -- {{{
        if vim.bo.filetype == "qf" then -- {{{
            local title
            if vim.b._is_loc then
                title = vim.fn.getloclist(0, {title = 0}).title
            else
                title = vim.fn.getqflist({title = 0}).title
            end
            return title and "  " .. title or ""
        end -- }}}

        local cwd     = vim.loop.cwd()
        local absPath = nvim_buf_get_name(0)

        -- Scratch buffer
        if absPath == "" then return vim.bo.filetype .. padding end
        local fileStr

        if vim.startswith(absPath, "diffview") then -- {{{
            fileStr = vim.fn.expand("%:t")
            local commit = string.match(absPath, ".git" .. _G._sep .. "(%w%w%w%w%w%w%w%w)")
            if commit then
                fileStr = fileStr .. " | " .. commit .. padding
            else
                return padding
            end
            return fileStr .. padding
        end -- }}}

        -- Get file path string
        local relPath = string.match(absPath, cwd .. ".(.*)")
        local winWidth = vim.api.nvim_win_get_width(0)
        if relPath then
            fileStr = relPath
            -- 11 is what vimmode text is command plus space of icons
            tightWinChk = #fileStr + 11 > winWidth / 2

            fileStr = tightWinChk and vim.fn.pathshorten(fileStr, 1) or fileStr
        else
            fileStr = string.format("..%s%s", _G._sep, vim.fn.expand("%:t"))
            -- 11 is what vimmode text is command plus space of icons
            tightWinChk = #fileStr + 11 > winWidth / 2
        end

        if tightWinChk then
            return fileStr .. padding
        else
            local isMod  = vim.bo.readonly and padding .. icon.ui.Plus or ""
            local isRead = vim.bo.readonly and padding .. icon.ui.Lock or ""

            local ext = vim.fn.expand("%:e")
            local fileTypeStr = ext ~= vim.bo.filetype and
                string.format(" | %s ", vim.bo.filetype) or padding
            return fileStr .. isMod .. isRead .. fileTypeStr
        end
    end -- }}}
    local changeHLColor = function(hlStr) -- {{{
        local cmdStr
        if vim.o.paste then
            cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
                hlStr, colors.red, colors.bg1, "bold")
        elseif vimMode == "c" then
            cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
                hlStr, modeColors[vimMode], colors.blue, "bold")
        elseif vimMode == "n" then
            cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
                hlStr, modeColors[vimMode], colors.bg1, "bold")
        else
            cmdStr = string.format("hi %s guibg=%s guifg=%s gui=%s",
                hlStr, modeColors[vimMode], colors.white, "bold")
        end

        vim.cmd(cmdStr)
    end -- }}}
    local lineInfo = function() -- {{{
        local cursorPos   = vim.api.nvim_win_get_cursor(0)
        local totalLineNr = vim.fn.line("$")
        local lineColumn  = string.format("  %d:%d |", cursorPos[1], cursorPos[2] + 1)
        local percentage
        if cursorPos[1] == 1 then
            percentage = " Top "
        elseif cursorPos[1] == totalLineNr then
            percentage = " Bot "
        else
            percentage = string.format(" %s%% ", math.modf((cursorPos[1] / totalLineNr) * 100))
        end

        return lineColumn .. percentage
    end -- }}}
    local hideInTight = function() -- {{{
        return not tightWinChk
    end -- }}}


    gls.left[1] = { -- {{{
        VimMode = {
            provider = function()
                vimMode = vim.fn.mode()

                changeHLColor("GalaxyVimMode")

                if _G._os_uname.machine == "aarch64" then
                    return string.format(" %s ", alias[vimMode])
                elseif not _G._is_term then
                    return string.format("  %s %s ", require("nvim-nonicons").get("vim"), alias[vimMode])
                else
                    if vimMode == "t" or vimMode == "!" then
                        return string.format("  %s %s ", icon.ui.Terminal, alias[vimMode])
                    else
                        return string.format("  %s %s ", icon.ui.Vim, alias[vimMode])
                    end
                end
            end,
            highlight = { colors.fg, colors.bg1 },
        }
    }


    gls.left[#gls.left + 1] = {
        VimModeCap = {
            provider = function()
                local cmdStr
                if vim.o.paste then
                    cmdStr = string.format("hi GalaxyVimModeCap guifg=%s", colors.red)
                else
                    cmdStr = string.format("hi GalaxyVimModeCap guifg=%s", modeColors[vimMode])
                end
                vim.cmd(cmdStr)

                return icon.ui.CircleHalfRight .. " "
            end,
            highlight = { colors.fg, colors.bg3 },
        }
    }

    gls.left[#gls.left + 1] = {
        FileIcon = {
            provider  = "FileIcon",
            condition = condition.buffer_not_empty,
            highlight = {
                require("galaxyline.provider_fileinfo").get_file_icon_color,
                colors.bg3
            }
        }
    }

    gls.left[#gls.left + 1] = {
        FileInfo = {
            provider  = fileInfo,
            condition = condition.buffer_not_empty,
            highlight = { colors.white, colors.bg3 }
        }
    }

    gls.left[#gls.left + 1] = {
        FileInfoCap = {
            provider  = function() return icon.ui.CircleHalfRight end,
            highlight = { colors.bg3, colors.bg2 },
        }
    }

    -- if vim.fn.has("unix") == 1 then
    gls.left[#gls.left + 1] = {
        GitIcon = {
            provider  = function() return " " end,
            -- condition = condition.check_git_workspace,
            condition = condition.hide_in_width,
            highlight = { colors.purple, colors.bg2 },
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

    gls.left[#gls.left + 1] = {
        DiffLeadingSpace = {
            provider  = function() return " " end,
            condition = hideInTight,
            highlight = { colors.bg2, colors.bg2 }
        }
    }

    gls.left[#gls.left + 1] = {
        DiffAdd = {
            provider  = "DiffAdd",
            condition = hideInTight,
            icon      = _G._os_uname.machine == "aarch64" and " " or icon.git.LineAdded .. " ",
            highlight = { colors.green, colors.bg2 }
        }
    }

    gls.left[#gls.left + 1] = {
        DiffModified = {
            provider  = "DiffModified",
            condition = hideInTight,
            icon      = _G._os_uname.machine == "aarch64" and " " or icon.git.LineModified .. " ",
            highlight = { colors.yellow, colors.bg2 }
        }
    }

    gls.left[#gls.left + 1] = {
        DiffRemove = {
            provider  = "DiffRemove",
            condition = hideInTight,
            icon      = _G._os_uname.machine == "aarch64" and " " or icon.git.LineRemoved .. " ",
            highlight = { colors.red, colors.bg2 }
        }
    }

    gls.left[#gls.left + 1] = {
        GitCap = {
            provider  = function() return icon.ui.CircleHalfRight .. " " end,
            highlight = { colors.bg2, colors.bg1 },
        }
    }

    gls.left[#gls.left + 1] = {
        DiagnosticLeadingSpace = {
            provider  = function() return " " end,
            highlight = { colors.bg1, colors.bg1 }
        }
    }

    gls.left[#gls.left + 1] = {
        DiagnosticHint = {
            provider  = "DiagnosticHint",
            icon      = icon.diagnostics.Hint .. " ",
            highlight = { colors.blueLight, colors.bg1 },
        }
    }

    gls.left[#gls.left + 1] = {
        DiagnosticInfo = {
            provider  = "DiagnosticInfo",
            icon      = icon.diagnostics.Information .. " ",
            highlight = { colors.blue, colors.bg1 },
        }
    }

    gls.left[#gls.left + 1] = {
        DiagnosticWarn = {
            provider  = "DiagnosticWarn",
            icon      = icon.diagnostics.Warning .. " ",
            highlight = { colors.yellow, colors.bg1 }
        }
    }

    gls.left[#gls.left + 1] = {
        DiagnosticError = {
            provider  = "DiagnosticError",
            icon      = icon.diagnostics.Error .. " ",
            highlight = { colors.red, colors.bg1 }
        }
    } -- }}}

    -- gls.mid[1] = { -- {{{
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

    gls.right[1] = { -- {{{
        EncodingCap = {
            provider = function()
                return icon.ui.CircleHalfLeft
            end,
            highlight = { colors.bg3, colors.bg1 },
        }
    }

    gls.right[#gls.right + 1] = {
        Encoding = {
            provider = function()
                return "  " .. vim.o.encoding .. " "
            end,
            condition = hideInTight,
            highlight = { colors.white, colors.bg3 },
        }
    }

    gls.right[#gls.right + 1] = {
        LineInfoCap = {
            provider = function() return icon.ui.CircleHalfLeft end,
            highlight = "GalaxyVimModeCap"
        }
    }

    gls.right[#gls.right + 1] = {
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

    gls.short_line_left[1] = { -- {{{
        SpecialFileTypeVimMode = {
            provider = function()
                -- UGLY: somehow non-special filetypes will sneak in
                if not isSpecialFileType() then return "" end
                vimMode = vim.fn.mode()
                changeHLColor("GalaxySpecialFileTypeVimMode")

                local leadingSpaces = "  "
                local fileType = vim.bo.filetype
                if fileType == "qf" then
                    -- The value of vim.b._is_loc is set up whenever a qf filetype
                    -- is set via `after/ftplugin/qf.lua`
                    fileType = vim.b._is_loc and "Location list" or "Quickfix"
                    return leadingSpaces .. icon.ui.Quickfix .. padding .. fileType .. padding
                else
                    local bufIcon  = _G._short_line_infos[fileType].icon
                    local fileName = _G._short_line_infos[fileType].name
                    if bufIcon then
                        return leadingSpaces .. bufIcon .. padding .. fileName .. padding
                    else
                        return leadingSpaces .. fileName .. padding
                    end
                end
            end,
            condition = isSpecialFileType,
            highlight = { colors.fg, colors.bg },
        }
    }

    gls.short_line_left[#gls.short_line_left + 1] = {
        SpecialFileTypeVimModeCap = {
            provider = function()
                vim.cmd("hi GalaxySpecialFileTypeVimModeCap guifg=" .. modeColors[vimMode])
                return icon.ui.CircleHalfRight
            end,
            condition = isSpecialFileType,
            highlight = { colors.fg, colors.bg },
        }
    }

    gls.short_line_left[#gls.short_line_left + 1] = {
        ShortFileIcon = {
            provider  = function()
                return " " .. require("galaxyline.provider_fileinfo").get_file_icon()
            end,
            condition = function()
                return not isNoNeckPain() and
                    condition.buffer_not_empty() and
                    not isSpecialFileType()
            end,
            highlight = { colors.gray, colors.bg1 }
        }
    }

    local fileInfoWhitelist = {"qf"}
    gls.short_line_left[#gls.short_line_left + 1] = {
        ShortFileInfo = {
            provider  = fileInfo,
            condition = function()
                if vim.tbl_contains(fileInfoWhitelist, vim.bo.filetype) then
                    return true
                elseif isNoNeckPain() then
                    return false
                else
                    return condition.buffer_not_empty() and not isSpecialFileType()
                end
            end,
            highlight = { colors.gray, colors.bg1 }
        }
    }

    -- local ShortRightLineInfoWhitelist = {"help"}
    gls.short_line_right[1] = {
        ShortRightLineInfo = {
            provider  = lineInfo,
            condition = function()
                if isNoNeckPain() then
                    return false
                    -- elseif vim.tbl_contains(ShortRightLineInfoWhitelist, vim.bo.filetype) then
                    --     return true
                else
                    return condition.buffer_not_empty() and not isSpecialFileType()
                end
            end,
            highlight = { colors.gray, colors.bg1 }
        }
    } --- }}}

end -- }}}
