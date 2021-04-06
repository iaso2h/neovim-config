-- File: foldMarker
-- Author: iaso2h
-- Description: Enhnace origin fold feature, mainly focus on markder fold method
-- Version: 0.0.8
-- Last Modified: 2021-04-06
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local util = require("util")
local M   = {}

----
-- Function: EnhanceFold
--
-- @param modeType: n/v/V standards for normal mode, visual characterwise mode,
-- visual linewise mode
-- @param marker:  string value need to provided to distinguish which marker to append in normal mode
-- Returns: 0
----
function M.enhanceFold(vimMode, marker) -- {{{
    local cursorPos = api.nvim_win_get_cursor(0)
    local curLine = api.nvim_get_current_line()
    local fileType = vim.bo.filetype
    if vimMode == "n" then
        if fileType == "vim" then
            local quoteCount = util.matchAll(curLine, '"')
            if #quoteCount % 2 ~= 0 then
                cmd("normal! A " .. marker)
            else
                cmd("normal! A " .. "\" " .. marker)
            end
        else
            cmd("normal! A " .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " " .. marker)
        end
        if marker == "}}}" then
            cmd "normal! zx"
        end
    elseif vimMode == "v" or vimMode == "V" then
        local selectStart = api.nvim_buf_get_mark(0, "<")
        local selectEnd   = api.nvim_buf_get_mark(0, ">")
        if selectEnd[2] == selectStart[2] then -- Sanity check
            return 0
        end

        if fileType == "vim" then
            local quoteCount = util.matchAll(curLine, '"')
            if #quoteCount % 2 ~= 0 then
                api.nvim_win_set_cursorn(0, selectStart)
                cmd("normal! g_a {{{")
                api.nvim_win_set_cursorn(0, selectEnd)
                cmd("normal! g_a }}}")
            else
                api.nvim_win_set_cursorn(0, selectStart)
                cmd "normal! g_a \" {{{"
                api.nvim_win_set_cursorn(0, selectEnd)
                cmd "normal! g_a \" }}}"
            end
        else
            api.nvim_win_set_cursorn(0, selectStart)
            cmd("normal! g_a " .. vim.g.FiletypeCommentDelimiter[fileType] .. " {{{")
            api.nvim_win_set_cursorn(0, selectEnd)
            cmd("normal! g_a " .. vim.g.FiletypeCommentDelimiter[fileType] .. " }}}")
        end

        api.nvim_win_set_cursor(0, cursorPos)
        cmd "normal! zx"
    end
end -- }}}

--"
-- Function: EnhanceFoldJump: Jump to previous/next fold location inclusively
--
-- @param direction:   Possible value "previous", "next"
-- @param showWarninvim.g. Boolean value. Whether to show warnning message
-- when not inside fold scope
-- @param returnVar:   Boolean value. Whether to return verbose list when cmd successfully
-- Returns: return [true, l:foldPos, l:matchPos] when returnVar is set to 1, otherwise return [true] when succeeded, return [false] when failed
--"
function M.enhanceFoldJump(CMD, showWarning, returnVar) -- {{{
    local saveView = winsaveview()
    local cursorPos = api.nvim_win_get_cursor(0)
    local lastFoldPos = cursorPos
    local lineCommentIdent
    local foldPos
    local matchPos
    -- Get fold position
    cmd("keepjumps normal! " .. CMD)
    while 1 do
        foldPos = api.nvim_win_get_cursor(0)
        local foldPosLine = api.nvim_get_current_line()
        -- Parsing pattern
        -- TODO: deprecated vimscript matchscript()?
        if CMD == "[z" then
            matchPos = fn.matchstrpos(foldPosLine, vim.g.enhanceFoldStartPat[vim.bo.filetype])
        elseif CMD == "]z" then
            matchPos = fn.matchstrpos(foldPosLine, vim.g.enhanceFoldEndPat[vim.bo.filetype])
        end
        if matchPos[1] ~= "" then
            local lineComment = matchPos[2] == 0
            lineCommentIdent = (matchPos[1][1] == " " or matchPos[1][1] == '\t') and true or false
            break
        end
        -- Check inside foldermarker scope
        if foldPos == lastFoldPos then
            if showWarning then
                api.nvim_echo({{"Not inside fold scope", "WarningMsg"}}, false, {})
            end
            fn.winrestview(saveView)
            return {false}
        else
            lastFoldPos = foldPos
            cmd("keepjumps normal! " .. CMD)
        end
    end
    -- Make jump location when returnVar is false
    if not returnVar then
        cmd [[normal! mz`z]]
        return {true}
    else
        return {true, foldPos, matchPos}
    end
end -- }}}


----
-- Function: EnhanceFoldHL Enhence Fold Highlight Light, highlight
-- previous/next fold when cursor within the fold scope
--
-- @param warningMsvim.g. string value to show when fold scope not found. Empty
-- string disable message display empty string wont't show message when fold
-- scope not found
-- @param time:       milisecond to start the EnhanceFoldRemoveHLMatch() and
-- the appending function
-- @param funcName:   function name in a string value, this function will be
-- invoke with the EnhanceFoldRemoveHLMatch() function when reaching time if
-- provide
-- Returns: 0
----
function M.enhanceFoldHL(warningMsg, time, funcName) -- {{{
    opts = opts or {hlGroup="Search", timeout=500}
    local saveView = fn.winsaveview()
    -- Doesn't suport fold line yet
    if fn.foldclosed(saveView["lnum"]) > 0 then return end
    -- Fold marker info
    local validStartFoldPos = M.enhanceFoldJump("[z", false, true)
    if not validStartFoldPos[1] then
        api.nvim_echo({{warningMsg, "Normal"}}, true, {})
        return
    end
    local foldStartPos = validStartFoldPos[2]
    local foldStartMatchPos = validStartFoldPos[3]
    local validEndFoldPos = M.enhanceFoldJump("]z", false, true)
    local foldEndPos= validEndFoldPos[2]
    local foldEndMatchPos = validEndFoldPos[3]
    local winID = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    -- Create highlight {{{
    local foldHLNS = api.nvim_create_namespace('foldHL')
    api.nvim_buf_clear_namespace(curBufNr, foldHLNS, 0, -1)

    local newContentResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                            M.inplacePutNewContentNS,
                                            M.inplacePutNewContentExtmark,
                                            {details = true})
    api.nvim_buf_add_highlight(curBufNr, foldHLNS, opts["hlGroup"], foldStartPos[1] - 1, foldStartPos[1], cols[2])

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight
    call EnhanceFoldRemoveHLMatch(a:time)
    -- Create Highlight {{{
    let l:foldStartMatchAdd = 0
    let l:foldEndMatchAdd = 0
    let s:foldStartDict = {
         --matchID" : vim.g.enhanceFoldStartHLID,
         --foldPos" : l:foldStartPos,
         --matchPos" : l:foldStartMatchPos,
         --matchAddCheck" : l:foldStartMatchAdd,
     }
    let s:foldEndDict = {
         --matchID" : vim.g.enhanceFoldEndHLID,
         --foldPos" : l:foldEndPos,
         --matchPos" : l:foldEndMatchPos,
         --matchAddCheck" : l:foldEndMatchAdd,
     }
    for i in [s:foldStartDict, s:foldEndDict]
        try
            let l:matchID = matchaddpos(
                 --Search" ,
                 [[i["foldPos"][1], i["matchPos"][1] + 1, i["matchPos"][2] - i["matchPos"][1] + 1]] ,
                 vim.g.enhanceFoldPriority, i["matchID"])
            add(vim.g.enhanceFoldHLMatch[s:winID], l:matchID)
            let i["matchAddCheck"] = 1
        finally
            -- If failed, let VimL deside which ID to use
            -- When ID added successfully, don't cmd it"
            if not f["matchAddCheck"]
                let l:matchID = matchaddpos(
                     --Search" ,
                     [[i["foldPos"][1], i["matchPos"][1] + 1, i["matchPos"][2] - i["matchPos"][1] + 1]] ,
                     vim.g.enhanceFoldPriority)
                add(vim.g.enhanceFoldHLMatch[s:winID], l:matchID)
                let i["matchID"] = l:matchID
            end
        endtry
        -- }}} Create Highlight
    end

    -- Restore view
    winrestview(l:saveView)
    -- Auto clear Highlight when time > 0
    if time   call timer_start(time, "EnhanceFoldRemoveHLMatch")   end
    -- cmd appending function
    if funcName end= ""
        timer_start(time, funcName)
        return 0
    end
end -- }}}

function M.enhanceFoldRemoveHLMatch(...) -- {{{
    while exists("vim.g.enhanceFoldHLMatch[s:winID]") and vim.g.enhanceFoldHLMatch[s:winID] end= []
        matchdelete(remove(vim.g.enhanceFoldHLMatch[s:winID], 0))
    end
end -- }}}

function M.enhanceDelete(...) -- {{{
    -- Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
    -- Create restore point
    cmd [[normal! mz`z]]
    -- }}} Fold marker info

    if s:lineComment == 1
        -- Delete fold start
        cmd printf("%ds#%s##g", l:foldStartPos[1], vim.g.enhanceFoldStartPat[vim.bo.filetype])
        let l:saveUnnamedReg = @@   d
        let l:foldEndPos[1] -= 1
        let l:saveView["lnum"] -= 1
        -- Delete fold end
        cmd printf("%ds#%s##g", l:foldEndPos[1], vim.g.enhanceFoldEndPat[vim.bo.filetype])
        -- Delete empty line
        if s:lineComment == 1   d   end
    else
        cmd printf("%ds#%s##g", l:foldStartPos[1], vim.g.enhanceFoldStartPat[vim.bo.filetype])
        cmd printf("%ds#%s##g", l:foldEndPos[1], vim.g.enhanceFoldEndPat[vim.bo.filetype])
    end
    -- Resotre
    winrestview(l:saveView)
    if exists("l:saveUnnamedReg")   let @@ = l:saveUnnamedReg   end
end -- }}}

function M.enhanceChange(...) -- {{{
    --TODO : " Mode - Commandline " Commandline & Insert {{{ Insert {{{
    -- Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
    -- }}} Fold marker info

    echohl Moremsg
    let l:newFoldMakrerName = input("New fold marder name: ")
    if empty(l:newFoldMakrerName)
        echohl WarningMsg   echo " "   echo "Cancel"   echohl None
        winrestview(l:saveView)
        return 0
    else
        if s:lineComment == 1
            let l:newFoldStart = printf("%s %s {{{", vim.g.FiletypeCommentDelimiter[vim.bo.filetype], l:newFoldMakrerName)
            let l:newFoldEnd = printf("%s }}} %s", vim.g.FiletypeCommentDelimiter[vim.bo.filetype], l:newFoldMakrerName)
        else
            let l:newFoldStart = printf(" %s %s {{{", vim.g.FiletypeCommentDelimiter[vim.bo.filetype], l:newFoldMakrerName)
            let l:newFoldEnd = printf(" %s }}} %s", vim.g.FiletypeCommentDelimiter[vim.bo.filetype], l:newFoldMakrerName)
        end
    end
    echohl None
    -- Clear highlight
    EnhanceFoldRemoveHLMatch()
    -- Change fold markder name
    cmd printf("%ds#%s#%s#g", l:foldStartPos[1], vim.g.enhanceFoldStartPat[vim.bo.filetype], l:newFoldStart)
    cmd printf("%ds#%s#%s#g", l:foldEndPos[1], vim.g.enhanceFoldEndPat[vim.bo.filetype], l:newFoldEnd)
    -- Reindent new comment line
    if s:lineCommentIdent
        cursor(l:foldStartPos[1], l:foldStartPos[2])
        cmd [[normal! ==]]
        cursor(l:foldEndPos[1], l:foldEndPos[2])
        cmd [[normal! ==]]
    end
    -- Resotre
    if exists("l:saveUnnamedReg")   let @@ = l:saveUnnamedReg   end
    winrestview(l:saveView)
end -- }}}

return M

