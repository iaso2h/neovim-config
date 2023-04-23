-- NOTE: Dependency: https://github.com/charlesmallah/lua-profiler

require("jump.jumplist").setup {
    returnAllJumps = true
}

local function jumplist()
    return require("jump.jumplist").go("n", false, "local")
end
Print("-------------------")
local function EnhancedJumps()
    return vim.fn["EnhancedJumps#FilterOutput"](false, "local")
end

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
