
local functionCallRep     = string.format(range .. [[s#call <sid>#lua require("%s").#e]],"%s", fn.expand("%:t:r"))

