(require-macros :macros/util)
(local cqueues (require :cqueues))
(local ipc (require :ipc))
(local util (require :util))

(local co-> coroutine.resume)

(local <-co coroutine.yeild)

(local ->co coroutine.create)

(fn main-loop
  []
  (var client-count 0)
  (var clients [])
  (var continue true)
  (var messages [])
  (fn add-child [f]
    (let [cc (+ client-count 1)
          new-child (->co (f cc))]
      (set client-count cc)
      (table.insert clients new-child)
      cc))
  (fn start []
    (while continue
      (when (not (= (# clients) 0))
        (each [idx,client (ipairs clients)]
              (when (and continue
                         (not (= client :done)))
                (let [msg (co-> client (. messages (# messages)))]
                  (if (= msg :done)
                    (tset clients idx :done)
                    (table.insert messages msg))))))))
  (fn stop
    []
    (set continue false))
  {:start start
   :add-child add-child
   :clients clients
   :client-count (fn [] client-count)
   :stop stop
   :messages messages})

(fn io-loop
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
                          (local invoked (<-co con))
                          (while true
                            (local resumption (<-co :result (ipc.read con :linen)))
                            ;; wake us when con is ready again
                            (<-co con)))))))
    srv))

{:main-loop main-loop
 :io-loop io-loop
 :tcp-server tcp-server}
