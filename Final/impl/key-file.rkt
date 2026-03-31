#lang racket

(define keys
  (map string->symbol
       (flatten
        (append
         (for/list ([ltr '(A B C D E F G)])
           (for/list ([num (map add1 (range 7))])
             (if (memv ltr '(A C D F G))
                 (list
                  (string-append (symbol->string ltr) (number->string num))
                  (string-append (symbol->string ltr) "#" (number->string num))
                  )
                 (string-append (symbol->string ltr) (number->string num)))))
         '("A0" "A#0" "B0" "C8")
         ))))

(define (key-dict-builder dict key)
  (match key
    ('() dict)
    ((cons a b) (begin (dict-set! dict a 0)
                       (key-dict-builder dict b)))))



(define key-dict (key-dict-builder (make-hash) keys))

(provide key-dict)