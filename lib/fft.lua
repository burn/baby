
local Lib=require("lib")
local Data=require("data")
local Csv=require("csv")
local Num=require("num")
local Sym=require("sym")
local Object=require("object")

local say, rep, reject , sprintf = 
      Lib.say, Lib.rep, Lib.reject, Lib.sprintf

--------- --------- --------- --------- --------- --------- 

-- FFT = Fast and Frugal Trees
local Fft ={}

Fft = Object:new{ data, root, growths,depth=4}


-- function Fft:new(spec)
--   x = Any.new(self, spec)
--   x.root = Fft1:new()
--   return x
-- end
-- 
-- Fft1 = BTree:new{ key,value, l,r}
-- 
-- ### control(num: number, bits: integer): table
-- Returns an array of size `2^bits` whose `i-th` element is true if the `i`-th bit is set. 
-- - e.g. sets(3,2) ==> {true,false}    
-- - e.g. sets(16,4) ==> {true, true, true, true}
function Fft.control(num, bits)
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local out = {} 
    for b = bits, 1, -1 do
        out[b] = math.fmod(num, 2) 
        num = math.floor((num - out[b]) / 2)
	out[b] = out[b] > 0 end
    return out
end

function Fft.controls(depth) 
  depth = depth or 4
  local max = 2^depth
  local out={}
  for j=0,max-1 do out[j+1]=Fft.control(j,depth) end
  return out
end

--assumes rows have a score 0..1 where 1 is desired.
function Fft:csv(file,goal,depth)
  local data = Data:new()
  local y=function(r) return goal==data:class(r) and 1 or 0 end
  for cells in Csv(file) do self:inc(cells, data) end
  for _,policies in pairs(self.controls(depth)) do
    print()
    self:grow(data,policies,y)
  end
end

function Fft:grow(data,policies,y,rows,depth,above,min)
  rows  = rows or data.rows
  depth = depth or 1
  last  = last or true
  min   = min or (#rows)^0.5
  local pre= sprintf("%4s :", #rows) .. rep(" |.. ",depth-1) .. " "
  if #rows < min or depth > #policies then
    print(" " .. pre .. "==> ", not above)
  else
    local policy = policies[depth]
    local s = self:split( policy, data, rows, y )   
    if s then
      for _,w in pairs{pre,s:show(), "==>", 
  	             policy, sprintf("%4.2f",s.score)} do
  	  say( " " .. tostring(w) ) end; print()
      rows= reject(rows, s.rule) -- <<= XXX wrong. need to compute the rejected set
      self:grow(data,policies,y,rows,depth+1,policy,min) end
  end
end

function Fft:split(policy,data,rows,y)
  local all={}
  for _,col in pairs(data.x.cols) do
     local s = col:best(rows,{y=y,min=not policy})
     if s then all[ #all+1 ] = s end
  end
  table.sort(all,function(a,b)  return a.score < b.score end) 
  return policy and all[#all] or all[1]
end 


function Fft:inc(cells,data)
  data:inc(cells)
end

function Fft:predict(cells,data)
  return true
end

function Fft:report(era,goal,log)
  return true
end

return Fft

