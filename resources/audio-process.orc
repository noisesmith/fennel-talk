nchnls = 2

;; global phase, goes from 0-1 each k cycle
  instr 1
aphase phasor kr
gaphase = aphase*ksmps
  endin

  instr 2
iins, istart, idur, ioffs, iamp, icurve, i_ passign
itab = p7
kpos init ioffs*kr
apos = kpos+gaphase
asig tab apos, itab
     kcurve linen iamp, icurve, idur, icurve
aout = asig*ampdbfs(kcurve-96)*0dbfs
     outs aout, aout
kpos = kpos+ksmps
  endin
