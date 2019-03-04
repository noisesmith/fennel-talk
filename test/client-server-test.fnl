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

(method
 all:test-message-cb
 []
 (let [m (sut.main-loop)
       child-state {}
       debug {:events []
              :result false}]
   ;; TODO - trigger the done path below
   (fn child []
     (var done false)
     (while (not done)
       (sut.poll-me 0.1)
       (let [msg (: child-state.queue :pop)]
         (print "message" msg)
         (table.insert debug.events :tick)
         (when (= msg :done)
           (set done true)))))
   (m.add-child
    child
    {:id (fn [self] :child-id)
     :set (fn [self data]
            (tset debug :result data))})
   (m.start 1)
   (is (= (type debug.result) 'table'))
   (is (= (: debug.result.queue :peek)
          nil))
   (is (= (# debug.events)
          1))))

(local runner (lu.LuaUnit.new))
(runner.setOutputType runner :tap)
(os.exit (runner.runSuite runner))
