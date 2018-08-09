local Data = require("data")
local Abcd = require("abcd")
local Object  = require("object")
local Lib  = require("lib")

Knn=Object:new()

function Knn:new(enough, file)
  local x     = Object.new(self)
  local test  = function(row, data) x:test( row, data) end
  x.log       = Abcd:new(file, "knn") 
  x.enough    = enough 
  Data:new():csv(file, test)
  return x
end

function Knn:test(row, data)
  if #data.rows > self.enough then
    local near = row:nearest(data.rows, data.x.cols)
    self.log:inc( data:class(row), data:class(near) )
  end 
end
 

return Knn
