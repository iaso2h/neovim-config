-- NOTE: Dependency: https://github.com/chenjinghs/lua-profiler
local function replaceGo()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[griw]], true, true, true), "x", false)
end

local profile = require("profile")
profile.start()
require("replace").operator({vimMode = "n", motionType = "char"})
profile.stop()
print(profile.report(10))
-- local profiler = require("profiler.src.profiler")
-- local reportPath = _G._config_path .. "/lua/replace/report/"


-- profiler.attachPrintFunction(replaceGo, true)
-- profiler.start()
-- replaceGo()
-- profiler.stop()
-- profiler.report(reportPath .. "replace.log")
