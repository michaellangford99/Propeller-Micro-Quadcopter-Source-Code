{{
 ┌──────────────────────────────┬──────┬──────────────────────┬───────┬──────────┐
 │ 1DKalman_Filter_Object.spin  │ 2015 │ Michael J. Langford  │Vs. 0.1│10/29/2015│
 ├──────────────────────────────┴──────┴──────────────────────┴───────┴──────────┤
 │ Basic 1D Kalman filter object, taking gyro rate(f) and returning int. angle.  │
 └───────────────────────────────────────────────────────────────────────────────┘
  
   prop1    prop2                  
     |        |
  [][] front [][]               
  [][]   |   [][]        
      \  |  /                                
      {[[[]]}-----microcontroller
      {[[[]]}
      /     \
  [][]       [][]
  [][]       [][]
    |          |
   prop3      prop4
}}
VAR
 long x, p, q, k, r, m
 
OBJ 
  fm : "FloatMath"
  
PUB Start_Kalman_Filter
  x := 0.0
  p:= 1.0
  q:= 1.0
  k:= 1.0
  r:= 1.0
  
Pub Kalman_Filter(gyro_rate)
    m := gyro_rate
    p := fm.fadd(p,q)
    k := fm.fdiv(p, fm.fadd(p, r))
    x := fm.fadd(x, fm.fmul(k, fm.fsub(m, x)))
    p := fm.fmul(fm.fsub(1, k), p)

    return x   