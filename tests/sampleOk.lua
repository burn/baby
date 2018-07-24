local ok=require("test").ok 
local sam=require("sample")
local lib=require("lib")

local int,rand,join,sorted = 
      lib.int, lib.rand, lib.join,lib.sorted

ok { basicSample = function(      m,n,a,b,c,d,e)
       n = 64 
       a = sam:new{max=n}
       b = sam:new{max=n}
       c = sam:new{max=n}
       d = sam:new{max=n}
       e = sam:new{max=n}
       a.txt, b.txt, c.txt, d.txt, e.txt=
          "apples","bananas","carrots","durian","eggfruit"
       m = 100
       for i=1,10000 do 
	  a:inc(int(0 - m * rand()^2)) 
	  b:inc(int(    m * rand()^1.2)) 
	  c:inc(int(    m * rand())) 
	  d:inc(int(    m * 2*rand()^0.5)) 
	  e:inc(int(    m * 2*rand()^0.33))  
       end
       a:shows({b,c,d,e},50, {{0.25,"-"}, {0.5,"-"}, {0.75," "}})
       print("")
       a:shows({b,c,d,e},50)
end }



