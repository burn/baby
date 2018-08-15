
local ok=require("test").ok 
local Fft=require("fft") 
local Lib=require("lib") 


local function f1()
	Fft:new():csv("../data/diabetes.csv","tested_positive",3):show()
end
local function f2()
	Fft:new():csv("../data/weatherLong.csv","yes",4):show()
end

f1()

f2()
