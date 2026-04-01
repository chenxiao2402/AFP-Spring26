#lang racket
(provide reg-ref reg-set!)


(define registers (make-hash))

(define (reg-ref x)
    (hash-ref registers x
              (lambda () (begin (hash-set! registers x 0) 0))))

(define (reg-set! x val)
    (hash-set! registers x val))