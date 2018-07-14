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
end

function Sym:dec1(x)
  self._ent= nil
  i.counts[x] = i.counts - 1
  return x 
end

Range=Any:new{score=0, val, f, all, stats}
function Range:new(col, val, f)
   x= Any.self:new(self)
   x.col, x.val, x.score = col, val, 0
   x.f,   x.all, x.stats = f, {}, Num:new()
   return x
end

function Range:inc(row)
  push( row, self.all )
  x.stats:inc( self.f(row) )
end

function Range:done(n)
  return self.stats.n / n * self.stats.mu 
end
  
function Sym:best(rows, f)
  local n, all = {}, #rows
  for _,row in pairs(rows) do
    local val   = row.cells[self.pos]
    local one = all[val] or Range:new(self, val,f)
    one:inc(row)
    all[val] = one end
  return sorted(all,
           function (x,y) return x:done(n) > y:done(n) end)[1]
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
end

function Num:dec1(x)
  local d = x - self.mu
  self.mu = self.mu - d/self.n
  self.m2 = self.m2 - d*(x - self.mu)
end

function Num:norm(x) 
  return (x - self.lo)/(self.hi - self.lo + The.zip) end

 function Num:best(rows, f)
  rows = sorted(rows, function(x,y) 
	          return x.cells[self.pos] < y.cells[self.pos] end)
  left, right=Num:new(), Num:new()
  for _,row in pairs(rows) do right:inc(row.cells[self.pos]) end
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
