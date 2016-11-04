{{  
 ┌─────────────────────────────┬──────┬──────────────────────┬────────┬──────────┐
 │ Sensors.spin                │ 2016 │ Michael J. Langford  │Vs. 0.5 │  7/5/16  │
 ├─────────────────────────────┴──────┴──────────────────────┴────────┴──────────┤
 │Main sensor program, polls gyro and acc and uses Kalman filter to get output.  │
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
CON    
    FULL_CIRCLE = 360
VAR
    long Gyro_Rate_X, Gyro_Rate_Y, Gyro_Rate_Z     'rate from gyro  
    long Acc_X, Acc_Y, Acc_Z        'raw data
    long Acc_A_X, Acc_A_Y, Acc_A_Z  'theta from acc

    long KF_Yaw, KF_Pitch, KF_Roll           'Kalman filtered output

    long stack[400]
       
OBJ
    'both return integer data     
    gyro : "Kalman_Gyro"  'returns integer rotational velocity in UN_unitized format 
    acc  : "Kalman_Acc"   'returns integer acceleration in calibrated format
   
    Kalman_Yaw   : "1DKalman_Filter_Object"  'takes float gyro rate
    Kalman_Pitch : "2DKalman_Filter_Object"  'takes float acc angle and float gyro rate 
    Kalman_Roll  : "2DKalman_Filter_Object"  'takes float acc angle and float gyro rate

    fm : "FloatMath"      'floating point math
  
PUB Start_Sensors

    gyro.Start_Gyro                         'no cog
    acc.Start_Acc                           '1  cog

    Kalman_Yaw.Start_Kalman_Filter          'no cog
    Kalman_Pitch.Start_Kalman_Filter        'no cog
    Kalman_Roll.Start_Kalman_Filter         'no cog

    cognew(Gyroscope, @stack)               '1  cog

Pub Stop_Sensors

    acc.stop     

Pub Update_Sensors

    Accelerometer 
    KF_Pitch := fm.fround(Kalman_Pitch.Kalman_Filter(fm.ffloat(Acc_A_Y), Gyro_Rate_Y))
    KF_Roll  := fm.fround(Kalman_Roll .Kalman_Filter(fm.ffloat(Acc_A_X), Gyro_Rate_X)) 
               
PUB Accelerometer 
        
    acc.Main

    Acc_Y := acc.GetX'fm.fround(fm.fmul(fm.fdiv(fm.fsub(fm.ffloat(acc.GetX), 3.6), 61.0), 71.0))
    Acc_X := acc.GetY
    Acc_Z := acc.GetZ  
    Acc_A_X := atan2(Acc_X, Acc_Z)     'possibly subtract 11 from Z axis 
    Acc_A_Y := atan2(Acc_Y, Acc_Z)

    if Acc_A_X > 180
      Acc_A_X -= 360
            
    if Acc_A_Y > 180
      Acc_A_Y -= 360

Pub Gyroscope
repeat
    gyro.Main
    Gyro_Rate_X := fm.fdiv(fm.ffloat(gyro.getx), 114.285)
    Gyro_Rate_Y := fm.fdiv(fm.ffloat(gyro.gety), 114.285)
    Gyro_Rate_Z := fm.fdiv(fm.ffloat(gyro.getz), 114.285)
    KF_Yaw   += fm.fround(Gyro_Rate_Z)
          
PUB Get_Kalman_Filtered_Output(Axis)

    case Axis
      1 : return KF_Yaw/100
      2 : return -KF_Pitch
      3 : return -KF_Roll

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
              