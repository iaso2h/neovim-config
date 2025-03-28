---@param path Path Plenary path object of vim module
---@param configPath Path Plenary path object of configpath
return function(path, configPath)
    local p = require("plenary.path")
    -- Module path is always full path in VimL
    if string.match(path.filename, configPath:joinpath("colors").filename) then
        local colorDirPath = configPath:joinpath("colors")
        local colorRel     = string.sub(
            p:new(path.filename):make_relative(colorDirPath.filename),
            1, -5)
        vim.cmd("noa silent! colorscheme " .. colorRel)
        vim.api.nvim_echo({{string.format("Colorscheme: %s", colorRel)}}, true)
    end
end
