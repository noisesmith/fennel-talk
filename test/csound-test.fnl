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
        print-messages 0
        cs (csound.new)
        _ (lu.assertUserdata cs.cs)
        (res final) (: cs :set-opts "-d" "-m0")
        _ (is (= res 0) "success from setting opts")
        _ (is (= final "-m0") "last opt processed is returned")
        res (: cs :start)
        _ (is (= res 0) "success from start")
        res (: cs :compile-orc orc)
        _ (is (= res 0) "success from compiling")
        result (: cs :read-score (mk-sco duration))
        _ (is (= res 0) "success from reading the score")
        sr (: cs :get-sr)
        ksmps (: cs :get-ksmps)
        kr (: cs :get-kr)
        iteration-count (/ (* duration sr) ksmps)]
    (is (not (= (: cs :get-message-cnt) 0))
        "expect messages at this point")
    (let [first-message (: cs :get-first-message)]
      (is (= :string (type first-message))
          (.. "expect string, got " (type first-message))))
    (let [#message1 (: cs :get-message-cnt)
          _ (: cs :pop-first-message)
          #message2 (: cs :get-message-cnt)]
      (is (= #message2 (- #message1 1))
          "pop removes the first message"))
    (is (= sr 44100))
    (is (= ksmps (/ sr kr)))
    (is (= iteration-count (* duration kr)))
    (for [i 0 iteration-count]
      (is (= (: cs :perform-ksmps)
             0)
          "success from performance cycle"))
    (let [#messages (: cs :get-message-cnt)
          messages (: cs :messages)]
      (is (= #messages (# messages))
          "we get all the messages reported")
      (each [_ s (ipairs messages)]
            (is (=  (type s) :string)
                "each message is what we expect it is")))
    (let [result (: cs :cleanup)]
      (: cs :destroy)
      (is (= result 0)
          "success from cleanup")
      result)))

(fn all.bad-opt
  [self]
  (let [cs (csound.new)
        bad-arg "-adsflsdfsd"
        (ret arg) (: cs :set-opts "-d" bad-arg "-m0")]
    (is (not (= 0 ret))
        "non zero return when bad option provided")
    (is (= arg bad-arg)
        "last arg processed is returned, stopped at the bad one")))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
