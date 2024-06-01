local M = {
    scratchBuf = -1
}

-- Python environment setup
if vim.fn.has("python3") == 0 then
    vim.notify("Python3 use is forced by configuration, yet your Vim does not appear to have Python3 support",
        vim.log.levels.ERROR)
    return
end
vim.g.thesaurusRoot = _G._config_path .. pathStr "/lua/thesaurus/python"

local pyExecLine = function(codeStr)
    vim.cmd(string.format([[
python3<<endOfPython
%s
endOfPython]], codeStr))
end


local pyExec = function(codeStr)
    vim.cmd("python3 " .. codeStr)
end


-- Import Python libs
pyExecLine[[
import sys, os, vim, glob
thesaurusRoot = vim.eval("g:thesaurusRoot")
if thesaurusRoot not in sys.path:
    sys.path.append(thesaurusRoot)

import extract
]]


local trim = function(input)
    input = vim.fn.substitute(input, "[ \\t]*[\\r\\n:][ \\t]*", " ", "g")
    return vim.fn.substitute(input, "^[ \\t]*\\(.\\{-}\\)[ \\t]*$", "\\1", "")
end


local query = function()

    pyExecLine -- {{{
[[
definition_family_list = extract.online_thesaurus(vim.eval("g:thesaurusWord"))
if definition_family_list:
    vim.command("let g:thesaurusTestFamily=v:true")
else:
    vim.command("let g:thesaurusTestFamily=v:false")
]] -- }}}

    if vim.g.thesaurusTestFamily then
        if vim.bo.modifiable and not vim.bo.buflisted and
                vim.api.nvim_buf_line_count(0) == 1 and vim.fn.getline(1) == "" then
            M.scratchBuf = vim.api.nvim_get_current_buf()
        else
            if not M.scratchBuf or (not vim.api.nvim_buf_is_valid(M.scratchBuf)) then
                M.scratchBuf = vim.api.nvim_create_buf(false, true)
            end
            vim.cmd [[split]]
            M.scratchBuf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = M.scratchBuf})
            vim.api.nvim_set_current_buf(M.scratchBuf)
        end

        pyExecLine -- {{{
[[
cb = vim.current.buffer
for each_family in definition_family_list:
    cb.append("DEFINITION: " + each_family._definition)
    cb.append("PART OF SPEECH: " + each_family._syntax)
    cb.append('SYNONYMS: '  + ', '.join(each_family._synonyms))
    cb.append('ANTONYMS: ' + ', '.join(each_family._antonyms))
cb[0] = None # delete the first empty line
]] -- }}}
        vim.cmd([[noa resize]] .. vim.api.nvim_buf_line_count(M.scratchBuf))
        if vim.o.cmdheight ~= 2 then
            vim.o.cmdheight = 2
        end
        vim.bo.modifiable = false
        vim.bo.filetype = "thesaurus"
    else
        vim.notify([[No result for "]] .. vim.g.thesaurusWord .. [["]])
    end
end


---Look up word
---@param word string
M.lookUp = function(word)
    vim.g.thesaurusWord = string.lower(trim(word))
    vim.g.thesaurusWord = string.gsub(vim.g.thesaurusWord, [=[["']]=], [[]])
    vim.loop.new_async(vim.schedule_wrap(query)):send()
end


return M
