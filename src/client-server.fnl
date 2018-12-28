(require-macros :macros/util)
(local cqueues (require :cqueues))
(local ipc (require :ipc))
(local util (require :util))

(local tracing? false)

(local trace-log [])

(local trace
       (fn [...]
         (when tracing?
           (table.insert trace-log (.. "<<" (table.concat [...] "; ") ">>"))
           (print ...))))

(local co->
       (fn [...]
         ;; (trace (: "client-server.fnl co-> resuming <<%s>>" :format (table.concat [...] "; ")))
         (coroutine.resume ...)))

(local <-co
       (fn [...]
         ;; (trace "client-server.fnl <-co yielding " ...)
         (coroutine.yeild ...)))

(local ->co
       (fn [...]
         ;; (trace "creating coroutine" ...)
         (coroutine.create ...)))

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
  (var client-count 1)
  (var clients [])
  (var ids {})
  (fn make-child
    [co cc]
    (fn [...]
      (while true
        ;; the child should return its pollable when resumed.
        (let [msg (co-> co :consume cc ...)]
          (trace (: "child of main was given '%s' for '%s'" :format msg ...))
          (<-co cc msg)))))
  (let [cq (cqueues.new)]
    (fn add-child [co]
      (let [cc client-count
            new-child (: cq :wrap (make-child co cc))]
        (set client-count (+ client-count 1))
        (table.insert clients new-child)
        (tset ids cc new-child)
        cc))
    (fn start [t-o]
      (trace "main-loop started at" (cqueues.monotime))
      (: cq :loop t-o)
      (trace "main-loop exited at" (cqueues.monotime))
      true)
    {:start start
     :add-child add-child
     :cq cq
     :client-count client-count}))

(fn tcp-server
  [add-child handler port host-mask wait]
  (let [srv (ipc.server port host-mask)]
    (add-child
     (fn [...]
       (trace "tcp server connected with" ...)
       (each [con (: srv.server :clients wait)]
             (add-child (fn [...]
                          (trace "tcp client added with" ...)
                          (local invoked (<-co con))
                          (while true
                            (local resumption (<-co :result (ipc.read con :linen)))
                            (trace "tcp client woken with" resumption)
                            ;; wake us when con is ready again
                            (<-co con)))))))
    srv))

{:main-loop main-loop
 :io-loop io-loop
 :tcp-server tcp-server
 :trace (fn [] (table.concat trace-log " --\n"))}
