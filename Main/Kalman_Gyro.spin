{{
                        
┌─────────────────────────────────────┬────────────────────────┬──────┬────────┐
│ L3G4200D_Example_Code.spin          │ (C)2011 Parallax, Inc. │ V1.0 │ Jul 25 │
├─────────────────────────────────────┴────────────────────────┴──────┴────────┤
│ Demonstrates X,Y,Z output to a serial terminal. Uses default (I²C) interface │
│ on the Gyroscope module.                                                     │
│ This program is for example purposes only for RAW data from the Gyroscope    │
│ Module. The calculations provided are for example only and should not be     │
│ relied on for accuracy. For details about calculating Gyroscope values and   │
│ other important information on functionality, please see the documents on our│
│ product page. Our Forums also have very useful information on this topic.    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

'=================================================================================================

 ┌──────────────────────────────┬──────┬──────────────────────┬───────┬──────────┐
 │ Kalman_Gyro.spin             │ 2015 │ Michael J. Langford  │Vs. 1.1│10/29/2015│
 ├──────────────────────────────┴──────┴──────────────────────┴───────┴──────────┤
 │Slightly modified basic gyro demo, almost all written by Parallax.             │
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

'=================================================================================================


   ┌─────────────────┐
   │   L        INT2 ┣───   Data ready/FIFO interrupt
   │   3        INT1 ┣───   Programmable interrupt
   │   G         SDO ┣───   SPI serial data output -- I²C LSB of the device address (SA0)
   │   4 SDA/SDI/SDO ┣───   I²C serial data (SDA) -- SPI serial data input (SDI) -- 3-wire SPI data output (SDO)
   │   2         SCL ┣───   I²C & SPI clock
   │   0         CS  ┣───   I²C/SPI mode selection (defaulted to I²C) pull low for SPI mode
   │   0         VIN ┣───   2.7 - 6.5VDC (module is regulated to 2.5VDC)
   │   D         GND ┣──┐
   └─────────────────┘  

}}  

CON
 '{
  _clkmode      = xtal1 + pll16x
  _clkfreq      = 80_000_000
  '}
  SCLpin         = 0           
  SDApin         = 1       
    
  '****Registers****

  WRITE         = $D2
  READ          = $D3
  
  CTRL_REG1     = $20    'SUB $A0 
  CTRL_REG3     = $22
  CTRL_REG4     = $23
  STATUS_REG    = $27
  OUT_X_INC     = $A8


  x_idx = 0
  y_idx = 1
  z_idx = 2 

VAR
long cx
long cy
long cz

long f_x, x
long f_y, y
long f_z, z

long multiBYTE[3] 

PUB Start_Gyro | last_ticks
 
  Wrt_1B(CTRL_REG3, $08)                                'set up data ready signal
  Wrt_1B(CTRL_REG4, $80)                                'set up "block data update" mode (to avoid bad reads when the values would get updated while we are reading) 
  Wrt_1B(CTRL_REG1, $1F)                                'write a byte to control register one (enable all axis, 100Hz update rate)

  Calibrate

  last_ticks := cnt 

PUB Main
  
    WaitForDataReady 
    Read_MultiB(OUT_X_INC)                              'Read out multiple bytes starting at "output X low byte"
    
    x := x - cx                                         'subtract calibration out
    y := y - cy
    z := z - cz      
    
    ' at 250 dps setting, 1 unit = 0.00875 degrees,
    ' that means about 114.28 units = 1 degree
    ' This will be done in upper level code
    
PUB getx
return x
PUB gety
return y
PUB getz
return z

PUB Calibrate
  cx := 0
  cy := 0
  cz := 0

  repeat 25
    WaitForDataReady
    Read_MultiB(OUT_X_INC)                              ' read the 3 axis values and accumulate
    cx += x
    cy += y
    cz += z

  cx /= 25                                              ' calculate the average
  cy /= 25
  cz /= 25

    
PUB WaitForDataReady | status
    repeat
      status := Read_1B(STATUS_REG)                     ' read the ZYXZDA bit of the status register (looping until the bit is on)
      if (status & $08) == $08
        quit
                        
PUB Wrt_1B(SUB1, data)

  ''Write single byte to Gyroscope.
  
      start
      send(WRITE)                   'device address as write command
        'slave ACK
      send(SUB1)                    'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      send(data)                    'data you want to send
        'slave ACK
      stop
 
PUB Wrt_MultiB(SUB2, data, data2)

 ''Write multiple bytes to Gyroscope.

      start
      send(WRITE)                   'device address as write command
        'slave ACK
      send(SUB2)                    'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      send(data)                    'data you want to send
        'slave ACK
      send(data2)                   'data you want to send
        'slave ACK
      stop

PUB Read_1B(SUB3) | rxd

 ''Read single byte from Gyroscope

      start
      send(WRITE)                   'device address as write command
        'slave ACK
      send(SUB3)                    'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      stop
      start                         'SR condition
      send(READ)                    'device address as read command
        'slave ACK
      rxd := receive(false)         'recieve the byte and put in variable rxd
      stop
  
     result := rxd

PUB Read_MultiB(SUB3) 

 ''Read multiple bytes from Gyroscope

     start
      send(WRITE)                     'device address as write command
        'slave ACK
      send(SUB3)                       'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      stop
      start                           'SR condition
      send(READ)                      'device address as read command
        'slave ACK
      multiBYTE[x_idx] := (receive(true)) |  (receive(true)) << 8         'Receives high and low bytes of Raw data
      multiBYTE[y_idx] := (receive(true)) |  (receive(true)) << 8                                                                                 
      multiBYTE[z_idx] := (receive(true)) |  (receive(false)) << 8 
      stop
  
      x := ~~multiBYTE[x_idx]
      y := ~~multiBYTE[y_idx]
      z := ~~multiBYTE[z_idx]

PRI send(value)  ' I²C Send data - 4 Stack Longs 

  value := ((!value) >< 8)

  repeat 8
    dira[SDApin]       := value
    dira[SCLpin]       := false
    dira[SCLpin]       := true
    value >>= 1

  dira[SDApin]         := false
  dira[SCLpin]         := false
  result               := not(ina[SDApin])
  dira[SCLpin]         := true
  dira[SDApin]         := true

PRI receive(aknowledge) ' I²C receive data - 4 Stack Longs
                                  
  dira[SDApin]         := false

  repeat 8
    result <<= 1
    dira[SCLpin]       := false
    result             |= ina[SDApin]
    dira[SCLpin]       := true

  dira[SDApin]         := (aknowledge)
  dira[SCLpin]         := false
  dira[SCLpin]         := true
  dira[SDApin]         := true

PRI start ' 3 Stack Longs

  outa[SDApin]         := false
  outa[SCLpin]         := false
  dira[SDApin]         := true
  dira[SCLpin]         := true

PRI stop ' 3 Stack Longs

  dira[SCLpin]         := false
  dira[SDApin]         := false
                 