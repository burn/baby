require "lib"

-- Returns distance between rows, in objective space.
local function dist(i, j,data)
  local d,n,z = 0,The.zip,The.zip
  for _,num  in pairs(data.y.nums) do
      local a = i.cells[ num.pos ]
      local b = j.cells[ num.pos ]
      a = (a - num.lo) / (num.hi - num.lo + z)
      b = (b - num.lo) / (num.hi - num.lo + z)
      d = d + (a-b)^2
      n = n + 1 end
  return d^0.5 / n^0.5 
end

-- Returns  furthest poinf from i, in objective space.
local function furthest(i, lst, data)
  local most,out = -1,i
  for _,j in pairs(lst) do
    local d = dist(i,j, data)
    if d > most then most,out = d,j end end
  return out
end

-- Pick anything. Find the `y` furthest from anything.
-- Find the `z` furthest from `y`. 
-- Return `y,z`
local function distantPoints(data,rows,y,z)
  local x = any(rows)
  y = y or furthest(x, rows, data)
  z = z or furthest(y, rows, data)
  return y,z
end

-- Top down bi-clustering of rows.
-- Find two most distant points. Label them
-- `bad` and `best` depending on who dominates wo.
-- Divide rows into those that are nearest `bad` or `best,
-- Recurse till too few rows. Then score each
-- row bad to best.
local function div(data,rows,few,        rank, bad, best)
  rank = rank or 1
  if #rows < few then
    for _,one in pairs(rows) do
      rank = rank + 1
      one.dom = rank end
  else
    bad,best = distantPoints(data,rows,bad,best)
    if bad:dominates(best,data) then 
      bad,best = best,bad end
    local c  = dist(bad,best, data)
    local c1 = c + The.dom.tiny
    local tmp = {}
    for pos,row in pairs(rows) do
      local a = dist(bad,  row, data)
      local b = dist(best, row, data)
      if a > c1 then 
	return div(data, rows, few, rank, row,  bad) end
      if b > c1 then 
	return div(data, rows, few, rank, row, best) end
      local x = (a*a + c*c - b*b) / (2*c + The.zip)
      tmp[ #tmp+1 ] = {x,row} 
    end
    tmp = sorted(tmp, function(x,y) return x[1] < y[1] end)
    for i,one in pairs(tmp) do tmp[i] = one[2] end
    local mid = int(#rows/2)
    rank = div(data, slice(tmp,    1, mid),  few, rank)
    rank = div(data, slice(tmp,mid+1, #tmp), few, rank) 
  end
  return rank 
end


-- Main function
local function fastdom(data,rows)
  few = max(The.dom.few, (#rows)^The.dom.power)
  div(data, rows, few) 
end

return fastdom
