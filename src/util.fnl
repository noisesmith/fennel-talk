(local ffi (require :ffi))

(ffi.cdef '
  int printf(const char *fmt, ...);
')

(fn pks [t spl]
  (let [splitter (or spl "\n")]
    (each [k v (pairs t)]
          (ffi.C.printf "%s%s" k splitter))
    (print)))

{:pks pks}
