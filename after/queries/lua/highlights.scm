; extends
;; https://github.com/MunifTanjim/tree-sitter-lua
;; commit: #0fc8996
(break_statement) @keyword.break

((identifier) @variable.builtin
  (#any-of? @variable.builtin "self" "string" "table" "vim" "debug" "math")
  (#set! "priority" 130))

(function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
            ;; built-in functions in Lua 5.1
            "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs"
            "load" "loadfile" "loadstring" "module" "next" "pairs" "pcall" "print"
            "rawequal" "rawget" "rawset" "require" "select" "setfenv" "setmetatable"
            "tonumber" "tostring" "type" "unpack" "xpcall")
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

((parameters (identifier) @parameter)
  (#set! "priority" 130))
