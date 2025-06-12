-- https://github.com/microsoft/pyright
-- https://github.com/microsoft/pyright/blob/master/docs/configuration.md
return {
    settings  = {
        python = {
            -- pythonPath = "python",
            -- venvPath = "",
            analysis = {
                -- extraPaths = "",
            }
        },
        pyright = {
            verboseOutput = true,
            reportMissingImports = true,
        }
    }
}
