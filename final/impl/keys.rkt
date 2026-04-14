#lang racket
(provide reg-ref reg-set! reg-push reg-pop)


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
(define saved-registers '())

(define (reg-ref x)
  (hash-ref registers x
            (lambda ()
              (if (memv x keys)
                  (begin
                    (hash-set! registers x 0) 0)
                  (error "keys: key ~s out of keyboard range" x)))))

(define (reg-set! x val)
  (if (reg-ref x)
      (begin (hash-set! registers x val) val)
      (error "keys: failed to reg-set! ~s" x)))

(define reg-push
  (lambda ()
    (set! saved-registers (cons registers saved-registers))
    (set! registers (make-hash))
    ;(println temp-registers)
    ))

(define reg-pop
  (lambda ()
    (set! registers (car saved-registers))
    (set! saved-registers (cdr saved-registers))
    ;(println registers)
    ))