VAR
  long p_const, i_const, d_const
  long target
  long p_val, i_val, d_val
  long pi_error, d_error
  long last_error

  long p, i, d, final 
   
OBJ
  f  : "FloatMath"
  
PUB Init(pc, ic, dc, targ)

    p_const := pc
    i_const := ic
    d_const := dc

    target := targ

pub set_constants(pc, ic, dc)

    p_const := pc
    i_const := ic
    d_const := dc

pub set_target(t)

    target := t
    
pub Main(value)

    pi_error   := target - value
    d_error      := pi_error - last_error      

    p := f.fmul(f.ffloat(pi_error),p_const)              
    i := f.fadd(i, f.fmul(f.ffloat(pi_error),i_const))        
    d := f.fmul(f.ffloat(d_error  )   ,d_const)                            

    final := f.fround(f.fdiv(f.fadd(f.fadd(p, i), d), f.ffloat(3)))   
    

    last_error := pi_error

    return final

      