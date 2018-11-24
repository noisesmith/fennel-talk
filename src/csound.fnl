(local ffi (require :ffi))
(local cs (require :csound_raw))
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
   (var return-value 0)
   (var option nil)
   (each [_ opt (ipairs [...])]
         (let [ret (: self :set-option opt)]
           (set option opt)
           (when (not (= ret 0))
             (set return-value ret)
             (break))))
   (values return-value option))

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

csound
