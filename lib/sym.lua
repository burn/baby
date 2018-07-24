----------------------------------------
-- class Sym
local Thing=require("thing") 

local Sym= Thing:new{counts,mode,most=0,_ent}

function Sym:new(spec)
  x = Thing.new(self, spec)
  x.counts = {} 
  return x
end

function Sym:doubt() return self:ent() end

function Sym:ent()
  if self._ent == nil then
    self._ent=0
    for x,n in pairs(self.counts) do
      p      = n/self.n
      self._ent = self._ent - p * math.log(p,2) end end
  return self._ent 
end

function Sym:inc1(x)
  self._ent= nil
  local old = self.counts[x] 
  local new = old and old + 1 or 1
  self.counts[x] = new
  if new > self.most then
    self.most, self.mode = new, x end 
  return x
end

function Sym:dec1(x)
  self._ent= nil
  i.counts[x] = i.counts - 1
  return x 
end

-----------------------------------------------------------
function Sym:best1(rows, cut, enough, x, y)
  local best, nums =  -1, {}
  for _,row in pairs(rows) do
    local num = nums[ x(row) ] or Num:new()
    num:inc( y(row) )
    nums[ x(row) ] = num end
  for val,num in pairs(nums) do 
    if num.n > enough then
      local tmp = num.n/#rows * num.mu 
      if tmp > best then 
        best, cut = tmp, self:eq(x, val, num.mu) end end end
  return cut
end
  
return Sym 
