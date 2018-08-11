----------------------------------------
-- class Sym
local Thing = require("thing") 
local Num   = require("num") 
local Split = require("split") 
local L = require("lib") 

local Sym= Thing:new{counts,mode,most=0,_ent}

function Sym:new(spec)
  local x = Thing.new(self, spec)
  x.counts = {} 
  return x
end

function Sym:nump() return true end

function Sym:doubt() return self:ent() end

function Sym:ent()
  if self._ent == nil then
    self._ent=0
    for x,n in pairs(self.counts) do
      local p      = n/self.n
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
function Sym:distance(i,j) 
  local no = Burn.ignore
  if     j == no and i == no then return 0,0  
  elseif j == no             then return 1,1
  elseif i == no             then return 1,1 
  elseif i ==j               then return 0,1 
  else                            return 1,1 end 
end

-----------------------------------------------------------
function Sym:best1(rows, enough, x,y)
  local cut, best, nums =  nil,-1, {}
  for _,row in pairs(rows) do
    local val = x(row)
    local num = nums[ val ] or Num:new()
    num:inc( y(row) )
    nums[ val ] = num end
  for val,num in pairs(nums) do 
    if num.n > enough then
      local tmp = num.n/#rows * num.mu 
      if tmp > best then 
        best, cut = tmp, 
	            Split.eq(x, self.txt, val, num) 
  end end end
  return cut
end
  
return Sym 
