(require-macros :macros/util)
(local sut (require :client-server))
(local ipc (require :ipc))
(local lu (require :luaunit))

(local tracing? false)

(local trace
       (fn [...]
         (if tracing?
           (print ...))))

(local co->
       (fn [...]
         (trace "client-server-test.fnl co-> resuming " ...)
         (coroutine.resume ...)))

(local <-co
       (fn [...]
          (trace "client-server-test.fnl <-co yielding " ...)
          (coroutine.yield ...)))

(local ->co coroutine.create)

(fn dump
  []
  (print
   (: ";;;;;;;; from test:\n--\n%s\n--\n:;;;;;;;; :from test"
      :format
      (sut.trace))))

(global all {})

(method all:setUp
  [])

(method
 all:test-main-loop:stop
 []
 (let [main (sut.main-loop)]
   (main.stop)
   (main.start)))

(method
 all:test-main-loop
 []
 (let [main (sut.main-loop)]
   (fn quick-exit-co
     [cc]
     (fn []
       (let [init (<-co :ready cc)]
         (<-co (main.stop)))))
   (main.add-child quick-exit-co)
   (main.start)))

(method
 all:test-main-loop:2
 []
 (local events [])
 (var stop (fn []))
 (fn track-calls
   [id calls]
   (table.insert events {:id id :calls calls})
   (when (> (# events)
          100)
     (stop)))
 (fn iterated-exit-co
   [cc]
   (var call-count 0)
   (fn []
     (while (< call-count cc)
       (<-co cc call-count)
       (set call-count (+ call-count 1))
       (track-calls cc call-count))))
 (let [main (sut.main-loop)]
   (set stop main.stop)
   (for [i 1 20]
     (local child-ret (main.add-child iterated-exit-co))
     (is (= i child-ret)
         (.. "expected <" i "> return-value, found " (tostring child-ret)))
     (is (= i (main.client-count))
         (.. "expected <" i "> children, found " (main.client-count))))
   (main.start)
   (is (= (# events) 101)
       (.. "expected 100 events, got: " (# events)))))

(comment
 (method
  all:test-main-loop
  []
  (var results {})
  (let [consume (->co
                 (fn []
                   (let [pollme {:timeout (fn [] 1)}]
                     (print "poll in consuming coroutine")
                     (<-co pollme)
                     (print "resume in consuming coroutine")
                     (let [msg "confirm 1"]
                       (table.insert results msg)))))
        m (sut.main-loop)]
    (is m)
    (is (m.add-child consume))
    (is (m.start 1))
    (dump)
    (is (= (# results) 1)
        (.. "expect one result, got " (tostring (# results))))
    (is (= (. results 1) "confirm 1")))))

(local runner (lu.LuaUnit.new))
(runner.setOutputType runner "tap")
(os.exit (runner.runSuite runner))
