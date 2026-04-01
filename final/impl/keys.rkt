#lang racket
(provide reg-ref reg-set! reg-swap-to-temp reg-restore)


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

(define temp-registers (make-hash))

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

(define reg-swap-to-temp
  (lambda ()
    (set! temp-registers registers)
    (set! registers (make-hash))
    ;(println temp-registers)
    ))

(define reg-restore
  (lambda ()
    (set! registers temp-registers)
    (set! temp-registers (make-hash))
    ;(println registers)
    ))