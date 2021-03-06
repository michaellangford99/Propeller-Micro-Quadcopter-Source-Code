{{
┌─────────────────────────────────────┬────────────────────────┬──────┬────────┐
│                                     │                        │      │        │
├─────────────────────────────────────┴────────────────────────┴──────┴────────┤
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

}}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
 long x, p, q, k, r, m, stack[200] 
   
OBJ
  pst : "Parallax Serial Terminal"
  fm : "FloatMath"
  g : "Gtest"
  
PUB Main
  pst.start(31250)
  g.startup
  x := 0.0
  p:= 1.0
  q:= 1.0
  k:= 1.0
  r:= 1.0
  cognew(gyro, @stack[100])
  repeat
   p := fm.fadd(p,q)
    k := fm.fdiv(p, fm.fadd(p, r))
    x := fm.fadd(x, fm.fmul(k, fm.fsub(m, x)))
    p := fm.fmul(fm.fsub(1, k), p)

    pst.charin
    
    pst.dec(fm.fround(x)/11400)
    pst.newline
    pst.dec(g.getx/11400)  
    pst.newline
    pst.dec(0)
    pst.newline
    


PUB gyro

    repeat
      g.main
      m := fm.ffloat(g.getx)
    