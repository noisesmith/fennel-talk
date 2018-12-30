(require-macros :macros/util)
(local lu (require :luaunit))
(local sut (require :sque))

(global all {})

(method all:setUp [])

(method
 all:test-q-new
 []
 (local q (sut.new))
 (is q))

(method
 all:test-q-push
 []
 (local q (sut.new))
 (is (: q :push :a))
 (is q))

(method
 all:test-q-peek
 []
 (local q (sut.new))
 (: q :push :b)
 (is (= :b (: q :peek))
     "peek returns the top of the queue")
 (is (= :b (: q :peek))
     "peek doesn't alter the queue"))

(method
 all:test-q-pop
 []
 (local q (sut.new))
 (: q :push :c)
 (is (= :c (: q :pop))
     "pop returns the top of the queue")
 (is (= nil (: q :peek))
     "pop empties the queue")
 (is (: q :push :d)
     "an emptied queue can be refilled")
 (: q :push :e)
 (each [_ x (ipairs [:d :e])]
       (is (= (: q :pop) x)
           "queue is fifo")))

(local runner (lu.LuaUnit.new))
(runner.setOutputType runner :tap)
(os.exit (runner.runSuite runner))
