local Ok  = require("test").ok 
local Knn = require("learn") 

Ok {knn = function ()
            Knn("../data/diabetes.csv")
end}


