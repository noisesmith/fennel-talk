(local ffi (require :ffi))
(local cs (ffi.load :libcsound64))

(ffi.cdef '
  void* csoundCreate(void *hostData);

  int csoundStart(void *csound);

  int csoundCompileOrc(void* csound, const char* str);

  int csoundReadScore(void* csound, const char* str);

  int csoundPerformKsmps(void* csound);

  int csoundCleanup(void* csound);

  double csoundGetKr(void* csound);

  double csoundGetSr(void* csound);

  int csoundSetOption(void* csound, const char* option);

  uint32_t csoundGetKsmps(void* csound);

  void csoundReset(void* csound);

  void csoundDestroy(void* csound);

  void csoundCreateMessageBuffer(void* csound, int toStdOut);

  int csoundGetMessageCnt(void* csound);

  const char* csoundGetFirstMessage(void* csound);

  void csoundPopFirstMessage(void* csound);

  double csoundGetControlChannel(void* csound, const char* name, int* err);

  void csoundSetControlChannel(void* csound, const char* name, double v);

  int csoundTableLength(void* csound, int table);

  double csoundTableGet(void* csound, int table, int index);

  void csoundTableSet(void* csound, int table, int index, double value);

  void csoundTableCopyIn(void* csound, int table, double* src);

  void csoundTableCopyOut(void* csound, int table, double* dest);

  void csoundScoreEventAsync(void* csound, char type, double* pFields, long numFields);

  long csoundGetOutputBufferSize(void* csound);

  double* csoundGetOutputBuffer(void* csound);
')

cs
