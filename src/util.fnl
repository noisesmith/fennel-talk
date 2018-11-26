(local ffi (require :ffi))

(ffi.cdef '
  int printf(const char *fmt, ...);
')

(fn pks [t spl]
  (let [splitter (or spl "\n")]
    (each [k v (pairs t)]
          (ffi.C.printf "%s%s" k splitter))
    (print)))

(fn boolean
  [x]
  (not (not x)))

(fn null?
  [x]
  (= x nil))

(fn zero?
  [x]
  (= x 0))

(fn str
  [x]
  (if (null? x)
    "nil"
    (.. "" x)))

{:pks pks
 :boolean boolean
 :null? null?
 :zero? zero?
 :str str}
