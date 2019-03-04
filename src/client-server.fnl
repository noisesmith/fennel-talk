(require-macros :macros/util)
(local cqueues (require :cqueues))
(local sq (require :sque))
(local ipc (require :ipc))
(local util (require :util))

(fn main-loop
  []
  "returns a set of functions to run a main loop,
  plus messages, a map from id to message queue
  and cq, an instances of cqueues used for i/o polling"
  (let [cq (cqueues.new)
        messages {}
        state {}]
    (fn add-child [f msg]
      "takes a child function 'f', and an optional
      messages object 'msg' with methods :id and :set"
      (when msg
        (let [id (: msg :id)
              q {:queue (sq.new)}]
          (tset messages id q)
          (: msg :set q)))
      (: cq :wrap f)
      true)
    (fn start [t-o]
      (while (and (not (: cq :empty))
                  (not state.done))
        (: cq :step t-o))
      state)
    (fn quit []
      (tset state :done true))
    {:start start
     :add-child add-child
     :messages messages
     :quit quit
     :cq cq}))

(fn tcp-server
  [add-child handler port host-mask wait]
  (let [srv (ipc.server port host-mask)]
    (add-child
     (fn [...]
       (each [con (: srv.server :clients wait)]
             (add-child (fn [...]
                          (while true
                            (ipc.read con :linen)))))))
    srv))

{:main-loop main-loop
 :tcp-server tcp-server
 :poll-me cqueues.sleep}
