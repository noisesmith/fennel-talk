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
    `(fn ~(sym (.. target '.' method))
       [self ~(unpack args)]
       ~...)))

(fn is
  [condition message]
  "an assertion that the arg is not false or nil, returns the arg,
  uses the message in the error output if provided

  on further consideration this is silly, it's just assert"
  `(let [lua-unit (require :luaunit)
         result ~condition]
     (lua-unit.assertTrue (not (not result))
                          ~message)
     result))

(fn blows-up?
  [...]
  `(let [(success? value) (pcall (fn [] ~...))]
     (if success?
       nil
       value)))

(fn if-let
  [bind then ...]
  `(let ~bind
     (if ~(. bind 1)
       ~then
       ~...)))

{:method method
 :is is
 :blows-up? blows-up?
 :if-let if-let}
