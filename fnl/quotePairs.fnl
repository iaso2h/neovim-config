; File: quotePairs
; Author: iaso2h
; Description: Auto make "" pair up
; Version: 0.0.2
; Last Modified: 2023-3-23
(local {: pp : strIdxAll} (require "fnlUtil"))
(local atomList ["list" "sequence" "local"])


(fn findAtomNode []
  (when (and (. package.loaded "nvim-treesitter.parsers")
             ((. (require "nvim-treesitter.parsers") "has_parser")))

    (local node ((. (require "nvim-treesitter.ts_utils") "get_node_at_cursor")))
    (when node
      (if (vim.tbl_contains atomList (node:type))
          node
          (do
            (var parentNode (node:parent))
            (while (and parentNode
                        (not (vim.tbl_contains atomList (parentNode:type))))
                (set parentNode (parentNode:parent)))

            (when parentNode parentNode))))))


(fn pairUp []
  (local curLine (vim.api.nvim_get_current_line))
  (local cursorPos (vim.api.nvim_win_get_cursor 0))
  (local cursorChar (curLine:sub (. cursorPos 2)
                                 (. cursorPos 2)))
  (local cursorCharNext (curLine:sub (+ (. cursorPos 2) 1)
                                     (+ (. cursorPos 2) 1)))
  (local atomNode (findAtomNode))
  (if (not atomNode)
    (vim.api.nvim_feedkeys "\"" "nt" false)
    (do
      (local range [(atomNode:range)])
      (var atomText "")
      (if (= (. range 1) (. range 3))
          (set atomText (curLine:sub (+ (. range 2) 2) (- (. range 4) 1)))
          (set atomText (curLine:sub (+ (. range 2) 2) -1)))
      (local quoteAllCount (length (strIdxAll atomText "\"")))
      (local quoteEscCount (length (strIdxAll atomText "\\\"")))
      (local quoteCount (- quoteAllCount quoteEscCount))
      ; (pp cursorChar)
      ; (pp cursorCharNext)
      ; (pp (= (% quoteCount 2) 0))
      ; (pp (cursorChar:match "%w"))
      ; (pp (cursorChar:match "[. ([{]"))
      ; (pp (cursorCharNext:match "%w"))
      (if (and (= (% quoteCount 2) 0
                (or (cursorChar:match "%w")
                    (and (cursorChar:match "[.: ([{]")
                         (cursorCharNext:match "%w")))))
          (do (vim.api.nvim_feedkeys "\"" "nt" false))
            ; (pp "Single insert")
          (do (vim.api.nvim_feedkeys (.. "\"\""
                                         (vim.api.nvim_replace_termcodes "<Left>"
                                                                   true
                                                                   true
                                                                   true)) "nt" false))))))
            ; (pp "Double insert")


{: pairUp}
