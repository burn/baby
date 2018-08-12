local Ok   = require("test").ok 
local Knn  = require("knn")
local Lib  = require("lib")
local Csv  = require("csv")

local function dataOkay(f)
  local d = Knn:new():csv("../data/".. f .. ".csv") 
  print(22)
  return d
end 

-- XXX add in the tiles report

--Ok { eras = function() Lib.rseed(1); local k=Knn:new(); Knn.nways(k,"../data/diabetes.csv", 10,100); print(); end }

--Ok { z = function() Lib.rseed(1); local z=ZeroR:new(); Knn.nways(z,"../data/diabetes.csv", 10,100); print(); end }
	 
Ok { all = function() 
  for _,goal in pairs{"tested_negative", "tested_positive"} do
    print("\n" .. goal)
    Lib.rseed(1); 
    local z=ZeroR:new(); 
    local n=Nb:new(); 
    local k=Knn:new(); 
    Knn.nways({z,k,n},
            goal,
            "../data/diabetes.csv", 
	    10,
	    128); print(); 
  end
end }
