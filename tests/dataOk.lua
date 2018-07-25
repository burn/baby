local ok=require("test").ok 
local Data=require("data")
local Sample=require("sample")
local lib=require("lib")

local printf,close,say,when = lib.printf,lib.close,lib.say,lib.when

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

--ok {weatherData = function() dataOkay("weather")    end }
ok {weather     = function() weatherOkay()          end }
--ok {auto        = function() dataOkay("auto")       end }
--ok {auto10K     = function() dataOkay("auto10K")    end }
--ok {auto100K    = function() dataOkay("auto100K")   end }
--ok {auto1000K   = function() dataOkay("auto1000K")  end }



ok {domOkay= function()
   for _,f in pairs{"auto", "auto1K", "auto2K", "auto3K","auto5K","auto10K"} do
 	  --"auto10K", --"auto100K", --"auto1000K"} do
      local d = dataOkay(f)
      local fast = {}
      printf("%10s %10s  %.5f ", f, #d.rows, when(function() d:bests(true) end)) 
      for _,row in pairs(d.rows) do fast[row.id] = row.dom end
      printf(" %.5f ",  when(function() d:bests() end)) 
      local some = Sample:new()
      for _,row in pairs(d.rows) do some:inc(100*(row.dom - fast[row.id])/#d.rows) end 
      some:show(50)
   end
 end}


-- 
-- function attrOkay()
--   local d= dataOkay("auto")
--   d:bests(true)
--   local y = function(row) return w[row.id] or 0 end
--   for _, row in pairs(best) do
--      if y(row) > 0 then
--         print(ooo(row:has(d,"y","nums")), y(row)) end end
-- end
-- -------------------------------------------------
-- -- ## Main Stuff
-- --main{data=weatherOkay}
--  main{data=domOkay}
