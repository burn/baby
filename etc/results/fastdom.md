# effects of fast/slow dow

shows 10,30,50,70,90 percentiles of rankings given to rows betwee
fast and slow domination scoring.

- fast matches to runtime = 10-6*N^1.1 (R^2=0.998)
- slow matches to runtime = 10-6*N^2   (R^2=1)

Conclusion: fastmap usually ranks rows within -5 to +5% of actual

```      
                                                                                                       X percentiles
    source          N     fast     slow |         X=100*(rank.slow - rank.fast)/N        |     10     30    50      70     90
    ------------------------------------|------------------------------------------------|------------------------------------
      auto        398  0.00525  0.15723 |           -------    *  --------               |,   -11,    -4,    -0,     3,    10
    auto1K       1000  0.01337  0.96807 |             ------    *  --------              |,   -10,    -4,    -1,     2,    10
    auto2K       2000  0.03206  3.86523 |         ----------   *  ---------------        |,   -17,    -5,    -1,     2,    18
    auto3K       3000  0.05253  9.10550 |                 -----   *  -----               |,   -10,    -3,    -0,     3,     9
    auto5K       4999  0.09883  26.3052 |                -------   *   --------------    |,   -14,    -4,    -1,     4,    21
   auto10K       9999  0.19571  119.245 |             -----------   *  ------            |,   -20,    -4,     0,     5,    12
```
