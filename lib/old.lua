-- ### Data:bests(): best:table, scores:table
-- For the best rows, set as `row.best=true'.
-- (the top `The.data.best` rows as computed
-- by the domination score).
function Data:bests(x,    w)
  local regrow = 1.5 
  local want   = min(1024, #self.rows)
  local nbest  = max(want*0.1, want^The.data.best)
  local rest   = Sample:new{max=nbest}

  local function elite(rows)
    local u, best = {},{}
    for _,row in pairs(rows) do 
      u[row.id] = row:ndominates(self,rows) end
    local gt= function(x,y) return u[x.id] > u[y.id] end
    for pos, row in pairs(sorted(rows, gt)) do
      if pos > want then break end
      if pos > nbest then rest:inc(row) 
	             else best[#best+1] = row end end
    w={}
    for _,row in pairs(best) do 
      w[row.id] = (u[row.id] + #rest.all) / 
                   (#best    + #rest.all) end
    return best, best[#best] end

  local b4,after    = anys(self.rows, want)
  local best, worst = elite(b4)
  local changed = false
  for _,row in pairs(after) do
     if   row:dominates(worst, self) 
     then best[ #best+1 ] = row  
	  changed = true
     else rest:inc(row) 
     end
     if   #best >= regrow * nbest 
     then best,worst= elite(best) 
          changed = true end end
  if changed then best = elite(best) end
  local out = {}
  for _,row in pairs(best) do out[row.id] = row end
  return out, w
end


