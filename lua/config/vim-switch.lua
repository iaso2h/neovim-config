-- https://github.com/AndrewRadev/switch.vim
return function ()
    local api = vim.api
    local words = vim.fn["switch#Words"]

    api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        desc    = "Additional switch dictionary for Lua",
        callback = function()
            vim.b.switch_custom_definitions = {
                {
-- Convert a ternary syntax into a if
-- s#\(\s\{-}\)\?\(local\)\?\s\?\(\w\+\)\s\+=\s\+\(.\{-}\)\s\+and\s\+\(.\{-}\)\s\+or\s\+\(.*\)$#\2 \3\rif \4 then\r\1\3 = \5\relse\r\1\3 = \6\rend
[ [=[\(\s\{-}\)\?\(local \)\?\s\?\(\w\+\)\s\+=\s\+\(.\{-}\)\s\+and\s\+\(.\{-}\)\s\+or\s\+\(.*\)$]=] ] = [[\2\3\rif \4 then\r\1\3 = \5\relse\r\1\3 = \6\rend]],
                },
                {
-- Convert a pcall function call into a standard functon call
-- '<,'>s#\(\s\{-}\)\?pcall(\(\w\+\),\(\s\+\)\?\(.*\))#\1\2(\4)
[ [=[\(\s\{-}\)\?pcall(\(\w\+\),\(\s\+\)\?\(.*\))]=] ] = [[\1\2(\4)]]

                }
            }
        end
    })

    api.nvim_create_autocmd("FileType", {
        pattern = "autohotkey",
        desc    = "Additional switch dictionary for Autohotkey",
        callback = function()
            vim.b.switch_custom_definitions = {
                words{"down", "up"},
                {
                    [ [=[send,\s\?{\(\w\+\)\s\+\w\+}]=] ] = [[send, \1]],
                    [ [=[send,\s\+\(\w\+\)]=] ] = [[send, {\1 down}]],
                },
            }
        end
    })

    -- OPTIM: dirty workaround. Filetype event with pattern set to "fennel"
    -- doesn't work :(
    api.nvim_create_autocmd("FileType", {
        pattern = "fennel",
        desc    = "Additional switch dictionary for Fennel",
        callback = function()
            vim.b.switch_custom_definitions = {
                {
                    [ [=[:\(\w\+\)]=] ] = [["\1"]],
                    [ [=["\(\w\+\)"]=] ] = [[:\1]],
                },
            }
        end
    })

end

