{{
┌───────────────────────────────────┬────────────────────┬────────┬────────────┐
│Mini_Quad_Main.spin                │  Michael Langford  │ Vs 5.9 │ 12/4/2015  │  
├───────────────────────────────────┴────────────────────┴────────┴────────────┤
│Main Quadcopter code running on custon control board with prop mini, a custom │
│3D printed chassis with 4 motors, 4 props, a motor controller, and a 3.7V     │
│Lithium-Polymer battery.                                                      │ 
└──────────────────────────────────────────────────────────────────────────────┘
}}                    
CON   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000
  
CON 'Settings

    yawbuffersize = 10
    pitchbuffersize = 12
    rollbuffersize = 12

    calibrate_time = 200
    
OBJ
  'objects used in code
   l    : "PID_Logic"                           'PID  object
   KF   : "Sensors"                             'Main sensor object 
   Term : "Parallax Serial Terminal"            'Basic serial communication object      'From Parallax.com
   SN   : "Simple_Numbers"                      'Math / String utility object           'From Parallax.com
   m    : "Motor_Control_4"                     'Motor control object
   fm   : "FloatMath"                                       

VAR                                       
   long altitude, yawbank[yawbuffersize], pitchbank[pitchbuffersize], rollbank[rollbuffersize]
   long S_TrueYaw, S_TruePitch, S_TrueRoll
   long yaw, pitch, roll, pitchoffset, rolloffset
   long myself, stack[100], stack2[300], kill   
         
PUB Start
''Starts the quadcopter, with 3 options:      ''(current cog(0))    '1  cog
'' 'Main'                                     ''
'' 'TestSensors'                              ''
'' 'TestMotors'                               ''
                                              ''
   'Start objects                             ''
   term.start(31250)                          ''start terminal      '1 cog
   KF.Start_Sensors                           ''start sensors       '2  cog  (acc, gyro)    
   l.Start                                    ''start PID           'no cog      
   m.init                                     ''start motors        '2  cogs (reg1, reg2)       
                                              ''
   'Prep top object                           ''
   Calibrate_Sensors                          ''
   myself := cogid                            ''
   kill := 0                                  ''
   cognew(sensors, @stack)                    ''start main sensors  '1  cog
                                              ''
  '======CHOOSE STARTUP OPTION======          ''
   main                                       ''
  'testsensors                                ''
  'testmotors                                 ''
                                              ''
Pub Main
''runs the Main flight loop
  { dira[2]~
   repeat until ina[2] == 1
        greenlight
        waitcnt(clkfreq/10 + cnt)
        blacklight
        waitcnt(clkfreq/10 + cnt)

   repeat until ina[2] == 0
        redlight
        waitcnt(clkfreq/20 + cnt)
        blacklight
        waitcnt(clkfreq/20 + cnt) 
                   }
   'Main code loop

   term.rx
   term.str(string("Ready!", 13))
   term.rx 
   cognew(Terminal, @stack2)
   repeat        
        Logic
        Motors   
'{
Pub Calibrate_Sensors | i, rv, pv, yv
''calibrates out any offset or drift in the sensors
    pitchoffset := 0.0

    repeat calibrate_time
    
        KF.Update_Sensors
        
        '====YAW=======
        repeat i from 0 to yawbuffersize-2
            yawbank[i] := yawbank[i+1]
        yawbank[yawbuffersize-1] := KF.Get_Kalman_Filtered_Output(1)   
        yv := 0
        repeat i from 0 to yawbuffersize-1
            yv := yv + yawbank[i]
        S_TrueYaw := yv/yawbuffersize
        
        '====PITCH=======
        repeat i from 0 to pitchbuffersize-2
            pitchbank[i] := pitchbank[i+1]
        pitchbank[pitchbuffersize-1] := fm.ffloat(KF.Get_Kalman_Filtered_Output(2))   
        pv := 0.0
        repeat i from 0 to pitchbuffersize-1
            pv := fm.fadd(pv,pitchbank[i])
        S_Truepitch := fm.fdiv(pv,fm.ffloat(pitchbuffersize))
        
        '====ROLL=======
        repeat i from 0 to rollbuffersize-2
            rollbank[i] := rollbank[i+1]
        rollbank[rollbuffersize-1] := KF.Get_Kalman_Filtered_Output(3)   
        rv := 0
        repeat i from 0 to rollbuffersize-1
            rv := rv+rollbank[i]
        S_Trueroll := rv/rollbuffersize
        

        rolloffset := S_TrueRoll+rolloffset
        pitchoffset := fm.fadd(S_TruePitch,pitchoffset)
        
    rolloffset  := rolloffset/calibrate_time
    pitchoffset := fm.fround(fm.fdiv(pitchoffset,fm.ffloat(calibrate_time))) 
     
Pub Sensors | i, rv, pv, yv
'' Main sensor loop - calls sensor update function in sensor library
    
    S_TrueYaw   := 0
    S_TruePitch := 0    'gets rid of any funny stuff with the floating point math in the calibration section
    S_TrueRoll  := 0
        
    repeat
    
        KF.Update_Sensors
        
        repeat i from 0 to yawbuffersize-2
            yawbank[i] := yawbank[i+1]
        yawbank[yawbuffersize-1] := KF.Get_Kalman_Filtered_Output(1)   
        yv := 0
        repeat i from 0 to yawbuffersize-1
            yv += yawbank[i]
        S_TrueYaw := yv/yawbuffersize

        repeat i from 0 to pitchbuffersize-2
            pitchbank[i] := pitchbank[i+1]
        pitchbank[pitchbuffersize-1] := KF.Get_Kalman_Filtered_Output(2)   
        pv := 0
        repeat i from 0 to pitchbuffersize-1
            pv += pitchbank[i]                            
        S_TruePitch := pv/pitchbuffersize - pitchoffset
        
        repeat i from 0 to rollbuffersize-2
            rollbank[i] := rollbank[i+1]
        rollbank[rollbuffersize-1] := KF.Get_Kalman_Filtered_Output(3)
        rv := 0  
        repeat i from 0 to rollbuffersize-1
            rv += rollbank[i]                         
        S_TrueRoll := rv/rollbuffersize - rolloffset
               
Pub Logic
''Loads PIDs with sensor data and updates the PIDs
        l.SetSensorData(0, 100, S_TrueYaw, S_TruePitch, S_TrueRoll, 0, 0)
        l.Main
        
Pub Motors
'' loads motors with values from the PIDs
        m.speed(l.GetMotorPower(1), l.GetMotorPower(2), l.GetMotorPower(3), l.GetMotorPower(4))
        
Pub Terminal
'' sends quadcopter data to C# terminal
'' it is used by the main quadcopter (flying) loop       
'' Comment out this code section (and its references) when Quadcopter is not connected over USB 
        '{

     repeat  
        kill := term.rx
        if kill ==  "k"
           end_flight
        term.str(SN.dec(S_TrueYaw))
        term.tx(13)
          
        term.str(SN.dec(S_TruePitch))
        term.tx(13)
         
        term.str(SN.dec(S_TrueRoll))
        term.tx(13)   
        '{
        '==extra==
        term.str(SN.dec(l.GetMotorPower(1)))
        term.tx(13)        
        term.str(SN.dec(l.GetMotorPower(2)))
        term.tx(13)        
        term.str(SN.dec(l.GetMotorPower(3)))
        term.tx(13)                         
        term.str(SN.dec(l.GetMotorPower(4)))
        term.tx(13)
        '}'} ' you don't need to remove this guy
        
Pub testsensors | n
'' tests sensors and sends data to C# data terminal
  waitcnt(clkfreq*2 + cnt)
 term.rx
 term.str(string("Ready!", 13))
 term.rx
 
     repeat
        
       term.rx
       
       term.str(SN.dec(S_TrueYaw))
       term.tx(13)
         
       term.str(SN.dec(S_TruePitch))
       term.tx(13)
        
       term.str(SN.dec(S_TrueRoll))
       term.tx(13)
                          
        

Pub testmotors | x
'' tests motors by ramping them
    repeat
        repeat x from 0 to 200
            m.speed(10, x, 0, 0)
        repeat x from 200 to 0
            m.speed(0, x, 0, 0)
           
pub end_flight    
    cogstop(myself)
    repeat
                   
        m.speed(0, 0, 0, 0)
        kill := term.rx
        if kill == " "
            reboot
                    
pri redlight

'led.setx(0, $FF_00_00, 255, -1)
'led.execute(5, -1, -1)

pri greenlight

'led.setx(0, $00_FF_00, 255, -1)
'led.execute(5, -1, -1)

pri bluelight

'led.setx(0, $00_00_FF, 255, -1)
'led.execute(5, -1, -1)

pri orangelight

'led.setx(0, $FF_60_00, 255, -1)
'led.execute(5, -1, -1)

pri whitelight

'led.setx(0, $C8_FF_FF, 255, -1)
'led.execute(5, -1, -1)

pri blacklight

'led.setx(0, $00_00_00, 0, -1)
'led.execute(5, -1, -1)
   