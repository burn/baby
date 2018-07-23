# effects of fast/slow dow

shows 10,30,50,70,90 percentiles of rankings given to rows betwee
fast and slow domination scoring.

fast matches in n^2.2

slow matches to n^4.9

data   | n    | fast     | slow         | 10    |  30   | 50   | 70   | 90
-------|------|----------|--------------|-------|-------|------|------|----
auto   |  400 | 0.010677 | 0.189307     | -42   | -11   | -1   | 24   | 51
auto1K | 1000 | 0.044715 | 4.401581   | -226  | -89   | -34  | 34   | 169
auto2K | 2000 | 0.11937  | 39.233112   | -851  | -298  | -67  | 144  | 415
auto3K | 3000 | 0.299793 | 185.563997 | -790  | -310  | 9    | 140  | 562
