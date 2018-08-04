local Ok   = require("test").ok 
local Knn  = require("knn")
local Data = require("data")
local Lib  = require("lib")

local function dataOkay(f)
  local d = Knn:new():csv("../data/".. f .. ".csv") 
  print(22)
  return d
end 

Ok{ knn = function()
    local d = dataOkay("diabetes") 
    print( #d.rows )
    for _,head in pairs(d.x.nums) do
      print(Lib.ooo(head), head:sd()) end
end }
