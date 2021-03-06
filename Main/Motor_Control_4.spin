{{
 ┌──────────────────────────────┬──────┬──────────────────────┬───────┬──────────┐
 │ Motor_Control_4.spin         │ 2016 │ Michael J. Langford  │Vs. 5.3│ 6/16/2016│
 ├──────────────────────────────┴──────┴──────────────────────┴───────┴──────────┤
 │ controls four uni-directional amplifiers                                      │
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
 
 ┌────────────────┐              ┌───────┐
 │              1 ├──────────────┤       ├── Motor 1 ────┐
 │   Propeller  2 ├──────────┐   │DRV8835├──x             
 │    P8X-32A   3 ├──────────┼───┤  (1)  ├── Motor 2 ────┐
 │              4 ├────────┐ │   │       ├──x             
 └────────────────┘        │ │   └───────┘
                           │ │   ┌───────┐
                           │ │   │       ├──x
                           │ └───┤DRV8835├── Motor 3 ────┐         
                           │     │  (2)  ├──x             
                           └─────┤       ├── Motor 4 ────┐        
                                 └───────┘                
}}
CON

  tl=14
  tr=15
  bl=12
  br=13  

VAR

long stack1[100], stack2[100]
long tlspeed
long trspeed
long blspeed
long brspeed

PUB init
  ''starts motor driver

  tlspeed := trspeed := blspeed := brspeed := 0
  
  cognew(run1, @stack1)
  return cognew(run2, @stack2)

PUB run1 | Cycle1, tlhigh, trhigh, time1

  ctra[30..26] := %00100     ' Counters A and B → NCO single-ended
  ctrb[30..26] := %00100     ' Counters A and B → NCO single-ended
  
  ctra[5..0] := tl                            ' Set pins for counters to control
  ctrb[5..0] := tr                            ' Set pins for counters to control
  
  frqa := frqb := 1                          ' Add 1 to phs with each clock tick
                         
  dira[tl] := 1                    ' Set I/O pins to output
  dira[tr] := 1                    ' Set I/O pins to output
  
  Cycle1 := clkfreq/10000                            ' Set up cycle time     
  repeat
    tlhigh := Cycle1 - (100 - tlspeed)*(Cycle1/100)          ' Set up high times for both signals
    trhigh := Cycle1 - (100 - trspeed)*(Cycle1/100)          ' Set up high times for both signals
              
    time1 := cnt                                       ' Mark current time.   
    phsa := -tlhigh                                   ' Define and start the A pulse
    phsb := -trhigh
    time1 += Cycle1                                        ' Calculate next cycle repeat
    waitcnt(time1)                                     ' Wait for next cycle


PUB run2 | Cycle2, blhigh, brhigh, time2

  ctra[30..26] := %00100     ' Counters A and B → NCO single-ended
  ctrb[30..26] := %00100     ' Counters A and B → NCO single-ended
  
  ctra[5..0] := bl                            ' Set pins for counters to control
  ctrb[5..0] := br                            ' Set pins for counters to control
  
  frqa := frqb := 1                          ' Add 1 to phs with each clock tick
                         
  dira[bl] := 1                    ' Set I/O pins to output
  dira[br] := 1                    ' Set I/O pins to output
  
  Cycle2 := clkfreq/10000                            ' Set up cycle time     
  repeat
    blhigh := Cycle2 - (100 - blspeed)*(Cycle2/100)          ' Set up high times for both signals
    brhigh := Cycle2 - (100 - brspeed)*(Cycle2/100)          ' Set up high times for both signals
              
    time2 := cnt                                       ' Mark current time.   
    phsa := -blhigh                                   ' Define and start the A pulse
    phsb := -brhigh
    time2 += Cycle2                                        ' Calculate next cycle repeat
    waitcnt(time2)                                     ' Wait for next cycle


PUB speed(tls, trs, bls, brs)
  ''sets motor speed values
  
  tlspeed := tls/2
  trspeed := trs/2
  blspeed := bls/2
  brspeed := brs/2
    