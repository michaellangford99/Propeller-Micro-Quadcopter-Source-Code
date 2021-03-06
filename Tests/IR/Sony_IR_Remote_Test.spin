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

VAR
   long v
   
OBJ                      
   ir : "Sony_IR_Decoder"          
   m    : "Motor_Control_4"                     'Motor control object
   
PUB Main
    m.init
    repeat
        v := ir.GetMessage(2)

        m.speed(v*20, v*20, v*20, v*20)

    