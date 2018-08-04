local Data = require("data")
local Abcd = require("abcd")
local Lib  = require("lib")

Knn=Data:new{era=1}

function Knn:new()
  local k  = Data.new(self)
  k.log = nil
  return k
end

function Knn:csv(file)
  self.log = Abcd:new(file, "knn") 
  print(1)
  Data.csv(self,file)
  print(2)
  return self.log
end

function Knn:data(cells)
  local row  = Data.data(self,cells)
  local near = row:nearest(self.rows, self.x.cols)
  local want = row[  self.klass.pos ]
  local got  = near[ self.klass.pos ] 
  self.log:inc( want, got )
  return row
end

return Knn
