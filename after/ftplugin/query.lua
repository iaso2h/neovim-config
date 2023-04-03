vim.bo.ts  = 2
vim.bo.sts = 2
vim.bo.sw  = 2
bmap(0, "i", [=[(]=], [=[()<Left>]=], {"noremap"}, "which_key_ignore")
bmap(0, "i", [=[[]=], [=[[]<Left>]=], {"noremap"}, "which_key_ignore")
bmap(0, "i", [=[{]=], [=[{}<Left>]=], {"noremap"}, "which_key_ignore")
bmap(0, "i", [=[']=], [=[''<Left>]=], {"noremap"}, "which_key_ignore")
bmap(0, "i", [=["]=], [=[""<Left>]=], {"noremap"}, "which_key_ignore")
