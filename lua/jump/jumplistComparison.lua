-- NOTE: Dependency: https://github.com/charlesmallah/lua-profiler

require("jump.jumplist").setup {
    returnFilterJumps = true
}

local function jumplist()
    Print(require("jump.jumplist").go("n", false, "local"))
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
profiler.report(reportPath .. "jumplist1.log")

profiler.attachPrintFunction(jumplist, true)
profiler.attachPrintFunction(EnhancedJumps, true)
profiler.start()
EnhancedJumps()
profiler.stop()
profiler.report(reportPath .. "EnhancedJumps1.log")
