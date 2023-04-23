-- NOTE: http://olivinelabs.com/busted/
---@diagnostic disable-next-line: undefined-global
local describe = describe
---@diagnostic disable-next-line: undefined-global
local it = it


local jumpUtil = require("jump.util")
local jumplist = require("jump.jumplist")
local outputLines
local outputCursorPos

local expectedLines
local expectedCursorPos
local cursorIndicatorChar = "^"

local jumplistThreshold = 50

describe([[vim.fn.getjumplist() and ex-command :jumps. ]], function()
    it([[Ex-command threshold]], function()
        local file = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        local jumpsExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(true, 1, jumplistThreshold, false, jumplistThreshold)

        jumpUtil.jumplistRegisterLines(1, jumplistThreshold)
        local currentJumpsTbl = jumpUtil.getJumpsTbl()
        assert.are.same(#jumpsExpectedCmdRaw, #currentJumpsTbl - 2)
    end)

    it([[Table length comparison]], function()
        local file  = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        local randomNr = math.random(1, jumplistThreshold)
        local jumpsExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(true, 1, randomNr, false, jumplistThreshold)
        jumpUtil.jumplistRegisterLines(1, randomNr)
        local jumps = vim.fn.getjumplist()[1]
        assert.are.same(#jumpsExpectedCmdRaw, #jumps)
    end)

    it([[Column and row check]], function()
        local file = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        local jumpsExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(true, 1, jumplistThreshold, false, jumplistThreshold)
        local jumpsExpectedCmd = vim.tbl_map(function(jumpCmdRaw)
            local parseResult = { string.match(jumpCmdRaw, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
            return {
                lnum  = tonumber(parseResult[2]),
                col   = tonumber(parseResult[3]),
            }
        end, jumpsExpectedCmdRaw)

        jumpUtil.jumplistRegisterLines(1, jumplistThreshold)
        local jumps = vim.tbl_map(function(jump)
            local parse = {
                lnum = jump.lnum,
                col  = jump.col
            }
            return parse
        end, vim.fn.getjumplist()[1])
        assert.are.same(jumpsExpectedCmd, jumps)
    end)

    it([[Current idxes relationship]], function()
        local file = vim.fn.stdpath("config") .. "/lua/jump/test/README.md"
        -- TODO: create a custom file
        vim.cmd([[e ]] .. file)

        -- Register every lines in jumplist
        local startLine = 1
        local endLine = vim.fn.line("$")
        jumpUtil.jumplistRegisterLines(startLine, endLine)

        ---@return table, number, table, number
        local getJumps = function()
            jumplist.setup {
                returnAllJumps = true
            }
            local jumpsCmdRaw    = jumpUtil.getJumpsTbl()

            -- Get jumps from built-in function
            local jumpsList   = vim.fn.getjumplist(0)
            local jumpsIdx    = jumpsList[2]
            local jumps       = jumpsList[1]
            local jumpsSliced = {}
            if jumpsIdx == 0 then
                vim.notify("Jumplist is empty", vim.log.levels.INFO)
                return jumpsSliced, {}
            end

            -- Get current index in jumplist
            local expectedCmdIdx = 0
            jumpsCmdRaw[1] = nil
            for i = #jumpsCmdRaw, 2, -1 do
                local jumpCmdRaw = jumpsCmdRaw[i]
                if string.sub(jumpCmdRaw, 1, 1) == ">" then
                    expectedCmdIdx = i
                    break
                end
            end
            return jumps, jumpsIdx, jumpsCmdRaw, expectedCmdIdx
        end
        local jumps, jumpsIdx, jumpsCmdRaw, expectedCmdRawIdx
        local jumpCmd, jump


        -- 1
        jumps, jumpsIdx, jumpsCmdRaw, expectedCmdRawIdx = getJumps()
        assert.are.same(expectedCmdRawIdx - jumplist._CUR_IDX_OFFSET, jumpsIdx)
        jumpCmd = jumpUtil.jumplistParse(jumpsCmdRaw[expectedCmdRawIdx - jumplist._ITEM_IDX_OFFSET], true)
        jump    = jumps[jumpsIdx]
        assert.are.same({
            lnum = jumpCmd.lnum,
            col  = jumpCmd.col
        }, {
            lnum = jump.lnum,
            col  = jump.col
        })

        -- 2
        vim.cmd(t[[normal! 1<C-o>]])
        jumps, jumpsIdx, jumpsCmdRaw, expectedCmdRawIdx = getJumps()
        assert.are.same(expectedCmdRawIdx - jumplist._CUR_IDX_OFFSET, jumpsIdx)
        jumpCmd = jumpUtil.jumplistParse(jumpsCmdRaw[expectedCmdRawIdx - jumplist._ITEM_IDX_OFFSET], true)
        jump    = jumps[jumpsIdx]
        assert.are.same({
            lnum = jumpCmd.lnum,
            col  = jumpCmd.col
        }, {
            lnum = jump.lnum,
            col  = jump.col
        })

        -- 3
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-o>]])
        vim.cmd(t[[normal! 1<C-i>]])
        vim.cmd(t[[normal! 1<C-i>]])
        jumps, jumpsIdx, jumpsCmdRaw, expectedCmdRawIdx = getJumps()
        -- vim.print{jumps, jumpsIdx}
        -- vim.print{jumpsCmdRaw, expectedCmdIdx}
        assert.are.same(expectedCmdRawIdx - jumplist._CUR_IDX_OFFSET, jumpsIdx)
        jumpCmd = jumpUtil.jumplistParse(jumpsCmdRaw[expectedCmdRawIdx - jumplist._ITEM_IDX_OFFSET], true)
        jump    = jumps[jumpsIdx]
        assert.are.same({
            lnum = jumpCmd.lnum,
            col  = jumpCmd.col
        }, {
            lnum = jump.lnum,
            col  = jump.col
        })
    end)
end)


describe([[Local jump. ]], function()
    it([[Older jump in /doc/usr_24.txt]], function()
        local file = vim.fn.stdpath("config") .. "/lua/jump/test/README.md"
        --TODO: support longer file
        -- local file = "/home/iaso2h/.config/nvim/lua/jump/test/jumplist_spec.lua"
        -- local file = vim.api.nvim_eval("$VIMRUNTIME") .. "/doc/usr_24.txt"
        vim.cmd([[e ]] .. file)
        local fileLastline = vim.fn.line("$")
        local eachIterAssert = function (i)
            local startLine
            if i >= jumplistThreshold then
                startLine = (math.floor(i / jumplistThreshold) - 1) * jumplistThreshold + 1
            else
                startLine = 1
            end
            local endLine = i

            -- Get expected parsed jumps
            local ExpectedCmdRaw = jumpUtil.jumplistRegisterLinesToTbl(
                true, startLine, endLine, false, jumplistThreshold)
            local ExpectedCmd = vim.tbl_map(function(jumpCmdRaw)
                return jumpUtil.jumplistParse(jumpCmdRaw, true)
            end, jumpUtil.tblReverse(ExpectedCmdRaw))

            -- Get filtered jumps
            jumpUtil.jumplistRegisterLines(startLine, endLine)
            jumplist.setup {
                returnAllJumps = true
            }
            local jumpsSliced, jumpsDiscarded, jumpsFiltered = jumplist.go("n", false, "local")

            -- Sliced Test
            -- vim.print(ExpectedCmd)
            -- vim.print("-----------1--------------")
            -- vim.print(jumpsSliced)
            -- vim.print("-----------2--------------")
            -- vim.print(vim.fn.getjumplist(0)[1])
            -- assert.are.same(#ExpectedCmd, #jumpsSliced)
            assert.are.same(
            vim.tbl_map(function(jump)
                jump.count = nil
                return jump
            end, vim.deepcopy(ExpectedCmd)),

            vim.tbl_map(function(jump)
                jump.coladd = nil; jump.bufnr = nil; jump.count = nil
                return jump
            end, vim.deepcopy(jumpsSliced)))

            -- Discarded Test
            assert.are.same({}, jumpsDiscarded)

            -- Filtered Test
            assert.are.same(ExpectedCmd, vim.tbl_map(function(jump)
                jump.coladd = nil; jump.bufnr = nil
                return jump
            end, vim.deepcopy(jumpsFiltered)))
        end


        for i = 1, fileLastline, 1 do
            -- For every <thresholdNumber> line, run assert tests
            -- Fail occurs in a iteration will halt the whole iterations
            if i % jumplistThreshold == 0 then
                eachIterAssert(i)
            end

            if i == fileLastline and fileLastline % jumplistThreshold ~= 0 then
                eachIterAssert(i)
            end
        end
    end)
end)
