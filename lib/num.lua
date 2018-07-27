-- ## class Num
-- Incremental collector of numeric statistics.
-- Place to store number tricks
--
require("burn")
local Thing=require("thing")
local Split=require("split")
local L=require("lib")

local copy,  interpolate,   abs,   max,   min  = 
     L.copy, L.interpolate, L.abs, L.max, L.min

-----------------------------------------------------------
-- `Num`s are a kind of `Thing`
local Num= Thing:new{lo=Burn.inf, hi=Burn.ninf, mu=0, m2=0} 

-- Polymorphism. `doubt` is a term used for entropy and sd
function Num:doubt() return self:sd() end

-- Compute sd
function Num:sd()
  return (self.m2/(self.n - 1 + Burn.zip))^0.5  
end

-- Add 1 number
function Num:inc1(x)
  local d = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  if    x > self.hi then self.hi = x end
  if    x < self.lo then self.lo = x end
  return x
end

-- Delete 1 number
function Num:dec1(x)
  local d = x - self.mu
  self.mu = self.mu - d/self.n
  self.m2 = self.m2 - d*(x - self.mu)
end

-- Normalize 1 number 0..1, min..max
function Num:norm(x) 
  return (x - self.lo)/(self.hi - self.lo + Burn.zip) 
end

-----------------------------------------------------------
--Many distributions are not normal so I use this tTestSame as a heuristic for speed criticl calcs. E.g. in the inner inner loop of some search where i need a quick opinion, is "this" the same as "that".
-- But when assessing experimental results after all the algorithms have terminated, I use a much safer, but somewhat slower, procedure (bootstrap)
function Num:same(j,  conf,  small)
    return self:hedges(j, small or Burn.num.small) or
           self:ttest( j, conf  or Burn.num.conf)  
end

function Num:ttest(j,  conf)
    local i  = self
    conf = conf or Burn.num.conf
    local df = min(i.n - 1, j.n - 1)
    local xs= {     1,     2,     5,    10,    15,    20,    25,    30,    60,  100}
    local ys = {}
    ys[0.9] = { 3.078, 1.886, 1.476, 1.372, 1.341, 1.325, 1.316, 1.31,  1.296, 1.29}
    ys[0.95]= { 6.314, 2.92,  2.015, 1.812, 1.753, 1.725, 1.708, 1.697, 1.671, 1.66}
    ys[0.99]= {31.821, 6.965, 3.365, 2.764, 2.602, 2.528, 2.485, 2.457, 2.39,  2.364}
    return (abs(i.mu - j.mu) / 
	    ((i:sd()/i.n + j:sd()/j.n)^0.5) ) < interpolate(df, xs, ys[conf]) 
end
    
-- Hedge's rule (using g):
-- based on <em>Systematic Review of Effect Size in
-- Software Engineering Experiments</em>
-- Kampenes, Vigdis By, et al. Information and Software Technology 49.11 (2007): 1073-1086. See equations 2,3,4 and Figure 9
function Num:hedges(j,small)
    small = small or 0.38
    local i = self
    local num   = (i.n - 1)*i:sd()^2 + (j.n - 1)*j:sd()^2
    local denom = (i.n - 1) + (j.n - 1)
    local sp    = ( num / denom )^0.5
    local delta = abs(i.mu - j.mu) / sp
    local c     = 1 - 3.0 / (4*(i.n + j.n - 2) - 1)
    return delta * c < small
end

-------------------------------------------------------------
-- ### Discretization.
-- Find the best place to cut a column such that one of the
-- cuts maximizes the `y` scoring function. Cuts must contain
-- at least `enough` items.
function Num:best1(rows,  the)
  local enough,  x, y = the.enough, the.x, the.y
  local cut, best = nil, -1
  local left = Num:new()
  local right= Num:new():incs(rows, y)
  rows = L.sorted(rows, function(a,b) return x(a) < x(b) end)
  for i,row in pairs(rows) do
    left:inc(  y(row) )
    right:dec( y(row) )
    if i > #rows - enough then break end
    if i > enough then
      local below = (left.n  / #rows) * left.mu  / right.mu 
      local above = (right.n / #rows) * right.mu / left.mu 
      if above > best and not left:same(right) then
	best,cut = above, Split.gt(x, self.txt, x(row), right.mu) end
      if below > best and not left:same(right) then 
	best,cut = below, Split.le(x, self.txt, x(row), left.mu) end end 
  end 
  return cut
end

-------------------------------------------------------------
-- And finally...
return Num
