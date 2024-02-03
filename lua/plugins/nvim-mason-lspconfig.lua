local M = {}

M.serverNames = {
    -- cmake    = {},
    cssls    = {},
    html     = {},
    jsonls   = {},
    lua_ls   = {},
    pyright  = {},
    tsserver = {},
    vimls    = {},
    grammarly = {},
    marksman = {},
    yamlls = {},
    bashls = {},
    clangd = {},
}

if _G._os_uname.sysname == "Linux" then
    if _G._os_uname.machine ~= "aarch64" then
        M.serverNames.grammarly = nil
        M.serverNames.marksman  = nil
        M.serverNames.yamlls    = nil
        M.serverNames.bashls    = nil
        M.serverNames.clangd    = nil
    else
        M.serverNames.fennel_language_server = {}
    end
elseif _G._os_uname.sysname == "Windows_NT" then
    M.serverNames.powershell_es = {}
end


M.config = function()
    require("mason-lspconfig").setup {
        -- A list of servers to automatically install if they're not already
        -- installed. Example: { "rust_analyzer@nightly", "lua_ls" }
        -- This setting has no relation with the `automatic_installation` setting.
        ensure_installed = vim.tbl_keys(require("plugins.nvim-mason-lspconfig").serverNames),
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
