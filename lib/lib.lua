Burn=require "burn"

-------------------------------------------------------------
-- ## Misc  Stuff 

local lib= {
  E      = 2.7182818285,
  PI     = 3.1415926536,
  abs    = math.abs,
  int    = math.floor,
  printf = function(s, ...) return io.write(s:format(...)) end,
  sprintf= function(s, ...) return s:format(...) end,
  match  = function(s,p)    return string.match(s,p) ~= nil end}

-------------------------------------------------------------
-- ## Maths Stuff

function lib.round(exact, quantum)
    local quant,frac = math.modf(exact/quantum)
    return quantum * (quant + (frac > 0.5 and 1 or 0))
end

-- ### close(m:number, n:number [, e:float])
-- Return true are `m` and `n` are within `e`% of each other
-- (default value for e = 1).
function lib.close(m,n,e) 
  e = e and e or 1
  return lib.abs(m-n)/n <= e/100 
end

-- ### min(x:number, y:number): number
-- ### max(x:number, y:number): number
function lib.max(a,b) return a > b and a or b end
function lib.min(a,b) return a < b and a or b end

-- ### rand()
-- Return a random number 0..1. To set the random number seed,
-- use `rseed(n:int)`.
do
  local seed0     = 10013
  local seed      = seed0
  local modulus   = 2147483647
  local multipler = 16807
  function lib.rseed(n) seed = n or seed0 end
  function lib.rand() -- park miller 
    seed = (multipler * seed) % modulus
    return seed / modulus end 
end

-- *** interpolate(x, xs:table, ys:table): number
-- Return a `y` value for `x` by interpolating across the points in `xs,ys`.
-- E.g. 
--
-- ```
-- interpolate(3, {1,2,4}, {10,20,40}) -- returns  30
-- ```                     
--
-- This function assumes that `y` changes linearly between the
-- points records in `xs,ys`. Also, anything less or more than
-- the first and last values in `xs` are capped to the `ys[1]` or `ys[#ys]
-- values, respectively.
function lib.interpolate(x,xs,ys,          x1,y1)
  local x0, y0 = xs[1], ys[1]
  if x <= x0 then return y0  end
  if x > xs[ #xs ] then return ys[ #ys ] end
  --if x >= xs[#xs] then return ys[#xs] end
  for i = 1, #xs do
    x1,y1 = xs[i],ys[i]
    if x0 <= x and x < x1 then break end
    x0, y0 = x1, y1 end
  return y0 +  (x - x0)/(x1 - x0) * (y1 - y0)
end
 
-- weibull(x,l,k): number
function lib.weibull(x,l,k)
  return x < 0 and 0 or k/l*(x/l)^(k-1)*E^(-1*(x/l)^k)
end

function lib.normal(x, mu, sigma)
    return E^(-.5 * (x-mu)*(x-mu)/(sigma*sigma)) / 
           math.sqrt(2.0*math.pi*sigma*sigma)
end

function lib.normCdf(x, mu, sigma)
    return 0.5 * (1.0 + E^((x-mu)/math.sqrt(2*sigma*sigma)))
end

-------------------------------------------------------------
-- ## Table Stuff

-- ### ordered(t:table)
-- Iterator. Returns key,values in key sorted order.
function lib.ordered(t)
  local i,tmp = 0,{}
  for key,_ in pairs(t) do tmp[#tmp+1] = key end
  table.sort(tmp)
  return function () 
    if i < #tmp then 
      i=i+1; return tmp[i], t[tmp[i]] end end 
end

-- ### sorted(t:table [,f:function]): table
-- Returns table `t`, sorted using `f` (defaults to "`lt`").
function lib.sorted(t, f)
  f = f or function (x,y) return x<y end
  table.sort(t,f)
  return t 
end

-- ### member(x,t:table)
-- Returns true if x is in x
function lib.member(x,t)
  for _,y in pairs(t) do if x==y then return true end end
  return false 
end

-- ### slice(t:table,i:integer, j:integer): table
-- Return items `i` to `j` of table `t`.
function lib.slice(t, i,j)
  local out={}
  for k=i,j do out[#out+1] = t[k] end
  return out 
end

-- ### push(x, t:table): x
-- Pushes `x` to the end of table `t`. Returns `x`.  
function lib.push(x,t) 
  t[ #t+1 ] = x; return x 
end

-- ### join(t:table [,sep:string]): string
-- Converts a table to a string.
function lib.join(t, sep)
  local u ={}
  for i,x in pairs(t) do u[i] = tostring(x) end
  return table.concat(u, sep or ", ") 
end

--- ### any(t: table): table
-- Extract any one item from a table
function lib.any(t)
  local pos =  math.floor(0.5 + rand() * #t)
  return t[ min(#t,max(1,pos)) ] 
end

--- ### anys(t: table, n:integer): table
-- Extract any `n` items from  `t` (using sampling with replacement).
function lib.anys(t,n)
  t = lib.shuffle(t)
  a,b  = {},{}
  for i=1,n    do a[#a+1] = t[i] end
  for i=n+1,#t do b[#b+1] = t[i] end
  return a,b 
end

-- ### merge(t1: table, t2: table): table
-- Add `t2` to the end of `t1`. Returns the modified `t1`.
function lib.merge(t1,t2)
  for _,x in pairs(t2) do t1[#t1+1] = x end
  return t1 
end 

-- ### shuffle(t: table): t
-- Elements in `t` are rearranged randomly.
function lib.shuffle( t )
  for i= 1,#t do
    local j = i + math.floor((#t - i) * lib.rand() + 0.5)
    t[i],t[j] = t[j], t[i] end
  return t 
end

-------------------------------------------------------------
-- ## Environment Stuff
-- ### args(settings:table, ignore: table, updates:table)
-- Reading from `updates` (or, if missing, `arg`),
-- ignoring any flags listed in `ignore`, update `settings`
-- with command-line settings such as `-k a=1 b=2`
-- (which sets `k` to true and `a,b` to 1,2).
function lib.args(settings,ignore, updates)
  updates = updates or arg
  ignore = ignore or {}
  local i = 1
  while updates[i] ~= nil  do
    local flag = updates[i]
    local b4   = #flag
    flag = flag:gsub("^[-]+","")
    if not lib.member(flag,ignore) then
      if settings[flag] == nil then error("unknown flag '" .. flag .. "'")
      else
        if b4 - #flag == 2     then settings[flag] = true
        elseif b4 - #flag == 1 then
          local a1 = updates[i+1]
          local a2 = tonumber(a1)
          settings[flag] = a2 or a1
          i = i + 1 end end end
    i = i + 1 end
  return settings 
end

-------------------------------------------------------------
-- ## String  Stuff

-- ### say(s)
-- Print a string to the screen with no new line.
function lib.say(x) io.write(tostring(x)); io.flush() end

-- ### scan(s:string): string
-- Convert `s` into a string or number, as appropriate.
function lib.scan(s) return tonumber(s) or s end

-- ### rep(s: string, n: int): string
-- Repeat a string, n times
function lib.rep(s, n) return n > 0 and s .. lib.rep(s, n-1) or "" end

-- ### split(s:string, sep:string [, use:function, prep:function]): list 
-- Return a table of cells generated by spliting `s` on `sep`.
function lib.split(s, sep)
  local t, sep = {}, sep or ","
  local notsep = "([^" ..sep.. "]+)"
  for y in string.gmatch(s, notsep) do t[#t+1] = y end 
  return t 
end

-- ### sub(s: string, [lo : int], [hi : int]): string
-- Extract substrings. Allow Python style negative indexes
function lib.sub(s,lo,hi) 
  if lo and lo < 0 then
    return lib.sub(s, string.len(s) + lo +1)
  else
    return string.sub(s,lo and lo or 1,hi) end 
end    

-- ### oo(x : anything)
-- Print anything, including nested things 
-- If you want the string, without printing it,
-- use `ooo(x)`.
function lib.oo(data) print(lib.ooo(data)) end
function lib.ooo(data) 
  local seen={}
  local function go(x,       str,sep)  
    if type(x) ~= "table" then return tostring(x) end
    if seen[x]            then return "..." end
    seen[x] = true
    for k,v in lib.ordered(x) do
      str = str .. sep .. k .. ": " .. go(v, "{","")
      sep = ", " end 
    return str .. '}'
  end 
  return go(data,"{","") 
end  

-------------------------------------------------------------
-- ## Meta  Stuff

-- ### map(t: table, f:function): nil
-- For each item `v` call `f(v)`.
function lib.map(t,f)
  if t then for i,v in pairs(t) do f(v) end end 
end

-- ### map2(t: table, x, f:function): x
-- For each item `v` call `f(x,v)`.  Return `x`.
function lib.map2(t,i,f)
  if t then for _,v in pairs(t) do f(i,v) end end
  return i
end

-- ### collect(t: table, f:function): table
-- Collect all results from each f(v) for each item `v` in `t`.
function lib.collect(t,f)
  local out={}
  if t then for i,v in pairs(t) do out[i] = f(v) end end
  return out
end

-- ### select(t: table, f:function): table
-- Select all items that satisfy f(v) for each item `v` in `t`.
function lib.select(t,f)
  local out={}
  if t then for i,v in pairs(t) do
              if f(v) then out[#out + 1]=v end end end
  return out
end

-- ### reject(t: table, f:function): table
-- Reject all results that do not satisfy f(v) for each item `v` in `t`.
function lib.reject(t,f)
  return lib.select(t, function(v) return not f(v) end)
end

function lib.when(f, r)
   r= r or 1
   local t1=os.clock()
   for _=1,r do f() end
   return (os.clock() - t1)/ r
end

return lib
