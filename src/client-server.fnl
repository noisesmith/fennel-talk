(require-macros :macros/util)
(local cqueues (require :cqueues))
(local ipc (require :ipc))
(local util (require :util))

(fn main-loop
  [handler port host-mask]
  (var connection-count 0)
  (let [srv (ipc.server port host-mask)
        cq (cqueues.new)
        add-child (fn [s]
                    (let [cc connection-count]
                      (if s
                        (tset children cc s)
                        (tset children s cc))
                      (set connection-count (+ connection-count 1))
                      (: cq :wrap
                        (fn []
                          (each [ln (: s :lines "*L")]
                            (: cq :write (handler cc ln)))
                          (: cq :shutdown "w")))
                      cc))
        wait nil]
    (: cq :wrap
       (fn []
         (each [con (: srv.server :clients wait)]
               (add-child con))))
    {:start (fn [t-o] (assert (: cq :loop t-o)))
     :add-child add-child
     :cq cq
     :connection-count connection-count}))

{:main-loop main-loop}
