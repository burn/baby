local ok=require("test").ok 

require "burn"
local my = Burn.sys.tests
local old= my.fail

ok {ids       = function () assert(1==2,"oops...") end,
    oopsFound = function () assert(my.fail == 1+old) end }



