;; simple queue
;; defines the following methods:
;; -- push - put item in queue
;; -- peek - see next item
;; -- pop - consume next item

(require-macros :macros/util)

(local sq {})

(method
 sq:push
 [item]
 (let [idx self.insert]
   (tset self.entries idx item)
   ;; rotate production index
   (tset self :insert (+ idx 1))
   true))

(method sq:peek
 []
 (when self.entries
   (. self.entries self.consume)))

(method sq:pop
 []
 (let [payload (: self :peek)]
   (if (= payload nil)
     ;; when we empty the queue, reset indexes and storage
     (do
      (tset self :entries {})
      (tset self :consume 1)
      (tset self :insert 1))
     ;; otherwise, rotate consumption index
     (do
      (tset self.entries self.consume nil)
      (tset self :consume (+ self.consume 1))))
   payload))

(fn sq.new
  []
  (let [self {}]
    (setmetatable self {:__index sq})
    (: self :pop)
    self))

sq
