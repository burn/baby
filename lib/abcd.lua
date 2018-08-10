local Object=require("object")
local Lib=require("lib")

-----------------------------------------------------------
local Abcd = Object:new{yes=0, no=0}

function Abcd:new(db,rx)
  local x = Object.new(self)
  x.known, x.a, x.b, x.c, x.d = {},{},{},{},{}
  x.rx = rx or "rx"
  x.db = db or "db"
  return x
end

-----------------------------------------------------------
function Abcd:has(x)
  if not self.known[x] then
    self.a[x] = 0
    self.b[x] = 0
    self.c[x] = 0
    self.d[x] = 0
    self.known[x] = 0
  end
  self.known[x] = self.known[x] + 1
  if self.known[x] == 1 then
    self.a[x] = self.yes + self.no end
end 

-----------------------------------------------------------
function Abcd:inc(want, got)
  self:has(want)
  self:has(got)
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

-----------------------------------------------------------
function Abcd:report()
  local p = function(x) return 100*x end
  local n = function(x) return x     end
  local out = {}
  for x,_ in pairs(self.known) do
    local pd,pf,pn,prec,g,f,acc = 0,0,0,0,0,0,0
    local a,b,c,d = self.a[x], self.b[x], 
                    self.c[x], self.d[x]
    if b+d > 0     then pd   = d     / (b+d) end
    if a+c > 0     then pf   = c     / (a+c) end
    if a+c > 0     then pn   = (b+d) / (a+c) end
    if c+d > 0     then prec = d     / (c+d) end
    if 1-pf+pd > 0 then g=2*(1-pf) * pd / (1-pf+pd) end
    if prec+pd > 0 then f=2*prec*pd / (prec + pd)   end
    if self.yes + self.no > 0 then 
       acc  = self.yes / (self.yes + self.no) end
    out[x] = {
       db=self.db, rx=self.rx, num=a+b+c+d, a=a, b=b, 
       c=c, d=d, acc=p(acc),  prec=p(prec), pd=p(pd),  
       pf=p(pf), f=p(f)}
  end
  return out
end

-----------------------------------------------------------
function Abcd:show()
  local head={"db", "rx", "num", "a", "b", 
       "c", "d", "acc",  "prec", "pd",  
       "pf", "f"}
  local t={}
  t[1] = head
  t[1][#head+1] = "class"
  local j
  for class,row in pairs(self:report()) do
     new={}
     for k,f in pairs(head) do
       j=k
       new[k] = row[f] end 
       new[ #new+1 ] = class
     t[ #t+1] = new
  end
  Lib.cols( t , "%5.0f" ) 
end

-----------------------------------------------------------
return Abcd
