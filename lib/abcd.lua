local Object=require("object")
local Lib=require("object")
local sprintf = Lib.sprintf

Abcd = Object:new(yes=0, no=0)

function Abcd:new(db,rx)
  local x = Object.new(self)
  x.known, x.a, x.b, x.c, x.d = {},{},{},{},{}
  x.rx = rx or "rx"
  x.db = db or "db"
end
------------------------------------------------------------------
function Abcd:known(x)
  if not self.known[x] then
    self.a[x], self.b[x], self.c[x], self.d[x] = 0,0,0,0
    self.known[x] = 0
  end
  self.known[x] = self.known[x] + 1
  if self.known[x] == 1 then
    self.a[x] = self.yes + self.no end
end 

----------------------------------------------  
function Abcd:inc(want, got)
  self:known(want)
  self:known(got)
  if   want == got 
  then self.yes = self.yes + 1
  else self.no  = self.no  + 1 
  end 
  for x,_ in pairs(self.known) do
    if want == x then
      if   want == got then
           self.d[x] = self.d[x] + 1
      else self.b[x] = self.b[x] + 1 end 
    else
      if   got == x then
           self.c[x] = self.c[x] + 1
      else self.a[x] = self.a[x] + 1 end end end 
end

------------------------------------------------
function Abcd:show()
  local order = {"db","rx","num","a","b","c","d",
                 "acc", "prec","pd","pf","f","class"}
  local tmp = {}
  for i,txt in ipairs(order) do
    if i==1 then txt = "#"..txt end
    tmp[#tmp+1] = txt
  end
  tmp = {tmp}
  for klass,result in ordered(self:report()) do
    result["class"] = klass
    local line = {}
    for i = 1,#order do
     line[ #line + 1 ] = result[order[i]]
    end
    tmp[#tmp+1] = line 
  end
  report(tmp)
end
------------------------------------------------------------------
function  Abcdd:report()
  local p = function(x) return sprintf("%.1f",100*x) end
  local n = function(x) return sprintf("%s"  ,x)     end
  local out = {}
  for x,_ in pairs(self.known) do
    local pd,pf,pn,prec,g,f,acc = 0,0,0,0,0,0,0
    local a,b,c,d = self.a[x], self.b[x], self.c[x], self.d[x]
    if b+d > 0        then pd   = d     / (b+d) end
    if a+c > 0        then pf   = c     / (a+c) end
    if a+c > 0        then pn   = (b+d) / (a+c) end
    if c+d > 0        then prec = d     / (c+d) end
    if 1-pf+pd    > 0 then g    = 2 * (1-pf) * pd / (1-pf+pd) end
    if prec+pd    > 0 then f    = 2 * prec*pd / (prec + pd)   end
    if self.yes+self.no > 0 then 
       acc  = self.yes / (self.yes + self.no) end
    if true then
    out[x] = {
      db=self.db, rx = self.rx, yes = n(b+d), all = n(a+b+c+d),
      a=n(a),   b=n(b),    c=n(c), d= n(d), acc = p(acc),
      pd=p(pd), pf=p(pf),  prec=p(prec), num = n(b+d),
      f=p(f),   g=p(g),    x=x}
    end end
  return out
end

