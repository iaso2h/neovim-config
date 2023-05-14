return function()
    vim.g["conjure#filetypes"] = {
        "clojure",
        "fennel",
        "janet",
        "hy",
        "julia",
        "racket",
        "scheme",
        "lua",
        "lisp",
        "rust",
    }
    -- if _G._os_uname.sysname ~= "Windows_NT" then
    table.insert(vim.g["conjure#filetypes"], "python")
    -- end
    vim.g["conjure#client#python#stdio#mapping#start"] = "lp"
    vim.g["conjure#client#python#stdio#mapping#stop"]  = "lP"
    if _G._os_uname.sysname == "Windows_NT" then
        vim.g["g:conjure#client#python#stdio#command"] = "python -iq"
    end
    vim.g["conjure#mapping#prefix"] = " "
    vim.g["conjure#mapping#eval_comment_current_form"] = "ecc"
    vim.g["conjure#mapping#eval_replace_form"]         = "eR"
    vim.g["conjure#mapping#eval_motion"]               = "ge"
    vim.g["conjure#mapping#doc_word"]                  = "K"

    vim.g["conjure#log#wrap"]                   = true
    vim.g["conjure#log#fold#enabled"]           = true
    vim.g["conjure#log#jump_to_latest#enabled"] = true
end
