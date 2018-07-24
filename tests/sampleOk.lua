local ok=require("test").ok 
local sam=require "sample" 
local lib=require "lib"

local int,rand,join,sorted = 
      lib.int, lib.rand, lib.join,lib.sorted

ok { basicSample = function(      n,a,b,c,d,e)
       n = 512 
       a = sam:new{max=n}
       b = sam:new{max=n}
       c = sam:new{max=n}
       d = sam:new{max=n}
       e = sam:new{max=n}
       for i=1,10000 do 
	  a:inc(int(1000* rand()^1.4)) 
	  b:inc(int(1000* rand()^1.2)) 
	  c:inc(int(1000* rand())) 
	  d:inc(int(1000* 2*rand()^0.5)) 
	  e:inc(int(1000* 2*rand()^0.33))  
       end
       a:shows({b,c,d,e},50)
end }



