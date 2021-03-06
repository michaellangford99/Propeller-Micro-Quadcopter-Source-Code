{{
****************************************************
* MMA7455 3-Axis Accelerometer Spin DEMO #1 Ver 2  *
* Author: Kevin McCullough                         *
* Author: Beau Schwabe                             *
* Copyright (c) 2009 Parallax                      *
* See end of file for terms of use.                *
****************************************************

'=================================================================================================

 ┌──────────────────────────────┬──────┬──────────────────────┬───────┬──────────┐
 │ Kalman_Acc.spin              │ 2015 │ Michael J. Langford  │Vs. 2.1│10/29/2015│
 ├──────────────────────────────┴──────┴──────────────────────┴───────┴──────────┤
 │Slightly modified basic acc. demo, almost all written by Kevin M. and Beau S.  │
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

   History:
                                Version 1 - (03-25-2009) initial concept
                                Version 2 - (06-10-2009) first DEMO release  

How to Use:
 • With board power initially off, connect VIN to 3.3VDC (the same voltage
   powering the Propeller).  Connect GND to board ground.

 • Connect P0, P1, and P2 on the Propeller directly to the CLK, DATA, and CS
   pins on the Digital 3-Axis Accelerometer module.

 • Make sure the "FullDuplexSerial.spin" and "MMA7455L_SPI_v2.spin" files are
   present in the same folder as this top-level spin file.

 • Start the Parallax Serial Terminal and set the baud to 38,400 and set the
   proper COM port.  The Parallax Serial Terminal is available on the Propeller
   Software Downloads web page

 • Power on the board.  Download and run this code on the propeller.

 • After Enabling the Parallax Serial Terminal, Check and then Un-Check the
   DTR button on the Parallax Serial Terminal.  
 
 • Acceleration values will stream back to the computer, and can be viewed
   using a generic serial terminal such as the Parallax Serial Terminal
   available on the Propeller Software Downloads web page.

 • The offset values for each axis can be calibrated by placing the device 
   on a flat horizontal surface and adjusting the corresponding constants
   until the values for each axis read (while in 2g mode):
        X = 0   (0g)
        Y = 0   (0g)
        Z = 63  (+1g)
   The values already present are for demonstration purposes and can
   be easily modified to fine tune your own device. Keep in mind that
   the offset values are in 1/2 bit increments, so for example, to offset
   an axis by 5 counts, the corresponding offset would need to be increased
   by a value of 10.  See the MMA7455L device datasheet for more
   information.

}}

CON

  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  CLKPIN        = 8
  DATAPIN       = 9
  CSPIN         = 10
  
  X_OFFSETVAL   = 0             ' X-Axis offset compensation value
  Y_OFFSETVAL   = 21          ' Y-Axis offset compensation value
  Z_OFFSETVAL   = 0             ' Z-Axis offset compensation value
{{
        The Offset value is an iterative process.
        To adjust the Offset, set X_OFFSETVAL, Y_OFFSETVAL, and Z_OFFSETVAL to Zero
        and run the program.

        Multiply the returned value by 2 and subtract from the corresponding current
        offset value.

                  0 - -28 = 28

        Note: - The Offset is valid only at Zero-g, so you will need to orient the
                Z axis so that it is perpendicular to the influence of gravity.

              - At rest, it is possible to see a g force greater than 1 or less than
                1 (where 1g returns 63) because depending on where you are, the force
                of gravity can be stronger or weaker depending on your elevation.   
  
}}
VAR

  long  XYZData[3]
  
OBJ

  SPI           : "MMA7455L_SPI_v2"      'Used to Communicate to the Accelerometer
  
PUB Start_Acc
  
  dira[11]~~
  outa[11] := 0  
  dira[7]~~
  outa[7] := 1
  SPI.start(CLKPIN, DATAPIN, CSPIN)
  
  waitcnt(clkfreq/100+cnt)
  
  SPI.write(SPI#XOFFL, X_OFFSETVAL)                         
  SPI.write(SPI#XOFFH, X_OFFSETVAL >> 8)
  SPI.write(SPI#YOFFL, Y_OFFSETVAL)
  SPI.write(SPI#YOFFH, Y_OFFSETVAL >> 8)
  SPI.write(SPI#ZOFFL, Z_OFFSETVAL)
  SPI.write(SPI#ZOFFH, Z_OFFSETVAL >> 8)
  
PUB stop

    SPI.stop
      
PUB Main

    Read8BitData(SPI#G_RANGE_2g)

PUB GetX

    return ~XYZData[0]

PUB GetY

    return ~XYZData[1]

PUB GetZ

    return ~XYZData[2]

PUB Read8BitData(G_RANGE)
    SPI.write(SPI#MCTL, (%0110 << 4)|(G_RANGE << 2)|SPI#G_MODE) 'Initialize the Mode Control register
    XYZData[0] := SPI.read(SPI#XOUT8)                       'repeat for X-axis
    XYZData[1] := SPI.read(SPI#YOUT8)                       'repeat for Y-axis
    XYZData[2] := SPI.read(SPI#ZOUT8)                       'and Z-axis

PUB Read10BitData
    SPI.write(SPI#MCTL, (%0110 << 4)|SPI#G_MODE)                 'Initialize the Mode Control register
    DataIn_High := SPI.read(SPI#XOUTH)                       'repeat for X-axis
    DataIn_Low  := SPI.read(SPI#XOUTL)
    XYZData[0]  := DataIn 
    DataIn_High := SPI.read(SPI#YOUTH)                       'repeat for Y-axis
    DataIn_Low  := SPI.read(SPI#YOUTL)
    XYZData[1]  := DataIn    
    DataIn_High := SPI.read(SPI#ZOUTH)                       'and Z-axis
    DataIn_Low  := SPI.read(SPI#ZOUTL)
    XYZData[2]  := DataIn    

DAT

DataIn        word              ' Data positioning trick to convert Words to Bytes
DataIn_Low    byte    0         ' or Bytes to a Word without using any math overhead
DataIn_High   byte    0

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