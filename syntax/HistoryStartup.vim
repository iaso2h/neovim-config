if exists("b:current_syntax")
    finish
endif
let b:current_syntax = "HistoryStartup"
syntax match HistoryStartupCreate    /< New Buffer >/
syntax match HistoryStartupFileRoot  /\/.*\/\zs.\+$/
syntax match HistoryStartupFileRoot  /\\.*\\\zs.\+$/

