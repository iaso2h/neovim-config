if _G._os_uname.machine ~= "aarch64" then
    -- https://clangd.llvm.org/config
    return {
        init_options = {
            -- capabilities         = {},
            clangdFileStatus     = true,
            usePlaceholders      = true,
            completeUnimported   = true,
            semanticHighlighting = true,
            fallbackFlags = {
            "-std=c99",
            "-Wall",
            "-Wextra",
            "-Wno-deprecated-declarations"
            }
        },
    }
else
    return {}
end
