;; the class we are defining
;; the ntables and pow parameters control the creation of ftables storing data,
;; they should only be set before creating a new csound instance
(local audio-process {:ntables 23 :pow 19})

(require-macros :macros/util)

;; will contain a csound instance ready to make sound
(local csound (require :csound))

(method audio-process:orchestra
  []
  (let [o (io.open "resources/audio-process.orc")]
    (: o :read "*a")))

(method audio-process:score
  []
  (local ftables [])
  ;; ntables table definitions
  (for [i 1 self.ntables]
    (table.insert ftables (.. "f" i " 0 " self.table-size " 2 0")))
  (.. (table.concat ftables "\n")
      ;; and the phasor instrument running for a very long time
      "\ni1 0 2147483648\n"))

(method audio-process:init-engine
  []
  (set self.cs (csound.new 0))
  (set self.table-size (math.pow 2 self.pow))
  (: self.cs :set-opts "-d" "--nchnls=2" "-m0")
  (: self.cs :start)
  (: self.cs :compile-orc (: this :orchestra))
  (: self.cs :read-score (: this :score)))

(method audio-process:stop-engine
  []
  (: self.cs :cleanup)
  (: self.cs :destroy)
  (tset self :cs nil))

(method audio-process:send-request
  [])

(method audio-process:list-available
  [])

(method audio-process:fetch-result
  [])

(method audio-process:fill-table
  ;; b should be a double-array, length >= the size of the tables
  [table-id b]
  (assert (<= self.ntables table-id))
  (: self.cs :table-copy-in table-id b))

(method audio-process:play-table
  [params]
  (: self.cs :score-event "i" 2
     (or (. params :start) 0)
     (. params :dur)
     (or (. params :offs) 0)
     (or (. params :amp) 1)
     (or (. params :curve) 0)
     (or (. params :table))))

;; send messages to coordination-process
;; poll for ready data, download
;; composite audio out of available pieces

(fn audio-process.new
  ;; eventually remotes will be managed internall,
  ;; as a minimal implementation we will start with
  ;; a hardcoded set of remotes
  [remotes]
  (let [self {}]
    (setmetatable self {:__index audio-process})
    self))

audio-process
