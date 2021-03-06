{{
 ┌──────────────────────────────┬──────┬──────────────────────┬────────┬─────────┐
 │ LogicHandeler.spin           │ 2014 │ Michael J. Langford  │ Vs. 4.0│ Mar. 19 │
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


   target_altitude_low = 192
   target_altitude_high = 198

   yaw_constant = 5
   pitch_constant = 5
   roll_constant = 5

   X_Velocity = 15
   Z_Velocity = 15
   

    
VAR

    'sensor values  
    LONG L_IRState[4]        ' state of all four IR's
    LONG L_ProximityState[2] ' state of a. the distance in a long, and b. the binary IR state (up/down)    
    LONG L_TrueYaw, L_TruePitch, L_TrueRoll  ' filtered YPR
    LONG L_V_x, L_V_y, L_V_z ' Velocity in all 3 axis
    

    '======local data===================
    LONG Direction[4], Prev_Direction[4], StoppedFlag[2]
    'LONG Forward[2], Backward[2], Left[2], Right[2]   
    'target values
    'LONG Target_ProximityState
    LONG TargetYawRotation, TargetPitch, TargetRoll
    Long Target_V_X, Target_V_Y, Target_V_Z
    LONG TargetThrottle                                     'throttle needed to hover
    
    'output 
    LONG MotorPower1, MotorPower2, MotorPower3, MotorPower4 'motor outputs

PUB Start ''starts NO cogs
{{
    just sets values to safe settings
}}
' set default sensor vals. to rest(ideal position)

L_IRState.byte[0] := 0
L_IRState.byte[1] := 0
L_IRState.byte[2] := 0
L_IRState.byte[3] := 0

L_ProximityState.byte[0] := 1   ' it "sees" the ground
L_ProximityState.byte[1] := 194 '195 and lower means too low
                                            
L_TrueYaw := 0
L_TruePitch := 0
L_TrueRoll := 0

Direction.Byte[0] := 0  'forward
Direction.Byte[1] := 0  'backward
Direction.Byte[2] := 0  'left
Direction.Byte[3] := 0  'right

TargetThrottle := 50

Target_V_X := 0
Target_V_Y := 0
Target_V_Z := 0


PUB Main
   dira[22]~~
   waitcnt(clkfreq/2+cnt)
   outa[22] := 1
   waitcnt(clkfreq/2+cnt)
   outa[22] := 0
        
   
   'Target_Direction
   'Target_Position
   Balance
   Compile_Motor_Commands
   

PUB Target_Direction

       ' ┌──────front IR
       ' │┌──────back IR
       ' ││┌─────left IR
       ' │││┌───right IR
       ' 
       ' 0000

       
       {{ if the front ir sees an opening, and it isn't going backward, set to forward}} 
       if (L_IRState.byte[0] == 0) and (Prev_Direction.BYTE[1]) == 0
           Direction.Byte[0] := 1  'forward
           Direction.Byte[1] := 0  'backward
           Direction.Byte[2] := 0  'left                         
           Direction.Byte[3] := 0  'right

           
       {{ if the back ir sees an opening, and it isn't going forward, set to backward}} 
       if (L_IRState.byte[1] == 0) and (Prev_Direction.BYTE[0]) == 0
           Direction.Byte[0] := 0  'forward
           Direction.Byte[1] := 1  'backward
           Direction.Byte[2] := 0  'left
           Direction.Byte[3] := 0  'right


       {{ if the left ir sees an opening, and it isn't going right, set to left}} 
       if (L_IRState.byte[2] == 0) and (Prev_Direction.BYTE[3]) == 0
           Direction.Byte[0] := 0  'forward  
           Direction.Byte[1] := 0  'backward
           Direction.Byte[2] := 1  'left
           Direction.Byte[3] := 0  'right


       {{ if the right ir sees an opening, and it isn't going left, set to right}} 
       if (L_IRState.byte[3] == 0) and (Prev_Direction.BYTE[2]) == 0
           Direction.Byte[0] := 0  'forward
           Direction.Byte[1] := 0  'backward
           Direction.Byte[2] := 0  'left
           Direction.Byte[3] := 1  'right

PUB Target_Position
    {{gets the desired velocity}}
    ''velocity is a variable, change with maze position on each
    
    if Direction.Byte[0] == 1 ' if direction == forward
         Target_V_X := X_Velocity                'velocity is a variable, change with maze position
         Target_V_Y := 0
         Target_V_Z := 0

    if Direction.Byte[1] == 1 ' if direction == backward
         Target_V_X := -X_Velocity
         Target_V_Y := 0
         Target_V_Z := 0

    if Direction.Byte[2] == 1 ' if direction == left
         Target_V_X := 0
         Target_V_Y := 0
         Target_V_Z := Z_Velocity

    if Direction.Byte[3] == 1 ' if direction == right
         Target_V_X := 0
         Target_V_Y := 0
         Target_V_Z := -Z_Velocity

    

    


PUB Balance
{{

    I also need to add pitch/roll tumble catches, not just velocity catches  (check!) :)
    
}}

  
    '======ROLLOVER PREVENT====================
    if L_TruePitch > TargetPitch
        TargetPitch--
    if L_TruePitch < TargetPitch
        TargetPitch++
        

    if L_TrueRoll > TargetRoll
        TargetRoll--
    if L_TrueRoll < TargetRoll
        TargetRoll++
    '======END ROLLOVER PREVENT================
    
    '=======ROLL===============================
    if L_V_x < Target_V_X
        TargetRoll++
    if L_V_x > Target_V_X
        TargetRoll--
        
    '=======PITCH==============================
    if L_V_z < Target_V_Z
        TargetPitch++
    if L_V_z > Target_V_Z
        TargetPitch--
        
    '=======YAW================================
    if L_TrueYaw > 0
        TargetYawRotation--    'how much i want to move relative to current
    if L_TrueYaw < 0
        TargetYawRotation++   'how much i want to move relative to current
        
    '=======THROTTLE===========================

    if L_ProximityState.byte[1] > target_altitude_low  
        TargetThrottle--                  ' makes a zone formation

    if L_ProximityState.byte[1] < target_altitude_high
        TargetThrottle++
        

PUB Compile_Motor_Commands | Throttle, Yaw, Pitch, Roll
{{
  maximum power to a motor is 100
  throttle gets 50, yaw gets 5, pitch gets 20, roll gets 20
}}

    MotorPower1 := 0
    MotorPower2 := 0
    MotorPower3 := 0
    MotorPower4 := 0

    '========THROTTLE SECTION===========================
    
    Throttle := 5
 
    
    MotorPower1 += TargetThrottle
    MotorPower2 += TargetThrottle
    MotorPower3 += TargetThrottle
    MotorPower4 += TargetThrottle

    
    '========END THROTTLE SECTION=======================    
    '============YAW SECTION============================
    
    Yaw := TargetYawRotation
    MotorPower1 += (Yaw * yaw_constant)   ''5' is a constant, change if needed, for a slower or faster reaction on each sector
    MotorPower2 += (-Yaw * yaw_constant)
    MotorPower3 += (-Yaw * yaw_constant)
    MotorPower4 += (Yaw * yaw_constant)
        
    '==========END YAW SECTION==========================   
    '=============PITCH SECTION=========================
    
    ''temporary
    MotorPower1 += TargetPitch * pitch_constant
    MotorPower2 += TargetPitch * pitch_constant
    MotorPower3 += -TargetPitch * pitch_constant
    MotorPower4 += -TargetPitch * pitch_constant

    '===========END PITCH SECTION=======================    
    '===============ROLL SECTION========================
    
    MotorPower1 += TargetRoll * roll_constant
    MotorPower2 += -TargetRoll * roll_constant
    MotorPower3 += TargetRoll * roll_constant
    MotorPower4 += -TargetRoll * roll_constant

    '=============END ROLL SECTION======================
          

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
    L_ProximityState.BYTE[0] := _PROXIMITYSTATE.BYTE[0]
    L_ProximityState.BYTE[1] := _PROXIMITYSTATE.BYTE[1]

    '======YAW PITCH ROLL=============================
         
    L_TrueYaw   := _TrueYaw
    L_TruePitch := _TruePitch
    L_TrueRoll  := _TrueRoll

    '======X-Y-Z VELOCITY============================= 
    L_V_x := _V_x
    L_V_z := _V_y
    