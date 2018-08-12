
# Three Learners

This is an incremetanl 10-way. Working in steps of 128 rows at a
time, data is divided 10-ways into 10% test and 90% train.

Note that

- The variance is large at the start, then reduces;
- The dumbest learner (zeror) does well for a majority class target
  (65% for `tested_negative`);
- The best learner (nb) does well for minority class
  (35% for `tested_positive`).

## tested\_negative

```
128    zeror |                --*-   |,   74,   80,   84
128      knn |             --*--     |,   63,   71,   77
128       nb |                  -*-  |,   80,   88,   90

256    zeror |               *---    |,   69,   72,   80
256      knn |              *----    |,   65,   67,   83
256       nb |                 *-    |,   77,   79,   83

384    zeror |               -*--    |,   69,   74,   82
384      knn |             --*--     |,   64,   70,   77
384       nb |               --*-    |,   71,   77,   80

512    zeror |                -*-    |,   75,   76,   82
512      knn |               -*-     |,   71,   72,   76
512       nb |                 *--   |,   77,   79,   84

640    zeror |                 *-    |,   76,   78,   83
640      knn |                *-     |,   74,   75,   78
640       nb |                 -*-   |,   79,   81,   84

768    zeror |                 *-    |,   78,   79,   81
768      knn |                *-     |,   75,   76,   77
768       nb |                 -*    |,   80,   80,   82
```

## tested\_positive

```
128    zeror |                       |,    0,    0,    0
128      knn |      ---*---          |,   33,   44,   57
128       nb |          ------*--    |,   50,   75,   80

256    zeror |                       |,    0,    0,    0
256      knn |        -*--           |,   40,   48,   55
256       nb |             -*-       |,   60,   67,   70

384    zeror |                       |,    0,    0,    0
384      knn |        -*--           |,   42,   45,   52
384       nb |           -*--        |,   53,   59,   67

512    zeror |                       |,    0,    0,    0
512      knn |          *-           |,   50,   51,   56
512       nb |          ---*--       |,   51,   61,   70

640    zeror |                       |,    0,    0,    0
640      knn |          *--          |,   48,   51,   57
640       nb |            -*-        |,   57,   60,   67

768    zeror |                       |,    0,    0,    0
768      knn |           *-          |,   52,   55,   57
768       nb |            -*-        |,   58,   62,   67
```
