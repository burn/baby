local ok=require("test").ok 
local csv=require("csv")

ok {csv = function()
  for row in csv("../data/weather.csv") do
     print(table.concat(row,", ")) end 
end}
