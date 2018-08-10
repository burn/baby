local Data = require("data")
local Csv = require("csv")
local Abcd = require("abcd")
local Object  = require("object")
local Lib  = require("lib")

rand, say,eras = Lib.rand, Lib.say, Lib.eras

Knn=Object:new()


function Knn:train(cells, era, data)
  data:inc(cells)
end

function Knn:test(row, era, data, log)
  if era > 0 and #data.rows > 0 then
    local row= Row:new{cells=row}
    local near = row:nearest(data.rows, data.x.cols)
    log:inc( data:class(row), data:class(near) )
  end 
end

function Knn:report(era,log)
  print("\n"..era)
  for _,log1 in pairs(log) do
    r=log1:report()
    if r["tested_positive"] then
     print(r["tested_positive"].f) end
  end
end

function Knn.nways(learner,file,ways,era, silent)
  ways = ways or 3
  era  = era  or 10^32
  local src    = Csv(file)
  local header = src()   -- first line is special. read it first
  local log,data   = {},{}
  for w = 1,ways do  -- make "ways" data stores
    log[w]  = Abcd:new(file, "knn") -- one log shared for all
    data[w] = Data:new()
    data[w]:inc(header) end
  for rows,era1 in eras(src, era) do
    if not silent then say(" " .. era1) end
    for _,cells in pairs(rows) do
      for w = 1,ways do
        if rand() < 1/ways then 
	     --say("?")
             learner:test( cells, era1, data[w],log[w])
        else learner:train(cells, era1, data[w]) 
	     --say(".") 
        end
      end
    end
    learner:report(era1, log)
  end
  --print("")
  return log
end
 
return Knn
