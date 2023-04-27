; extends
((function_call
  name: (_) @_python_exec
  arguments: (arguments (string content: _ @injection.content)))
  (#set! injection.language "python")
  (#any-of? @_python_exec "pyExecLine" "pyExec"))
