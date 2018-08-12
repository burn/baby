local Data = require("data")
local Csv = require("csv")
local Abcd = require("abcd")
local Object  = require("object")
local Lib  = require("lib")
local Sample  = require("sample")

rand, say,eras = Lib.rand, Lib.say, Lib.eras

--------- --------- --------- --------- --------- --------- 
local function report(era,log,name,k)
  say(era.." " .. Lib.sprintf("%8s ",name))
  local s = Sample:new()
  for _,log1 in pairs(log) do
    local r=log1:report()
    s:inc(r[k].f)
  end
  s:show(25, 
         {{0.10,"-"}, {0.30," "}, {0.5," "},
          {0.7, "-"}, {0.9, "-"}}, 
	 "%4.0f", "%20s",0,100)
end

--------- --------- --------- --------- --------- --------- 
ZeroR = Object:new{name="zeror"}

function ZeroR:inc(cells, data)
   data:inc(cells)
end

function ZeroR:predict(cells, data)
  local z=data._class.mode
  return z
end

function ZeroR:report(era,goal,log)
  report(era,log,self.name, goal)
end

--------- --------- --------- --------- --------- --------- 
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
  report(era,log,self.name, goal)
end

--------- --------- --------- --------- --------- --------- 
Nb = Object:new{maybes=0, name="nb"}

function Nb:new()
  local n=Object.new(self)
  n.datas={}
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

function Nb:what(cells,data0)
  local c = cells[ data0._class.pos ]
  if not self.datas[c] then 
    self.maybes = self.maybes + 1
    self.datas[c] = data0:clone()
  end
  return self.datas[c]
end

function Nb:inc(cells,data0)
  local data1 = self:what(cells,data0)
  data1:inc(cells)
  data0:inc(cells)
end

function Nb:predict(cells,data0)
  local max,got = -10^32,nil
  for h1,data1 in pairs(self.datas) do
    got = got or h1
    local l = self:like(cells, data1, Burn.nb.m, 
                        Burn.nb.k, #data0.rows)
    if l > max then  max,got = l,h1 end 
  end
  return got
end


function Nb:report(era,goal,log)
  report(era,log,self.name,goal)
end


--------- --------- --------- --------- --------- --------- 
function Knn.nways(learners,goal,file,ways,era, silent,logger)
  ways   = ways or 3
  era    = era  or 10^32
  logger = logger or Abcd
  local src    = Csv(file)
  local header = src()   -- first line is special. read it first
  local log,data = {},{}
  for l,learner in pairs(learners) do
    log[l]={}
    data[l]={}
    for w = 1,ways do  -- make "ways" data stores
      log[l][w]  = logger:new(file, learner.name) -- one log shared for all
      data[l][w] = Data:new()
      data[l][w]:inc(header) 
    end
  end
  local line=0
  for rows,era1 in eras(src, era) do
    for _,cells in pairs(rows) do
      line=line+1
      for w = 1,ways do
        if rand() < 1/ways then 
          if era1 > 0 then
	    -- spin learners
            for l,learner in pairs(learners) do
	      if #(data[l][w].rows) >0 then
	        local got = learner:predict(cells, data[l][w]) 
                local want= cells[ data[l][w]._class.pos ]
                log[l][w]:inc(want,got) 
	      end
	    end
          end
        else 
	  -- spin learners
	  for l,learner in pairs(learners) do
	    learner:inc(cells, data[l][w]) end
	end
      end
    end
    -- spin learners
    -- spin over all logs of a learner
    print()
    for l,learner in pairs(learners) do
      learner:report(line, goal,log[l])
    end
  end
end
 
return Knn
