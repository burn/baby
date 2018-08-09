local Ok   = require("test").ok 
local Knn  = require("knn")

local function dataOkay(f)
  local d = Knn:new():csv("../data/".. f .. ".csv") 
  print(22)
  return d
end 

Ok{ knn = function()
	    local x= Knn:new(5, "../data/diabetes.csv")
	    x.log:show()

end }
