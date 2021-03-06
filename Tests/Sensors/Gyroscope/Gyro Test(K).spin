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
  
   long n
OBJ
   s : "Parallax Serial Terminal"
   g : "Kalman_Gyro"
PUB Main
  s.start(31250)
  g.start_gyro
  waitcnt(clkfreq*2+cnt)
  repeat
    s.home
    n += g.getz
    s.dec(n/11400)   