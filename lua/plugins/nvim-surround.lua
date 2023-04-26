return function()
    local M = require("nvim-surround.config")
    require("nvim-surround").setup {
        keymaps =  {
            normal     = "gs",
            normal_cur = "gss",
            delete     = "ds",
            change     = "cs",
        },
        surrounds = { -- #e604712(2023-04-02) {{{
            ["("] = {
                add = { "(", ")" },
                find = function()
                    return M.get_selection({ motion = "a(" })
                end,
                delete = "^(. ?)().-( ?.)()$",
            },
            [")"] = {
                add = { "(", ")" },
                find = function()
                    return M.get_selection({ motion = "a)" })
                end,
                delete = "^(.)().-(.)()$",
            },
            ["{"] = {
                add = { "{", "}" },
                find = function()
                    return M.get_selection({ motion = "a{" })
                end,
                delete = "^(. ?)().-( ?.)()$",
            },
            ["}"] = {
                add = { "{", "}" },
                find = function()
                    return M.get_selection({ motion = "a}" })
                end,
                delete = "^(.)().-(.)()$",
            },
            ["<"] = {
                add = { "<", ">" },
                find = function()
                    return M.get_selection({ motion = "a<" })
                end,
                delete = "^(. ?)().-( ?.)()$",
            },
            [">"] = {
                add = { "<", ">" },
                find = function()
                    return M.get_selection({ motion = "a>" })
                end,
                delete = "^(.)().-(.)()$",
            },
            ["["] = {
                add = { "[", "]" },
                find = function()
                    return M.get_selection({ motion = "a[" })
                end,
                delete = "^(. ?)().-( ?.)()$",
            },
            ["]"] = {
                add = { "[", "]" },
                find = function()
                    return M.get_selection({ motion = "a]" })
                end,
                delete = "^(.)().-(.)()$",
            },
            ["'"] = {
                add = { "'", "'" },
                find = function()
                    return M.get_selection({ motion = "a'" })
                end,
                delete = "^(.)().-(.)()$",
            },
            ['"'] = {
                add = { '"', '"' },
                find = function()
                    return M.get_selection({ motion = 'a"' })
                end,
                delete = "^(.)().-(.)()$",
            },
            ["`"] = {
                add = { "`", "`" },
                find = function()
                    return M.get_selection({ motion = "a`" })
                end,
                delete = "^(.)().-(.)()$",
            },
            ["i"] = { -- TODO: Add find/delete/change functions
                add = function()
                    local left_delimiter = M.get_input("Enter the left delimiter: ")
                    local right_delimiter = left_delimiter and M.get_input("Enter the right delimiter: ")
                    if right_delimiter then
                        return { { left_delimiter }, { right_delimiter } }
                    end
                end,
                find = function() end,
                delete = function() end,
            },
            ["t"] = {
                add = function()
                    local user_input = M.get_input("Enter the HTML tag: ")
                    if user_input then
                        local element = user_input:match("^<?([^%s>]*)")
                        local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

                        local open = attributes and element .. " " .. attributes or element
                        local close = element

                        return { { "<" .. open .. ">" }, { "</" .. close .. ">" } }
                    end
                end,
                find = function()
                    return M.get_selection({ motion = "at" })
                end,
                delete = "^(%b<>)().-(%b<>)()$",
                change = {
                    target = "^<([^%s<>]*)().-([^/]*)()>$",
                    replacement = function()
                        local user_input = M.get_input("Enter the HTML tag: ")
                        if user_input then
                            local element = user_input:match("^<?([^%s>]*)")
                            local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

                            local open = attributes and element .. " " .. attributes or element
                            local close = element

                            return { { open }, { close } }
                        end
                    end,
                },
            },
            ["T"] = {
                add = function()
                    local user_input = M.get_input("Enter the HTML tag: ")
                    if user_input then
                        local element = user_input:match("^<?([^%s>]*)")
                        local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

                        local open = attributes and element .. " " .. attributes or element
                        local close = element

                        return { { "<" .. open .. ">" }, { "</" .. close .. ">" } }
                    end
                end,
                find = function()
                    return M.get_selection({ motion = "at" })
                end,
                delete = "^(%b<>)().-(%b<>)()$",
                change = {
                    target = "^<([^>]*)().-([^/]*)()>$",
                    replacement = function()
                        local user_input = M.get_input("Enter the HTML tag: ")
                        if user_input then
                            local element = user_input:match("^<?([^%s>]*)")
                            local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

                            local open = attributes and element .. " " .. attributes or element
                            local close = element

                            return { { open }, { close } }
                        end
                    end,
                },
            },
            ["f"] = {
                add = function()
                    local result = M.get_input("Enter the function name: ")
                    if result then
                        return { { result .. "(" }, { ")" } }
                    end
                end,
                find = function()
                    if vim.g.loaded_nvim_treesitter then
                        local selection = M.get_selection({
                            query = {
                                capture = "@call.outer",
                                type = "textobjects",
                            },
                        })
                        if selection then
                            return selection
                        end
                    end
                    return M.get_selection({ pattern = "[^=%s%(%){}]+%b()" })
                end,
                delete = "^(.-%()().-(%))()$",
                change = {
                    target = "^.-([%w_]+)()%(.-%)()()$",
                    replacement = function()
                        local result = M.get_input("Enter the function name: ")
                        if result then
                            return { { result }, { "" } }
                        end
                    end,
                },
            },
            invalid_key_behavior = {
                add = function(char)
                    if not char or char:find("%c") then
                        return nil
                    end
                    return { { char }, { char } }
                end,
                find = function(char)
                    if not char or char:find("%c") then
                        return nil
                    end
                    return M.get_selection({
                        pattern = vim.pesc(char) .. ".-" .. vim.pesc(char),
                    })
                end,
                delete = function(char)
                    if not char or char:find("%c") then
                        return nil
                    end
                    return M.get_selections({
                        char = char,
                        pattern = "^(.)().-(.)()$",
                    })
                end,
            },
        }, -- }}}
        aliases     = {},
        highlight   = {duration = 550},
        move_cursor = {move_cursor = true}
    }
    _G._nvim_surround = function(motionType)
        if motionType == "line" then
            require("nvim-surround.cache").normal = { line_mode = true }
        else
            require("nvim-surround.cache").normal = { line_mode = false }
        end
        require("nvim-surround").normal_callback(motionType)
    end
    map("n", [[<Plug>surroundNormal]], function()
        require("nvim-surround").normal_curpos = require("nvim-surround.buffer").get_curpos()

        vim.o.operatorfunc = "v:lua._nvim_surround"
        return "g@"
    end, {"expr"}, "Add a surrounding pair around a motion (normal mode)")
    map("n", [[<Plug>surroundNormalCurLine]], function()
        require("nvim-surround").normal_curpos = require("nvim-surround.buffer").get_curpos()

        vim.o.operatorfunc = "v:lua._nvim_surround"
        return "g@"
    end, {"expr"}, "Add a surrounding pair around a motion (normal mode)")
    map("x", [[<Plug>surroundVisual]],
        luaRHS[[
        :lua
        local visualMode = vim.fn.visualmode();
        if visualMode == "v" then
            require("nvim-surround").visual_surround { line_mode = false }
        elseif visualMode == "V" then
            require("nvim-surround").visual_surround { line_mode = true }
        else
            return
        end<CR>]], {"silent"}, "Add a surrounding pair around a visual selection")
    map("n", [[gs]], [[<Plug>surroundNormal]], "Add a surrounding pair around a normal motion")
    map("x", [[S]],  [[<Plug>surroundVisual]], "Add a surrounding pair around a visual selection")
end
