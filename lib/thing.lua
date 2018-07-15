require "lib"

Thing=Any:new{pos,txt,w=1,n=0}

function Thing:incs(t, f)
  f = f or function (z) return z end
  for _,v in pairs(t) do self:inc( f(v) ) end 
  return self
end

function Thing:inc(x)
  if x==The.ignore then return x end
  self.n = self.n + 1
  return self:inc1(x) 
end

function Thing:prep(x) return x end

function Thing:dec(x)
  if x==The.ignore then return x end
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
function Thing:best(rows, o)
  o = o or {}
  o.min = o.min or false
  o.x = function(r) return r.cells[self:pos] end
  o.y = o.y or function(r) return r.cells[#r.cells] end
  o.z = function(r) return min and -1*o.y(r) or o.y(r) end 
  return self:best1(rows, o)

----------------------------------------
-- class Sym
Sym= Thing:new{counts,mode,most=0,_ent}

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

Range=Any:new{txt,rule, op, val}

function Range:show() return self.txt..self.op..self.val end

function Sym:best1(rows, o)
  local cut, best, nums = nil, -1, {}
  for _,row in pairs(rows) do
    local val = o.x(row)
    local num = nums[val] or Num:new{txt=val}
    num:inc( o.z(row) )
    nums[val] = num end
  for _,num in pairs(nums) do 
    local tmp = num.n/#rows * num.mu 
    if tmp > best then best, cut = tmp, num.val end end
  local x = o.x
  return Range:new{txt=self.txt, val=cut, op="=",
                   rule=function(row) return x(rows)==cut end}
end
   
----------------------------------------
-- class Num
Num= Thing:new{lo=The.inf, hi=The.ninf, mu=0, m2=0} 

function Num:doubt() return self:sd() end

function Num:sd()
  return (self.m2/(self.n - 1 + The.zip))^0.5  
end

function Num:inc1(x)
  local d = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  if    x > self.hi then self.hi = x end
  if    x < self.lo then self.lo = x end
  return x
end

function Num:dec1(x)
  local d = x - self.mu
  self.mu = self.mu - d/self.n
  self.m2 = self.m2 - d*(x - self.mu)
end

function Num:norm(x) 
  return (x - self.lo)/(self.hi - self.lo + The.zip) end

-- gt or lt
function Num:best1(rows, o)
  local cut,best = nil,-1
  local left  = Num:new()
  local right = Num:new():incs(rows, o.z)
  rows = sorted(rows, function(a,b) return o.x(a) < o.x(b) end)
  for i,row in pairs(rows) do
    left:inc(  o.z(row) )
    right:dec( o.z(row) )
    if i > #row - o.enough then break end
    if i > o.enough then
      local tmp = left.n / #rows * left.mu / right.mu 
      if tmp > best then 
	best,cut = tmp, o.x( rows[i] ) end end end 
  local x = o.x
  return Ranges:new{txt=self.txt, val=cut, op=">", 
                  rule=function(row) return x(row) > cut end}
end
 
function numOkay(    n) 
  n = Num:new()
  local t={4,10,15,38,54,57,62,83,100,100,174,190,215,225,
           233,250,260,270,299,300,306,333,350,375,443,475, 
           525,583,780,1000}
  n:incs(t)
  assert(close(n.mu,   270.3,   0.001))
  assert(close(n:sd(), 231.946, 0.001))
  oo(n)
end

function numIncOkay(    n) 
  local mu, sd, n = {}, {}, Num:new()
  local t={4,10,15,38,54,57,62,83,100,100,174,190,215,225,
           233,250,260,270,299,300,306,333,350,375,443,475, 
           525,583,780,1000}
  for i=1,#t do
    n:inc( t[i] )
    mu[i], sd[i] = n.mu, n:sd() end
  for i=#t,1,-1 do
    if i>2 then
      assert(close( mu[i] , n.mu,   0.01))    
      assert(close( sd[i] , n:sd(), 0.01))    
      n:dec( t[i] ) end end
end

main{thing=numIncOkay}
