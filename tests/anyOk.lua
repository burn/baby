package.path = package.path .. ';../lib/?.lua'
local ok=require("test").ok 

local Any=require "any" 

ok(function ()
  local x,y = Any:new(), Any:new()
  x.sub = y
  y.sub = x
  x.lname="tim"; x.fname="menzies"
  assert(y.id == 1 + x.id) 
end)


