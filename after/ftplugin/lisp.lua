vim.bo.ts  = 2
vim.bo.sts = 2
vim.bo.sw  = 2
-- LUARUN: for _, ft in ipairs(_G._lisp_language) do pcall(vim.cmd, string.format([[noa w! %s%safter%sftplugin%s%s.lua]], _G._config_path, _G._sep, _G._sep, _G._sep, ft)) end
-- bmap(0, "i", [=["]=], [=[""<Left>]=], {"noremap"}, "which_key_ignore")
