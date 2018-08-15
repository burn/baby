
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

function Frule:inc(todo,s,xpect)
  local old = self.score
  if todo then
    self.score = self.score + xpect end
  self.steps[ #self.steps+1 ] = {todo, s}
  return self,self.score - old
end

function Frule:show()
  --for _,x in pairs(self.steps) do Lib.oo(x) end
  --if true then return true end
  local pre="if"
  print()
  print(self.score)
  for i=#self.steps,2,-1 do
    print(pre, self.steps[i][2]:show(),"then",self.steps[i][1])  
    pre="else if"
  end
  print("else",self.steps[1][1])
end

function Fft.policies(depth,  f)
  local out ={}
  local add=function(t,x) 
    local u=copy(t) 
    u[#u+1]=x 
    return u 
  end
  f=function(d, path)
    if   d > depth 
    then out[#out+1] = path 
    else 
      f(d+1,add(path,false))
      f(d+1,add(path,true))
    end
  end
  f(1,{})
  return out
end

--assumes rows have a score 0..1 where 1 is desired.
function Fft:csv(file,goal,depth)
  local data = Data:new()
  for cells in Csv(file) do self:inc(cells, data) end
  return self:learn(data,goal,depth)
end

function Fft:learn(data,goal,depth)
  self.y=function(r) return goal==data:class(r) and 1 or 0 end
  self.enough = (#data.rows)^0.5
  self.data = data
  local out,tmp,best= nil, nil,-1
  for _,policy in pairs(Fft.policies(depth)) do
    tmp = self:grow(depth,policy,data.rows, true)
    if tmp.score >= best then
      out,best = tmp, tmp.score end
  end
  return out
end

function  Fft:grow(d,todos,rows,last)
  local todo=todos[d]
  if #rows >= self.enough and d > 0  then
    local s = self:bestSplit( todo, rows )   
    if s then
      rows1= reject(rows, s.rule) 
      local tmp = self:grow(d-1,todos,reject(rows,s.rule), todo )
      tmp,improvement = tmp:inc(todo, s, s:xpect() )
      if improvement > 0 then return tmp end
    end end
  local stats= Num:new():incs(rows,self.y)
  local proxy ={ score=stats.mu }
  return Frule:new():inc(not last,proxy, stats.mu * stats.n )
end

function Fft:bestSplit(todo,rows)
  local all={}
  for _,col in pairs(self.data.x.cols) do
     local s = col:best(rows,{y=self.y,min=not todo,enough=self.enough})
     if s then all[ #all+1 ] = s end
  end
  table.sort(all,function(a,b)  return a.score < b.score end) 
  return todo and all[#all] or all[1]
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

