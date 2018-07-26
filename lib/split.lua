local Object=require("object")

local Split=Object:new{txt,rule, op, val}

function Split:show() return self.txt..self.op..self.val end

-- ## Factory: Split.eq
-- Returns a spliter on x==val
function Split.eq(x, txt, val, score)
  return Split:new{txt=txt, 
     score= score, 
     val  = val, 
     op   = "=", 
     rule = function(r) return x(r)==val end} 
end

-- ## Factory: Split.gt
-- Returns a spliter on x>val
function Split.gt(x, txt,val,score)
  return Split:new{txt=txt, 
     score= score, 
     val  = val, 
     op   = ">", 
     rule = function(r) return x(r) > val end} 
end

-- ## Factory: Split.le
-- Returns a spliter on x <= val
function Split.le(x,txt, val,score)
  return Split:new{txt=txt, 
     score= score, 
     val  = val, 
     op   = "<=", 
     rule = function(r) return x(r) <= val end} 
end

return Split
