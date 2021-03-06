{{
  
 ┌──────────────────────────────┬──────┬──────────────────────┬────────┬─────────┐
 │ (name).spin                  │(year)│ Michael J. Langford  │ (vs.)  │  (date) │
 ├──────────────────────────────┴──────┴──────────────────────┴────────┴─────────┤
 │ ...                                                                           │ 
 │                                                                               │
 │                                                                               │
 │                                                                               │
 │                                                                               │
 │                                                                               │
 │                                                                               │
 └───────────────────────────────────────────────────────────────────────────────┘

  
   prop1    prop2
     |        |
  [][] front [][]
  [][]   |   [][]        
      \  |  /                                
      {[[[]]}-----microcontoller
      {[[[]]}
      /     \
  [][]       [][]
  [][]       [][]
    |           |
   prop3      prop4
}}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        xoffset = 0
        yoffset = 0

        FULL_CIRCLE = 360    
        
VAR

    LONG Gyro_X, Gyro_Y, Gyro_Z     'theta from gyro

    
    LONG Acc_X, Acc_Y, Acc_Z        'raw data
    LONG Acc_A_X, Acc_A_Y, Acc_A_Z  'theta from acc

    LONG CF_X, CF_Y, CF_Z           'comp. filtered uotput
    LONG TrueAccX, TrueAccY

    long stack[200], stack2[200]

    long a, b, c, d, e, f, g, h, i

    long gcog
    long ccog

OBJ  
    gyro  : "Gtest"    
    acc   : "Atest"   
                              
    fl : "FloatMath"
    
PUB Start

    dira[11]~~
    outa[11] := 0

    dira[7]~~
    outa[7] := 1
    
    gyro.startup
    acc.startup                              '1 cog
    gcog := Cognew(GyroScope, @stack)   '1 cog
    ccog := Cognew(Main, @stack2)        '1 cog

PUB Stop
    
    acc.stop
    cogstop(gcog)
    cogstop(ccog)
    
PUB Main
   repeat     
        Accelerometer

        
 {roll} CF_X := fl.fround(fl.FAdd(fl.FMul(0.0, fl.FFloat(Gyro_X)), fl.FMul(1.0, fl.FFloat(Acc_A_X))))
{pitch} CF_Y := fl.fround(fl.FAdd(fl.FMul(0.0, fl.FFloat(Gyro_Y)), fl.FMul(1.0, fl.FFloat(Acc_A_Y))))
 {yaw}  CF_Z := Gyro_Z
        
        
PUB GyroScope
     repeat
        'waitcnt(clkfreq/230 +cnt)
        gyro.Main
        
        a:= b
        b := c
        c := gyro.getx
        Gyro_X := (a+(2*b)+c)/400 
        
        d := e
        e := f
        f := gyro.gety 
        Gyro_Y := (d+(2*e)+f)/400

        g := h
        h := i
        i := gyro.getz
        Gyro_Z := (g+(2*h)+i)/400       
        

PUB Accelerometer 
        
        acc.Main

        Acc_Y := fl.fround(fl.fmul(fl.fdiv(fl.fsub(fl.ffloat(acc.GetX), 3.6), 61.0), 71.0))
        
        Acc_X := acc.GetY
        Acc_Z := acc.GetZ

        Acc_A_X := atan2(Acc_X, Acc_Z)     'possibly subtract 11 from Z axis 
        Acc_A_Y := atan2(Acc_Y, Acc_Z)

        if Acc_A_X > 180
            Acc_A_X -= 360
            
        if Acc_A_Y > 180
            Acc_A_Y -= 360
            
        {    
        if Acc_X < 0

            if Acc_Z-11 < 0
                 Acc_A_X := floatstuff.FNeg(floatstuff.FAdd(90.01, floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(-(Acc_Z-11), 63), floatstuff.FDiv(-Acc_X, 63)))))                                                                                
                 
            if Acc_Z-11 > 0
                 Acc_A_X := floatstuff.FNeg(floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(-Acc_X, 63), floatstuff.FDiv(Acc_Z-11, 63))))
                 
        if Acc_X > 0


            if Acc_Z-11 < 0
                 Acc_A_X := floatstuff.FAdd(90.01, floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(-(Acc_Z-11), 63), floatstuff.FDiv(Acc_X, 63))))                                                                                       
                 
            if Acc_Z-11 > 0
                 Acc_A_X :=  floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(Acc_X, 63), floatstuff.FDiv(Acc_Z-11, 63)))
                 
        '=============================================================================================================================================
        if Acc_Y < 0

            if Acc_Z-11 < 0
                 Acc_A_Y := floatstuff.FNeg(floatstuff.FAdd(90.01, floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(-(Acc_Z-11), 63), floatstuff.FDiv(-Acc_Y, 63)))))                                                                                
                 
            if Acc_Z-11 > 0
                 Acc_A_Y := floatstuff.FNeg(floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(-Acc_Y, 63), floatstuff.FDiv(Acc_Z-11, 63))))
                 
        if Acc_Y > 0


            if Acc_Z-11 < 0
                 Acc_A_Y := floatstuff.FAdd(90.01, floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(-(Acc_Z-11), 63), floatstuff.FDiv(Acc_Y, 63))))                                                                                       
                 
            if Acc_Z-11 > 0
                 Acc_A_Y :=  floatstuff.Degrees(floatstuff.ATan2(floatstuff.FDiv(Acc_Y, 63), floatstuff.FDiv(Acc_Z-11, 63)))
        'goes up top  
        'a := b
        'b := c
        'c := TrueAccX
        'TrueAccX := switch.Fround(Floatstuff.Fmul(Floatstuff.Fsub(Floatstuff.FDiv(switch.FFloat(Acc_X), switch.FFloat(63)), Floatstuff.Sin(Floatstuff.Radians(switch.FFloat(Gyro_X)))), switch.FFloat(63)))
        'TrueAccX := (TrueAccX+a+b+c)/4

        
        'd := e
        'e := f
        'f := TrueAccY
        'TrueAccY := switch.Fround(Floatstuff.Fmul(Floatstuff.Fsub(Floatstuff.FDiv(switch.FFloat(Acc_Y), switch.FFloat(63)), Floatstuff.Sin(Floatstuff.Radians(switch.FFloat(Gyro_Y)))), switch.FFloat(63)))
        'TrueAccY := (TrueAccY+d+e+f)/4
        } 
PUB GetGyroRaw(Axis)

    case Axis
       1 : return Acc_A_X
       2 : return Acc_A_Y
       3 : return Gyro_Z

PUB GetAccRaw(Axis)

    case Axis
       1 : return TrueAccX + xoffset
       2 : return TrueAccY + yoffset
       3 : return Acc_Z

PUB GetComp_Filter_Output(Axis)

    case Axis
       1 : return CF_X
       2 : return CF_Y
       3 : return CF_Z

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
          