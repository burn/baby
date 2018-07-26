local ok=require("test").ok 
local Sym=require("sym")
local L=require("lib")

ok  { baseSym=function() 
	s=Sym:new():incs{
		    'y','y','y','y','y','y','y','y','y',
	            'n','n','n','n','n'}
	assert( L.close( s:ent() , 0.9403) )  
        s:ent()
end }



