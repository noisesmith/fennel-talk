(require-macros :macros/util)
(local cqueues (require :cqueues))
(local ipc (require :ipc))
(local util (require :util))

(fn main-loop
  [handler port host-mask]
  (let [srv (ipc.server port host-mask)
        cq (cqueues.new)
        wait nil]
    (var connection-count 0)
    (: cq :wrap
       (fn []
         (each [con (: srv.server :clients wait)]
               (let [cc connection-count]
                 (set connection-count
                      (+ connection-count 1))
                 (: cq :wrap
                    (fn []
                      (each [ln (: con :lines "*L")]
                            (: cq :write (handler cc ln)))
                      (: cq :shutdown "w")))))))
    {:start (fn [t-o] (assert (: cq :loop t-o)))
     :cq cq
     :connection-count connection-count}))

{:main-loop main-loop}
