(require-macros :macros/util)
(local ffi (require :ffi))
(local lume (require :lume))

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

(fn last
  [coll]
  (when coll
    (. coll (# coll))))

(fn butlast
  [coll]
  (when coll
    (tset coll (# coll) nil)
    coll))

(fn comp
  [...]
  (let [fns [...]
        composer (fn composer [x functions]
                   (if-let [f (last functions)]
                     (composer (f x) (butlast functions))
                     x))]
    (fn [x]
      (composer x (lume.clone fns)))))

(fn comp+
  [...]
  (let [fns [...]]
    (fn [x]
      (var res x)
      (each [_ f (lume.ripairs fns)]
            (set res (f res)))
      res)))

(fn find-nonzero
  [array size index]
  (if (> index size)
    nil
    (not (zero? (. array index)))
    index
    (find-nonzero array size (+ index 1))))

{:pks pks
 :boolean boolean
 :null? null?
 :zero? zero?
 :str str
 :last last
 :butlast butlast
 :comp comp+
 :find-nonzero find-nonzero}
