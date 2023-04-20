return  function()
    local getHex = require("cokeline/utils").get_hex
    local space  = {text = " "}
    require("cokeline").setup{
        buffers = {
            new_buffers_position = "last"
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
                    return buffer.filename
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
    map("n", [[g<A-,>]], [[<Plug>(cokeline-switch-prev)]], "Cokeline switch previous")
    map("n", [[g<A-.>]], [[<Plug>(cokeline-switch-next)]], "Cokeline switch next")
end
