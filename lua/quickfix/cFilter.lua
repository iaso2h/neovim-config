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
local fn  = vim.fn
local M   = { }

local lastFilterPat = ""
--- Filter out quickfix list or locallist by specific pattern
--- @param qfChk boolean whether filter out quickfix or not
--- @param pat string pattern to filter out
--- @param bang string if bang value is "!", then items not matching the
---        pattern will be preserved
M.main = function(qfChk, pat, bang)
    local items = qfChk and fn.getqflist() or fn.getloclist(0)

    -- Parsing the pat
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

    if pat == "%" or pat == "#" then
        pat = fn.expand("#:t:r")
    end

    if pat == '' then return end


    local cond
    local regex = vim.regex(fn.escape(pat, "\\"))
    if not regex then return end

    if bang == '!' then
        cond = function(i)
            return (not regex:match_str(i.text)) and (not regex:match_str(fn.bufname(i.bufnr)))
        end
    else
        cond = function(i)
            return regex:match_str(i.text) or regex:match_str(fn.bufname(i.bufnr))
        end
    end

    local newItems = vim.tbl_filter(cond, items)
    -- Check whether item list is emptry and prompt for continuation
    if not next(newItems) then
        vim.cmd "noa echohl MoreMsg"
        local answer = fn.confirm("No satisified items, proceed?  ",
            ">>> &Yes\n&No\n&Cancel", 3, "Question")
        vim.cmd "noa echohl None"

        if answer ~= 1 then
            return
        end
    end

    -- Store the previous item list
    if #newItems ~= #items then require("quickfix.undo").lastItems = items end

    -- Populate new items
    if qfChk then
        fn.setqflist({}, " ", {items = newItems})
    else
        fn.setloclist(0, {}, " ", {items = newItems})
    end

    -- Optional step need to do for todo-comment
    vim.defer_fn(require("quickfix.highlight").clear, 0, 0)
end

return M
