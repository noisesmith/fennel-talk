(require-macros :macros.util)
(local lu (require :luaunit))
(local ipc (require :ipc))
(local util (require :util))

(local str util.str)
(local null? util.null?)

(global all {})

(method all:setUp
  [])

(method all:test-baseline
  []
  (is true "never fails"))

 (method all:test-server
   []
   (let [server (is (ipc.server)
                    "server creation with no args")]
     (is (= (type server) :table)
         "the server object is a table")
     (is server.port
         (.. "the server port is returned: "
             (str server.port)))
     (is (: server :status)
         "we got a running server")
     (: server :close)))

 (method all:test-server-close
   []
   (let [server (ipc.server)]
     (is (null? (: server :close))
         "we can close the server with no error")
     (is (blows-up? (: server.server :stat))
         "accessing the server value inside errors after close")
     (is (not (: server :status))
         "asking for status after close gives false, but no error")
     (: server :close)))

(method all:test-server-badport
  []
  (let [bad-srv (ipc.server 80)]
    (is (= bad-srv.error
           "Permission denied")
        (.. "legible error string on failure, got: "
            bad-srv.error))
    (: bad-srv :close)))


(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
