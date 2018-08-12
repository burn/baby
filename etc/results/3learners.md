
# Three Learners

This is an incremetanl 10-way. Working in steps of 128 rows at a
time, data is divided 10-ways into 10% test and 90% train.

Note that

- The variance is large at the start, then reduces;
- The dumbest learner (zeror) does well for a majority class target
  (65% for `tested_negative`);
- The best learner (nb) does well for minority class
  (35% for `tested_positive`).


```
tested_negative

128    zeror |             ---  *--  |,   62,   74,   80,   82,   91
128      knn |         ----  *-----  |,   46,   63,   71,   75,   90
128       nb |               --- *-  |,   71,   80,   88,   88,   91

256    zeror |            ---* ---   |,   58,   69,   72,   77,   86
256      knn |             -*----    |,   62,   65,   67,   69,   84
256       nb |              ---*---  |,   67,   77,   79,   80,   92

384    zeror |              - * -    |,   67,   69,   74,   80,   82
384      knn |               *--     |,   63,   64,   70,   74,   77
384       nb |                 *-    |,   68,   71,   77,   78,   83

512    zeror |                 *-    |,   72,   75,   76,   79,   83
512      knn |                *-     |,   68,   71,   72,   76,   79
512       nb |               --*--   |,   72,   77,   79,   79,   85

640    zeror |                -*-    |,   73,   76,   78,   81,   83
640      knn |               -*-     |,   70,   74,   75,   77,   78
640       nb |                  *-   |,   77,   79,   81,   82,   85

768    zeror |                -*-    |,   73,   78,   79,   80,   83
768      knn |                *-     |,   72,   75,   76,   76,   79
768       nb |                  *    |,   80,   80,   80,   81,   83
```

```
tested_positive

128    zeror |                       |,    0,    0,    0,    0,    0
128      knn |------   *----         |,    0,   33,   44,   50,   60
128       nb |      ----      * ---  |,   33,   50,   75,   80,   91

256    zeror |                       |,    0,    0,    0,    0,    0
256      knn |   ----- * -           |,   22,   40,   48,   53,   55
256       nb |       ------ *-----   |,   36,   60,   67,   70,   86

384    zeror |                       |,    0,    0,    0,    0,    0
384      knn |  ------ *--           |,   19,   42,   45,   52,   56
384       nb |         -- *---       |,   45,   53,   59,   63,   69

512    zeror |                       |,    0,    0,    0,    0,    0
512      knn |       ---*--          |,   39,   50,   51,   53,   58
512       nb |         -   *--       |,   44,   51,   61,   67,   71

640    zeror |                       |,    0,    0,    0,    0,    0
640      knn |       ---*--          |,   38,   48,   51,   53,   58
640       nb |         --- *--       |,   45,   57,   60,   65,   70

768    zeror |                       |,    0,    0,    0,    0,    0
768      knn |         --*-          |,   46,   52,   55,   56,   57
768       nb |         --- *-        |,   48,   58,   62,   64,   67
```
