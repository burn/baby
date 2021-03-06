-----------------------------------------------------------
-- ## Defaults
-- usage:
-- 
-- ```
-- require "burn"
-- ```

Burn= {
  ignore= "?",
  sep=    ",",
  inf=    10^32,
  ninf=   -10^32,
  zip =   10^(-32),
  data=   { best = 0.5 },
  sample= { max=256,
            cliffsMax=1000, 
            cliffsDelta=0.147 -- small,medium,large=0.147,0.33,0.474
            },
  nb=     {k=1,
           m=2},
  dom=    {few=20,
           tiny=0.02,
           power=0.5},
  tree=   { ish=1.02,
            min=2, 
            maxDepth=10},
  tbl=    { k=5 },
  nb =    { k=1,m=2},
  chop=   { m=0.5,
            cohen=0.2},
  num=    { conf=0.95,
            small=0.38} -- small,medium = 0.38,1
}

Burn.sys = Burn.sys or {}

return Burn
