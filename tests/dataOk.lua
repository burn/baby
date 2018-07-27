local ok=require("test").ok 
local Data=require("data")
local Num=require("num")
local Sample=require("sample")
local L=require("lib")

local int,printf,close,say,when = L.int,L.printf,L.close,L.say,L.when

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
  local key=function(z)  print(z.score); return z.score end
  local d=dataOkay("auto")
  d:bests()
  local cols={}
  for i,num in pairs(d.x.nums) do
    cols[i] = num:best(d.rows,{min=true,y=function(row) return row.dom end}) 
  end
  cols = L.sorted(cols,function(a,b) return key(a) > key(b) end)
  for _,col in pairs(cols) do
    say(col.txt .." " )
    L.oo(col) end
end
autoBreaks()
os.exit()

ok {divs= function()   
  local d=dataOkay("auto")
  local f=d:bests()
  local hi,lo ={},{}
  for _,num in pairs(d.y.nums) do 
    print(num.pos)
    hi[ num.pos ] = Num:new{txt=num.txt} 
    lo[ num.pos ] = Num:new{txt=num.txt} end
  for _,row in pairs(d.rows) do
    local what = f(row) and hi or lo
    for pos, num in pairs(what) do
       num:inc(row.cells[ pos ]) end end
  for pos,h in pairs(hi) do 
     local l = lo[pos]
     print()
     print("hi",h.txt, int(h.mu), int(h:sd())) 
     print("lo",l.txt, int(l.mu), int(l:sd())) 
   end
end}

ok {weatherData = function() dataOkay("weather")    end }
ok {weather     = function() weatherOkay()          end }
ok {sensory        = function() dataOkay("sensory")       end }
ok {auto        = function() dataOkay("auto")       end }
ok {auto10K     = function() dataOkay("auto10K")    end }
ok {auto100K    = function() dataOkay("auto100K")   end }
ok {canIread_a_million_Records   = function() dataOkay("auto1000K")  end }
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


