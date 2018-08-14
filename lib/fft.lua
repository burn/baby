
local Lib=require("lib")
local Data=require("data")
local Csv=require("csv")
local Num=require("num")
local Sym=require("sym")
local Object=require("object")

local say, rep, reject , sprintf,copy = 
      Lib.say, Lib.rep, Lib.reject, Lib.sprintf,Lib.shallowCopy

--------- --------- --------- --------- --------- --------- 

-- FFT = Fast and Frugal Trees
local Fft ={}

Fft = Object:new{ data, root, growths,depth=4}

local Frule={}
Frule = Object:new{ steps, score=0}

function Frule:new()
  local f=Object.new(self)
  f.steps={}
  return f
end

function Frule:inc(policy,s,n)
  if policy then
    self.score = self.score + s.score*n end
  self.steps[ #self.steps+1 ] = {policy,s}
end

function Frule:copy()
  local f = Frule:new()
  f.score = self.score
  f.steps = copy(self.steps)
  return f
end

function Frule:show()
  local pre="if"
  print()
  print(self.score)
  for i=1,(#self.steps) - 1 do
    print(pre, self.steps[i][2]:show(),"then",self.steps[i][1])  
    pre="else if"
  end
  print("else",self.steps[#self.steps][1])
end

function Frule:last()
  return self.steps[ #self.steps ][1]
end

--assumes rows have a score 0..1 where 1 is desired.
function Fft:csv(file,goal,depth)
  local data = Data:new()
  for cells in Csv(file) do self:inc(cells, data) end
  self:learn(data,goal,depth)
end

function Fft:learn(data,goal,depth)
  local y=function(r) return goal==data:class(r) and 1 or 0 end
  local one,out=Frule:new(),{}
  self:grow(data,y,depth,one,out)
  for _,tree in pairs(out) do
    tree:show()
  end
end

function  Fft:grow(data,y,depth,one,out,rows,min,last)
  rows  = rows or data.rows
  last  = last or true
  min   = min  or (#rows)^0.5
  if #rows < min or depth == 0  then
    last = one:last()
    local two = one:copy()
    two:inc(not last, {score=Num:new():incs(rows,y).mu} ,#rows)
    out[ #out + 1 ] = two
  else
    two,three = one:copy(), one:copy()
    self:grow1(true, data,y,depth-1,two,   out,rows,min,last)
    self:grow1(false,data,y,depth-1,three ,out,rows,min,last)
  end
end

function Fft:grow1(policy,data,y,depth,one,out,rows,min,last)
    local s = self:split( policy, data, rows, y )   
    if s then
      local b4=#rows
      rows= reject(rows, s.rule) 
      one:inc(policy, s, b4 - #rows )
      self:grow(data,y,depth, one,out,rows,min,policy )
    end
end

function Fft:split(policy,data,rows,y)
  local all={}
  for _,col in pairs(data.x.cols) do
     local s = col:best(rows,{y=y,min=not policy})
     if s then all[ #all+1 ] = s end
  end
  table.sort(all,function(a,b)  return a.score < b.score end) 
  return policy and all[#all] or all[1]
end 


function Fft:inc(cells,data)
  data:inc(cells)
end

function Fft:predict(cells,data)
  return true
end

function Fft:report(era,goal,log)
  return true
end

return Fft

