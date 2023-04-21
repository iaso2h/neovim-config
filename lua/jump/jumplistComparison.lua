-- NOTE: Dependency: https://github.com/charlesmallah/lua-profiler

require("jump.jumplist").setup {
    filterMethod = "lua_match",
    checkCursorRedundancy = true
}

local function jumplist()
    Print(require("jumplist")("n", false, "local"))
end
Print("-------------------")
local function EnhancedJumps()
    Print(vim.fn["EnhancedJumps#FilterOutput"](false, "local"))
end
-- jumplist()
-- EnhancedJumps()
-- do return end


local profiler = require("profiler.src.profiler")
local reportPath = _G._config_path .. "/lua/jump/report/"


profiler.attachPrintFunction(jumplist, true)
profiler.attachPrintFunction(EnhancedJumps, true)
profiler.start()
jumplist()
profiler.stop()
profiler.report(reportPath .. "jumplist2.log")

profiler.attachPrintFunction(jumplist, true)
profiler.attachPrintFunction(EnhancedJumps, true)
profiler.start()
EnhancedJumps()
profiler.stop()
profiler.report(reportPath .. "EnhancedJumps2.log")
