(require-macros :macros/util)
(local cs (require :csound))
(local lu (require :luaunit))
(local util (require :util))
(local audio-process (require :audio-process))

(global all {})

(method all:setUp
  [])

(fn find-nonzero-in-out
  [ap]
  (let [size (: ap.cs :output-buffer-size)
        out-buf (: ap.cs :output-buffer)]
      (util.find-nonzero out-buf (- size 1) 0)))

(fn mk-ap-with-buf
  []
  "returns a buffer with the right size for the output and initialized audio-process"
  (let [ap (: (audio-process.new) :init-engine)
        b (cs.doubles ap.table-size)]
    (: ap.cs :perform-ksmps)
    ;; run the synth on table 1 (empty)
    {:ap ap
     :b b}))

(fn play-table-1
  [ap]
  (: ap :play-table
     {:dur 1
      :table 1
      :amp 1})
  (: ap.cs :perform-ksmps))

(fn find-nonzero-in-table
  [cs tab idx-max idx]
  ; (print "find-nonzero-in-table" idx (: cs :table-get tab idx))
  (if (not idx)
    (find-nonzero-in-table cs tab idx-max 0)
    (>= idx idx-max)
    false
    (not (util.zero? (: cs :table-get tab idx)))
    true
    :else
    (find-nonzero-in-table cs tab idx-max (+ idx 1))))

(method all:test-processing
  []
  (let [ctx (mk-ap-with-buf)]
    (play-table-1 ctx.ap)
    (is (= nil
           (find-nonzero-in-out ctx.ap))))
   (let [ctx (mk-ap-with-buf)]
    (for [i 0 ctx.ap.table-size]
      (tset ctx.b i (math.sin i)))
    (is (util.find-nonzero ctx.b
                           (- ctx.ap.table-size 1)
                           0)
        "must find non-zero contents in the buffer")
    (: ctx.ap.cs :table-copy-in 1 ctx.b)
    (is (find-nonzero-in-table ctx.ap.cs 1 ctx.ap.table-size)
        "must find non-zero contents in the table")
    (play-table-1 ctx.ap)
    ;; TODO - this should pass, the instrument or score statement is broken
    (comment
    (is (find-nonzero-in-out ctx.ap)
        "with table contents, there should be a nonzero output"))))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
