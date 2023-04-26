return function(path, configPath)
    local p = require("plenary.path")
    -- Module path is always full path in VimL
    if string.match(path.filename, configPath:joinpath("colors").filename) then
        local colorDirPath = configPath:joinpath("colors")
        local colorRel     = string.sub(
            p:new(path.filename):make_relative(colorDirPath.filename),
            1, -5)
        vim.cmd("noa silent! colorscheme " .. colorRel)
        vim.notify(string.format("Colorscheme: %s", colorRel), vim.log.levels.INFO)
    end
end
