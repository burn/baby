local Data = require("data")
local Csv = require("csv")
local Abcd = require("abcd")
local Object  = require("object")
local Lib  = require("lib")

rand, say,eras = Lib.rand, Lib.say, Lib.eras

--------- --------- --------- --------- --------- --------- 
Knn=Object:new()

function Knn:train(cells, data)
  data:inc(cells)
end

function Knn:test(cells, data, log)
  local row= Row:new{cells=cells}
  local near = row:nearest(data.rows, data.x.cols)
  log:inc( data:class(row), data:class(near) )
end

function Knn:report(era,log)
  print("\n"..era)
  for _,log1 in pairs(log) do
    local r=log1:report()
    if r["tested_positive"] then
     print(r["tested_positive"].f) end
  end
end

--------- --------- --------- --------- --------- --------- 
ZeroR = Object:new()

function ZeroR:train(cells, data)
   data:inc(cells)
   self.xpect = data._class.mode
end

function ZeroR:test(cells, data, log)
  local row= Row:new{cells=cells}
  log:inc( data:class(row), self.xpect )
end

function ZeroR:report(era,log)
  print("\n"..era)
  for _,log1 in pairs(log) do
    local r=log1:report()
    if r["tested_positive"] then
     print(r["tested_positive"].f) end
  end
end

--------- --------- --------- --------- --------- --------- 
Nb = Object:new()

function Nb:new()
  local n=Object.new(self)
  local n.datas={}
  local n.maybes=0
  return n
end

function Nb:like(cells, data1, m,k, n,     inc)
  local prior= ( #data1.rows + k ) / ( n+ k*self.maybes )
  local like = math.log(prior)
  for _,col in pairs(data1.x.cols) do 
    local x = cells[ col.pos ]
    if x ~= Burn.ignore then
      if col:nump() then
        inc = Lib.normal(x, col.mu, col:sd())
      else
        inc = ( (col.counts or 0) + m * prior ) /
              ( #data1.rows + m )
      end
      like = like + math.log(inc) end end 
  return like
end

function Nb:classify(cells,data0,log)
  local max,got = 0,nil
  for h1,data1 in pairs(self.classes) do
    got = got or h1
    local l = self:like(cells, data1, Burn.nb.m, 
                        Burn.nb.k, #data0.rows)
    if l > max then  max,got = l,h1 end 
  end
  return got
end

function Nb:class1(cells,data0)
  local c = cells[ data0._class.pos ]
  if not self.datas[c] then 
    self.maybes = self.maybes + 1
    self.datas[c] = data0:clone()
  end
  return self.datas[c]
end

function Nb:train(cells,data0)
  local data1 = self:class1(cells,data0)
  data1:inc(cells)
  data0:inc(cells)
end

function Nb:test(cells,data0,log)
  log:inc( data0:class(row), 
           self:classify(cells,data0) )
end

--------- --------- --------- --------- --------- --------- 
function Knn.nways(learner,file,ways,era, silent)
  ways = ways or 3
  era  = era  or 10^32
  local src    = Csv(file)
  local header = src()   -- first line is special. read it first
  local log,data   = {},{}
  for w = 1,ways do  -- make "ways" data stores
    log[w]  = Abcd:new(file, "knn") -- one log shared for all
    data[w] = Data:new()
    data[w]:inc(header) end
  for rows,era1 in eras(src, era) do
    if not silent then say(" " .. era1) end
    for _,cells in pairs(rows) do
      for w = 1,ways do
        if rand() < 1/ways then 
	     --say("?")
          if era1 > 0 and #data[w].rows > 0 then
            learner:test( cells, data[w],log[w]) end
        else learner:train(cells, data[w]) 
	     --say(".") 
        end
      end
    end
    learner:report(era1, log)
  end
  --print("")
  return log
end
 
return Knn
