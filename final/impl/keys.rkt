#lang racket
(provide reg-ref reg-set!)


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

(define registers (make-hash))

(define (reg-ref x)
  (hash-ref registers x
            (lambda ()
              (if (memv x keys)
                  (begin
                    (hash-set! registers x 0) 0)
                  (error "keys: key out of keyboard range")))))

(define (reg-set! x val)
  (if (memv x keys)
                  (begin
                    (hash-set! registers x val) val)
                  (error "keys: key out of keyboard range")))