;; b.rkt
#lang s-exp "a.rkt"

(require rackunit)

Whatever ;; no errors
(+ 10 20)
(+ 11)
(+ 11 2 30 40)

(let-values ([x] 3) x)
(let ([a 5]) a)
(let ([a 5]) (+ a a a a))
(let ([a 5]) (+ a a a a (let ([b 1]) b)))
(let ([b 1]) (let ([a 5]) a))

((lambda (x) (+ 2 x)) 17)


(check-exn exn:fail? (thunk (+ 'h 0)))