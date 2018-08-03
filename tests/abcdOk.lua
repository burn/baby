local ok=require("test").ok 
local lib=require("lib")
local Abcd=require("abcd")

-- === Confusion Matrix ===
--  a b c   <-- classified as
--  6 0 0 | a = yes
--  0 2 0 | b = no
--  0 1 5 | c = maybe

ok { abcd = function ()
  local x = Abcd:new()
  for _ = 1,6 do x:inc("yes",   "yes")   end
  for _ = 1,2 do x:inc("no",    "no")    end
  for _ = 1,5 do x:inc("maybe", "maybe") end
  x:inc("maybe","no")
  lib.cols( x:report(), "%5.0f" )
end }
--
-- === Detailed Accuracy By Class ===
--                TP Rate   FP Rate   Precision   Recall  F-Measure   ROC Area  Class
--                  1         0          1         1         1          1        yes
--                  1         0.083      0.667     1         0.8        0.938    no
--                  0.833     0          1         0.833     0.909      0.875    maybe
-- Weighted Avg.    0.929     0.012      0.952     0.929     0.932      0.938

