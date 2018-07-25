require "burn"
local lib=require("lib")
local Num=require("num")

local E,     abs,     any,     slice,     shuffle = 
      lib.E, lib.abs, lib.any, lib.slice, lib.shuffle

local Stats={}

function Stats.cliffsDelta(t1, t2, small,max)
  local max   = max   or Burn.sample.cliffsMax
  local small = small or Burn.sample.cliffsDelta
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

function Stats.weibull(x,l,k)
  return x < 0 and 0 or k/l*(x/l)^(k-1)*E^(-1*(x/l)^k)
end

function Stats.weibullCdf(x,l,k)
  return x < 0 and 0 or 1-E^(-(x/l)^k)
end

function Stats.normal(x, mu, sigma)
    return E^(-.5 * (x-mu)*(x-mu)/(sigma*sigma)) / 
           math.sqrt(2.0*math.pi*sigma*sigma)
end

function Stats.normCdf(x, mu, sigma)
    return 0.5 * (1.0 + E^((x-mu)/math.sqrt(2*sigma*sigma)))
end

function Stats.bootstrap(y0, z0, conf, b)
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

function Stats.same(t1,t2)
  return Stats.cliffsDelta(t1,t2) or Stats.bootstrap(t1,t2)
end

return Stats

