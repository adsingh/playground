; SICP exercise 1.14
;
; Draw the tree illustrating the process generated by the count-change
; procedure of section 1.2.2 in making charge for 11 cents. What are the orders
; of growth of the space and number of steps used by this process as the amount
; to be changed increases.

; The spaces grows in Θ(n), since the maximum depth of the tree is a function
; of n (number-of-denominations + n / smallest-denomination + 1).
;
; I believe the time is Θ(aˣ), but I'm not certain. The amount of nodes seem to
; roughly double every time we add 5 to n, but this is oversimplifying it (it
; gets more complex when we start adding 50 in increments.
;
; And about draing a tree? In ASCII? Seriously? Meh, sure:
;
;                                                                                                                                                                (count-change 11 5)
;                                                                                                                                                                         |
;                                                                                                                                                               ._____(cc 11 5)_____.
;                                                                                                                                                        ._____/                     \_____.
;                                                                                                                                   .___________(cc 11 4)__________.                        (cc -39 5)
;                                                                                                                      .___________/                                \____________.               |
;                                                                                     ._______________________(cc 11 3)_______________________.                                   (cc -14 4)     0
;                                                       .____________________________/                                                         \________________________.             |
;                                      .__________(cc 11 2)____________.                                                                                                 (cc 1 3)     0
;                    .________________/                                 \___________________.                                                                           /        \
;           (cc 11 1)                                                              ._________(cc 6 2)________.                                                  (cc 1 2)          (cc -9 3)
;          /         \                                                  ._________/                           \__ ______.                                      /        \             |
; (cc 11 0)           (cc 10 1)                                 (cc 6 1)                                                 (cc 1 2)                      (cc 1 1)          (cc -4 2)    0
;     |              /         \                               /        \                                               /        \                    /        \             |
;     0     (cc 10 0)           (cc 9 1)               (cc 6 0)          (cc 5 1)                               (cc 1 1)          (cc -4 2)   (cc 0 1)          (cc 1 0)     0
;               |              /        \                  |            /        \                             /        \             |           |                 |
;               0      (cc 9 0)          (cc 8 1)          0    (cc 5 0)          (cc 4 1)             (cc 1 0)          (cc 0 1)     0           0                 1
;                          |            /        \                  |            /        \                |                 |
;                          0    (cc 8 0)          (cc 7 1)          0    (cc 4 0)          (cc 3 1)        0                 1
;                                   |            /        \                  |            /        \
;                                   0    (cc 7 0)          (cc 6 1)          0    (cc 3 0)          (cc 2 1)
;                                            |            /        \                  |            /        \
;                                            0    (cc 6 0)          (cc 5 1)          0    (cc 2 0)          (cc 1 1)
;                                                     |            /        \                  |            /        \
;                                                     0    (cc 5 0)          (cc 4 1)          0    (cc 1 0)          (cc 0 1)
;                                                              |            /        \                  |                 |
;                                                              0    (cc 4 0)          (cc 3 1)          0                 1
;                                                                       |            /        \
;                                                                       0    (cc 3 0)          (cc 2 1)
;                                                                                |            /        \
;                                                                                0    (cc 2 0)          (cc 1 1)
;                                                                                         |            /        \
;                                                                                         0    (cc 1 0)          (cc 0 1)
;                                                                                                  |                 |
;                                                                                                  0                 1
;
; It fits my MacBook Pro screen like a boss