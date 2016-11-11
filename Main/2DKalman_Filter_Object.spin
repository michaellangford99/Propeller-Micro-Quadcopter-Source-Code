{{
 ┌──────────────────────────────┬──────┬──────────────────────┬───────┬──────────┐
 │ 2DKalman_Filter_Object.spin  │ 2015 │ Michael J. Langford  │Vs. 5.3│10/29/2015│
 ├──────────────────────────────┴──────┴──────────────────────┴───────┴──────────┤
 │ Basic 2D Kalman filter object, taking accelerometer angle(f) and gyro rate(f).│
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
 long Q_angle
 long Q_gyro
 long R_angle
 long y_bias
 long YP_00, YP_01, YP_10, YP_11
 long KFangleY 
   
OBJ

fm : "FloatMath"

Pub Start_Kalman_Filter  
    Q_angle := 0.045
    Q_gyro  := 0.0003
    R_angle := 0.007
    
    YP_00 := 0.0
    YP_01 := 0.0
    YP_10 := 0.0
    YP_11 := 0.0
    KFangleY := 0.0
    
'Pub Start_Kalman_Set_Const()
PUB Kalman_Filter(accAngle, gyroRate) | y, s, K_0, K_1

  y := s := 0.0
  K_0 := K_1 := 0.0
  KFangleY := fm.Fadd(KFangley, fm.Fsub(gyroRate, y_bias))    
  YP_00 := fm.fadd(YP_00, fm.fadd(fm.fmul(-1.0, fm.fadd(YP_10, YP_01)), Q_angle))
  YP_01 := fm.fadd(YP_01, fm.fmul(-1.0, YP_11))
  YP_10 := fm.fadd(YP_10, fm.fmul(-1.0, YP_11)) 
  YP_11 := fm.fadd(YP_11, Q_gyro)  
  y := fm.fsub(accAngle, KFangleY)
  s := fm.fadd(YP_00, R_angle)  
  K_0 := fm.fdiv(YP_00, s) 
  K_1 := fm.fdiv(YP_10, s)  
  KFangleY := fm.fadd(KFangleY, fm.fmul(K_0, y))
  y_bias := fm.fadd(y_bias, fm.fmul(K_1, y))
  YP_00 := fm.fsub(YP_00, fm.fmul(K_0, YP_00))
  YP_01 := fm.fsub(YP_01, fm.fmul(K_0, YP_01))
  YP_10 := fm.fsub(YP_10, fm.fmul(K_1, YP_00))
  YP_11 := fm.fsub(YP_11, fm.fmul(K_1, YP_01)) 
  
  return KFangleY
    