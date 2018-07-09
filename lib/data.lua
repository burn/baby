require "csv"

------------------------------
-- ## Data class
-- Holds rows of data.
-- Data columns are classified in numerous ways.
-- 
-- - Independent and depdendent columns are labelled `x,y` (respectively);
-- - `nums` and `syms` hold numeric or symbolic columns,
-- - goals to be maximized/minimized are held in `less,more`
-- - If the data has a class, that is held in `klass`. 
--
-- Note that the above categories are not mutually exclusive.
-- and many columns have multiple categories (e.g. `x.nums`,
-- `y.less`, etc).

Data = Any:new{
  name, header, klass,
  rows={}, 
  all={nums={}, syms={}, cols={}}, -- all columns
  x  ={nums={}, syms={}, cols={}}, -- all independents
  y  ={nums={}, syms={}, cols={},  -- all dependent columns
       less={}, more={}}}  

Row = Any:new{cells, _dom, best=false}

-------------------------------------------------
-- ## Data Methods
--
-- ### Data:csv(file: string)
-- Read data in  from `file`. Return `self`.
function Data:csv(file)
  for row in csv(file) do self:inc(row) end 
  return self end

-- ### Data:inc(row: list)
-- If this is the first row, interpret `row` as the column headers.
-- Otherwise, read `row` as data.
function Data:inc(row)
  if   self.header then self:data(row) 
  else self.header=row; self:head(row) end end

-- ### Data:data(row: list)
-- Add `row` to `self.rows`. Increment the header statistics
-- with information from `row`'s values.
function Data:data(row) 
   push( Row:new{cells=row}, self.rows )
   for _,thing in pairs(self.all.cols) do
     thing:inc( row[thing.pos ] ) end end

-- ### Data:head(row: list)
-- Build the data headers.
function Data:head(columns)
  local less= function (i) push(i, self.y.less); i.w= -1 end
  local more= function (i) push(i, self.y.more) end
  local klass=function (i) self.klass = i end
  local all = {{".", Sym, "x","syms"      }, -- default
	       {"%$",Num, "x","nums"      },
               {"<" ,Num, "y","nums", less},
               {">" ,Num, "y","nums", more},
               {"!" ,Sym, "y","syms", klass}}
  local function which(txt)
    for i=2,#all do
      if string.find(txt,all[i][1]) then return all[i] end end
    return all[1] end -- first item is the default

  for pos,txt in pairs(columns) do 
    local _,what,xy,ako,also = unpack( which(txt) )
    local it = what:new{pos=pos,txt=txt}
    if also then also(it) end 
    push(it, self.all[ako]); push(it, self[xy].cols)
    push(it, self.all.cols); push(it, self[xy][ako]) end end

function Data:best()
  order = function (x,y) oo(x);oo(y); 
    oo(self.rows[1])
    print(x.dom(self))
    return x.dom(self) > y.dom(self) end
  print(3)
  table.sort(self.rows, order)
  for i=1, math.floor( #rows*The.data.best ) do
    self.rows[i].best = true end end

-------------------------------------------------
-- ## Row Methods
function Row:doms(j, nums) 
  local s1, s2, n, z = 0, 0, #self.y.nums, The.zip
  for _,num in pairs(nums) do
    local a = self.cells[ num.pos ]
    local b = j[ num.pos ]
    a       = (a - num.lo) / (num.hi - num.lo + z)
    b       = (b - num.lo) / (num.hi - num.lo + z)
    s1      = s1 - 10^(num.w * (a - b) / n)
    s2      = s2 - 10^(num.w * (b - a) / n) end
  return s1 / n < s2 / n end
 
function Row:dom(d)
  oo(d)
  if not self._dom then
    for _,row in pairs(d.rows) do
      oo(row)
      print(3)
      if self:doms(row.cells, d.y.nums) then
 	self._dom = self._dom + 1  end end end
  return self._dom end

-------------------------------------------------
-- ## Test Stuff
do
  local function dataOkay(f)
    roguesOkay()
    return Data:new():csv("../data/".. f .. ".csv") end
  
  function autoOkay()      dataOkay("auto") end
  function auto10KOkay()   dataOkay("auto10K") end
  function auto1000KOkay() dataOkay("auto1000K") end
  function weatherOkay()   
    local d = dataOkay("weather") 
    assert( close( d.all.syms[1]:ent(),  1.58, 1) ) 
    assert( close( d.all.syms[2]:ent(),  0.98, 1) )  
    assert( close( d.all.syms[3]:ent(),  0.94, 1) )  
    assert( close( d.all.nums[1].mu,    73.57, 1) )
    assert( close( d.all.nums[1]:sd(),   6.57, 1) )  end
  
  function domOkay()
    local d = dataOkay("auto")
    local n = #d.rows
    d:best() 
    hi = #d.rows
    for i=1,10     do print(i, join(d.rows[i].cells)) end
    for i=hi-10,hi do print(i, join(d.rows[i].cells)) end end end

-------------------------------------------------
-- ## Main Stuff

main{data=domOkay}
