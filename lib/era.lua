local Data = require("data")
local Abcd = require("abcd")
local Object  = require("object")
local Lib  = require("lib")

Era=Object:new()

-- splits is actually a seperate idea. nothing to do with era
--
-- splits are ony cop of era....

function Era:new(file, enough, b4, after, finale)
  local x     = Object.new(self)
  x.era       = {}
  x.enough    = enough
  x._b4       = b4
  x._after    = after
  x._done     = done
  Data:new():csv(file,
                 function(row, data) x:b4( row, data) end,
                 function(row, data) x:after( row, data) end,
                 function(row, data) x:finale( row, data) end)
  return x
end

function Era:b4(row,data)
  self.era[ #self.era + 1 ] = row
  if #self.era >= self.enough then
    self.era = Lib.shuffle(era)
    if x._b4 then 
     for _,row1 in pairs( self.era ) do x._b4(row1,data) end 
  end end
end 

function Era:after(row,data)
  if x._after and #self.era = self.enough then
    for _,row1 in pairs( self.era ) do x._after(row1,data) end 
    self.era = {}
  end
end 

function Era:finale(data)
  if x._done and #self.era > 0 then 
    for _,row1 in pairs( self.era ) do x._done(row1,data) end 
  end 
end 

return Era


