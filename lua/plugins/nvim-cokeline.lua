-- https://github.com/willothy/nvim-cokeline
return function()
    local getHighlightAttr = require("cokeline.hlgroups").get_hl_attr
    local icon   = require("icon")
    local space  = {text = " "}
    require("cokeline").setup{
        default_hl = {
            fg = function(buffer)
                return buffer.is_focused and getHighlightAttr("Normal", "fg") or getHighlightAttr("Comment", "fg")
            end,
            bg = function(buffer)
                return buffer.is_focused and getHighlightAttr("StatusLine", "bg") or getHighlightAttr("Normal", "bg")
            end,
        },
        components = {
            space,
            {
                text = function(buffer)
                    return buffer.devicon.icon
                end,
                fg = function(buffer)
                    return buffer.devicon.color
                end
            },
            {
                text = function(buffer)
                    local filename = buffer.filename
                    if filename == "init.lua" then
                        local lastIdx = 0
                        local idxTbl = {}
                        repeat
                            lastIdx = string.find(buffer.path, _G._sep, lastIdx + 1, false)
                            if lastIdx then
                                idxTbl[#idxTbl + 1] = lastIdx
                            end
                        until not lastIdx

                        if not next(idxTbl) then
                            return filename
                        end

                        if #idxTbl == 1 then
                            return buffer.path
                        end

                        local secondToLastSep = idxTbl[#idxTbl - 1]
                        if secondToLastSep then
                            return string.sub(buffer.path, secondToLastSep + 1, -1)
                        end
                    end

                    return filename
                end,
                style = function(buffer)
                    if buffer.is_focused then
                        return "bold"
                    else
                        return nil
                    end
                end
            },
            {
                text = function(buffer)
                    if buffer.is_readonly then
                        return " " .. icon.ui.Lock
                    elseif buffer.is_modified then
                        return " " .. icon.ui.Dot
                    else
                        return ""
                    end
                end,
                fg = function(buffer)
                    if buffer.is_readonly then
                        return getHighlightAttr("Comment", "fg")
                    elseif buffer.is_modified then
                        return getHighlightAttr("diffChanged", "fg")
                    else
                        return nil
                    end
                end
            },
            space
        },
        sidebar = {
            filetype = {
                "NvimTree",
                "dapui_watches",
                "dapui_console",
                "dapui_stacks",
                "dapui_breakpoints",
                "dapui_scopes"
            },
            components = {
                {
                    text = "",
                    bg = getHighlightAttr("Normal", "bg"),
                },
            }
        },
    }
    map("n", [=[g[b]=],  [[<Plug>(cokeline-switch-prev)]], "Cokeline switch previous")
    map("n", [=[g]b]=],  [[<Plug>(cokeline-switch-next)]], "Cokeline switch next")
    -- BUG:
    map("n", "<leader>b", [[<CMD>lua require"cokeline.mappings".pick("focus")<CR>]],  "Cokeline focus")
end
