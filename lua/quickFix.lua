local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

--- Highlight relative row in quickfix with color
--- @param qfChk boolean whether filter out quickfix or not
M.highlightRelative = function (qfChk)
    local alterBufNr = fn.bufnr("#")
    if not api.nvim_buf_is_valid(alterBufNr) then return end
    local items = qfChk and fn.getqflist() or fn.getloclist(0)
    --  TODO: implement with api hihghlight
end
-- cfilter.lua: Plugin to filter entries from a quickfix/location list
-- Last Change: Aug 23, 2018
-- Maintainer: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
-- Version: 1.1
--
-- Commands to filter the quickfix list:
--   :Cfilter[!] /{pat}/
--       Create a new quickfix list from entries matching {pat} in the current
--       quickfix list. Both the file name and the text of the entries are
--       matched against {pat}. If ! is supplied, then entries not matching
--       then
--       {pat} are used. The pattern can be optionally enclosed using one of
--       the following characters: ', ", /. If the pattern is empty, then the
--       then
--       last used search pattern is used.
--   :Lfilter[!] /{pat}/
--       Same as :Cfilter but operates on the current location list.
--
local lastFilterPat = ""
--- Filter out quickfix list or locallist by specific pattern
--- @param qfChk boolean whether filter out quickfix or not
--- @param pat string pattern to filter out
--- @param bang string if bang value is "!", then items not matching the
---        pattern will be preserved
_G.qFilter = function(qfChk, pat, bang)
    local items = qfChk and fn.getqflist() or fn.getloclist(0)

    local firstChar = string.sub(pat, 1, 1)
    local lastChar  = string.sub(pat, -1, -1)
    if firstChar == lastChar and (firstChar == '/' or firstChar == '"' or firstChar == "'") then
        pat = string.sub(pat, 2, -2)
        if pat == '' then
            -- Use the last search pattern
            pat = lastFilterPat
        end
    else
        pat = pat
    end

    if pat == "%" or "#" then pat = fn.expand("#") end

    if pat == '' then return end


    local cond
    local regex = vim.regex(pat)
    if bang == '!' then
        cond = function(i)
            return (not regex:match_str(i.text)) and (not regex:match_str(fn.bufname(i.bufnr)))
        end
    else
        cond = function(i)
            return regex:match_str(i.text) or regex:match_str(fn.bufname(i.bufnr))
        end
    end

    items = vim.tbl_filter(cond, items)
    if qfChk then
        fn.setqflist({}, ' ', {items = items})
    else
        fn.setloclist(0, {}, ' ', {items = items})
    end
end

