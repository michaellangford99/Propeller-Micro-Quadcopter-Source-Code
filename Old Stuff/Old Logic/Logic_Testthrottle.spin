{{
┌────────────────────────────────────┬────────────────────┬────────┬───────────┐
│Tiny_Quadcopter_Main.spin           │  Michael Langford  │ Vs 3.9 │ 7/17/2015 │  
├────────────────────────────────────┴────────────────────┴────────┴───────────┤
│Main Quadcopter code running on custon control board with prop mini, and a    │
│custom 3D printed chassis with 4 motors, 4 props, a motor controller, and a   │
│3.7V LiPo battery.                                                            │ 
└──────────────────────────────────────────────────────────────────────────────┘
}}
CON   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000
CON 'Settings

    yawbuffersize = 40
    pitchbuffersize = 10
    rollbuffersize = 10

    'calibrate_time = 1000
    
OBJ
  'objects used in code
   l    : "pidlogicthrottle"                    'PID  object
   KF   : "Kalman_Filter"                       'Main sensor object 
   Term : "FullDuplexSerial"                    'Basic serial communication object      'From Parallax.com
   SN   : "Simple_Numbers"                      'Math utility object                    'From Parallax.com
   m    : "motorcontrol4"                       'Motor control object                                       

VAR                                       
   long altitude, yawbank[yawbuffersize], pitchbank[pitchbuffersize], rollbank[rollbuffersize]
   long S_TrueYaw, S_TruePitch, S_TrueRoll
   long yaw, pitch, roll, pitchoffset, rolloffset
   long myself, stack[100]
         
PUB Start | cogresult
                
   term.start(31, 30, 0, 31250)               'start terminal      '1 cog
   KF.Start                                   'start sensors       '2 cogs (main, acc)      
   l.Start                                    'start PID           'no cog      
   m.init                                     'start motors        '2 cogs (reg1, reg2)       

   myself := cogid   
   cognew(sensors, @stack)                                                
  '======CHOOSE STARTUP OPTION======
  'main
   testsensors
  'testmotors  

Pub Main

   dira[2]~
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

   'Main code loop
   repeat
        Sensors
        Logic
        Motors
        Terminal
{
Pri Calibrate_Sensors | i, rv, pv, yv
    repeat calibrate_time
        repeat i from 0 to rollbuffersize-2
            rollbank[i] := rollbank[i+1]
        rollbank[rollbuffersize-1] := KF.GetComp_Filter_Output(1)
        rv := 0  
        repeat i from 0 to rollbuffersize-1
            rv += rollbank[i]                         
        S_TrueRoll := rv/rollbuffersize

         
        repeat i from 0 to pitchbuffersize-2
            pitchbank[i] := pitchbank[i+1]
        pitchbank[pitchbuffersize-1] := KF.GetComp_Filter_Output(2)   
        pv := 0
        repeat i from 0 to pitchbuffersize-1
            pv += pitchbank[i]                            
        S_TruePitch := pv/pitchbuffersize
        
        repeat i from 0 to yawbuffersize-2
            yawbank[i] := yawbank[i+1]
        yawbank[yawbuffersize-1] := KF.GetComp_Filter_Output(3)   
        yv := 0
        repeat i from 0 to yawbuffersize-1
            yv += yawbank[i]
        S_TrueYaw := yv/yawbuffersize

        rolloffset += S_TrueRoll
        pitchoffset += S_TruePitch

    rolloffset /= calibrate_time
    pitchoffset /= calibrate_time
 }       
Pub Sensors | i, rv, pv, yv
    
    repeat 
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
        S_TruePitch := pv/pitchbuffersize' - pitchoffset
        
        repeat i from 0 to rollbuffersize-2
            rollbank[i] := rollbank[i+1]
        rollbank[rollbuffersize-1] := KF.Get_Kalman_Filtered_Output(3)
        rv := 0  
        repeat i from 0 to rollbuffersize-1
            rv += rollbank[i]                         
        S_TrueRoll := rv/rollbuffersize' - rolloffset

         
                                                
Pub Logic

        l.SetSensorData(0, 50, S_TrueYaw, -S_TruePitch, S_TrueRoll, 0, 0)
        l.Main
        
Pub Motors

        m.speed(l.GetMotorPower(1), l.GetMotorPower(2), l.GetMotorPower(3), l.GetMotorPower(4))
        
Pub Terminal
       
       'Comment out this code section when not connected over USB 
        '{  
        term.tx(1)
   
        term.str(SN.dec(S_TrueRoll))
        term.str(string(" ", 13))
        
        term.str(SN.dec(S_TruePitch))
        term.str(string(" ", 13))
        
        term.str(SN.dec(S_TrueYaw))
        term.str(string(" ", 13))    
        

        term.tx(2)
        term.tx(0)
        term.tx(7)
        term.str(SN.dec(l.GetMotorPower(1)))
        term.str(string(" []"))

        
        term.tx(2)
        term.tx(7)
        term.tx(7)
        term.str(SN.dec(l.GetMotorPower(2)))
        
        term.tx(2)
        term.tx(0)
        term.tx(12)
        term.str(SN.dec(l.GetMotorPower(3)))
        

        term.tx(2)
        term.tx(7)
        term.tx(12)
        term.str(SN.dec(l.GetMotorPower(4)))
        '} ' you don't need to remove this guy
        
Pub testsensors

    repeat
        'Sensors
        
        term.rx
        
        term.str(SN.dec(S_TrueYaw))
        term.str(string(" ", 13))    
         
        term.str(SN.dec(S_TruePitch))
        term.str(string(" ", 13))
        
        term.str(SN.dec(-S_TrueRoll))
        term.str(string(" ", 13))
                          
        

Pub testmotors | x

    repeat
        repeat x from 0 to 200
            m.speed(0, x, 0, 0)
        repeat x from 200 to 0
            m.speed(0, x, 0, 0)
           
        
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
   