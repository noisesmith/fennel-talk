(require-macros :macros/util)
(local cqueues (require :cqueues))
(local sq (require :sque))
(local ipc (require :ipc))
(local util (require :util))

(fn main-loop
  []
  (let [cq (cqueues.new)]
    (fn add-child [f]
      (: cq :wrap f)
      true)
    (fn start [t-o]
      (: cq :loop t-o)
      true)
    {:start start
     :add-child add-child
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
