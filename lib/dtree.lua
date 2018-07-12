
require "data"
require "btree"


DTree = Any:new{ data, root, growths}

function Dtree:new(spec)
  x = Any.new(self, spec)
  x.root = DNode:new()
  return x
end

DNode = Btree:new{ key,value, l,r}

main{dtree=print}
