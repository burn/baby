
local ok=require("test").ok 
local Fft=require("fft") 
local Lib=require("lib") 


local function f1()
	Fft:new():csv("../data/diabetes.csv","tested_positive",3)
end
local function f2()
	Fft:new():csv("../data/weatherLong.csv","yes",2)
end

f2()
