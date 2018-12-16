(require-macros :macros/util)
(local csound (require :csound))


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

;; creates a simple sco that runs for a given number of seconds
(fn mk-sco [seconds]
  (.. "f1 0 32768 10 1" "\n"
   "i1 0 " seconds " 10000"))

(fn wobble
  [n factor]
  (let [;; get a fraction from -1 .. 1
        raw (- (* (math.random) 2) 1)
        ;; get a curved distribution, preserving sign
        curved (* raw raw raw)
        value (* curved factor)]
    (+ n value)))

(fn setup-csound
  [duration]
  (let [cs (csound.new 0)]
    (assert (= 0 (: cs :set-opts "-d" "--nchnls=2" "-m0")))
    (assert (= 0 (: cs :start)))
    (assert (= 0 (: cs :compile-orc orc)))
    (assert (= 0 (: cs :read-score (mk-sco duration))))
    cs))

(fn composition
  [duration]
  (let [cs (setup-csound duration)
        kr (: cs :get-kr)
        iteration-count (* duration kr)]
    (var [wobble-factor cpsl cpsr] [3 440 440])
    (for [i 0 iteration-count]
      (set wobble-factor (wobble wobble-factor 3))
      (set cpsl (wobble cpsl wobble-factor))
      (set cpsr (wobble cpsr wobble-factor))
      (: cs :set-control-channel :cps-left cpsl)
      (: cs :set-control-channel :cps-right cpsr)
      (assert (= 0 (: cs :perform-ksmps))))
    (assert (= 0 (: cs :cleanup)))
    (: cs :destroy)))
