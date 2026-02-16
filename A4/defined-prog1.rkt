#lang s-exp "defined.rkt"

(define x 1)
(println x)

(set! x 15)

(define y x)
(println y)
