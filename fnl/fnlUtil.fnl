(local fennel (require "fennel"))
(fn pp [x] (print (fennel.view x)))


(fn strIdxAll [targetStr subStr]
  ; Initiation
  (var idxTbl [])
  (var idx (select 2 (string.find targetStr subStr)))

  (when idx
    (do
     (while idx
       (table.insert idxTbl idx)
       (set idx (+ idx 1))
       (set idx (select 2 (string.find targetStr subStr idx))))))

  idxTbl)

{"pp" pp "strIdxAll" strIdxAll}
