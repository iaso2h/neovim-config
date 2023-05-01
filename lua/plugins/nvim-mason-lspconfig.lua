local M = {}

M.servers = {
    cmake = {},
    cssls = {},
    html = {},
    jsonls = {},
    lua_ls = {},
    pyright = {},
    tsserver = {},
    vimls = {},
}

if _G._os_uname.sysname == "Linux" and _G._os_uname.machine ~= "aarch64" then
    M.servers.fennel_language_server = {}
elseif _G._os_uname.sysname == "Windows_NT" then
    M.servers.powershell_es = {}
end

if _G._os_uname.machine ~= "aarch64" then
    M.servers = vim.tbl_extend("keep", M.servers, {
        grammarly = {},
        marksman = {},
        yamlls = {},
        bashls = {},
        clangd = {},
    })
end



M.config = function()
    require("mason-lspconfig").setup {
        -- A list of servers to automatically install if they're not already
        -- installed. Example: { "rust_analyzer@nightly", "lua_ls" }
        -- This setting has no relation with the `automatic_installation` setting.
        ensure_installed = vim.tbl_keys(require("plugins.nvim-mason-lspconfig").servers),
        -- Whether servers that are set up (via lspconfig) should be automatically
        -- installed if they're not already installed.
        -- This setting has no relation with the `ensure_installed` setting.
        -- Can either be:
        --   - false: Servers are not automatically installed.
        --   - true: All servers set up via lspconfig are automatically installed.
        --   - { exclude: string[] }: All servers set up via lspconfig, except the
        --   ones provided in the list, are automatically installed.
        --       Example: automatic_installation = { exclude = { "rust_analyzer",
        --       "solargraph" } }
        automatic_installation = true
    }
end

return M
