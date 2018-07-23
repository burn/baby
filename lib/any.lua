-------------------------------------------------------------
-- ## Object Stuff

-- ### Any:new(o)
-- Create the `any` base object
local Any={}

function Any:new(o)
  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  if not self.id then self.id=0 end
  self.id = self.id and self.id+1 or 1
  o.id    = self.id
  self.__index = self
  return o
end

return Any
