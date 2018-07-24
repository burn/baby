-- ## Unit Test  Stuff

require "burn"
Burn.sys.tests={try=0, fail=0}

local my=Burn.sys.tests
local Test={}

function Test.report()
  local n= 1-((my.try-my.fail)/my.try)  
  print("-- Failures: ".. 100*n  .. "%") 
end

-- ### tests()
-- Run any function ending in "Ok". Report number of failures.
function Test.ok(t)
  for x,f in pairs(t) do
    print("-- Checking ".. x .."... ")
    my.try = my.try + 1
    local passed,err = pcall(f)
    if not passed then 
      my.fail = my.fail+1
      print("-- E> Failure: " .. err) 
      Test.report() end end  
end 

-- ### rogues()
-- Checked for escaped local. Report number of assertion failures.
function Test.rogues()
  local ignore = {
           jit=true, math=true, package=true, table=true, coroutine=true, 
           bit=true, os=true, io=true, bit32=true, string=true,
           arg=true, debug=true, _VERSION=true, _G=true }
  for k,v in pairs( _G ) do
    if type(v) ~= "function" and not ignore[k] then
       assert(match(k,"^[A-Z]"),"rogue local "..k) end end 
end

return Test
