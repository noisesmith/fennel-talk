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
')

(local csound {})

(fn csound.new []
  (let [self {:cs (cs.csoundCreate 0)}]
    (setmetatable self {:__index csound})))

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

{:csound csound
 :cs cs}
