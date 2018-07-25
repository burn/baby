local Object=require("object")
local Num=require("num")
local Sym=require("sym")
local Row=require("row")

local lib=require("lib")
local csv=require("csv")
local fastdom = require("fastdom")

local push = lib.push

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
 
local Data = Object:new{
  name, header, klass,
  rows={}, 
  all={nums={}, syms={}, cols={}}, -- all columns
  x  ={nums={}, syms={}, cols={}}, -- all independents
  y  ={nums={}, syms={}, cols={},  -- all dependent columns
       less={}, more={}}}  

-- ### Data:csv(file: string)
-- Read data in  from `file`. Return `self`.
function Data:csv(file)
  for row in csv(file) do self:inc(row) end 
  return self 
end

-- ### Data:inc(row: list)
-- If this is the first row, interpret `row` as the column headers.
-- Otherwise, read `row` as data.
function Data:inc(row)
  if   self.header then self:data(row) 
  else self.header=row; self:head(row) end 
end

-- ### Data:data(row: list)
-- Add `row` to `self.rows`. Increment the header statistics
-- with information from `row`'s values.
function Data:data(row) 
   push( Row:new{cells=row}, self.rows )
   for _,thing in pairs(self.all.cols) do
     thing:inc( row[thing.pos ] ) end 
end

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
    push(it, self.all.cols); push(it, self[xy][ako]) end 
end

function Data:doms(how,rows)
  if   how
  then fastdom(self,rows)
  else for _,row in pairs(rows) do
         row.dom = row:ndominates(self,rows) end end
 end

function Data:bests(how,rows)
  how  = how or false
  rows = rows or self.rows
  self:doms(how,rows)
  rows = sorted(rows,function(a, b) return a.dom > b.dom end)
  best = rows[ int(#rows*0.2) ].dom
  return function(r) return r.dom >= best end
end

return Data
