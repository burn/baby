
local ok=require("test").ok 
local Fft=require("fft") 
local Lib=require("lib") 


local function f1()
	Fft:new():csv("../data/diabetes.csv","tested_positive",3)
end
--ok {fft0 = function () f1() end}

--for _,x in pairs(Fft.controls()) do Lib.oo(x) end

f1()
