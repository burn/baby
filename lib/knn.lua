local Row    = require("row")
local Learn  = require("learn")
local Object = require("object")

--------- --------- --------- --------- --------- --------- 
Knn={}

Knn=Object:new{name="knn"}

function Knn:inc(cells, data)
  data:inc(cells)
end

function Knn:predict(cells, data)
  local row  = Row:new{cells=cells}
  local near = row:nearest(data.rows, data.x.cols)
  return data:class(near)
end

function Knn:report(era,goal, log)
  Learn.report(era,log,self.name, goal)
end

return Knn
