.{
 ************************************************************************************************************
 *                                                                                                          *
 *  AUTO-RECOVER NOTICE: This file was automatically recovered from an earlier Propeller Tool session.      *
 *                                                                                                          *
 *  ORIGINAL FOLDER:     C:\...\Propeller Tool v1.3\MJL QuadCopterMazebot\Unit_Tests\LogicHandeler\         *
 *  TIME AUTO-SAVED:     over 1 day ago (8/20/2014 7:07:39 AM)                                              *
 *                                                                                                          *
 *  OPTIONS:             1)  RESTORE THIS FILE by deleting these comments and selecting File -> Save.       *
 *                           The existing file in the original folder will be replaced by this one.         *
 *                                                                                                          *
 *                           -- OR --                                                                       *
 *                                                                                                          *
 *                       2)  IGNORE THIS FILE by closing it without saving.                                 *
 *                           This file will be discarded and the original will be left intact.              *
 *                                                                                                          *
 ************************************************************************************************************
.}
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

     long yaw

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

   
   yaw := 0
   repeat
        g.main
        yaw := g.getz / 10 
        p.Main
        l.SetSensorData(0, 196, yaw, 0, 0, 0, 0)
        l.Main
        s.Clear
        s.Dec(l.GetMotorPower(1))
        s.Str(string(13))
        s.Dec(l.GetMotorPower(2))
        s.Str(string(13))
        s.Dec(l.GetMotorPower(3))
        s.Str(string(13))
        s.Dec(l.GetMotorPower(4))
        s.Str(string(13))

        s.Dec(yaw)
        s.Str(string(13))
        
        m.Set(l.GetMotorPower(1), l.GetMotorPower(2), l.GetMotorPower(3), l.GetMotorPower(4))
                 
        m.Fly