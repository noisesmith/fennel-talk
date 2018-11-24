(local ffi (require :ffi))
(local socket (require :socket))
(local lume (require :lume))

(ffi.cdef '
  int printf(const char *fmt, ...);
')

(fn pks [t spl]
  (let [splitter (or spl "\n")]
    (each [k v (pairs t)]
          (ffi.C.printf "%s%s" k splitter))
    (print)))

(local poll-timeout 0.05)

(local
 client-accept-co
 (coroutine.create
  (fn [server _ state]
    (let [(client err-state) (: server :accept)]
      (if client
        ;; connection
        (coroutine.yield {:client client
                          :result err-state
                          :action :receive})
        ;; timeout or error
        (coroutine.yield state))))))

(local
 client-receive-co
 (coroutine.create
  (fn [server client state]
    (let [(data err-state) (: client :receive)]
      (if data
        (coroutine.yield {:action :send
                          :result err-state
                          :data data})
        (= err-state :timeout)
        (coroutine.yield state)
        (coroutine.yield {:action :accept
                          :client (do (: client :close) nil)
                          :result err-state}))))))

(local
 client-send-co
 (coroutine.create
  (fn [server client state]
    (let [(sent status) (: client :send state.data)]
      (if (= status :timeout)
        (coroutine.yield state)
        sent
        (coroutine.yield {:action :receive
                          :result status
                          :sent sent})
        (coroutine.yield {:action :accept
                          :result status
                          :client (do (: client :close) nil)}))))))

(fn mk-client-co
  [server actor clients]
  (fn []
    (client-accept-co server actor {:action :accept})))

;; TODO - things are kind of a mess here -- I've written most of it as trampolining rather than coroutines - revisit
(fn mk-event-loop
  [clients]
  (coroutine.create
   ;; TODO - what do we really want here? What should each state do?
   (fn [client-data state]
     (when state.client
       ;; we have a new client!
       (: client :settimeout poll-timeout))
     (if (= state.acton :receive
            )))))

(fn service [actor]
  (let [server (socket.bind :* 0)
        _ (: server :settimeout poll-timeout)
        (ip port) (: server :getsockname)
        clients []
        client-fn (fn []
                    (let [client-connection (mk-client-co server clients)]
                      (lume.push clients client-connection)))
        event-loop (mk-event-loop clients)]
    {:server server
     :client-fn client-fn
     :event-loop event-loop}))

{:pks pks
 :service service}
