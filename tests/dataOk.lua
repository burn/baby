local ok=require("test").ok 
local Data=require("data")
local Sample=require("sample")
local L=require("lib")

local printf,close,say,when = L.printf,L.close,L.say,L.when

local function dataOkay(f)
  local d=  Data:new():csv("../data/".. f .. ".csv") 
  return d
end 
  
local function weatherOkay()   
  local d = dataOkay("weather") 
  assert( close( d.all.syms[1]:ent(),  1.58, 1) ) 
  assert( close( d.all.syms[2]:ent(),  0.98, 1) )  
  assert( close( d.all.syms[3]:ent(),  0.94, 1) )  
  assert( close( d.all.nums[1].mu,    73.57, 1) )
  assert( close( d.all.nums[1]:sd(),   6.572, 1) )  

end
local function sensory()   
  local key=function(split)  return split.score.mu end
  local d=dataOkay("sensory")
  local cols={}
  for _,sym in pairs(d.x.syms) do
    cols[ #cols + 1 ] = sym:best(d.rows) end
  cols  = L.sorted(cols,function(a,b) return key(a) > key(b) end)
  for _,col in pairs(cols) do
    L.oo(col) end
end

local function autoBreaks()   
  local key=function(split)  return split.score.mu end
  local d=dataOkay("auto")
  d:bests()
  local cols={}
  for _,num in pairs(d.x.nums) do
	  print(#cols + 1)
    cols[ #cols + 1 ] = num:best(d.rows) end
  local cols = L.sorted(cols,function(a,b) return key(a) > key(b) end)
  for _,col in pairs(cols) do
    L.oo(col) end
end
autoBreaks()


ok {weatherData = function() dataOkay("weather")    end }
ok {weather     = function() weatherOkay()          end }
ok {sensory        = function() dataOkay("sensory")       end }
ok {auto        = function() dataOkay("auto")       end }
ok {auto10K     = function() dataOkay("auto10K")    end }
ok {auto100K    = function() dataOkay("auto100K")   end }
ok {auto1000K   = function() dataOkay("auto1000K")  end }
ok {weather     = function() weatherOkay()          end }

ok {domOkay= function()
   for _,f in pairs{"auto", "auto1K", "auto2K", "auto3K"} do -- "auto5K","auto10K"} do
      local d = dataOkay(f)
      local fast = {}
      printf("%10s %10s  %.5f ", f, #d.rows, when(function() d:bests(true) end)) 
      for _,row in pairs(d.rows) do  fast[row.id] = row.dom end
      printf(" %.5f ",  when(function() d:bests() end)) 
      local some = Sample:new()
      for _,row in pairs(d.rows) do some:inc(100*(row.dom - fast[row.id])) end 
      some:show(50)
   end
 end}


