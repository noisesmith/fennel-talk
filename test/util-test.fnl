(require-macros :macros/util)
(local lu (require :luaunit))

(global all {})

(fn all.setUp
  [self])

(fn all.test-baseline
  [self]
  (is true "never fails"))


;; (fn all.test-fails
 ;;  [self]
 ;;  (print "failing test run")
 ;;  (lu.assertTrue false "always fails"))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
