; extends
;; https://github.com/nvim-treesitter/nvim-treesitter/tree/master/queries/lua
;; commit: #b8a0791
(break_statement) @keyword.break

((identifier) @constant.builtin
  (#eq? @constant.builtin "_VERSION")
  (#set! "priority" 130))

((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "_G" "debug" "io" "jit" "math" "os" "package" "string" "table" "utf8" "vim")
  (#set! "priority" 130))

((identifier) @variable.builtin
  (#any-of? @variable.builtin "self")
  (#set! "priority" 130))

(function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
    ;; built-in functions in Lua 5.1
    "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs"
    "load" "loadfile" "loadstring" "module" "next" "pairs" "pcall" "print"
    "rawequal" "rawget" "rawlen" "rawset" "require" "select" "setfenv" "setmetatable"
    "tonumber" "tostring" "type" "unpack" "xpcall"
    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
    "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
    "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm")
  (#set! "priority" 150))

(function_call
  name: (identifier) @function.call
  (#set! "priority" 140))

(function_call
  name: (dot_index_expression field: (identifier) @function.call)
  (#set! "priority" 140))

(function_declaration
  name: (dot_index_expression field: (identifier) @function)
  (#set! "priority" 140))

(method_index_expression
  method: (identifier) @method.call
  (#set! "priority" 140))

;;Field
((field name: (identifier) @field)
  (#set! "priority" 130))

((dot_index_expression field: (identifier) @field)
  (#set! "priority" 130))

;;Constant
((identifier) @constant
  (#lua-match? @constant "^[A-Z][A-Z_0-9]*$")
  (#set! "priority" 130))
