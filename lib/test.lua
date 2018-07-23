-------------------------------------------------------------
-- ## Unit Test  Stuff

local Test={}

TRY, FAIL=0,0

-- ### tests()
-- Run any function ending in "Ok". Report number of failures.
function Test.ok(f)
    TRY = TRY + 1
    local passed,err = pcall(f)
    if not passed then 
       FAIL = FAIL + 1
       print("-- E> Failure 11: " .. err)  end  
end 

function Test.report()
  print("-- Failures: ".. 1-((TRY-FAIL)/try) .. "%") 
end
-- ### Test:rogues()
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

-- ## main{m:string = f:function}
-- Run function `f` if we are in module `m`.
-- Used  like Python's if \_\_name\_\_ == '\_\_main\_\_'. 
-- e.g. `main{lib=doThis}` will call `doThis()` if
-- the environment variable MAIN equals `lib`.
function Test.main(com) 
  roguesOkay()
  for s,f in pairs(Test.all) do
    if s == os.getenv("MAIN") then return f() end end end

return Test
