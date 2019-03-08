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

(method all:test-processing
  []
  (let [ctx (mk-ap-with-buf)]
    (play-table-1 ctx.ap)
    (is (= nil
           (find-nonzero-in-out ctx.ap))))
   (let [ctx (mk-ap-with-buf)]
    (for [i 0 ctx.ap.table-size]
      (tset ctx.b i (math.sin i)))
    (: ctx.ap.cs :table-copy-in 1 ctx.b)
    (play-table-1 ctx.ap)
    (is (find-nonzero-in-out ctx.ap)
        "with table contents, there should be a nonzero output")))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
