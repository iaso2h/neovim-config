-- https://github.com/iaso2h/nvim-cokeline/tree/master
return function()
    local getHex = require("cokeline/utils").get_hex
    local space  = {text = " "}
    require("cokeline").setup{
        buffers = {
            new_buffers_position = "bufnr"
        },
        default_hl = {
            fg = function(buffer)
                return buffer.is_focused and getHex("Normal", "fg") or getHex("Comment", "fg")
            end,
            bg = function(buffer)
                return buffer.is_focused and getHex("StatusLine", "bg") or getHex("Normal", "bg")
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
                        return " "
                    elseif buffer.is_modified then
                        return " ●"
                    else
                        return ""
                    end
                end,
                fg = function(buffer)
                    if buffer.is_readonly then
                        return getHex("Comment", "fg")
                    elseif buffer.is_modified then
                        return getHex("diffChanged", "fg")
                    else
                        return nil
                    end
                end
            },
            space
        },
        sidebar = {
            filetype = {"NvimTree", "dapui_"},
            components = {
                {
                    text = "",
                    bg = getHex("Normal", "bg"),
                },
            }
        },
    }
    map("n", [[g<A-,>]],  [[<Plug>(cokeline-switch-prev)]], "Cokeline switch previous")
    map("n", [[g<A-.>]],  [[<Plug>(cokeline-switch-next)]], "Cokeline switch next")
    map("n", "<leader>b", [[<Plug>(cokeline-pick-focus)]],  "Cokeline focus")
end
