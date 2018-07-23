local ok=require("test").ok 

local Object=require "object" 

ok {ids = function ()
	local x,y = Object:new(), Object:new()
	x.sub = y
	y.sub = x
	x.lname="tim"; x.fname="menzies"
	assert(y.id == 101 + x.id,
	       "object ids not sequential") 
end}


