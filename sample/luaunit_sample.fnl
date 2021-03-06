;; example of using luaunit via fennel
;; run with 'fennel luaunit_sample.fnl test_toto
(local lu (require :luaunit))

;; the name is not idiomatic, but a name with dashes breaks(!?)
(global test_toto {})

(fn test_toto.setUp
  [self]
  (set self.a 1)
  (set self.s "hop")
  (set self.t1 [1 2 3])
  (set self.t2 {:one 1 :two 2 :three 3})
  (set self.t3 {1 1 2 2 :three 3}))

(fn test_toto.test1-with-failure
  [self]
  (print "some stuff test 1")
  (lu.assertEquals self.a 1)
  (lu.assertEquals self.a 2))

(local runner (lu.LuaUnit.new))

(runner.setOutputType runner "tap")

(os.exit (runner.runSuite runner))
