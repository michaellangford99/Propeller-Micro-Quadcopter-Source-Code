 {{
 ┌──────────────────────────────┬──────┬──────────────────────┬────────┬─────────┐
 │ pidlogic.spin                │ 2014 │ Michael J. Langford  │ Vs. 5.0│ Oct. 30 │
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
    |          |
   prop3      prop4


   
}}
CON


   TARGET_ALTITUDE_HIGH = 198
   TARGET_ALTITUDE_LOW = 192

   YAW_CONSTANT = 1 
   PITCH_CONSTANT = 1
   ROLL_CONSTANT = 1

   MAX_THROTTLE = 1400
   MIN_THROTTLE = 800
   
   {{
   X_Velocity = 15    
   Y_Velocity = 15
   }}'to be used later


   
   '==================PID LOOP CONSTANTS===================================
   PCONSTANT_YAW      = 1
   PCONSTANT_PITCH    = 5
   PCONSTANT_ROLL     = 5

   ICONSTANT_YAW      = 10
   ICONSTANT_PITCH    = 2
   ICONSTANT_ROLL     = 2
   
   ICONSTANT_THROTTLE = 10

   DCONSTANT_YAW      = 1
   DCONSTANT_PITCH    = 4
   DCONSTANT_ROLL     = 5                         
   '================END PID LOOP CONSTANTS=================================



   
    
VAR

    'sensor values  
    LONG L_IRState[4]        ' state of all four IR's
    LONG L_ProximityState ' state of a. the distance in a long, and b. the binary IR state (up/down)    
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

    'set to zero in case it stays
    error_Throttle := 0
    {throttle is slightly more complicated because of the deadband}
    if L_ProximityState < TARGET_ALTITUDE_LOW
         error_Throttle := TARGET_ALTITUDE_LOW - L_ProximityState[0]

    if L_ProximityState > TARGET_ALTITUDE_HIGH
        error_Throttle := -(L_ProximityState[0] - TARGET_ALTITUDE_HIGH)
    '========PI========
    '========D=======    
    d_error_Yaw      := error_Yaw        - ly
    d_error_Pitch    := error_Pitch      - lp
    d_error_Roll     := error_Roll       - lr
    '==============================END ERROR SECTOR===============================
       
    '============================PROPORTIONAL SECTOR============================================
    _Pyawval      := (error_Yaw     /PCONSTANT_YAW)
    _Ppitchval    := (error_Pitch   /PCONSTANT_PITCH)
    _Prollval     := (error_Roll    /PCONSTANT_ROLL)
    '==========================END PROPORTIONAL SECTOR==========================================

    '============================INTEGRAL SECTOR============================================
    _Iyawval      += (error_Yaw     /ICONSTANT_YAW)
    _Ipitchval    += (error_Pitch   /ICONSTANT_PITCH)
    _Irollval     += (error_Roll    /ICONSTANT_ROLL)
    cthrottle     += (error_Throttle/ICONSTANT_THROTTLE)
    '==========================END INTEGRAL SECTOR==========================================
    
    '============================DERIVATIVE SECTOR============================================
    _Dyawval      := (d_error_Yaw     /DCONSTANT_YAW)
    _Dpitchval    := (d_error_Pitch   /DCONSTANT_PITCH)
    _Drollval     := (d_error_Roll    /DCONSTANT_ROLL)
    '==========================END DERIVATIVE SECTOR==========================================


    'get average for final values
    cyaw      := (_Pyawval     +_Iyawval     +_Dyawval)     /3
    cpitch    := (_Ppitchval   +_Ipitchval   +_Dpitchval)   /3
    croll     := (_Prollval    +_Irollval    +_Drollval)    /3
    

    ly := error_Yaw
    lp := error_Pitch
    lr := error_Roll

      
PUB Compile_Motor_Commands
{{
  maximum power to a motor is 100
  throttle gets 50, yaw gets 5, pitch gets 20, roll gets 20
}}

    'reset
    MotorPower1 := 0
    MotorPower2 := 0
    MotorPower3 := 0
    MotorPower4 := 0

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


    
    ''=============DUAL PASS FILTER======================

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
          
    ''===========END DUAL PASS FILTER====================



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



PUB SetSensorData(_IR_STATE, _PROXIMITYSTATE, _TrueYaw, _TruePitch, _TrueRoll, _V_x, _V_y)



    '==========IR'S=======================
    L_IRState.BYTE[0] :=  _IR_STATE.BYTE[0]
    L_IRState.BYTE[1] :=  _IR_STATE.BYTE[1]
    L_IRState.BYTE[2] :=  _IR_STATE.BYTE[2]
    L_IRState.BYTE[3] :=  _IR_STATE.BYTE[3]

    '=========PROX.===================================
    L_ProximityState := _PROXIMITYSTATE

    '======YAW PITCH ROLL=============================
         
    L_TrueYaw   := _TrueYaw
    L_TruePitch := _TruePitch
    L_TrueRoll  := _TrueRoll

    '======X-Y-Z VELOCITY============================= 
    L_V_x := _V_x
    L_V_y := _V_y

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