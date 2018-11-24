(local lu (require :luaunit))
(local csound (require :csound))

(global all {})

(fn all.setUp
  [self])

(local orc
"instr 1
  out(linen(oscili(p4,p5),0.1,p3,0.1))
 endin
")

;; creates a simple sco that runs for a given number of seconds
(fn mk-sco [seconds]
  (.. "i1 0 " seconds " 2000 440"))

(local is lu.assertTrue)

(fn all.test-synth
  [self]
  (let [duration 5
        cs (csound.csound.new)
        _ (lu.assertUserdata cs.cs)
        res (: cs :set-option "-d")
        _ (is (= res 0))
        res (: cs :set-option "-m0")
        _ (is (= res 0))
        res (: cs :start)
        _ (is (= res 0))
        res (: cs :compile-orc orc)
        _ (is (= res 0))
        result (: cs :read-score (mk-sco duration))
        _ (is (= res 0))
        sr (: cs :get-sr)
        ksmps (: cs :get-ksmps)
        kr (: cs :get-kr)
        iteration-count (/ (* duration sr) ksmps)]
    (is (= sr 44100))
    (is (= ksmps (/ sr kr)))
    (is (= iteration-count (* duration kr)))
    (for [i 0 iteration-count]
      (is (= (: cs :perform-ksmps)
             0)))
    (let [result (: cs :cleanup)]
      (: cs :destroy)
      (is (= result 0))
      result)))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
