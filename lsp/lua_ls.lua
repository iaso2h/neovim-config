-- https://github.com/LuaLS/lua-language-server
-- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
return {
    settings = {
        Lua = {
            -- https://luals.github.io/wiki/settings/
            runtime = {
                version = "LuaJIT",
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            format = {enable = true},
            completion = {
                callSnippet    = "Replace",
                keywordSnippet = "Replace",
            },
            diagnostics = {
                disable = {
                    "trailing-space",
                    "empty-block"
                },
                globals = {
                    "vim"
                },
            },
            workspace = {
                checkThirdParty = false,
                useGitIgnore    = true
            },
        },
    },
}
