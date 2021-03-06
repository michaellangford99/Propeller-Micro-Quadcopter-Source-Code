{{
 ┌──────────────────────────────┬──────┬──────────────────────┬────────┬─────────┐
 │ MotorHandeler.spin           │ 2014 │ Michael J. Langford  │ Vs. 5.0│ Jun. 16 │
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


   motor1offset=150
   motor2offset=-150
   motor3offset=120
   motor4offset=-150

   
OBJ

   Motor : "Servo32v7 "
   
VAR
    Long PowerMotor1, PowerMotor2, PowerMotor3, PowerMotor4

PUB Start
    'initiate variables
    
    
    PowerMotor1 := 1
    PowerMotor2 := 1
    PowerMotor3 := 1
    PowerMotor4 := 1
    'start all servos    
    Motor.Start


       
PUB Fly

    PulseController2(12, PowerMotor1+motor1offset)
    PulseController2(13, PowerMotor2+motor2offset)
    PulseController2(18, PowerMotor3+motor3offset)
    PulseController2(20, PowerMotor4+motor4offset)

PUB Set(p1, p2, p3, p4)

    PowerMotor1 := p1
    PowerMotor2 := p2
    PowerMotor3 := p3
    PowerMotor4 := p4
     
PRI PulseController(Pin, Rotation) | CalculatedRotation
{{
  'Rotation is a 0-100 variable stating the rotation of the motor; 0 is
   off, 100 is fully forward
}}
    'gets the data into a pulse form in the correct range
    CalculatedRotation := (Rotation * 20) + 500
    'feeds the scaled data through the pulse controller code
    Motor.Set(Pin, CalculatedRotation) '#1 = s1

PRI PulseController2(Pin, Rotation) | CalculatedRotation
    
    Motor.Set(Pin, Rotation) '#1 = s1
     