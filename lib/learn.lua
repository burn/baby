Lib    = require("lib")
Object = require("object")
Data   = require("data")
Abcd   = require("abcd")
Csv    = require("csv")

Learner = Object:new{train,test,log}

function Learner:new(file,rx)
  local x = Object.new(self)
  x._log = Abcd:new(file, rx)
  x.data = Data:new()
  return x
end

function Learner:log(want,got)
  self._log:inc(want,got)
end

local function Learn(file, learners, era)
  local era   = era or 20
  local klass = function(r) return r.cells[d.klass.pos] end
  local test  = function(todo)  
    for _,row in pairs(todo) do
      for _,x in pairs(learners) do x.test(row) end end
  end
  local todo={}
  local keep= function(row)
    todo[ #todo+1 ] = row
    if #todo > era then test(todo) ; todo={} end
  end
  local n=0
  for row in Csv(file) do
    for _,x in pairs(learners) do x.train(row) end
    if n > 0 then keep(row) end
    n = n + 1
  end
  for _,x in pairs(learners) do 
    Lib.cols( x._log:report(), "%5.0f" ) end
end

local function xx(file)
  k = Learner:new(file,"knn")
  k.test= function(row)
            local x= row:nearest(k.d.rows, k.d.x.cols)
	    k.log( row:klass(k.d), x:klass(k.d) ) end
  k.train= function(row) 
	     return k.d:inc(row) end
  Learn(file, {k})
end

xx("../data/diabetes.csv")

return Learn    
