local object=require "object"
local lib=require "lib"

local rand,int,min,max = lib.rand, lib.int, lib.min, lib.max
local ordered, join    = lib.ordered, lib.join
local sprintf          = lib.sprintf

-------------------------------------------------------------
-- ## Sampling Stuff

local Sample = object:new{max=Burn.sample.max, n=0, all}

function Sample:new(spec) 
  local x=object.new(self,spec) 
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
  y = int(0.5 + #t*y)
  y = min( #t, max( 1, y))
  return t[y] end

function Sample:median() return self:yth(0.5) end

function Sample:shows(all, widths, ps, fmt, sfmt)
  all[ #all+1 ] = self
  lo,hi = 10^32, -10^32
  for _,one in pairs(all) do
    lo1,hi1 = one:yth(0), one:yth(1)
    if lo1 < lo then lo = lo1 end
    if hi1 > hi then hi = hi1 end end
  table.sort(all, function(a,b) return 
	            a:median() < b:median() end)
  for _,one in pairs(all) do 
    one:show(width, ps, fmt, sfmt, lo,hi) end
end

function Sample:show(width, ps, fmt, sfmt, lo, hi)
  local t,f="-"," "
  ps    = ps or {{0.1,t},{0.3,f},{0.5,f},{0.7,t},{0.9,f}} 
  width = width or 50 
  fmt   = fmt or "%5.0f"
  sfmt  = sfmt or "%20s"
  lo    = lo or self:yth(0)
  hi    = hi or self:yth(1)
  local	pos = function(y) 
     y = (self:yth(y) -lo)/(hi - lo + 10^-32)
     return int(width*y)  end
  local b4,mark,tmp = nil,nil,{}
  for i=1,width do tmp[i]=" " end
  for _,pair in pairs(ps) do
    local now,mark1 = pair[1],pair[2]
    if b4 then
      for k = pos(b4),pos(now) do tmp[k]= mark end end 
    b4,mark = now,mark1
  end
  tmp[1], tmp[ #tmp ], tmp[ pos(0.5) ] = "|", "|", "*"
  local pre= self.txt and sprintf(sfmt, self.txt)..", " or "" 
  local out= pre .. join(tmp,"")
  for _,pair in ordered(ps) do
    out = out..", "..sprintf(fmt, self:yth(pair[1])) end 
  print(out)
end

return Sample
