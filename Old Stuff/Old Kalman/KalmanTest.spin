{{
┌─────────────────────────────────────┬────────────────────────┬───────┬───────┐
│KalmanTest.spin                      │    Michael Langford    │9/26/15│Vs. 0.0│
├─────────────────────────────────────┴────────────────────────┴───────┴───────┤
│A working Kalman Filter in a console test wrapper.                            │
└──────────────────────────────────────────────────────────────────────────────┘

}}
CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

OBJ
  pst : "Parallax Serial Terminal"
  kf : "2DKalman_Filter_Object"
  fs :"FloatString"
  fm : "FloatMath"
  
PUB Main | va, vb
    kf.Start_Kalman_Filter
    pst.start(31250)

    repeat
        pst.str(string("Enter Acc angle", 13))
        va := pst.decin
        pst.str(string("Enter gyro rate", 13))
        vb := pst.decin

        pst.str(string("Kalman Filtered Angle: "))
        pst.str(fs.floattostring( kf.KalmanFilter(fm.ffloat(va), fm.ffloat(vb)) ))
        pst.newline
