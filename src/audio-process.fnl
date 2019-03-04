;; the class we are defining
(local audio-process {})
(require-macros "macros.util")

;; will contain a csound instance ready to make sound
(local csound (require :csound))

(method audio-process:orchestra
  []
  (let [o (io.open "resources/audio-process.orc")]
    (: o :read "*a")))

(method audio-process:score
 []
 (let [s (io.open "resources/audio-process.sco")]
   (: s :read "*a")))

(method audio-process:init-csound
  []
  (set self.cs (csound.new))
  (: self.cs :compile-orc (: this :orchestra))
  (: self.cs :read-score (: this :score)))

(method audio-process:send-request
  [])

(method audio-process:list-available [])

(method audio-process:get-result [])

(method audio-process:play-buffer [])

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
