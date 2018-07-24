require("burn")
local lib=require("lib")
local Object=require("object")

local Thing=Object:new{pos,txt,w=1,n=0}

function Thing:incs(t, f)
  f = f or function (z) return z end
  for _,v in pairs(t) do self:inc( f(v) ) end 
  return self
end

function Thing:inc(x)
  if x==Burn.ignore then return x end
  self.n = self.n + 1
  return self:inc1(x) 
end

function Thing:prep(x) return x end

function Thing:dec(x)
  if x==Burn.ignore then return x end
  if self.n < 3    then return x end
  self.n = self.n - 1
  return self:dec1(x) 
end

function Thing:simpler(i,j) 
  local  n = self.n
  return self.doubt() > The.ish*(i.doubt()*i.n/n + 
                                 j.doubt()*j.n/n) 
end

function Thing:norm(x) return x end

-- ### Thing:best(rows [, o]): function
-- Returns a function that returns true if a row selects for best ranges.
-- o = {x,y,enough=10,min=false}
function Thing:best(rows, enough, y, min)
  y   = y or function (r) return r.cells[#r.cells] end
  min = min or false
  return self:best1(rows,  
      self:eq(x, x(rows[1]), 0), 
      enough or 10,
      function(r) return r.cells[self.pos] end,
      function(r) return min and 1-y(r) or y(r) end)
end

local Split=Object:new{txt,rule, op, val}

function Split:show() return self.txt..self.op..self.val end

function Thing:eq(x, val,score)
  return Split:new{txt=self.txt, 
     score= score, 
     val  = val, op="=", 
     rule = function(r) return x(r)==val end} 
end

function Thing:gt(x, val,score)
  return Split:new{txt=self.txt, 
     score= score, 
     val  = val, op=">", 
     rule = function(r) return x(r) > val end} 
end

function Thing:le(x, val,score)
  return Split:new{txt=self.txt, 
     score= score, 
     val  = val, op="<=", 
     rule = function(r) return x(r) <= val end} 
end

return Thing,Split

 
--main{thing=numIncOkay}
