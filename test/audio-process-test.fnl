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

(method all:test-processing
  []
  (let [ap (: (audio-process.new) :init-engine)
        b (cs.doubles ap.table-size)]
    ;; run the synth on table 1 (empty)
    (: ap :play-table
       {:dur 1
        :table 1})
    (: ap.cs :perform-ksmps)
    ;; test the output buffer - should be all zeroes
    (is (= nil
           (find-nonzero-in-out ap)))
    ;; fill b with data, transfer to table 1
    (for [i 0 ap.table-size]
      (tset b i (math.sin i)))
    (: ap.cs :table-copy-out 1 b)
    ;; run the synth
    (: ap.cs :perform-ksmps)
    ;; test the output buffer - should be nonzero
    ;; TODO - failing test
    (is (find-nonzero-in-out ap))))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
