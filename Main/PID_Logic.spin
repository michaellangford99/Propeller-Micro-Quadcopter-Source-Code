{{  
 ┌─────────────────────────────┬──────┬──────────────────────┬────────┬──────────┐
 │ PID_Logic.spin              │ 2016 │ Michael J. Langford  │Vs. 5.2 │ 6/15/16  │
 ├─────────────────────────────┴──────┴──────────────────────┴────────┴──────────┤
 │Main pid control code, uses target angles & sensors data to return motor outs. │
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


   TARGET_ALTITUDE_HIGH = 198
   TARGET_ALTITUDE_LOW = 192

   YAW_CONSTANT = 1 
   PITCH_CONSTANT = 1
   ROLL_CONSTANT = 1

   MAX_THROTTLE = 200
   MIN_THROTTLE = 0

   M1CONST = 0
   M2CONST = 0
   M3CONST = 0
   M4CONST = 0
   
                                                                          
   '==================PID LOOP CONSTANTS===================================
   PCONSTANT_YAW      = 0.0
   PCONSTANT_PITCH    = 1.0
   PCONSTANT_ROLL     = 1.0

   ICONSTANT_YAW      = 0.0
   ICONSTANT_PITCH    = 0.0
   ICONSTANT_ROLL     = 0.0         
   
   ICONSTANT_THROTTLE = 10

   DCONSTANT_YAW      = 0.0
   DCONSTANT_PITCH    = 0.0
   DCONSTANT_ROLL     = 0.0                         
   '================END PID LOOP CONSTANTS=================================

OBJ
        f : "floatmath"
            
VAR

    'sensor values  
    LONG L_IRState[4]        ' state of all four IR's
    LONG L_throttle ' state of a. the distance in a long, and b. the binary IR state (up/down)    
    LONG L_TrueYaw, L_TruePitch, L_TrueRoll  ' filtered YPR
    LONG L_V_x, L_V_y
    
    
    '======local data===================
    'TO BE USED LATER, ALL ZERO FOR NOW 
    LONG TargetYaw, TargetPitch, TargetRoll           
    LONG Target_V_X, Target_V_Y
    LONG Target_Throttle

    LONG ly, lp, lr
    LONG ld
    
    
    LONG CYaw, CPitch, CRoll
    Long C_V_X, C_V_Y
    LONG CThrottle

    LONG _Pyawval, _Ppitchval, _Prollval, _Pthrottleval
    LONG _Iyawval, _Ipitchval, _Irollval, _Ithrottleval
    LONG _Dyawval, _Dpitchval, _Drollval, _Dthrottleval
     
    
    'output 
    LONG MotorPower1, MotorPower2, MotorPower3, MotorPower4 'motor outputs


    

PUB Start ''starts NO cogs
{{
    just sets values to safe settings
}}
' set default sensor vals. to rest(ideal position)

_Iyawval   := f.ffloat(0)
_Ipitchval := f.ffloat(0)
_Irollval  := f.ffloat(0) 
                                            
L_TrueYaw := 0           
L_TruePitch := 0
L_TrueRoll := 0

CThrottle := 990 'STARTER VALUE




PUB Main

   Balance
   Compile_Motor_Commands  

PUB Balance | error_Yaw, error_Pitch, error_Roll, error_Throttle, d_error_Yaw, d_error_Pitch, d_error_Roll, d_error_Throttle
{{

    I also need to add pitch/roll tumble catches, not just velocity catches  (check!) :)
    
}}
    '================================ERROR SECTOR=================================
    '========PI========
    error_Yaw   := TargetYaw   - L_TrueYaw
    error_Pitch := TargetPitch - L_TruePitch
    error_Roll  := TargetRoll  - L_TrueRoll
    
    CThrottle := L_throttle
    
    'set to zero in case it stays
    'error_Throttle := 0
    {throttle is slightly more complicated because of the deadband}
    'if L_ProximityState < TARGET_ALTITUDE_LOW
    '     error_Throttle := TARGET_ALTITUDE_LOW - L_ProximityState[0]

    'if L_ProximityState > TARGET_ALTITUDE_HIGH
    '    error_Throttle := -(L_ProximityState[0] - TARGET_ALTITUDE_HIGH)
    '========D=======    
    d_error_Yaw      := error_Yaw        - ly
    d_error_Pitch    := error_Pitch      - lp
    d_error_Roll     := error_Roll       - lr
    '==============================END ERROR SECTOR===============================
       
    '============================PROPORTIONAL SECTOR============================================
    _Pyawval      := f.fmul(f.ffloat(error_Yaw  )  ,PCONSTANT_YAW)
    _Ppitchval    := f.fmul(f.ffloat(error_Pitch)  ,PCONSTANT_PITCH)
    _Prollval     := f.fmul(f.ffloat(error_Roll )  ,PCONSTANT_ROLL)
    '==========================END PROPORTIONAL SECTOR==========================================

    '============================INTEGRAL SECTOR============================================
    _Iyawval      := f.fadd( _Iyawval  ,  f.fmul( f.ffloat(error_Yaw  )   ,ICONSTANT_YAW  )  )
    _Ipitchval    := f.fadd( _Ipitchval,  f.fmul( f.ffloat(error_Pitch)   ,ICONSTANT_PITCH)  )
    _Irollval     := f.fadd( _Irollval ,  f.fmul( f.ffloat(error_Roll )   ,ICONSTANT_ROLL )  )
    'cthrottle     += (error_Throttle/ICONSTANT_THROTTLE)
    '==========================END INTEGRAL SECTOR==========================================
    
    '============================DERIVATIVE SECTOR============================================
    _Dyawval      := f.fmul(f.ffloat(d_error_Yaw  )   ,DCONSTANT_YAW)
    _Dpitchval    := f.fmul(f.ffloat(d_error_Pitch)   ,DCONSTANT_PITCH)
    _Drollval     := f.fmul(f.ffloat(d_error_Roll )   ,DCONSTANT_ROLL)
    '==========================END DERIVATIVE SECTOR==========================================


    'get average for final values
    cyaw      := f.fround(f.fdiv(   f.fadd(f.fadd(_Pyawval, _Dyawval),   _Iyawval  ), f.ffloat(3)))    
    cpitch    := f.fround(f.fdiv(   f.fadd(f.fadd(_Ppitchval, _Dpitchval), _Ipitchval), f.ffloat(3)))
    croll     := f.fround(f.fdiv(   f.fadd(f.fadd(_Prollval, _Drollval),  _Irollval ), f.ffloat(3)))
    

    ly := error_Yaw
    lp := error_Pitch
    lr := error_Roll

      
PUB Compile_Motor_Commands 

    'reset
    MotorPower1 := M1CONST
    MotorPower2 := M2CONST
    MotorPower3 := M3CONST
    MotorPower4 := M4CONST

    ''========THROTTLE SECTION===========================
         
    MotorPower1 += CThrottle
    MotorPower2 += CThrottle
    MotorPower3 += CThrottle
    MotorPower4 += CThrottle
    
    ''========END THROTTLE SECTION=======================    
    ''============YAW SECTION============================
    
    MotorPower1 += (CYaw * yaw_constant)   
    MotorPower2 += (-CYaw * yaw_constant)
    MotorPower3 += (-CYaw * yaw_constant)
    MotorPower4 += (CYaw * yaw_constant)
        
    ''==========END YAW SECTION==========================   
    ''=============PITCH SECTION=========================
                                                         
    MotorPower1 += CPitch * pitch_constant
    MotorPower2 += CPitch * pitch_constant
    MotorPower3 += -CPitch * pitch_constant
    MotorPower4 += -CPitch * pitch_constant

    ''===========END PITCH SECTION=======================    
    ''===============ROLL SECTION========================
    
    MotorPower1 += CRoll * roll_constant
    MotorPower2 += -CRoll * roll_constant
    MotorPower3 += CRoll * roll_constant
    MotorPower4 += -CRoll * roll_constant

    ''=============END ROLL SECTION======================


    
    ''=============CLAMP======================

    ''low pass
    if MotorPower1 < MIN_THROTTLE
          MotorPower1 := MIN_THROTTLE
    if MotorPower2 < MIN_THROTTLE
          MotorPower2 := MIN_THROTTLE
    if MotorPower3 < MIN_THROTTLE
          MotorPower3 := MIN_THROTTLE
    if MotorPower4 < MIN_THROTTLE
          MotorPower4 := MIN_THROTTLE

    ''high pass
    if MotorPower1 > MAX_THROTTLE
          MotorPower1 := MAX_THROTTLE
    if MotorPower2 > MAX_THROTTLE
          MotorPower2 := MAX_THROTTLE
    if MotorPower3 > MAX_THROTTLE
          MotorPower3 := MAX_THROTTLE
    if MotorPower4 > MAX_THROTTLE
          MotorPower4 := MAX_THROTTLE
          
    ''===========END CLAMP====================



PUB GetMotorPower(Motor)
{{
  returns the motor data to QCP
  which relays it to motorhandeler(in a
  seperate cog)

}}

    Case Motor
        1 : return MotorPower1
        2 : return MotorPower2
        3 : return MotorPower3
        4 : return MotorPower4



PUB SetSensorData(_IR_STATE, throttle, _TrueYaw, _TruePitch, _TrueRoll, _V_x, _V_y)



    '==========IR'S=======================
    L_IRState.BYTE[0] :=  _IR_STATE.BYTE[0]
    L_IRState.BYTE[1] :=  _IR_STATE.BYTE[1]
    L_IRState.BYTE[2] :=  _IR_STATE.BYTE[2]
    L_IRState.BYTE[3] :=  _IR_STATE.BYTE[3]

    '=========PROX.===================================
    L_throttle := throttle

    '======YAW PITCH ROLL=============================
         
    L_TrueYaw   := _TrueYaw
    L_TruePitch := _TruePitch
    L_TrueRoll  := _TrueRoll

    '======X-Y-Z VELOCITY============================= 
    L_V_x := _V_x
    L_V_y := _V_y

pub set_target_pitch(p_angle)
    TargetPitch := p_angle

pub set_target_roll(r_angle)
    TargetRoll := r_angle

pub set_target_yaw(y_angle)
    TargetYaw := y_angle

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}            