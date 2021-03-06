{{
  
 ┌──────────────────────────────┬──────┬──────────────────────┬────────┬─────────┐
 │ Kalman_Filter.spin           │ 2015 │ Michael J. Langford  │Vs. 0.0 │ 9/27/15 │
 ├──────────────────────────────┴──────┴──────────────────────┴────────┴─────────┤
 │Main sensor program, polls gyro and acc and uses Kalman filter to get output.  │
 └───────────────────────────────────────────────────────────────────────────────┘
}}
CON    
  FULL_CIRCLE = 360    
        
VAR

    LONG Gyro_X, Gyro_Y, Gyro_Z     'theta from gyro  
    LONG Acc_X, Acc_Y, Acc_Z        'raw data
    LONG Acc_A_X, Acc_A_Y, Acc_A_Z  'theta from acc

    LONG KF_X, KF_Y, KF_Z           'Kalman filtered output

    long stack2[200]
    long kcog

    long Q_angleX, Q_angleY
    long Q_gyroX, Q_gyroY
    long R_angleX, R_angleY
    long x_bias, Y_bias
    long XP_00, XP_01, XP_10, XP_11
    long YP_00, YP_01, YP_10, YP_11
    long KFangleX, KFangleY 
  
OBJ  
    gyro  : "Gtest"    
    acc   : "Atest"   
                              
    fm : "FloatMath"
    
PUB Start
      
    Q_angleX := 0.01
    Q_gyroX  := 0.0003
    R_angleX := 0.01
    XP_00 := 0.0
    XP_01 := 0.0
    XP_10 := 0.0
    XP_11 := 0.0
    KFangleX := 0.0

      
    Q_anglex := 0.01
    Q_gyrox  := 0.0003
    R_anglex := 0.01
    YP_00 := 0.0
    YP_01 := 0.0
    YP_10 := 0.0
    YP_11 := 0.0
    KFangleY := 0.0
    dira[11]~~
    outa[11] := 0  
    dira[7]~~
    outa[7] := 1
    
    gyro.startup
    acc.startup                          '1 cog
    kcog := Cognew(Main, @stack2)        '1 cog

PUB Stop
    
    acc.stop     
    cogstop(kcog)
    
PUB Main
   repeat
        'get angles     
        Accelerometer
        
        gyro.Main
        Gyro_X := gyro.getfx 
        Gyro_Y := gyro.getfy
        Gyro_Z := gyro.getz

        'kalman filter angles
        KalmanFilter(Acc_A_X, Gyro_X, Acc_A_Y, Gyro_Y) 
        '
PUB KalmanFilter(accAngleX, gyroRateX, accAngleY, gyroRateY) | yy, ys, yK_0, yK_1, xy, xs, xK_0, xK_1

  xy := xs := 0.0
  xK_0 := xK_1 := 0.0
  KFangleX := fm.Fadd(KFangleX, fm.Fsub(gyroRatex, x_bias))
  XP_00 := fm.fadd(XP_00, fm.fadd(fm.fmul(-1.0, fm.fadd(XP_10, XP_01)), Q_anglex)) 
  XP_01 := fm.fadd(XP_01, fm.fmul(-1.0, XP_11))
  XP_10 := fm.fadd(XP_10, fm.fmul(-1.0, XP_11))
  XP_11 := fm.fadd(XP_11, Q_gyrox)
  xy := fm.fsub(accAnglex, KFanglex)
  xs := fm.fadd(XP_00, R_anglex)
  xK_0 := fm.fdiv(XP_00, xs)
  xK_1 := fm.fdiv(XP_10, xs)
  KFangleX := fm.fadd(KFangleX, fm.fmul(xK_0, xy))
  x_bias := fm.fadd(x_bias, fm.fmul(xK_1, xy))
  xP_00 := fm.fsub(xP_00, fm.fmul(xK_0, xP_00))
  xP_01 := fm.fsub(xP_01, fm.fmul(xK_0, xP_01))
  xP_10 := fm.fsub(xP_10, fm.fmul(xK_1, xP_00))
  xP_11 := fm.fsub(xP_11, fm.fmul(xK_1, xP_01))
  '===========y============
  yy := ys := 0.0
  yK_0 := yK_1 := 0.0
  KFangley := fm.Fadd(KFangley, fm.Fsub(gyroRatey, y_bias))
  yP_00 := fm.fadd(yP_00, fm.fadd(fm.fmul(-1.0, fm.fadd(yP_10, yP_01)), Q_angley)) 
  yP_01 := fm.fadd(yP_01, fm.fmul(-1.0, yP_11))
  yP_10 := fm.fadd(yP_10, fm.fmul(-1.0, yP_11))
  yP_11 := fm.fadd(yP_11, Q_gyroy)
  yy := fm.fsub(accAngley, KFangley)
  ys := fm.fadd(yP_00, R_angley)
  yK_0 := fm.fdiv(yP_00, ys)
  yK_1 := fm.fdiv(yP_10, ys)
  KFangley := fm.fadd(KFangley, fm.fmul(yK_0, yy))
  y_bias := fm.fadd(y_bias, fm.fmul(yK_1, yy))
  yP_00 := fm.fsub(yP_00, fm.fmul(yK_0, yP_00))
  yP_01 := fm.fsub(yP_01, fm.fmul(yK_0, yP_01))
  yP_10 := fm.fsub(yP_10, fm.fmul(yK_1, yP_00))
  yP_11 := fm.fsub(yP_11, fm.fmul(yK_1, yP_01))

  KF_X := fm.fround(KFanglex)
  KF_Y := fm.fround(KFangley)
  KF_Z := (Gyro_Z++)/100
            
PUB Accelerometer 
        
        acc.Main

        Acc_Y := fm.fround(fm.fmul(fm.fdiv(fm.fsub(fm.ffloat(acc.GetX), 3.6), 61.0), 71.0))
        Acc_X := acc.GetY
        Acc_Z := acc.GetZ  
        Acc_A_X := atan2(Acc_X, Acc_Z)     'possibly subtract 11 from Z axis 
        Acc_A_Y := atan2(Acc_Y, Acc_Z)

        if Acc_A_X > 180
            Acc_A_X -= 360
            
        if Acc_A_Y > 180
            Acc_A_Y -= 360
        
PUB Get_Kalman_Filtered_Output(Axis)

    case Axis
       1 : return KF_X
       2 : return KF_Y
       3 : return KF_Z

PUB atan2(y, x) | arg, adder, n
{{
atan2 function from Phil Pilgrim
Propeller forums 5-7-2010
}}
'' Four-quadrant arctangent. Y and X are signed integers.
'' FULL_CIRCLE is an integer constant equal to the number of units in a full circle.
 
  if ((n := >|(||x <# ||y)) > 21)
    x ~>= n - 21
    y ~>= n - 21
  if (||x > ||y)                     
    arg := y << 10 / x
    adder := constant(FULL_CIRCLE / 2) & (x < 0)
  else
    arg := -x << 10 / y
    adder := constant(FULL_CIRCLE / 4) + constant(FULL_CIRCLE / 2) & (y < 0)
  result := arg * constant(FULL_CIRCLE * 14551 / 100000) / (936 + (arg * arg) >> 12) + adder
  result += FULL_CIRCLE & (result < 0)
          