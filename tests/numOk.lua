local ok=require("test").ok 
local Num=require("Num")
local lib=require("lib")

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


