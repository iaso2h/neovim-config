; extends
(((comment) @comment
    (#lua-match? @comment "{{{")) @fold_marker_start)

(((comment) @comment
    (#lua-match? @comment "}}}")) @fold_marker_end)
