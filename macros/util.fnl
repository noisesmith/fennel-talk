(fn method
  [spec args ...]
  "given (method :foo:bar [x] (+ x x))
  (: foo :bar 2) => 4
  binds the 'self' variable in the same manner a lua method definition would"
  (let [pos (string.find spec ':' 2)
        _ (assert pos "method requires a spec in the form of :object:newmethod")
        target (string.sub spec 1 (- pos 1))
        method (string.sub spec (+ pos 1))]
    (list (sym :fn)
          (sym (.. target '.' method))
          [(sym :self) (unpack args)]
          ...)))

{:method method}
