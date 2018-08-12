local Object=require("object")
local Learn=require("learn")

ZeroR = {}
ZeroR = Object:new{name="zeror"}

--------- --------- --------- --------- --------- --------- 
function ZeroR:inc(cells, data)
   data:inc(cells)
end

function ZeroR:predict(cells, data)
  local z=data._class.mode
  return z
end

function ZeroR:report(era,goal,log)
  Learn.report(era,log,self.name, goal)
end

return ZeroR
