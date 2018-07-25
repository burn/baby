local ok=require("test").ok 
local Data=require("data")
local lib=require("lib")

local close=lib.close

local function dataOkay(f)
  return Data:new():csv("../data/".. f .. ".csv") 
end 
  
local function weatherOkay()   
  local d = dataOkay("weather") 
  print(#d.rows)
  assert( close( d.all.syms[1]:ent(),  1.58, 1) ) 
  assert( close( d.all.syms[2]:ent(),  0.98, 1) )  
  assert( close( d.all.syms[3]:ent(),  0.94, 1) )  
  assert( close( d.all.nums[1].mu,    73.57, 1) )
  assert( close( d.all.nums[1]:sd(),   6.48, 1) )  

end

ok {weather = function() weatherOkay()        end }
ok {weatherData = function() dataOkay("weather")        end }
ok {auto = function() dataOkay("auto")        end }
--ok {weatherData = function() dataOkay("weather")        end }
--00ok {weatherOkay  = function() weatherOkay()        end }
--ok {autoData     = function() dataOkay("auto")     end }
--ok {auto10KData  = function() dataOkay("auto10K")  end }
--ok {auto100KData = function() dataOkay("auto100K") end }

-- function domOkay()
--   for _,f in pairs{"auto", "auto1K", 
-- 	           "auto2K", "auto3K" } do
-- 	  --"auto10K", --"auto100K", --"auto1000K"} do
--      say(f)
--      local d = dataOkay(f)
--      local fast = {}
--      say(" " .. when(function() d:bests(true) end)) 
--      for _,row in pairs(d.rows) do
--        fast[row.id] = row.dom end
--      say(" " .. when(function() d:bests() end)) 
--      local some = Sample:new()
--      for _,row in pairs(d.rows) do
--        some:inc(row.dom - fast[row.id]) end 
--      print(" ", join(some:tiles{10,30,50,70,90}))
--   end
-- end
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
