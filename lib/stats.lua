require "thing"

local tests = {
  {2,	{"x1",	0.34,	 0.49,	 0.51,	  0.6},	
        {"x2",	6,	 7,	 8,	  9}},	  -- two grups 
  {2,   {"x1",	0.1,	 0.2,	 0.3,	  0.4},	
        {"x2",	0.1,	 0.2,	 0.3,	  0.4},	
	{"x3",	6,	 7,	 8,	  9}},	 -- 2 groups
  {3,	{"x1",	0.34,	 0.49,	 0.51,	  0.6},	
        {"x2",	0.6,	 0.7,	 0.8,	  0.9},	
        {"x3",	0.15,	 0.25,	 0.4,	  0.35},	
        {"x4",	0.6,	 0.7,	 0.8,	  0.9},	
        {"x5",	0.1,	 0.2,	 0.3,	  0.4}},	
  {1,	{"x1",	101,	 100,	 99,	  101,	 99.5},	
        {"x2",	101,	 100,	 99,	  101,	 100},	
        {"x3",	101,	 100,	 99.5,	  101,	 99},	
        {"x4",	101,	 100,	 99,	  101,	 100}},	
  {1,	{"x1",	11,	 11,	 11},	
        {"x2",	11,	 11,	 11},	
        {"x3",	11,	 11,	 11}},	
  {2,	{"x1",	11,	 11,	 11},	
        {"x2",	11,	 11,	 11},	
        {"x4",	32,	 33,	 34,	35}}}

local function bigTest()
  local t1,t2,t3 = {"x1"},{"x2"},{"x3"}
  for i = 1,256 do t1[ #t1+1 ] = rand()^0.5 end
  for i = 1,256 do t2[ #t2+1 ] = rand()^2   end
  for i = 1,256 do t3[ #t3+1 ] = rand()     end
  return {3,  t1, t2, t3}
end

function cliffsDelta(t1, t2, small,max)
  local max = max or 1000
  local small = small or 0.147
  local n,lt,gt = 0,0,0
  if #t1 > max then
     t1 = slice(shuffle(t1), 1, max) end
  if #t2 > max then
     t2 = slice(shuffle(t2), 1, max) end
  for _,x in pairs(t1) do
    for _,y in pairs(t2) do
      n = n + 1
      if x > y then gt = gt + 1 end
      if x < y then lt = lt + 1 end end end
  return abs(gt - lt) / n < (small or 0.147) 
end

function cliffsDeltaOkay()
  for i=10,1,-1 do
    local a,b={},{}
    for _=1,10000 do a[#a+1] = rand() end
    for j,x in pairs(a) do b[j] = x*i/10 end
    print(i, cliffsDelta(a,b))
  end
end

cliffsDeltaOkay()

-- def cliffsDelta(lst1,lst2,
--                 dull = [0.147, # small
--                         0.33,  # medium
--                         0.474 # large
--                         ][0] ):
--   n= gt = lt = 0.0
--   for x in lst1:
--     for y in lst2:
--       n += 1
--       if x > y:  gt += 1
--       if x < y:  lt += 1
--   return abs(lt - gt)/n > dull

function bootstrap(y0, z0, conf, b)
  local function testStatistic(y, z) 
    local d = z.mu - y.mu
    local s = y:sd() + z:sd()
    return s==0 and delta or  
           d / ((y:sd()/y.n + z:sd()/z.n)^0.5)
  end
  local function sample(t)
    u = {}; for i=1,#t do u[ #u+1 ] = any(t) end
    return u
  end
  conf = conf or 0.95
  b    = b or 512
  local x = Num:new():incs(y0):incs(z0)
  local y = Num:new():incs(y0)
  local z = Num:new():incs(z0)
  local tobs = testStatistic(y, z)
  local yhat, zhat = {}, {}
  for _,y1 in pairs(y0) do yhat[#yhat+1]= y1 - y.mu+x.mu end
  for _,z1 in pairs(z0) do zhat[#zhat+1]= z1 - z.mu+x.mu end
  local bigger = 0
  for i in 1,b do
    if testStatistic( Num:new():incs(sample(yhat)),
                      Num:new():incs(sample(zhat))) > tobs then
      bigger = bigger + 1 end end
  return bigger / b < conf
end

function different(t1,t2)
  return cliffsDelta(t1,t2) and bootstrap(t1,t2)
end

Pairs = Any:new{all, stats}
function Pairs:new(t)
  m = getmetatable(self)
  x = Pairs:new(self)
  x.all   = t
  x.stats = Num:new():incs(t)
  return x
end

function Pairs._lt(a,b) return a.stats.mu < b.stats.mu end 

-- function scottknott(data,cohen, small, epsilon)
--   cohen = cohen or 0.3
--   local all = {}
--   for _,one in pairs(data) do all:incs(one.all) end
--   small = small or all.stats:sd()*cohen
--   local function div(1, #data, all)
--     local left,right = Num:new(), Num:new():incs(all)    
-- 
--   local function split(data, lo, ho)
--   all  = reduce(lambda x,y:x+y,data)
--   same = lambda l,r: abs(l.median() - r.median()) <= all.s()*cohen
--   if useA12:
--     same = lambda l, r:   not different(l.all,r.all) 
--   big  = lambda    n: n > small
--   return rdiv(data,all,minMu,big,same,epsilon)
-- 
-- def rdiv(data,  # a list of class Nums
--          all,   # all the data combined into one num
--          div,   # function: find the best split
--          big,   # function: rejects small splits
--          same, # function: rejects similar splits
--          epsilon): # small enough to split two parts
--   """Looks for ways to split sorted data, 
--   Recurses into each split. Assigns a 'rank' number
--   to all the leaf splits found in this way. 
--   """
--   def recurse(parts,all,rank=0):
--     "Split, then recurse on each part."
--     cut,left,right = maybeIgnore(div(parts,all,big,epsilon),
--                                  same,parts)
--     if cut: 
--       # if cut, rank "right" higher than "left"
--       rank = recurse(parts[:cut],left,rank) + 1
--       rank = recurse(parts[cut:],right,rank)
--     else: 
--       # if no cut, then all get same rank
--       for part in parts: 
--         part.rank = rank
--     return rank
--   recurse(sorted(data),all)
--   return data
-- 
-- def maybeIgnore((cut,left,right), same,parts):
--   if cut:
--     if same(sum(parts[:cut],Num('upto')),
--             sum(parts[cut:],Num('above'))):    
--       cut = left = right = None
--   return cut,left,right
-- 
-- def minMu(parts,all,big,epsilon):
--   """Find a cut in the parts that maximizes
--   the expected value of the difference in
--   the mean before and after the cut.
--   Reject splits that are insignificantly
--   different or that generate very small subsets.
--   """
--   cut,left,right = None,None,None
--   before, mu     =  0, all.mu
--   for i,l,r in leftRight(parts,epsilon):
--     if big(l.n) and big(r.n):
--       n   = all.n * 1.0
--       now = l.n/n*(mu- l.mu)**2 + r.n/n*(mu- r.mu)**2  
--       if now > before:
--         before,cut,left,right = now,i,l,r
--   return cut,left,right
-- 
-- def leftRight(parts,epsilon=The.epsilon):
--   """Iterator. For all items in 'parts',
--   return everything to the left and everything
--   from here to the end. For reasons of
--   efficiency, take a first pass over the data
--   to pre-compute and cache right-hand-sides
--   """
--   rights = {}
--   n = j = len(parts) - 1
--   while j > 0:
--     rights[j] = parts[j]
--     if j < n: rights[j] += rights[j+1]
--     j -=1
--   left = parts[0]
--   for i,one in enumerate(parts):
--     if i> 0:
--       if parts[i]._median - parts[i-1]._median > epsilon:
--         yield i,left,rights[i]
--       left += one
-- """
-- 
-- 
-- ## Putting it All Together
-- 
-- Driver for the demos:
-- 
-- """
-- def rdivDemo(data):
--   def zzz(x):
--     return int(100 * (x - lo) / (hi - lo + 0.00001))
--   data = map(lambda lst:Num(lst[0],lst[1:]),
--              data)
--   print("")
--   ranks=[]
--   for x in scottknott(data,useA12=True):
--     ranks += [(x.rank,x.median(),x)]
--   all=[]
--   for _,__,x in sorted(ranks): all += x.all
--   all = sorted(all)
--   lo, hi = all[0], all[-1]
--   line = "----------------------------------------------------"
--   last = None
--   print(('%4s , %12s ,    %s   , %4s ' % \
--                ('rank', 'name', 'med', 'iqr'))+ "\n"+ line)
--   for _,__,x in sorted(ranks):
--     q1,q2,q3 = x.quartiles()
--     print(('%4s , %12s ,    %4s  ,  %4s ' % \
--                  (x.rank+1, x.name, q2, q3 - q1))  + \
--               xtile(x.all,lo=lo,hi=hi,width=30,show="%5.2f"))
--     last = x.rank 
-- 
-- def _rdivs():
--   seed(1)
--   rdiv0();  rdiv1(); rdiv2(); rdiv3(); 
--   rdiv5(); rdiv6(); print("###"); rdiv7()
-- 
-- ####################################
-- 
-- def thing(x):
--     "Numbers become numbers; every other x is a symbol."
--     try: return int(x)
--     except ValueError:
--         try: return float(x)
--         except ValueError:
--             return x
--           
-- def main():
--   log=None
--   all={}
--   now=[]
--   for line in sys.stdin:
--     for word in line.split():
--       word = thing(word)
--       if isinstance(word,str):
--         now = all[word] = all.get(word,[])
--       else:
--         now += [word]
--   rdivDemo( [ [k] + v for k,v in all.items() ] ) 
-- 
--   
-- if args.demo:
--   _rdivs()
-- else:
--   main()
--   


