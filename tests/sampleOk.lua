local ok=require("test").ok 
local sam=require "sample" 
local lib=require "lib"

local int,rand,join,sorted = 
      lib.int, lib.rand, lib.join,lib.sorted

ok { basicSample = function ()
       local x = sam:new{max=500}
       for i=1,10000 do x:inc(int(1000* rand()^2)) end
       --assert(x:yth(0.5) < 525 and x:yth(0.5)> 475)
       print( join(x:tiles{0.1,0.3,0.5,0.7,0.9}))
       x:show({0.1,0.3,0.5,0.7,0.9},50,0,1000)
end }



