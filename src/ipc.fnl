(require-macros :macros.util)
(local cqueues (require :cqueues))
(local socket (require :cqueues.socket))
(local thread (require :cqueues.thread))
(local errno (require :cqueues.errno))

(fn server
  [port host]
  (var srv {:type :server})
  (method srv:init
    [port host]
    (let [host-mask (or host "127.0.0.1")
          attempted-port (or port 0)
          opened (socket.listen host-mask attempted-port)
          (socket-type host port) (: opened :localname)]
      (set self.server opened)
      (set self.host host)
      (set self.port port)
      (set self.error (when (not socket-type)
                        (errno.strerror host))))
    self)
  (method srv:close
    []
    (: self.server :close))
  (method srv:status
    []
    (let [(success ret) (pcall (fn [] (: self.server :stat)))]
      (when success
        ret)))
  (: srv :init port host))

(fn worker
  [f ...]
  (let [(other-thread socket) (thread.start f ...)]
    {:thread other-thread
     :socket socket}))

{:server server
 :thread worker}
