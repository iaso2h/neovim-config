local M = {}


M.tblReverse = function(t)
    local tblReversed = {}
    local len = #t
    for k, v in ipairs(t) do
        tblReversed[len + 1 - k] = v
    end
    return tblReversed
end


M.jumplistRegisterLines = function(startLineNr, lastLineNr)
    startLineNr = startLineNr or 1
    vim.cmd([[norm! ]] .. startLineNr .. [[G0]])
    vim.cmd [[clearjumps]]
    lastLineNr = lastLineNr or vim.fn.line("$")

    for i = 1, lastLineNr, 1 do
        if i ~= lastLineNr then
            -- NOTE: m``` failed to register in jumplist when cursor is at the
            -- last line of the buffer
            vim.cmd [[norm! m```j]]
        end
    end
end


M.getJumpsCmd = function(noStdlib)
    local jumpsTbl = {}
    local jumpsOutput = vim.api.nvim_exec2("jumps", { output = true }).output
    if not noStdlib then
        return vim.split(jumpsOutput, "\n", { plain = true, trimempty = false })
    else
        local lastIdx = { 0 }
        local idxTbl = {}
        repeat
            lastIdx = { string.find(jumpsOutput, "\n", lastIdx[1] + 1, true) }
            if next(lastIdx) then
                idxTbl[#idxTbl + 1] = vim.deepcopy(lastIdx)
            end
        until not next(lastIdx)

        if not next(idxTbl) then
            return {}
        end

        -- {        idx1,     idx2,     idx3,     idx4      }
        --      ↑          ↑         ↑         ↑         ↑
        -- {<headStr1>,<subStr2>,<subStr3>,<subStr4>,<tailStr5>}
        for i, idx in ipairs(idxTbl) do
            if i < #idxTbl then
                local nextIdx = idxTbl[i + 1]
                if idx[2] + 1 ~= nextIdx[1] then
                    -- Skip adjacent to next idx
                    local midStr = string.sub(jumpsOutput, idx[2] + 1, nextIdx[1] - 1)
                    jumpsTbl[#jumpsTbl + 1] = midStr
                end
            end
            if i == 1 then
                if idx[1] ~= 1 then
                    -- Skip adjacent to the beginning
                    local headStr = string.sub(jumpsOutput, 1, idx[1] - 1)
                    jumpsTbl[#jumpsTbl + 1] = headStr
                end
            end
            if i == #idxTbl then
                if idx[2] ~= string.len(jumpsOutput) then
                    -- Skip adjacent to the end
                    local tailStr = string.sub(jumpsOutput, idx[2] + 1, -1)
                    jumpsTbl[#jumpsTbl + 1] = tailStr
                end
            end
        end
    end

    return jumpsTbl
end


M.jumpCmdParse = function(jumpCmdRaw)
    local parseResult = { string.match(jumpCmdRaw, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
    if not next(parseResult) then
        return parseResult
    else
        return {
            count = parseResult[1],
            lnum  = tonumber(parseResult[2]),
            col   = tonumber(parseResult[3]),
            text  = parseResult[4]
        }
    end
end


M.jumplistRegisterLinesToTbl = function(returnJumpsChk, startLineNr, lastLineNr, onlyOutputSpecialCharChk, bufferThreshold)
    startLineNr = startLineNr or 1
    lastLineNr = lastLineNr or vim.fn.line("$")
    bufferThreshold = bufferThreshold or 50

    local currentBuf = vim.api.nvim_get_current_buf()
    local jumpsTbl = {}
    local extendJump = function()
        local jumps = M.getJumpsCmd()
        vim.cmd [[noa clearjumps]]
        for _, jump in ipairs(jumps) do
            if jump ~= " jump line  col file/text" and string.sub(jump, 1, 1) ~= ">" then
                jumpsTbl[#jumpsTbl+1] = jump
            end
        end
    end

    -- Start registering
    vim.cmd([[norm! ]] .. startLineNr .. [[G0]])
    vim.cmd [[clearjumps]]
    for i = 1, lastLineNr, 1 do
        -- Register in every lines
        if i ~= lastLineNr then
            -- NOTE: m``` failed to register in jumplist when cursor is at the
            -- last line of the buffer
            vim.cmd [[norm! m```j]]
        else
            if lastLineNr % 50 ~= 0 then
                extendJump()
            end
        end

        if i % 50 == 0 then
            extendJump()
        end
    end

    -- Check special character
    if onlyOutputSpecialCharChk then
        local specialCharTick = false
        for _, j in ipairs(jumpsTbl) do
            if string.find(j, "^", 1, true) then
                specialCharTick = true
                break
            end
        end
        if not specialCharTick then
            vim.notify("No special characters found")
            return
        end
    end

    if returnJumpsChk then
        return jumpsTbl
    end

    -- Output the result into a new scratch buffer
    local scratchBuf
    if vim.bo.modifiable and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
        scratchBuf = currentBuf
    else
        -- TODO: how to determine performing a vertical split or a horizontal split
        vim.cmd [[vsplit]]
        scratchBuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(scratchBuf, "bufhidden", "wipe")
        vim.api.nvim_set_current_buf(scratchBuf)
    end
    vim.api.nvim_buf_set_lines(scratchBuf, 0, -1, false, jumpsTbl)
end


return M
