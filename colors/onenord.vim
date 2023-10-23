if type(luaeval("package.loaded['onenord']")) == v:t_dict
    luado require("onenord").foreceReload()
else
    lua require("onenord")
endif
