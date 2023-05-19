-- NOTE: http://olivinelabs.com/busted/
---@diagnostic disable-next-line: undefined-global
local describe = describe
---@diagnostic disable-next-line: undefined-global
local it = it
local jumpUtil = require("jump.util")
local jumplist = require("jump.jumplist")


local getJumpsCmdSliced = function(isNewer, filter)
    local jumpsCmdRaw = jumpUtil.getJumpsCmd()
    local CmdIdx = jumplist.getJumpCmdIdx(jumpsCmdRaw)
    local jumpsExpectedCmd = jumplist.getJumpsSliced(isNewer, filter, CmdIdx, jumpsCmdRaw)

    return jumpsExpectedCmd
end


local toCmdValues = function(jumps)
    local map = function(jump)
        local jumpCompare = {}
        jumpCompare.lnum = jump.lnum
        jumpCompare.col  = jump.col

        return vim.deepcopy(jumpCompare)
    end

    return vim.tbl_map(map, jumps)
end


describe([[vim.fn.getjumplist() and ex-command :jumps. ]], function()
    it([[Ex-command threshold]], function() -- {{{
        local file = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        vim.cmd("clearjumps")
        local jumpsExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(true, 1, jumplist._CMD_THRESHOLD, false, jumplist._CMD_THRESHOLD)

        jumpUtil.jumplistRegisterLines(1, jumplist._CMD_THRESHOLD)
        local currentJumpsTbl = jumpUtil.getJumpsCmd()
        assert.are.same(#jumpsExpectedCmdRaw, #currentJumpsTbl - 2)
    end) -- }}}

    it([[Table length comparison]], function() -- {{{
        local file  = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        vim.cmd("clearjumps")
        local randomNr = math.random(1, jumplist._CMD_THRESHOLD)
        local jumpsExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(true, 1, randomNr, false, jumplist._CMD_THRESHOLD)
        jumpUtil.jumplistRegisterLines(1, randomNr)
        local jumps = vim.fn.getjumplist()[1]
        assert.are.same(#jumpsExpectedCmdRaw, #jumps)
    end) -- }}}

    it([[Column and row check]], function() -- {{{
        local file = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        vim.cmd("clearjumps")
        local jumpsExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(true, 1, jumplist._CMD_THRESHOLD, false, jumplist._CMD_THRESHOLD)
        local jumpsExpectedCmd = vim.tbl_map(function(jumpCmdRaw)
            local parseResult = { string.match(jumpCmdRaw, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
            return {
                lnum  = tonumber(parseResult[2]),
                col   = tonumber(parseResult[3]),
            }
        end, jumpsExpectedCmdRaw)

        jumpUtil.jumplistRegisterLines(1, jumplist._CMD_THRESHOLD)
        local jumps = vim.tbl_map(function(jump)
            local parse = {
                lnum = jump.lnum,
                col  = jump.col
            }
            return parse
        end, vim.fn.getjumplist()[1])
        assert.are.same(jumpsExpectedCmd, jumps)
    end) -- }}}

    it([[Current idexes relationship]], function() -- {{{
        vim.cmd [[enew ]]
        vim.cmd("clearjumps")
        for i = 1, jumplist._CMD_THRESHOLD, 1 do
            vim.api.nvim_put({"line: " .. i}, "l", true, true)
        end

        -- Register every lines in jumplist
        local startLine = 1
        local endLine = vim.api.nvim_buf_line_count(0)
        local isNewer = false
        local filter  = "local"
        local winId   = vim.api.nvim_get_current_win()

        jumpUtil.jumplistRegisterLines(startLine, endLine)
        local jumpsSliced
        local jumpsExpectedCmdSliced

        -- 1
        jumpsSliced            = toCmdValues(jumplist.getJumps(isNewer, winId, filter))
        jumpsExpectedCmdSliced = toCmdValues(getJumpsCmdSliced(isNewer, filter))

        assert.are.same(jumpsExpectedCmdSliced, jumpsSliced)

        -- 2
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        jumpsSliced            = toCmdValues(jumplist.getJumps(isNewer, winId, filter))
        jumpsExpectedCmdSliced = toCmdValues(getJumpsCmdSliced(isNewer, filter))

        assert.are.same(jumpsExpectedCmdSliced, jumpsSliced)

        -- 3
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-i>]])
        vim.cmd(t[[normal! 1<C-i>]])
        jumpsSliced            = toCmdValues(jumplist.getJumps(isNewer, winId, filter))
        jumpsExpectedCmdSliced = toCmdValues(getJumpsCmdSliced(isNewer, filter))

        assert.are.same(jumpsExpectedCmdSliced, jumpsSliced)
    end)

    it([[Custom vim.split]], function() -- {{{
        vim.cmd [[enew ]]
        vim.cmd("clearjumps")
        for i = 1, jumplist._CMD_THRESHOLD, 1 do
            vim.api.nvim_put({"line: " .. i}, "l", true, true)
        end

        local expectedOutput = jumpUtil.getJumpsCmd()
        _G._noStdlib = true
        local myOutput = jumpUtil.getJumpsCmd()
        assert.are.same(expectedOutput, myOutput)
    end)
end) -- }}}


describe([[Local jump. ]], function()

    it([[Older jump in /doc/usr_24.txt]], function() -- {{{
        local file = vim.fn.stdpath("config") .. "/lua/jump/test/README.md"
        --TODO: support longer file
        -- local file = "/home/iaso2h/.config/nvim/lua/jump/test/jumplist_spec.lua"
        -- local file = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        vim.cmd("clearjumps")
        local fileLastline = vim.api.nvim_buf_line_count(0)
        local eachIterAssert = function (i)
            local startLine
            if i >= jumplist._CMD_THRESHOLD then
                startLine = (math.floor(i / jumplist._CMD_THRESHOLD) - 1) * jumplist._CMD_THRESHOLD + 1
            else
                startLine = 1
            end
            local endLine = i
            local isNewer = false
            local filter = "local"

            -- Get filtered jumps
            jumpUtil.jumplistRegisterLines(startLine, endLine)
            jumplist.setup {
                returnAllJumps = true
            }
            local jumpsSliced, jumpsDiscarded, jumpsFiltered = jumplist.go("n", isNewer, filter)
            -- Get expected parsed jumps
            jumplist.setup {
                returnAllJumps = true
            }
            local jumpsExpectedCmdSliced = getJumpsCmdSliced(isNewer, filter)

            -- assert.are.same(#ExpectedCmd, #jumpsSliced)
            assert.are.same(toCmdValues(jumpsExpectedCmdSliced), toCmdValues(jumpsSliced))

            -- Discarded Test
            assert.are.same({}, jumpsDiscarded)

            -- Filtered Test
            assert.are.same(toCmdValues(jumpsExpectedCmdSliced), toCmdValues(jumpsFiltered))
        end


        for i = 1, fileLastline, 1 do
            -- For every <thresholdNumber> line, run assert tests
            -- Fail occurs in a iteration will halt the whole iterations
            if i % jumplist._CMD_THRESHOLD == 0 then
                eachIterAssert(i)
            end

            if i == fileLastline and fileLastline % jumplist._CMD_THRESHOLD ~= 0 then
                eachIterAssert(i)
            end
        end
    end) -- }}}


end)
