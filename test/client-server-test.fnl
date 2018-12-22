(require-macros :macros/util)
(local sut (require :client-server))
(local lu (require :luaunit))

(global all {})

(method all:setUp
  [])

(method all:test-main-loop
  []
  (let [m (sut.main-loop print)]
    (assert m)
    (assert m.start)
    (assert (m.start 10))))

(local runner (lu.LuaUnit.new))
(runner.setOutputType runner "tap")
(os.exit (runner.runSuite runner))
