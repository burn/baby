local Any=require "any"

-------------------------------------------------------------
-- ## Sampling Stuff

local Sample = Any:new{max=The.sample.max, n=0, all}

function Sample:new(spec) 
  x=Any.new(self,spec) 
  x.all = {}
  return x 
end

-- Sample:inc(x): x
-- Keep at most `max` number of items (selected at random).
function Sample:inc(x)
  self.n = self.n + 1
  local now = #self.all
  if now < self.max then self.all[ self.n ] = x 
  else if rand() < now/self.n then
    self.all[ int( 0.5+ rand() * now ) ] = x end end
  return x 
end

function Sample:tiles(ps)
  t= sorted(self.all)
  local u = {}
  for _,p in pairs(ps) do u[#u+1] = t[ int(#t*p/100) ] end
  return u
end

function sampleOkay()
  rseed(1)
  local s=Sample:new{max=10}
  for i=1,10^3 do s:inc(i) end
  table.sort(s.all)
  print(join(s.all)) 
end

return Sample
