local Object=require("object")

local Split=Object:new{txt,rule, op, val,n=0,score=0}

function Split:show() return self.txt..self.op..self.val end

function Split:xpect()
   return self.n*self.score
end

-- ## Factory: Split.eq
-- Returns a spliter on x==val
function Split.eq(x, txt, val, n,score)
  return Split:new{txt=txt, 
     score= score, 
     val  = val, 
     op   = "=", 
     n    = n,
     rule = function(r) return x(r)==val end} 
end

-- ## Factory: Split.gt
-- Returns a spliter on x>val
function Split.gt(x, txt,val,n,score)
  return Split:new{txt=txt, 
     score= score, 
     val  = val, 
     op   = ">", 
     n    = n,
     rule = function(r) return x(r) > val end} 
end

-- ## Factory: Split.le
-- Returns a spliter on x <= val
function Split.le(x,txt, val,n,score)
  return Split:new{txt=txt, 
     score= score, 
     val  = val, 
     op   = "<=", 
     n    = n,
     rule = function(r) return x(r) <= val end} 
end

return Split
