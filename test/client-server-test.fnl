(require-macros :macros/util)
(local sut (require :client-server))
(local ipc (require :ipc))
(local lu (require :luaunit))

(global all {})

(method all:setUp
  [])

(fn child-fn
  [s v]
  (let [ipc (require :ipc)]
    (: s :write v)))

(method all:test-main-loop
  []
  (var results {})
  (let [m (sut.main-loop (fn [msg] (table.insert results msg)))]
    (is m)
    (is m.start)
    (is (m.start 10))
    (let [child (ipc.thread child-fn "confirm 1")]
      (is child)
      (is child.thread)
      (is child.socket)
      (: child.socket :close)
      (is (= (# results) 1)
          (.. "expect one result, got " (tostring (# results))))
      (is (= (. results 1) "confirm 1")))))

(local runner (lu.LuaUnit.new))
(runner.setOutputType runner "tap")
(os.exit (runner.runSuite runner))
