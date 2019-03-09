(local ffi (require :ffi))
(local cs (require :csound-raw))
(require-macros 'macros.util')

;; the class we are defining here
(local csound {})

(fn csound.new [buffer]
  (let [buffer-arg (or buffer 0)
        self {:cs (cs.csoundCreate 0)
              :csound-library cs}]
    (setmetatable self {:__index csound})
    (: self :create-message-buffer buffer-arg)
    ;; override some default opts...
    (: self :set-opts "-d" "-m0")
    self))

(local doubles (ffi.typeof "double[?]"))

(tset csound :doubles doubles)

(method csound:create
  []
  (set self.cs (cs.csoundCreate 0)))

(method csound:start
  []
  (cs.csoundStart self.cs))

(method csound:compile-orc
  [orc]
  (cs.csoundCompileOrc self.cs orc))

(method csound:read-score
  [score]
  (cs.csoundReadScore self.cs score))

(method csound:perform-ksmps
  []
  (cs.csoundPerformKsmps self.cs))

(method csound:cleanup
  []
  (cs.csoundCleanup self.cs))

(method csound:get-kr
  []
  (cs.csoundGetKr self.cs))

(method csound:get-sr
  []
  (cs.csoundGetSr self.cs))

(method csound:set-option
  [opt]
  (cs.csoundSetOption self.cs opt))

(method csound:get-ksmps
  []
  (cs.csoundGetKsmps self.cs))

(method csound:reset
  []
  (cs.csoundReset self.cs))

(method csound:destroy
  []
  (cs.csoundDestroy self.cs))

(method csound:create-message-buffer
  [to-stdout]
  (cs.csoundCreateMessageBuffer self.cs to-stdout))

(method csound:get-message-cnt
   []
   (cs.csoundGetMessageCnt self.cs))

(method csound:get-first-message
   []
   (ffi.string (cs.csoundGetFirstMessage self.cs)))

(method  csound:pop-first-message
   []
   (cs.csoundPopFirstMessage self.cs))

(method csound:set-opts
  [...]
  (var ret 0)
  (var option nil)
  (each [_ opt (ipairs [...])]
        (when (= ret 0)
          (set option opt)
          (set ret (: self :set-option option))))
  (values ret option))

(method csound:messages
  []
  (var res [])
  (var done? false)
  (while (not done?)
    (let [message (: self :get-first-message)]
      (table.insert res message)
      (: self :pop-first-message)
      (set done?  (<= (: self :get-message-cnt) 0))))
    res)

(method csound:get-control-channel
  [id]
  (cs.csoundGetControlChannel self.cs id))

(method csound:set-control-channel
  [id v]
  (cs.csoundSetControlChannel self.cs id v))

(method csound:table-length
  [n]
  (cs.csoundTableLength self.cs n))

(method csound:table-get
   [table-id index]
   (cs.csoundTableGet self.cs table-id index))

(method csound:table-set
   [n index value]
   (cs.csoundTableSet self.cs n index value))

(method csound:table-update
  [n f]
  (let [size (: self :table-length n)]
    (assert (not (= size -1))
            (.. "table-update: table " n " not found"))
    (for [i 0 (- size 1)]
      (let [current (: self :table-get n i)
            updated (f current)]
        (: self :table-set n i updated)))))

(method csound:table-copy-in
  [table-id src]
  (cs.csoundTableCopyIn self.cs table-id src))

(method csound:table-copy-out
  [table-id dest]
  (cs.csoundTableCopyOut self.cs table-id dest))

(method csound:score-event
  [event-type ...]
  (let [ev-type (string.byte event-type)
        fields [...]
        field-count (# fields)
        field-array (doubles field-count)]
    (for [i 1 field-count]
      (tset field-array (- i 1) (. fields i)))
    (cs.csoundScoreEventAsync self.cs ev-type field-array field-count)))

(method csound:output-buffer-size
   []
   (cs.csoundGetOutputBufferSize self.cs))

(method csound:output-buffer
   []
   (cs.csoundGetOutputBuffer self.cs))

csound
