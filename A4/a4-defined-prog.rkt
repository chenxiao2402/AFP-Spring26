#lang s-exp "a4-defined-lang.rkt"

(define x 1)
(println x)

(set! x 3)

(define y x)
(println y)