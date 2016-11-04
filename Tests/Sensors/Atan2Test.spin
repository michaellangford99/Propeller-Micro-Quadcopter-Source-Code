CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
  FULL_CIRCLE = 360
  
VAR
  
   
OBJ                      
  pst : "Parallax Serial Terminal"
  
PUB Main
  pst.start(115_200)
                   
  repeat
    pst.dec(atan2(pst.decin, pst.decin))
 
 
PUB atan2(y, x) | arg, adder, n
{{
atan2 function from Phil Pilgrim
Propeller forums 5-7-2010
}}
'' Four-quadrant arctangent. Y and X are signed integers.
'' FULL_CIRCLE is an integer constant equal to the number of units in a full circle.
 
  if ((n := >|(||x <# ||y)) > 21)
    x ~>= n - 21
    y ~>= n - 21
  if (||x > ||y)                     
    arg := y << 10 / x
    adder := constant(FULL_CIRCLE / 2) & (x < 0)
  else
    arg := -x << 10 / y
    adder := constant(FULL_CIRCLE / 4) + constant(FULL_CIRCLE / 2) & (y < 0)
  result := arg * constant(FULL_CIRCLE * 14551 / 100000) / (936 + (arg * arg) >> 12) + adder
  result += FULL_CIRCLE & (result < 0)
   