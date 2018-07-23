local ok=require("test").ok 

local lib=require "lib"

ok { interpolate = function ()
  assert(lib.interpolate(0, {1,2,4}, {10,20,40}) == 10) 
  assert(lib.interpolate(4, {1,2,4}, {10,20,40}) == 50) 
  assert(lib.interpolate(3, {1,2,4}, {10,20,40}) == 30) 
end}

ok { shuffle = function()
  local t= {}
  lib.rseed(1)
  for i = 1,9  do t[i] = i end
  for _ = 1,10 do print( lib.join( lib.shuffle(t), "") )  end 
end}

ok {sub= function()
  assert(lib.sub("timm")     == "timm")
  assert(lib.sub("timm",2)   == "imm")
  assert(lib.sub("timm",2,3) == "im")
  assert(lib.sub("timm",-1)  == "m")
  assert(lib.sub("aa",3,10)  == "")
end}


