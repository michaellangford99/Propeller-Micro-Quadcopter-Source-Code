CON

    SONY_IR_NO_SIGNAL = -1

VAR                                                                         
     Word Pulse[5]                   ' Pulse width of each bit of message
     long message                    ' Inteteger created from the five bits

PUB GetMessage(pin)
  'repeat
    Pulse[0] := (RCTIME(pin, 0))/2         
    if (Pulse[0] > 975) and (Pulse[0] < 1425)

        Pulse[0] :=  PULSIN(pin,0)
        Pulse[1] :=  PULSIN(pin,0)
        Pulse[2] :=  PULSIN(pin,0)
        Pulse[3] :=  PULSIN(pin,0)
        Pulse[4] :=  PULSIN(pin,0)

        if Pulse[0] < 400                        ' convert long and short pulses to
            message := 0                         ' bits in message variable.
        else
            message := 1
        if Pulse[1] > 400    
            message := message + 2
        if Pulse[2] > 400    
            message := message + 4
        if Pulse[3] > 400    
            message := message + 8
        if Pulse[4] > 400    
            message := message + 16

        message := message + 1                   ' make message = IR Remote numerical button
        if message == 10                         ' special case
            message := 0                   

        return message                            
    return -1
PUB RCTIME (Pin,State):Duration | ClkStart, ClkStop
{{
   Reads RCTime on Pin starting at State, returns discharge time, returns in 1uS units
     dira[5]~~                 ' Set as output
     outa[5]:=1                ' Set high
     BS2.Pause(10)             ' Allow to charge
     x := RCTime(5,1)          ' Measure RCTime
     BS2.DEBUG_DEC(x)          ' Display
}}

   DIRA[Pin]~
   ClkStart := cnt                                         ' Save counter for start time
   waitpne(State << pin, |< Pin, 0)                        ' Wait for opposite state to end
   clkStop := cnt                                          ' Save stop time
   Duration := (clkStop - ClkStart)/(clkfreq / 1_000_000)                     ' calculate in 1us resolution



PUB PULSIN (Pin, State) : Duration 
{{
  Reads duration of Pulse on pin defined for state, returns duration in 2uS resolution
  Shortest measureable pulse is around 20uS
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin(5,1)
    BS2.Debug_Dec(x)
}}

   Duration := PULSIN_Clk(Pin, State) / (clkfreq/1_000_000) / 2 + 1         ' Use PulsinClk and calc for 2uS increments
  
   
PUB PULSIN_uS (Pin, State) : Duration | ClkStart, clkStop, timeout
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1uS resolution
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_uS(5,1)
    BS2.Debug_Dec(x)
}}
 
   Duration := PULSIN_Clk(Pin, State) / (clkfreq/1_000_000) + 1             ' Use PulsinClk and calc for 1uS increments
    
PUB PULSIN_Clk(Pin, State) : Duration 
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1/clkFreq increments - 12.5nS at 80MHz
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_Clk(5,1)
    BS2.Debug_Dec(x)
}}

  DIRA[pin]~
  ctra := 0
  if state == 1
    ctra := (%11010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, A level count
  else
    ctra := (%10101 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, !A level count
  frqa := 1
  waitpne(State << pin, |< Pin, 0)                         ' Wait for opposite state ready
  phsa:=0                                                  ' Clear count
  waitpeq(State << pin, |< Pin, 0)                         ' wait for pulse
  waitpne(State << pin, |< Pin, 0)                         ' Wait for pulse to end
  Duration := phsa                                         ' Return duration as counts
  ctra :=0                                                 ' stop counter
   