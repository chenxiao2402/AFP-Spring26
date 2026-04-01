#lang racket

(define keys
  (map string->symbol
       (flatten
         (append
           '("A0" "A#0" "B0")
           (for/list ([num (map add1 (range 7))])
             (for/list ([ltr '(C D E F G A B)])
               (if (memv ltr '(C D F G A))
                   (list
                     (string-append (symbol->string ltr) (number->string num))
                     (string-append (symbol->string ltr) "#" (number->string num))
                     )
                   (string-append (symbol->string ltr) (number->string num)))))
           '("C8")
           ))))

(define (make-counter)
  (let ([n -1])
    (lambda ()
      (set! n (add1 n))
      n)))

(define (key-dict-builder dict key init-fun)
  (match key
    ('() dict)
    ((cons a b) (begin (dict-set! dict a (init-fun))
                  (key-dict-builder dict b init-fun)))))



(define registers (key-dict-builder (make-hash) keys (lambda () 0)))

(define key-values (key-dict-builder (make-hash) keys (make-counter)))


(provide registers key-values)