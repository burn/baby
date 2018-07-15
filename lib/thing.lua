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

Split=Any:new{txt,rule, op, val}

function Split:show() return self.txt..self.op..self.val end

-----------------------------------------------------------
-- ### Thing:best(rows [, o]): function
-- Returns a function that returns true if a row selects for best ranges.
-- o = {x,y,enough=10,min=false}
function Thing:best(rows, enough, y, min)
  y   = y or function (r) return r.cells[#r.cells] end
  min = min or false
  return self:best1( 
      rows,  
      self:eq(x, x(rows[1]), 0), 
      enough or 10
      function(r) return r.cells[self.pos] end,
      function(r) return min and 1-y(r) or y(r) end)
end

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


-----------------------------------------------------------
--Many distributions are not normal so I use this tTestSame as a heuristic for speed criticl calcs. E.g. in the inner inner loop of some search where i need a quick opinion, is "this" the same as "that".
-- But when assessing experimental results after all the algorithms have terminated, I use a much safer, but somewhat slower, procedure (bootstrap)
function Num:same(j,  conf. small)
    return self:ttest(i,conf or 0.95) or self:hedges(j, small or 0.38)

function Num:ttest(j,  conf)
    local i = self
    conf = conf or 0.95
    local df = min(i.n - 1, j.n - 1)
    local xs= {            1,     2,     5,    10,    15,    20,    25,    30,    60,  100},
    local ys= {0.9=  { 3.078, 1.886, 1.476, 1.372, 1.341, 1.325, 1.316, 1.31,  1.296, 1.29},
               0.95= { 6.314, 2.92,  2.015, 1.812, 1.753, 1.725, 1.708, 1.697, 1.671, 1.66},
               0.99= {31.821, 6.965, 3.365, 2.764, 2.602, 2.528, 2.485, 2.457, 2.39,  2.364}}
    return interpolate(df, xs, ys[conf]) >= 
           abs(i.mu - j.mu) / ((i:sd()/i.n + j:sd()/j.n)**0.5) 
end
    
-- Hedge's rule (using g):
--    """
---    Hedges effect size test.
--    Returns true if the "i" and "j" difference is only a small effect.
--    "i" and "j" are   objects reporing mean (i.mu), standard deviation (i.s)
--    and size (i.n) of two  population of numbers.
--    """
-- - Still parametric
-- - Modifies &Delta; w.r.t. the standard deviation of both samples.
-- - Adds a correction factor c for small sample sizes.
-- - In their review of use of effect size in SE, Kampenses et al. report that many papers use something like g &lt; 0.38
--  is the boundary between small effects and bigger effects.
-- Systematic Review of Effect Size in
-- Software Engineering Experiments
-- Kampenes, Vigdis By, et al. Information and Software Technology 49.11 (2007): 1073-1086. See equations 2,3,4 and Figure 9
function hedges(j,small):
    small = small or 0.38
    local i = self
    local num   = (i.n - 1)*i:sd()**2 + (j.n - 1)*j:sd()**2
    local denom = (i.n - 1) + (j.n - 1)
    local sp    = ( num / denom )**0.5
    local delta = abs(i.mu - j.mu) / sp
    local c     = 1 - 3.0 / (4*(i.n + j.n - 2) - 1)
    return delta * c < small
end

-------------------------------------------------------------
function Num:best1(rows, cut, enough, x y)
  local best = -1
  local left = Num:new()
  local right= Num:new():incs(rows, y)
  rows = sorted(rows, function(a,b) return x(a) < x(b) end)
  for i,row in pairs(rows) do
    left:inc(  y(row) )
    right:dec( y(row) )
    if i > #row - enough then break end
    if i > enough then
      local below  = (left.n  / #rows) * left.mu  / right.mu 
      local above  = (right.n / #rows) * right.mu / left.mu 
      if above > best then 
	best,cut = tmp, self:gt(x, x(row), right.mu) end 
      if below > best then 
	best,cut = tmp, self:le(x, x(row), left.mu) end end 
  end 
  return cut
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
