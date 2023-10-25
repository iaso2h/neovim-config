local util = require("util")
local M    = {}


--- Get the start position and end position of the visual selected area
--- @param bufNr integer current buffer number
--- @return table
M.getVisualStartEnd = function(bufNr) -- {{{
    return vim.api.nvim_buf_get_mark(bufNr, "<"), vim.api.nvim_buf_get_mark(bufNr, ">")
end -- }}}
--- Compare the region of an text object with another textobject's
---@return boolean # true will be return if these two textobject
local compareTxWithTx = function(c1, c2) -- {{{
    if util.compareDist(c1.posStart, c2.posStart) == 0 and
        util.compareDist(c1.posEnd, c2.posEnd) == 0 then
        return true
    else
        return false
    end
end -- }}}
--- Compare the region of an text object with treesitter node's
--- @param textObjCandidate ExpandRegionCandidate
--- @param tsNodeCandidate ExpandRegionCandidate
--- @return integer # Return 0 to indicate the textObjCandidate has the same range of tsNodeCandidate, 1 to indicate the textObjCandidate has larger range then tsNodeCandidate's, -1 to indicate smaller range then tsNodeCandidate's, 2 to indicate they have some overlapping area
local compareTxWithTs = function(textObjCandidate, tsNodeCandidate) -- {{{
    if util.compareDist(textObjCandidate.posStart, tsNodeCandidate.posStart) == 0 and
        util.compareDist(textObjCandidate.posEnd, tsNodeCandidate.posEnd) == 0 then

        return 0
    elseif ( util.compareDist(textObjCandidate.posStart, tsNodeCandidate.posStart) < 0 and
        util.compareDist(textObjCandidate.posEnd, tsNodeCandidate.posEnd) > 0 ) then
        return 1
    elseif ( util.compareDist(textObjCandidate.posStart, tsNodeCandidate.posStart) > 0 and
        util.compareDist(textObjCandidate.posEnd, tsNodeCandidate.posEnd) < 0 ) then
        return -1
    else
        return 2
    end
end -- }}}
--- Generate all text object contain different types of text object, might
--- contain duplicated items
--- @param textObjs ExpandRegionTextObj
--- @param curBufNr integer Current buffer number
--- @param tsNodeCandidate? ExpandRegionCandidate
--- @return ExpandRegionCandidate[], boolean # The second will be true if the
--it's OK to get into the next iteration to continue compute textobject
--candidates
local getAllTextObjCandidates = function(textObjs, curBufNr, tsNodeCandidate) -- {{{
    local breakNextIterationChk = false
    local candidates = {}
    local savedView = nil

    for _, textObj in ipairs(textObjs) do
        if savedView then
            -- Restore view and cursor Position
            vim.fn.winrestview(savedView)
        end
        savedView = vim.fn.winsaveview()

        -- Make sure Neovim isn't lingering in visual mode before simulating
        -- keystrokes
        if vim.api.nvim_get_mode().mode ~= "n" then
            vim.cmd([[noa norm v]]  .. t"<Esc>")
        end
        -- Simulating keystroke
        if textObj.builtin then
            vim.cmd([[noa norm! v]] .. textObj.mapping .. t"<Esc>")
        else
            vim.cmd([[noa norm v]] .. textObj.mapping .. t"<Esc>")
        end

        -- Store candidate info
        local candidate = {
            textObj = textObj.mapping,
            type = "textobject"
        }
        candidate.posStart, candidate.posEnd = M.getVisualStartEnd(curBufNr)

        if util.compareDist(candidate.posStart, candidate.posEnd) == 0 then
            candidate.content = ""
            candidate.length  = 0
        else
            candidate.content = require("selection").get("string", true)
            candidate.length  = #candidate.content
        end

        -- Abort the whole function calling process when expandRegion was
        -- starting from a whitespace position
        local whitespace = string.match(candidate.content, "%s+")
        if whitespace and #whitespace == candidate.length then
            breakNextIterationChk = true
            candidates = {}
            break
        end

        -- Need to correct the i,w and iB text objects due to some malfunctions
        if candidate.textObj == "i,w" then -- {{{
            local line = vim.api.nvim_buf_get_lines(0, candidate.posStart[1] - 1,
                                            candidate.posStart[1], false)[1]
            local selectChars
            if candidate.posStart[1] == candidate.posEnd[1] then
                selectChars = string.sub(line, candidate.posStart[2] + 1,
                                                candidate.posEnd[2] + 1)

                local nonWordIdx  = string.find(selectChars, "%W")
                -- HACK:make ,w not select the non-word character
                if nonWordIdx then
                    candidate.content = string.sub(candidate.content, 1, nonWordIdx - 1)
                    candidate.posEnd  = {candidate.posStart[1],
                                        candidate.posStart[2] + nonWordIdx - 2}
                    candidate.length  = nonWordIdx - 1
                end
            else
                selectChars = string.sub(line, candidate.posStart[2] + 1, #line)
                candidate.content = selectChars
                candidate.posEnd  = {candidate.posStart[1],
                                    candidate.posStart[2] + #selectChars - 1}
                candidate.length  = #selectChars
            end
        elseif candidate.textObj == "iB" then
            local line = vim.api.nvim_buf_get_lines(0, candidate.posEnd[1] - 1,
                                            candidate.posEnd[1], false)[1]
            if #line == candidate.posEnd[2] then
                candidate.content = string.sub(candidate.content,
                                            1, #candidate.content - 1)
                candidate.posEnd  = {candidate.posEnd[1], candidate.posEnd[2] - 1}
                candidate.length  = candidate.length - 1
            end
        end -- }}}

        -- Stop parsing text objects when the initialized treesitter node has
        -- the same or smaller range
        if tsNodeCandidate then
            local compareResult = compareTxWithTs(candidate, tsNodeCandidate)
            if compareResult == 0 or compareResult == 1 then
                breakNextIterationChk = true
                break
            else
                candidates[#candidates+1] = candidate
            end
        else
            candidates[#candidates+1] = candidate
        end
    end

    vim.fn.winrestview(savedView)
    return candidates, breakNextIterationChk
end -- }}}
--- Remove the items with the same length and same position of column and row
--- @param candidates ExpandRegionCandidate[]
--- @return ExpandRegionCandidate[] #
local removeDuplicate = function(candidates) -- {{{
    local i = 1
    local candidatesRefined = {}
    while i < #candidates do
        if candidates[i].type == "textobject" then
            if not(candidates[i].length == candidates[i+1].length
                and candidates[i].posStart[2] == candidates[i+1].posStart[2]) then

                table.insert(candidatesRefined, candidates[i])
            end
        else
            table.insert(candidatesRefined, candidates[i])
        end

        i = i + 1
    end

    -- Always add the last item
    candidatesRefined[#candidatesRefined+1] = candidates[i]

    return candidatesRefined
end -- }}}
--- Generate a region table containing different types of text object
--- @param opts table option table
--- @param bufNr integer current buffer number
--- @param cursorPos table cursor position of current window
--- @param tsNodeCandidate? ExpandRegionCandidate Used to compare with other
--textobject candidates during their generation so that the process will halt
--at some point when the initial(hopefully the smallest) tsNodeCandidate can
--take over the generation of higher hierarchy candidates
--- @return ExpandRegionCandidate
M.getTextObjCandidate = function(opts, bufNr, cursorPos, tsNodeCandidate) -- {{{
    local textObjectCountAddLastIter
    local loopTimes = 0
    local allCandidates = {}
    local currentIterCandidates
    local breakChk = false
    repeat
        loopTimes = loopTimes + 1

        ---@type ExpandRegionTextObj
        local textObjs
        if loopTimes == 1 then
            textObjs = opts.textObjs
        else
            -- Append new text object in the end for each iteration.
            -- e.g. "iw" -> "iwiw" -> "iwi wiw"
            textObjs = vim.tbl_map(
                function(i) return
                    {
                        mapping = string.rep(i.mapping, loopTimes),
                        builtin = i.builtin
                    }
                end,
                opts.textObjs
            )
        end

        -- Get candidates from current iterations
        currentIterCandidates, breakChk = getAllTextObjCandidates(textObjs, bufNr, tsNodeCandidate)

        -- Concantenate all candidates
        for i, candidate in ipairs(currentIterCandidates) do
            -- Avoid meaningless loop
            if loopTimes > 1 and
                textObjectCountAddLastIter == #currentIterCandidates then

                local candidateLastIter = allCandidates[#allCandidates - textObjectCountAddLastIter + i]
                if compareTxWithTx(candidate, candidateLastIter) then
                    -- Break the current loop and signify the breakChk to
                    -- break the whole loop to avoid meaningless loop if the
                    -- current textobject has the same region as the one from
                    -- last iteration
                    breakChk = true
                    break
                end
            end
            table.insert(allCandidates, candidate)
        end

        -- Abort the process when breakChk is true or the loop times reaches 8
        if breakChk or loopTimes == 8 then
            if loopTimes == 8 then
                logBuf("expandRegion iteration of finding textobject candidate caped at 5")
                logBuf("currentIterCandidates: " .. currentIterCandidates)
                logBuf(require("expandRegion").candidates)
            end

            -- Make sure Neovim isn't lingering in visual mode
            if vim.api.nvim_get_mode().mode ~= "n" then
                vim.cmd([[noa norm v]]  .. t"<Esc>")
            end

            -- Filter out invalid candidate if it's 0 length or out of cursor scope
            allCandidates = vim.tbl_filter(function(i)
                return i.length > 1 and util.withinRegion(cursorPos, i.posStart, i.posEnd)
            end
, allCandidates)

            -- Sort by text length
            table.sort(allCandidates, function(a, b) return b.length > a.length end)

            if tsNodeCandidate then
                -- Insert treesitter node candidate at the end to let treesitter
                -- take over the next generation of candidate form higher hierarchy
                table.insert(allCandidates, tsNodeCandidate)
            end

            break
        end

        -- Before entering into next iteration, store the new addition of
        -- candidates at current iteration
        textObjectCountAddLastIter = #currentIterCandidates
    until false


    return removeDuplicate(allCandidates)
end -- }}}

return M
