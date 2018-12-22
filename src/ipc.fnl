(require-macros :macros.util)
(local cqueues (require :cqueues))
(local socket (require :cqueues.socket))
(local thread (require :cqueues.thread))
(local errno (require :cqueues.errno))

(local
 read-specs
 {:eof "*a"
  :line "*l"
  :linen "*L"
  :header "*h"
  :headern "*H"})

(fn spec
  [s]
  "translates a symbolic representation of a read action into
  a format for xread

  accepts:
  number N
    positive - minimum N bytes or until eof
    negative - minimum 1 byte, max abs(N) or until eof
  string
    'eof' - read until closed
    'line' - read until newline
    'linen' - read until newline, keep newline
    'header' - read a mime header
    'headern' - read a mime header, keep newline
    any string accepted by cqueues.socket:read or lua file:read
  table
    [:mime m] - read mime entity for marker m
    [:max n] - read minimum 1 byte, max n, or until eof
    [:min n] - read minimum n bytes, or until eof
  "
  (if (= (type s) :number)
    (tostring s)
    (= (type s) :string)
    (or (. read-specs s)
        s)
    (~= (type s) :table)
    (tostring s)
    (= (. s 1) :mime)
    (.. "--" (tostring (. s 2)))
    (= (. s 1) :max)
    (.. "-" (tostring (. s 2)))
    (= (. s 1) :min)
    (tostring (. s 2))))

(fn read
  [socket fmt ...]
  (: socket :xread (spec fmt) ...))

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

(fn -thread
  [f ...]
  (let [(other-thread socket) (thread.start f ...)]
    {:thread other-thread
     :socket socket}))

{:read read
 :server server
 :thread -thread}
