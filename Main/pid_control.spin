{{
┌─────────────────────────────────────┬────────────────────────┬──────┬────────┐
│                                     │                        │      │        │
├─────────────────────────────────────┴────────────────────────┴──────┴────────┤
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

}}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

   '==================PID LOOP CONSTANTS===================================
   PCONSTANT_YAW      = 1.0
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

        
VAR

   targets[3]         'target angles
   angles[3]          'curent angles
   outputs[3]         'output from PIDs
   motor_outputs[4]   'output to motors
   
OBJ

    yaw_pid   :  "pid"
    pitch_pid :  "pid"
    roll_pid  :  "pid"
    
PUB Init(t[3])

    target[0]:=t[0]
    target[1]:=t[1]
    target[2]:=t[2]
    
    yaw_pid.init(PCONSTANT_YAW, ICONSTANT_YAW, DCONSTANT_YAW, target[0])
    pitch_pid.init(PCONSTANT_PITCH, ICONSTANT_PITCH, DCONSTANT_PITCH, target[1])
    roll_pid.init(PCONSTANT_ROLL, ICONSTANT_ROLL, DCONSTANT_ROLL, target[2])

pub SetTargets(t[3])

    target[0]:=t[0]
    target[1]:=t[1]
    target[2]:=t[2]
       