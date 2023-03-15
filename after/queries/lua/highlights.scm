; extends
;; https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax
;; :h treesitter-query
;; https: //github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/lua/highlights.scm
;; version: #11b2d43
(break_statement) @keyword.break

(break_statement) @keyword.break

(
 (
  (identifier) @variable.builtin
  (#any-of? @variable.builtin "self" "string" "table" "vim")
  )
 (#set! "priority" 200)
 )

(
 (function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
            ;; built-in functions in Lua 5.1
            "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs"
            "load" "loadfile" "loadstring" "module" "next" "pairs" "pcall" "print"
            "rawequal" "rawget" "rawset" "require" "select" "setfenv" "setmetatable"
            "tonumber" "tostring" "type" "unpack" "xpcall")
  )
 (#set! "priority" 200)
 )

;;Field
(
 (field name: (identifier) @field)
 (#set! "priority" 200)
 )

(
 (dot_index_expression field: (identifier) @field)
 (#set! "priority" 200)
 )

;;Constant
(
 (identifier) @constant
 (#lua-match? @constant "^[A-Z][A-Z_0-9]*$")
 (#set! "priority" 200)
 )

;; vim:ts=2:sts=2:sw=2:ft=scheme
