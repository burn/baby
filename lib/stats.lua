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
  if #t1 > max then t1 = slice(shuffle(t1), 1, max) end
  if #t2 > max then t2 = slice(shuffle(t2), 1, max) end
  for _,x in pairs(t1) do
    for _,y in pairs(t2) do
      n = n + 1
      if x > y then gt = gt + 1 end
      if x < y then lt = lt + 1 end end end
  return abs(gt - lt) / n < small 
end

function cliffsDeltaOkay()
  for i=10,1,-1 do
    local a,b={},{}
    for _=1,10000 do a[#a+1] = rand() end
    for j,x in pairs(a) do b[j] = x*i/10 end
    print(i, cliffsDelta(a,b))
  end
end

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
  b = b or 512
  conf = conf or 0.95
  local function testStatistic(y, z) 
    local d = z.mu - y.mu
    local s = y:sd() + z:sd()
    return s==0 and delta or  
           d / ((y:sd()/y.n + z:sd()/z.n)^0.5)
  end
  local function sample(t)
    u = {}
    for i=1,#t do u[ #u+1 ] = any(t) end
    return u
  end
  local x = Num:new():incs(y0):incs(z0)
  local y = Num:new():incs(y0)
  local z = Num:new():incs(z0)
  local tobs = testStatistic(y, z)
  local yhat, zhat = {}, {}
  for _,y1 in pairs(y0) do yhat[#yhat+1]= y1 - y.mu + x.mu end
  for _,z1 in pairs(z0) do zhat[#zhat+1]= z1 - z.mu + x.mu end
  local bigger = 0
  for i = 1,b do
    if testStatistic( Num:new():incs(sample(yhat)),
                      Num:new():incs(sample(zhat))) > tobs then
      bigger = bigger + 1 end end
  return bigger / b < conf
end

function bootstrapOkay()
  local repeats=10
  for i=100,10,-10 do
    local bs,cd,cnt = 0,0,0
    for r=1,repeats do
      local l, k = 1, max(0.5,rand()*2)
      local a,b={},{}
      for x=1,3000,30 do a[#a+1] = weibull(x/1500, l,       k)       end
      for x=1,3000,30 do b[#b+1] = weibull(x/1500, l*i/100, k*i/100) end
      local same1 = bootstrap(a,b)
      local same2= cliffsDelta(a,b)  
      if same1 then bs=bs+1 end
      if same2 then cd=cd+1 end
      if same1 or same2 then cnt=cnt+1 end end
    print(i, int(100*bs/repeats), 
             int(100*cd/repeats), int(100*cnt/repeats)) end
end

--bootstrapOkay()

function bootstrap1Okay()
  print(" ")
  local repeats=30
  for i=100,10,-10 do
    local bs,cd,cnt = 0,0,0
    for r=1,repeats do
      local a,b={},{}
      local l, k = 1, max(0.5,rand()*5)
      for x=1,1000,10  do a[#a+1] = rand()      end
      for x=1,1000,10  do b[#b+1] = rand()*i/100 end
      local same1 = bootstrap(a,b)
      local same2= cliffsDelta(a,b)  
      if same1 then bs= bs+1 end
      if same2 then cd= cd+1 end
      if same1 or same2 then cnt=cnt+1 end end
    print(i, int(100*bs/repeats), 
             int(100*cd/repeats), int(100*cnt/repeats)) end
end

bootstrap1Okay()

function bootstrap2Okay()
  local samples = function(m1,s1, m2,s2)
    local a,b,xs={},{},{}
    for x=-2,2,0.1 do 
      xs[#xs+1] = x
      a[#a+1] = normCdf(x, m1, s1) 
      b[#b+1] =  normCdf(x, m2, s2) 
      print(x,a[#a],b[#b])
    end 
    -- print(join(sorted(collect(a,
    --      function(z) return round(z,0.001) end))))
    --print(join(sorted(collect(b,
    --      function(x) return round(x,3) end))))
    --rint(join(b))
    local n1=Num:new():incs(a)
    local n2=Num:new():incs(b)
    print(n1.mu, n1:sd(), n2.mu, n2:sd())
    local same1 = bootstrap(a,b)
    local same2 = cliffsDelta(a,b)  
    print(m1,m2, s1,s2, same1, same2, same1 or same2) 
  end
  print(" ")
  samples(-0.5,1,  0.5, 1)
  --samples(1, 0.1, 0.5, 0.1)
  --samples(-0.1, 0.1, 0.1, 0.1)
end

bootstrap2Okay()

function same(t1,t2)
  return cliffsDelta(t1,t2) or bootstrap(t1,t2)
end


