(local ffi (require :ffi))
(local cs (ffi.load :libcsound64))
(require-macros 'macros.util')

(ffi.cdef '
  void* csoundCreate(void *hostData);
  int csoundStart(void *csound);
  int csoundCompileOrc(void *csound, const char *str);
  int csoundReadScore(void *csound, const char *str);
  int csoundPerformKsmps(void *csound);
  int csoundCleanup(void *csound);
  double csoundGetKr(void *csound);
  double csoundGetSr(void *csound);
  int csoundSetOption(void *csound, const char *option);
  uint32_t csoundGetKsmps(void *csound);
  void csoundReset(void *csound);
  void csoundDestroy(void *csound);
  void csoundCreateMessageBuffer(void *csound, int toStdOut);
  int csoundGetMessageCnt(void *csound);
  const char* csoundGetFirstMessage(void *csound);
  void csoundPopFirstMessage(void *csound);
')

(local csound {})

(fn csound.new [buffer]
  (let [buffer-arg (or buffer 0)
        self {:cs (cs.csoundCreate 0)
              :csound-library cs}]
    (setmetatable self {:__index csound})
    (: self :create-message-buffer buffer-arg)
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
