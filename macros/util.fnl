(fn method
  [spec-sym args ...]
  "given (method foo:bar [x] (+ x x))
  (: foo :bar 2) => 4
  binds the 'self' variable in the same manner a lua method definition would"
  (let [[spec] spec-sym
        pos (string.find spec ':' 2)
        _ (assert pos "method requires a spec symbol in the form of object:newmethod")
        target (string.sub spec 1 (- pos 1))
        method (string.sub spec (+ pos 1))]
    (list (sym :fn)
          (sym (.. target '.' method))
          [(sym :self) (unpack args)]
          ...)))

(fn is
  [condition message]
  (list (sym :let) [(sym :lua-unit) (list (sym :require) :luaunit)
                    (sym :result) condition]
    (list (sym :lua-unit.assertTrue)
          ;; the old trick - (not (not x)) coerces x to boolean
          (list (sym :not) (list (sym :not) (sym :result)))
          message)
    (sym :result)))

(fn blows-up?
  [...]
  (list (sym :let)
        [(list (sym :success?) (sym :value))
         (list (sym :pcall) (list (sym :fn) [] ...))]
        (list (sym :if) (sym :success?)
              nil
              (sym :value))))

{:method method
 :is is
 :blows-up? blows-up?}
