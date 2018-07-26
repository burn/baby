local Object=require("object")

Row = Object:new{cells, _dom, best=false}

-------------------------------------------------
-- ## Row Methods
function Row:has(data, y,z)
  local t={}
  for _,head in pairs(data[y][z]) do
    t[ head.txt ] = self.cells[head.pos] end
  return t
end

-- ### Row:dom(row2:row, nums: list of Num): boolean
-- Returns true if self dominates row2.
-- Computed using the row cells found in `nums`
-- and the Zilter continuous domination indicator
-- (so should work for many more goals than just 2).
function Row:dominates(j, data) 
  local nums = data.y.nums
  local s1, s2, n, z = 0, 0, #nums, Burn.zip
  for _,num in pairs(nums) do
    local a = self.cells[ num.pos ]
    local b =    j.cells[ num.pos ]
    a       = (a - num.lo) / (num.hi - num.lo + z)
    b       = (b - num.lo) / (num.hi - num.lo + z)
    s1      = s1 - 10^(num.w * (a - b) / n)
    s2      = s2 - 10^(num.w * (b - a) / n) end
  return s1 / n < s2 / n 
end

-- #### Row:ndominates(d: data): integer
-- Returns a count how how rows in `d` are domianted by self.
function Row:ndominates(data, others)
  local n = 0
  for _,row in pairs(others) do
    if self:dominates(row, data) then n=n + 1/#data.rows end end 
  return n 
end

return Row
