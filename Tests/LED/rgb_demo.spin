CON

  _clkmode = xtal1 + pll16x                                     ' 16x required for WS2812                              
  _xinfreq = 5_000_000                                          ' use 5MHz crystal
 
obj

  led : "rgb"                                        ' single-shot WS2812 LED driver

pub main | x

  led.start_b(0)                           
 repeat
  repeat x from 1 to 255
           led.set_rgb(0, 255-x, x, 0, -1)
           led.execute(5, -1, -1)
           waitcnt(clkfreq/400 + cnt)

  repeat x from 1 to 255
           led.set_rgb(0, 0, 255-x, x, -1)
           led.execute(5, -1, -1)
           waitcnt(clkfreq/400 + cnt)

  repeat x from 1 to 255
           led.set_rgb(0, x, 0, 255-x, -1)
           led.execute(5, -1, -1)
           waitcnt(clkfreq/400 + cnt)   
 
pri redlight

led.setx(0, $FF_00_00, 255, -1)
led.execute(5, -1, -1)

pri greenlight

led.setx(0, $00_FF_00, 255, -1)
led.execute(5, -1, -1)

pri bluelight

led.setx(0, $00_00_FF, 255, -1)
led.execute(5, -1, -1)

pri orangelight

led.setx(0, $FF_60_00, 255, -1)
led.execute(5, -1, -1)

pri whitelight

led.setx(0, $C8_FF_FF, 255, -1)
led.execute(5, -1, -1)

pri blacklight

led.setx(0, $00_00_00, 255, -1)
led.execute(5, -1, -1)       