;; b.rkt
#lang s-exp "a.rkt"
Whatever ;; no errors
(+ 10 20)
; (let-values ([x] e) x) -> e

(let-values ([x] 3) x)
(let ([a] 5) a)
(let ([a] 5) (+ a a a a))
; (let ([a] 5) (+ a a a a (let ([b] 1) b)))
; (let ([b] 1) (let ([a] 5) a))
(+ 11)
(+ 11 2 30 40)