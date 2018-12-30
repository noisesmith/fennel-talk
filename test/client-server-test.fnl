(require-macros :macros/util)
(local cqueues (require :cqueues))
(local ipc (require :ipc))
(local lu (require :luaunit))
(local sut (require :client-server))

(global all {})

(method all:setUp [])

(method
 all:test-main-loop
 []
 (var results {})
 (let [m (sut.main-loop)]
   (fn consume []
     (print "poll in consuming coroutine")
     (sut.poll-me 0.1)
     (print "resume in consuming coroutine")
     (let [msg "confirm 1"]
       (table.insert results msg)))
   (is m)
   (is (m.add-child consume))
   (is (m.start 1))
   (is (= (# results) 1)
       (.. "expect one result, got " (tostring (# results))))
   (is (= (. results 1) "confirm 1"))))

(local runner (lu.LuaUnit.new))
(runner.setOutputType runner :tap)
(os.exit (runner.runSuite runner))
