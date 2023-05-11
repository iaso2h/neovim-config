-- File: nvim-feline.lua
-- Author: iaso2h
-- Description: Statusline configuration
-- Last Modified: Mon 08 May 2023
return function()
    local feline         = require("feline")
    local icon           = require("icon")
    local pallette       = require("onenord.pallette")
    local colors = { -- {{{
        fg       = pallette.n10,
        bg       = pallette.n1,
        bg2      = pallette.n2,
        bg3      = pallette.n3,
        bg4      = pallette.n3b,
        blue     = pallette.n10,
        cyan     = pallette.n8,
        green    = pallette.n14,
        orange   = pallette.orange,
        purple   = pallette.n15,
        magenta  = pallette.purple,
        red      = pallette.n11,
        yellow   = pallette.n13,
        gray     = "#66738e",
        white    = pallette.n4,
    } -- }}}
    local vi_mode_colors = { -- {{{
        NORMAL        = "cyan",
        OP            = "blue",
        INSERT        = "green",
        VISUAL        = "orange",
        LINES         = "orange",
        BLOCK         = "orange",
        REPLACE       = "red",
        ["V-REPLACE"] = "red",
        SELECT        = "magenta",
        COMMAND       = "yellow",
        TERM          = "blue",
        SHELL         = "blue",
    } -- }}}
    local padding     = _G._os_uname.machine ~= "aarch64" and " " or ""
    --- @return string
    local getFileInfo = function() -- {{{
        local fileType = vim.bo.filetype

        local cwd     = vim.loop.cwd()
        local absPath = nvim_buf_get_name(0)

        -- Check scratch buffer
        if absPath == "" then
            if fileType == "" then
                return "Scratch" .. padding
            else
                return fileType .. padding
            end
        end
        local fileStr

        -- Get file path string
        local relPath = string.match(absPath, cwd .. ".(.*)")
        local winWidth = vim.api.nvim_win_get_width(0)
        local tightWinChk = false
        if relPath then
            fileStr = relPath
            -- 11 is what vimmode text is command plus space of icons
            tightWinChk = #fileStr + 13 > winWidth / 2

            fileStr = tightWinChk and vim.fn.pathshorten(fileStr, 1) or fileStr
        else
            fileStr = string.format("..%s%s", _G._sep, vim.fn.expand("%:t"))
            -- 11 is what vimmode text is command plus space of icons
            tightWinChk = #fileStr + 13 > winWidth / 2
        end

        if tightWinChk then
            return fileStr .. padding
        else
            local isMod       = vim.bo.modified and padding .. icon.ui.Plus or ""
            local isRead      = vim.bo.readonly and padding .. icon.ui.Lock or ""

            local ext         = vim.fn.expand("%:e")
            local fileTypeStr = ext ~= fileType and
                string.format(" | %s", fileType) or ""
            return fileStr .. isMod .. isRead .. fileTypeStr
        end
    end -- }}}
    --- @return string
    local getLineInfo = function() -- {{{
        local cursorPos       = vim.api.nvim_win_get_cursor(0)
        local bufferLineCount = vim.api.nvim_buf_line_count(0)
        local lineColumn      = string.format("%d:%d%s", cursorPos[1], cursorPos[2] + 1, padding)
        local percentage
        if cursorPos[1] == 1 then
            percentage = "Top"
        elseif cursorPos[1] == bufferLineCount then
            percentage = "Bot"
        else
            percentage = string.format("%2d%%%%", math.ceil(cursorPos[1] / bufferLineCount * 99))
        end

        return lineColumn .. percentage .. padding
    end -- }}}
    --- @return table
    local getVimModeHighlight = function() -- {{{
        local u = require("feline.providers.vi_mode")
        local tbl = {
            name  = "FelineVimMode",
            style = "bold",
        }
        local vimMode = u.get_vim_mode()
        if vim.o.paste then
            tbl.name = "StatusComponentVimPaste"
            tbl.fg   = colors.bg
            tbl.bg   = colors.red
        elseif vimMode == "COMMAND" then
            tbl.name = u.get_mode_highlight_name()
            tbl.fg   = colors.blue
            tbl.bg   = u.get_mode_color()
        elseif vimMode == "NORMAL" then
            tbl.name = u.get_mode_highlight_name()
            tbl.fg   = colors.bg
            tbl.bg   = u.get_mode_color()
        else
            tbl.fg   = colors.white
            tbl.name = u.get_mode_highlight_name()
            tbl.bg   = u.get_mode_color()
        end
        return tbl
    end -- }}}
    --- @return table
    local getVimModeHighlightInverse = function() -- {{{
        local u = require("feline.providers.vi_mode")
        local tbl = {
            bg    = colors.bg4,
        }
        if vim.o.paste then
            tbl.name = "StatusComponentVimPasteInverse"
            tbl.fg   = colors.red
        else
            tbl.name = u.get_mode_highlight_name() .. "Inverse"
            tbl.fg   = u.get_mode_color()
        end
        return tbl
    end -- }}}
    --- @return string
    local getGitDiff = function(type) -- {{{
        local gsd = vim.b.gitsigns_status_dict

        if gsd and gsd[type] and gsd[type] > 0 then
            return tostring(gsd[type])
        else
            return ""
        end
    end -- }}}
    --- @return string
    local getDiagnostics = function(severity) -- {{{
        local count = require("feline.providers.lsp").get_diagnostics_count(severity)

        return count ~= 0 and tostring(count) or ''
    end -- }}}
    local components = { -- {{{
        vimMode = {-- {{{
            provider  = {
                name = "vi_mode",
                opts = {
                    show_mode_name = true,
                    -- padding = "center",
                },
            },
            hl = getVimModeHighlight,
            left_sep  = "block",
            right_sep = {
                always_visible = true,
                str = icon.ui.CircleHalfRight,
                hl = getVimModeHighlightInverse,
            }
        }, -- }}}
        vimModeSpecialFiletype = { -- {{{
            provider = function()
                local fileType = vim.bo.filetype
                if fileType == "qf" then
                    -- The value of vim.b._is_local is set up whenever a qf filetype
                    -- is set via `after/ftplugin/qf.lua`
                    fileType = vim.b._is_local and "Location list" or "Quickfix"
                    return padding .. icon.ui.Quickfix .. padding .. fileType .. padding
                elseif vim.tbl_contains(_G._short_line_list, fileType)then
                    local bufIcon = _G._short_line_infos[fileType].icon
                    local fileStr
                    if bufIcon then
                        fileStr = _G._short_line_infos[fileType].name
                        return bufIcon .. padding .. fileStr .. padding
                    else
                        return fileStr .. padding
                    end
                elseif vim.startswith(nvim_buf_get_name(0), "diffview") then
                    return icon.ui.History .. padding .. "Diff"
                else
                    return fileType:upper()
                end
            end,
            hl = getVimModeHighlight,
            left_sep  = "block",
            right_sep = {
                always_visible = true,
                str = icon.ui.CircleHalfRight,
                hl = getVimModeHighlightInverse
            }
        }, -- }}}
        fileInfo = { -- {{{
            provider = function()
                local fileInfo = getFileInfo()
                -- Avoid loading nvim-web-devicons if an icon is provided already
                local iconStr, iconColor = require('nvim-web-devicons').get_icon_color(
                    vim.fn.expand('%:t'),
                    nil, -- extension is already computed by nvim-web-devicons
                    { default = true }
                )
                if iconStr then
                    return fileInfo, {
                        str = padding .. iconStr .. padding,
                        hl = {
                            fg = iconColor
                        }
                    }
                else
                    return fileInfo
                end
            end,
            hl = {
                fg = colors.white,
                bg = colors.bg4
            },
            right_sep = {
                str = icon.ui.CircleHalfRight,
                hl = {
                    bg = colors.bg3,
                    fg = colors.bg4
                },
            }
        }, -- }}}
        fileInfoInactive = { -- {{{
            provider = function() return padding .. getFileInfo() end,
            hl = {
                fg = colors.gray,
                bg = colors.bg2
            },
            right_sep = {
                str = icon.ui.CircleHalfRight,
                hl = {
                    fg = colors.bg2,
                    bg = colors.bg1
                },
            }
        }, -- }}}
        fileInfoSpecialFileType = { -- {{{
            provider = function()
                local fileType = vim.bo.filetype
                local fileName = nvim_buf_get_name(0)
                if fileType == "help" then
                    return padding .. getFileInfo()
                elseif fileType == "qf" then
                    -- Check quickfix
                    local fileStr
                    if vim.b._is_local then
                        fileStr = vim.fn.getloclist(0, { title = 0 }).title
                    else
                        fileStr = vim.fn.getqflist({ title = 0 }).title
                    end
                    return fileStr and padding .. fileStr or ""
                elseif vim.startswith(fileName, "diffview") then
                    -- Check diffview
                    local fileStr = vim.fn.expand("%:t")
                    local commit = string.match(fileName, ".git" .. _G._sep .. "(%w%w%w%w%w%w%w%w)")
                    if commit then
                        fileStr = padding .. fileStr .. " | " .. commit
                        return fileStr
                    else
                        return padding
                    end
                else
                    return " "
                end
            end,
            hl = {
                fg = colors.white,
                bg = colors.bg4
            },
            right_sep = {
                str = icon.ui.CircleHalfRight,
                hl = {
                    bg = colors.bg1,
                    fg = colors.bg4
                },
            }
        }, -- }}}
        gitBranch = { -- {{{
            provider = "git_branch",
            hl = {
                fg = colors.green,
                bg = colors.bg3,
                style = "bold",
            },
            truncate_hide = true,
            left_sep = "block",
            right_sep = "block",
        }, -- }}}
        gitDiffAdded = { -- {{{
            provider = function()
                return getGitDiff("changed"), padding .. icon.git.LineAdded .. padding
            end,
            hl = {
                fg = colors.green,
                bg = colors.bg3
            },
            truncate_hide = true,
        }, -- }}}
        gitDiffChanged = { -- {{{
            provider = function()
                return getGitDiff("changed"), padding .. icon.git.LineModified .. padding
            end,
            hl = {
                fg = colors.yellow,
                bg = colors.bg3
            },
            truncate_hide = true,
        }, -- }}}
        gitDiffRemoved = { -- {{{
            provider = function()
                return getGitDiff("changed"), padding .. icon.git.LineRemoved .. padding
            end,
            hl = {
                fg = colors.red,
                bg = colors.bg3
            },
            truncate_hide = true,
        }, -- }}}
        gitSeparatorRight = { -- {{{
            provider = icon.ui.CircleHalfRight,
            hl = {
                fg = colors.bg3,
                bg = colors.bg
            },
        }, -- }}}
        diagnosticHints = { -- {{{
            provider = function()
                return getDiagnostics(vim.diagnostic.severity.HINT), padding .. icon.diagnostics.HintBold .. padding
            end,
            hl = {
                fg = colors.blueLight,
            },
            truncate_hide = true,
        }, -- }}}
        diagnosticInfo = { -- {{{
            provider = function()
                return getDiagnostics(vim.diagnostic.severity.INFO), padding .. icon.diagnostics.InformationBold .. padding
            end,
            hl = {
                fg = colors.blue,
            },
        }, -- }}}
        diagnosticWarnings = { -- {{{
            provider = function()
                return getDiagnostics(vim.diagnostic.severity.WARN), padding .. icon.diagnostics.WarningBold .. padding
            end,
            hl = {
                fg = colors.yellow,
            },
            truncate_hide = true,
        }, -- }}}
        diagnosticErrors = { -- {{{
            provider = function()
                return getDiagnostics(vim.diagnostic.severity.ERROR), padding .. icon.diagnostics.ErrorBold .. padding
            end,
            hl = {
                fg = colors.red,
            },
            truncate_hide = true,
        }, -- }}}
        fileEncoding = { -- {{{
            provider = function()
                return
                    vim.bo.fenc ~= '' and vim.bo.fenc .. padding or vim.o.enc .. padding
            end,
            hl = {
                fg = colors.white,
                bg = colors.bg4
            },
            left_sep = icon.ui.CircleHalfLeft,
            truncate_hide = true,
        }, -- }}}
        lineInfo = { -- {{{
            provider = getLineInfo,
            hl       = getVimModeHighlight,
            left_sep = {
                str = icon.ui.CircleHalfLeft,
                hl  = getVimModeHighlightInverse
            },
        }, -- }}}
        lineInfoInactive = { -- {{{
            provider = getLineInfo,
            hl = {
                fg = colors.gray,
                bg = colors.bg2
            },
            left_sep = {
                str = icon.ui.CircleHalfLeft,
                hl = {
                    fg = colors.bg2,
                    bg = colors.bg1
                },
            },
        }, -- }}}
    } -- }}}

    feline.setup {
        components = {
            active = {
                {
                    components.vimMode,
                    components.fileInfo,
                    components.gitDiffAdded,
                    components.gitDiffChanged,
                    components.gitDiffRemoved,
                    components.gitSeparatorRight,
                    components.diagnosticInfo,
                    components.diagnosticHints,
                    components.diagnosticWarnings,
                    components.diagnosticErrors
                },
                {},
                {
                    components.fileEncoding,
                    components.lineInfo,
                },
            },
            inactive = {
                {components.fileInfoInactive},
                {},
                {components.lineInfoInactive},
            },
        },
        conditional_components = {
            {
                condition = function() return vim.bo.filetype == "no-neck-pain" end,
                active   = { {}, {}, {} },
                inactive = { {}, {}, {} },
            },
            {
                condition = function()
                    return vim.bo.filetype == "help" or vim.bo.filetype == "qf"
                end,
                active = {
                    {
                        components.vimModeSpecialFiletype,
                        components.fileInfoSpecialFileType
                    },
                    {},
                    {components.lineInfo}
                },
                inactive = {
                    {
                        components.vimModeSpecialFiletype,
                        components.fileInfoSpecialFileType
                    },
                    {},
                    {components.lineInfoInactive}
                },
            },
            {
                condition = function()
                    return require("buffer.util").isSpecialBuf(0)
                end,
                active = {
                    {
                        components.vimModeSpecialFiletype,
                        components.fileInfoSpecialFileType
                    },
                    {},
                    {}
                },
                inactive = {
                    {
                        components.vimModeSpecialFiletype,
                        components.fileInfoSpecialFileType
                    },
                    {},
                    {}
                },
            },
        },
        theme = colors,
        vi_mode_colors = vi_mode_colors,
    }
end
