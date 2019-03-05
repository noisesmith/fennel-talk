(require-macros :macros/util)
(local lu (require :luaunit))
(local audio-process (require :audio-process))

(global all {})

(method all:setUp
  [])

(method all:test-processing
  []
  (let [ap (: (audio-process.new) :init-engine)
        b (cs.doubles ap.table-size)]
    ;; run the synth
    ;; test the output buffer - should be all zeroes
    ;; fill b with data
    ;; run the synth
    ;; test the output buffer - should be nonzero
    ))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
