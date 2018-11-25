(local lu (require :luaunit))

(local util (require :util))

(global all {})

(fn all.setUp
  [self])

(fn all.test-baseline
  [self]
  (print "baseline test run")
  (lu.assertTrue true "never fails"))


;; (fn all.test-fails
 ;;  [self]
 ;;  (print "failing test run")
 ;;  (lu.assertTrue false "always fails"))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
