OBJ

   ir : "IRDetector"
   

VAR
    Long distance, up_or_down

PUB Start(anode, cathode, recieve)


    ir.Init(anode, cathode, recieve)
    
    
PUB Main
    
        
  distance := ir.distance                          
  if distance =< 195
      up_or_down := 1
          
          
  if distance => 195
      up_or_down := 0
 
  
  waitcnt(CLkfreq/100 + CNT)

PUB GetDist

    return distance

PUB GetUD

    return up_or_down
      
        
        
        