local M = {}

M.serverNames = {
    "clangd",
    "cssls",
    "harper_ls",
    "html",
    "jsonls",
    "lua_ls",
    "pyright",
    "vimls",
    "yamlls",
    "omnisharp",
    "ruff",
}

if _G._os_uname.sysname == "Windows_NT" then
    table.insert(M.serverNames, "powershell_es")
end


M.config = function()
    require("mason-lspconfig").setup {
        ensure_installed = require("plugins.nvim-mason-lspconfig").serverNames,
        automatic_enable = true
    }
end

return M
