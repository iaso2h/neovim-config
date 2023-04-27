local M = {

}

-- Python environment setup
if vim.fn.has("python3") == 0 then
    vim.notify("Python3 use is forced by configuration, yet your Vim does not appear to have Python3 support",
        vim.log.levels.ERROR)
    return
end
vim.g.thesaurusRoot = vim.fn.expand("%:p:h")

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

import thesaurus_query.thesaurus_query as tq_interface
from thesaurus_query.tq_common_lib import decode_utf_8
]]


local init = function()
    pyExec "tq_framework = tq_interface.Thesaurus_Query_Handler()"
end

local trim = function(input)
    input = vim.fn.substitute(input, "[ \\t]*[\\r\\n:][ \\t]*", " ", "g")
    return vim.fn.substitute(input, "^[ \\t]*\\(.\\{-}\\)[ \\t]*$", "\\1", "")
end


---Look up word
---@param word string
---@param replaceChk boolean Whether to replace the word under the cursor
M.lookUp = function(word, replaceChk)
    word = word or "dummy"
    vim.g.thesaurusReplaceChk = replaceChk
    vim.g.thesaurusWordTrimmed = trim(word)
    vim.g.thesaurusWord = string.lower(vim.g.thesaurusWordTrimmed)
    vim.g.thesaurusWord = string.gsub(vim.g.thesaurusWord, [=[["']]=], [[]])
    pyExecLine[[
tq_framework.session_terminate()
tq_framework.session_init()

tq_continue_query = 1

while tq_continue_query>0:
    vim.command("redraw")
    tq_next_query_direction = True if tq_continue_query==1 else False
    tq_synonym_result = tq_framework.query(decode_utf_8(vim.eval("g:thesaurusWord")), tq_next_query_direction)
# Use Python environment for handling candidate displaying {{{
# mark for exit function if no candidate is found
    if not tq_synonym_result:
        vim.command("echom \"No synonym found for \\\"{0}\\\".\"".format(vim.eval("g:thesaurusWordTrimmed").replace('\\','\\\\').replace('"','\\"')))
        vim.command("g:thesaurusSynoFound=v:false")
        tq_framework.session_terminate()
        tq_continue_query = 0
# if replace flag is on, prompt user to choose after populating candidate list
    elif vim.eval("g:thesaurusReplaceChk") != "0":
        tq_continue_query = tq_interface.tq_replace_cursor_word_from_candidates(tq_synonym_result, tq_framework.good_backends[-1])
    else:
        tq_continue_query = 0
        tq_framework.session_terminate()

del tq_continue_query
del tq_next_query_direction
# }}}
    ]]

end

init()

return M
