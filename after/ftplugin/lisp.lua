vim.bo.ts  = 2
vim.bo.sts = 2
vim.bo.sw  = 2
-- LUARUN: for _, ft in ipairs(_G._lisp_language) do pcall(vim.api.nvim_command, string.format([[noa w! %s%safter%sftplugin%s%s.lua]], _G._config_path, _G._sep, _G._sep, _G._sep, ft)) end
bmap(0, "n", [[gK]],         [[<CMD>lua require("luaKeywordHelp")()<cr>]], {"silent"}, "Lookup in Neovim help")
local ok, _ = pcall(require, "quotePairs")
if ok then
    bmap(0, "i", [=["]=], [=[<C-o><CMD>lua require("quotePairs").pairUp()<CR>]=], {"noremap"}, "which_key_ignore")
end
