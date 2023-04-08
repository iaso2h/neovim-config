-- NOTE: http://olivinelabs.com/busted/
local exchange = require("exchange")
local initLines

local outputLines
local outputCursorPos

local expectedLines
local expectedCursorPos
local expectedDotLines
local cursorIndicatorChar = "^"
describe([[Exchange on the same line.]], function()

    it([[Region1 is ahead of Region2, adjacent]], function()
        initLines = [[
the middle part
       ^
        ]]
        expectedLines = [[
the dlemid part
       ^
        ]]
--      expectedDotLines = [[
-- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
--      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "mid"
        component.srcBehind = "dle"
        component.prefix    = "the "
        component.posfix    = " part"
        component.middle    = ""

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        vim.cmd[[norm! mm]]
        outputLines, outputCursorPos     = feedkeysOutput([[gxb`mgxe]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        print(vim.inspect(exchange))
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

    it([[Region1 is ahead of Region2, not adjacent]], function()
        initLines = [[
vim.api.nvim_get_current_buf(bufnr)
    ^
        ]]
        expectedLines = [[
vim.bufnr.nvim_get_current_buf(api)
    ^
        ]]
--      expectedDotLines = [[
-- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
--      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "api"
        component.srcBehind = "bufnr"
        component.prefix    = "vim."
        component.posfix    = ")"
        component.middle    = ".nvim_get_current_buf("

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gxiw4wgxiw]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

    it([[Region2 is ahead of Region1, adjacent]], function()
        initLines = [[
vim.api.feedkeysOutput()
                ^
        ]]
        expectedLines = [[
vim.api.Outputfeedkeys()
                ^
        ]]
--      expectedDotLines = [[
-- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
--      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "feedkeys"
        component.srcBehind = "Output"
        component.prefix    = "vim.api."
        component.posfix    = "()"
        component.middle    = ""

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gxebgxtO]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

    it([[Region2 is ahead of Region1, not adjacent]], function()
        initLines = [[
Lorem ipsum dolor sit amet
                  ^
        ]]
        expectedLines = [[
Lorem sit dolor ipsum amet
                  ^
        ]]
--      expectedDotLines = [[
-- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
--      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "ipsum"
        component.srcBehind = "sit"
        component.prefix    = "Lorem "
        component.posfix    = " amet"
        component.middle    = " dolor "

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gxiw2bgxiw]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)
end)

describe([[Exchange on lines that across a mutual line.]], function()

    it([[Region1 is ahead of Region2, adjacent]], function()
        initLines = [[
        ex fugiat reprehenderit enim labore culpa sint
                                                  ^
Lorem ipsum dolor sit amet, officia excepteur
        ]]
        expectedLines = [[
        ex fugiat reprehenderit enim labore culpa dolorsint Lorem ipsum  sit amet, officia excepteur
                                                  ^
        ]]
    --      expectedDotLines = [[
    -- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
    --      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "sint Lorem ipsum "
        component.srcBehind = "dolor"
        component.prefix    = "        ex fugiat reprehenderit enim labore culpa "
        component.posfix    = " sit amet, officia excepteur"
        component.middle    = ""

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gx3w3wgxiw]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

    it([[Region1 is ahead of Region2, not adjacent]], function()
        initLines = [[
Lorem ipsum dolor sit amet, officia excepteur
                                    ^
ex fugiat reprehenderit enim labore culpa sint
        ]]
        expectedLines = [[
Lorem ipsum dolor sit amet, officia enimfugiat reprehenderit excepteur ex  labore culpa sint
                                    ^
        ]]
    --      expectedDotLines = [[
    -- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
    --      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "excepteur ex "
        component.srcBehind = "enim"
        component.prefix    = "Lorem ipsum dolor sit amet, officia "
        component.posfix    = " labore culpa sint"
        component.middle    = "fugiat reprehenderit "

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gx2w4wgxiw]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

    it([[Region2 is ahead of Region1, adjacent]], function()
        initLines = [[
Many thanks to Steve Oualline and New Riders for creating this book and
publishing it under the OPL!  It has been a great help while writing the user
           ^
        ]]
        expectedLines = [[
Many thanks to Steve New Riders for thisOualline and  book and publishing creating it under the OPL!  It has been a great help while writing the user
        ]]
    --      expectedDotLines = [[
    -- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
    --      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "creating "
        component.srcBehind = "this book and publishing "
        component.prefix    = "Many thanks to Steve Oualline and New Riders for "
        component.posfix    = "it under the OPL!  It has been a great help while writing the user"
        component.middle    = ""

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gx4b`[gxb]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

    it([[Region2 is ahead of Region1, not adjacent]], function()
        initLines = [[
The Vim user manual and reference
manual are Copyright (c) 1988-2003 by Bram
          ^
        ]]
        expectedLines = [[
The manual and reference manual are user Vim Copyright (c) 1988-2003 by Bram
          ^
        ]]
    --      expectedDotLines = [[
    -- if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
    --      ]]
        initLines        = vim.split(initLines, "\n")
        expectedLines    = vim.split(expectedLines, "\n")
        -- expectedDotLines = vim.split(expectedDotLines, "\n")
        local component = {}
        component.srcAhead  = "Vim"
        component.srcBehind = "manual and reference manual are"
        component.prefix    = "The "
        component.posfix    = " Copyright (c) 1988-2003 by Bram"
        component.middle    = " user "

        -- Setup buffer lines
        initLinesCursor(initLines, "lua", cursorIndicatorChar)

        -- replace
        outputLines, outputCursorPos     = feedkeysOutput([[gx5b`[2bgxiw]])
        expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
        -- assert.are.same(outputCursorPos, expectedCursorPos)
        assert.are.same(component, exchange._acrossLineComponent)
        assert.are.same(outputLines, expectedLines)
        -- Post
        exchange._acrossLineComponent = {}

        -- replace, via dot
        -- outputLines, outputCursorPos     = feedkeysOutput([[.]])
        -- expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        -- assert.are.same(outputLines, expectedLines)
    end)

end)
