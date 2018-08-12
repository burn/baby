local Csv = require("csv")
local Abcd = require("abcd")
local Data = require("data")
local Lib    = require("lib")
local Sample = require("sample")

rand, say,eras = Lib.rand, Lib.say, Lib.eras

Learn = {}

--------- --------- --------- --------- --------- --------- 
function Learn.report(era,log,name,k)
  say(era.." " .. Lib.sprintf("%8s ",name))
  local s = Sample:new()
  for _,log1 in pairs(log) do
    local r=log1:report()
    s:inc(r[k].f)
  end
  s:show(25, 
         {{0.25,"-"}, {0.50,"-"}, {0.75," "}},
	 "%4.0f", "%20s",0,100)
end

--------- --------- --------- --------- --------- --------- 
function Learn.nways(learners,goal,file,ways,era, silent,logger)
  ways   = ways or 3
  era    = era  or 10^32
  logger = logger or Abcd
  local src    = Csv(file)
  local header = src()   -- first line is special. read it first
  local log,data = {},{}
  for l,learner in pairs(learners) do
    log[l]={}
    data[l]={}
    for w = 1,ways do  -- make "ways" data stores
      log[l][w]  = logger:new(file, learner.name) -- one log shared for all
      data[l][w] = Data:new()
      data[l][w]:inc(header) 
    end
  end
  local line=0
  for rows,era1 in eras(src, era) do
    for _,cells in pairs(rows) do
      line=line+1
      for w = 1,ways do
        if rand() < 1/ways then 
          if era1 > 0 then
	    -- spin learners
            for l,learner in pairs(learners) do
	      if #(data[l][w].rows) >0 then
	        local got = learner:predict(cells, data[l][w]) 
                local want= cells[ data[l][w]._class.pos ]
                log[l][w]:inc(want,got) 
	      end
	    end
          end
        else 
	  -- spin learners
	  for l,learner in pairs(learners) do
	    learner:inc(cells, data[l][w]) end
	end
      end
    end
    -- spin learners
    -- spin over all logs of a learner
    print()
    for l,learner in pairs(learners) do
      learner:report(line, goal,log[l])
    end
  end
end
 
return Learn
