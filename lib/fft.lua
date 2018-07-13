
require "data"
require "btree"

-----------------------------------------
-- FFT = Fast and Frugal Trees

Fft = Any:new{ data, root, growths}

function Fft:new(spec)
  x = Any.new(self, spec)
  x.root = Fft1:new()
  return x
end

Fft1 = BTree:new{ key,value, l,r}

-- ### control(num: number, bits: integer): table
-- Returns an array of size `2^bits` whose `i-th` element is true if the `i`-th bit is set. 
-- - e.g. sets(3,2) ==> {true,false}    
-- - e.g. sets(16,4) ==> {true, true, true, true}
function control(num,bits)
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local out = {} 
    for b = bits, 1, -1 do
        out[b] = math.fmod(num, 2) 
        num = math.floor((num - out[b]) / 2)
	out[b] = out[b] > 0 end
    return out
end

function controlOkay() 
  local depth = 5
  for i=1,depth do 
     max = 2^i
     for j=0,max-1 do
       print(j, join(control(j,i))) end end
end


