local Object=require "object"
local Lib=require "lib"

local rand,int,min,max = Lib.rand, Lib.int, Lib.min, Lib.max

-------------------------------------------------------------
-- ## Sampling Stuff

local Sample = Object:new{max=The.sample.max, n=0, all}

function Sample:new(spec) 
  x=Object.new(self,spec) 
  x.all = {}
  x.sorted = false
  return x 
end

-- Sample:inc(x): x
-- Keep at most `max` number of items (selected at random).
function Sample:inc(x)
  self.n = self.n + 1
  local now = #self.all
  if now < self.max then self:inc1( #self.all+1, x) 
  else if rand() < now/self.n then
    self:inc1( int(0.5+ rand() * now),  x) end end
  return x 
end

function Sample:inc1(i,x)
  self.all[i] = x
  self.sorted= false
end

function Sample:ordered()
  if not self.sorted then table.sort(self.all) end
  self.sorted = true
  return self.all
end

function Sample:yth(y)
  local t= self:ordered()
  y = int(0.5 + y*#all)
  y = min( #all, max( 1, want))
  return t[y] end

function Sample:tiles(want)
  local got = {}
  for i,y in pairs(want or {0,1}) do got[i]= self:yth(y) end
  return got
end

function Sample:median() return self:yth(0.5) end

function Sample:shows(all, ps, width)
  all = all[ #all+1 ] = self
  lo,hi = 10^32, -10^32
  for _,one in pairs(all) do
    lo1,hi1 = one:range{0,1}
    if lo1 < lo then lo = lo1 end
    if hi1 > hi then hi = hi1 end end
  table.sort(all, function(a,b) a:median() < b:median() end)
  for _,one in pairs(all) do one:show(ps, width, lo, hi) end
end

function Sample:show(ps, width, lo, hi)
  ps    = ps    or {0.1,0.3,0.5,0.7,0.9}, 
  width = width or 50
  lo    = lo or self:yth(0)
  hi    = hi or self:yth(0)
  local	pos = function(y) 
     math.floor(0.5+ width*(self:yth(y) - lo / (hi - lo))) end
  local toggle,b4,tmp = true,0,{}
  for i=1,width do tmp[i]=" " end
  for i,j in pairs(ps) do
    for k = pos(b4),pos(j) do tmp[i]= toggle and "-" or " " end
    b4 = j
    toggle = not toggle  end
  tmp[1], tmp[ #tmp ] = "|","|",
  tmp[ pos(0.5) ] = "*"
  local out = table.contact(tmp)
  for i,here in pairs(ps) do
    out = out .. ", " .. self:yth(here) end
  print(out)
end

return Sample
