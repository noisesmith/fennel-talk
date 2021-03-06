(require-macros :macros/util)
(local util (require :util))
(local lu (require :luaunit))
(local csound (require :csound))

(global all {})

(fn all.setUp
  [self])

(local orc
"chn_k \"cps-left\", 3
 chn_k \"cps-right\", 3

 instr 1
  kcpsl chnget \"cps-left\"
  kcpsr chnget \"cps-right\"
  al linen oscili(p4,kcpsl,1), 0.1, p3, 0.1
  ar linen oscili(p4,kcpsr,1), 0.1, p3, 0.1
  outs al, ar
 endin
")

(local table-size 32768)

;; creates a simple sco that runs for a given number of seconds
(fn mk-sco [table-size seconds]
  (.. "f1 0 " table-size " 10 1" "\n"
   "i1 0 " seconds " 10000"))

(fn wobble
  [n factor]
  (let [;; get a fraction from -1 .. 1
        raw (- (* (math.random) 2) 1)
        ;; get a curved distribution, preserving sign
        curved (* raw raw raw)
        value (* curved factor)]
    (+ n value)))

(fn test-buffer
  [cs]
  (let [buf (: cs :output-buffer)
        size (: cs :output-buffer-size)
        found (util.find-nonzero buf (- size 1) 0)]
    ;; (print "buffer of size" size "has non-zero at position" found)
    (is found
        "buffer needs to contain non-zero samples")))

(fn test-perform
  [cs iteration-count]
  (var cpsl 440)
  (var cpsr 440)
  (for [i 0 iteration-count]
    (set cpsl (wobble cpsl 10))
    (set cpsr (wobble cpsr 10))
    (: cs :set-control-channel :cps-left cpsl)
    (: cs :set-control-channel :cps-right cpsr)
    (is (= (: cs :perform-ksmps)
           0)
        "success from performance cycle")
    (when (= 0 (% i 1000))
      (: cs :table-update 1 (fn [x] (wobble x 0.01)))))
  (test-buffer cs)
  (is (= nil
         (: cs :score-event "e" 0))))

(fn all.test-synth
  [self]
  (let [duration 5
        cs (csound.new 0)
        _ (lu.assertUserdata cs.cs)
        (res final) (: cs :set-opts "-d" "--nchnls=2" "-m0")
        _ (is (= res 0) "success from setting opts")
        _ (is (= final "-m0") (.. "last opt processed is returned: " final))
        res (: cs :start)
        _ (is (= res 0) "success from start")
        res (: cs :compile-orc orc)
        _ (is (= res 0) "success from compiling")
        result (: cs :read-score (mk-sco table-size duration))
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
    (test-perform cs iteration-count)
    (let [#messages (: cs :get-message-cnt)
          messages (: cs :messages)]
      (is (= #messages (# messages))
          "we get all the messages reported")
      (each [_ s (ipairs messages)]
            ;; (print "MESSAGE:" s)
            (is (=  (type s) :string)
                "each message is what we expect it is")))
    (let [result (: cs :cleanup)]
      (: cs :destroy)
      (is (= result 0)
          "success from cleanup")
      result)))

(fn generic-setup
  [duration]
  (let [cs (csound.new 0)]
    (: cs :set-opts "-d" "--nchnls=2" "-m0")
    (: cs :start)
    (: cs :compile-orc orc)
    (: cs :read-score (mk-sco table-size duration))
    cs))

(fn generic-shutdown
  [cs]
  (: cs :cleanup)
  (: cs :destroy))

(fn all.test-event
  [self]
  ;; long running csound...
  (let [cs (generic-setup 10000)]
    ;; make csound exit early
    (is (= nil
           (: cs :score-event "e" 0)))
    ;; one perfomance cycle, so the "e" event runs
    (: cs :perform-ksmps)
    (let [ret (: cs :perform-ksmps)]
      (is (= ret 2)
          (.. "early exit, nonzero from performance cycle: " ret)))
    (generic-shutdown cs)))

(fn all.test-table-copy
  [self]
  ;; table copy out
  (let [cs (generic-setup 10)
        data (cs.doubles table-size)]
    ;; init pass
    (: cs :perform-ksmps)
    (is (not (util.find-nonzero data (- table-size 1) 0))
        "before copying the table, the array contents are all zeroes")
    (is (= nil
           (: cs :table-copy-out 1 data))
        "can copy an ftable to an array without error")
    (is (util.find-nonzero data (- table-size 1) 0)
        "after copying the table, the contents of the array are nonzero")
    (generic-shutdown cs))
  ;; table copy in
  (let [cs (generic-setup 10)
        data (cs.doubles table-size)]
    (is (not
           (util.find-nonzero data (- table-size 1) 0))
        "before copying the table, the array contents are all zeroes")
    ;; init pass
    (: cs :perform-ksmps)
    (is (= nil
           (: cs :table-copy-in 1 data))
        "can copy an array to an ftable without error")
    (is (do
          (tset data 0 42)
          (util.find-nonzero data (- table-size 1) 0))
         "can put non-zero contents into the array by hand")
    (is  (not
            (do
             (: cs :table-copy-out 1 data)
             (util.find-nonzero data (- table-size 1) 0)))
        "after copying the table to the array, the contents of the array are zero again")
    (generic-shutdown cs)))

;; TODO - why is this broken? - in a fennel repl doing this causes a segfault
;; (fn all.test-bad-opt
;;  [self]
;;  (let [cs (csound.new)
;;        bad-arg "--adsflsdfsd"
;;        (ret arg) (: cs :set-opts "-d" bad-arg "-m0")]
;;    (is (not (= 0 ret))
;;        (.. "non zero return when bad option provided: " ret))
;;    (is (= arg bad-arg)
;;        (.. "last arg processed is returned:"
;;            bad-arg "vs" arg))))

(local runner (lu.LuaUnit.new))
(: runner :setOutputType :tap)

(os.exit (: runner :runSuite))
