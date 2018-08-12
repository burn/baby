local Ok    = require("test").ok 
local Learn = require("learn")
local Knn   = require("knn")
local Nb    = require("nb")
local ZeroR = require("zeror")
local Lib   = require("lib")

 
Ok { all = function() 
  for _,goal in pairs{"tested_negative", "tested_positive"} do
    print("\n" .. goal)
    Lib.rseed(1); 
    local z=ZeroR:new(); 
    local n=Nb:new(); 
    local k=Knn:new(); 
    Learn.nways({z,k,n},
            goal,
            "../data/diabetes.csv", 
	    10,
	    128); print(); 
  end
end }

