CON
   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000



OBJ
                            
   l : "pidlogic"
   s : "Parallax Serial Terminal"
   p : "IRRadar"
   m : "MotorHandeler Vs 5.0"
   g : "Gtest"

VAR

     long yaw, pitch, roll
     long stack[1000]
     long stack2[1000]
     long myself

PUB Start | prox[2]

   prox.BYTE[0] := 191
   prox.BYTE[1] := 1
    m.Start
    m.fly

    g.startup
    
    
   ' repeat 9000                         
    m.Set(500, 500, 500, 500)       'set values         
    m.Fly                   'run with changes
    Waitcnt(clkfreq/1000 + CNT)  'pace the cog 

    repeat 9000                          
        m.Set(900, 900, 900, 900)      'set values         
        m.Fly                   'run with changes
        
    
   s.Start(115_200)
   p.Start(23, 25, 27)
   l.Start
   cognew(gyro, @stack)
   cognew(stop, @stack2) 

   
   
   repeat
        
        myself := cogid  
        p.Main
        l.SetSensorData(0, 196, 0, pitch, roll, 0, 0)
        l.Main
        
        s.Clear
        s.Dec(l.GetMotorPower(1))
        s.Str(string(13))
        s.Str(string(13))
        s.Dec(pitch)
        s.Str(string(13))
        s.Dec(roll)
        
        m.Set(l.GetMotorPower(1), l.GetMotorPower(2), l.GetMotorPower(3), l.GetMotorPower(4))
                 
        m.Fly

Pub gyro


  repeat
        g.main
        yaw := g.getz / 100
        roll := g.getx / 100
        pitch := -g.gety / 100


Pub stop

  repeat
    if s.Decin == 0
        cogstop(myself)
        m.Set(800, 800, 800, 800)
        m.Fly