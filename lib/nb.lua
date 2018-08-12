local Lib    = require("lib")
local Burn   = require("burn")
local Learn  = require("learn")
local Object = require("object")

Nb = {}
Nb = Object:new{maybes=0, name="nb"}

--------- --------- --------- --------- --------- --------- 
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
  Learn.report(era,log,self.name,goal)
end

return Nb
