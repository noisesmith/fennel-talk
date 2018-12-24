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

(comment
(method
 (all:test-main-loop
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
