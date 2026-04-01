#lang racket

(require "keys.rkt"
         "commands.rkt")





(define (interp-arith op insts kont)
  (define (arith-op op operands)
    (let ([aop (match op
                 ['ARITH_ADD +]
                 ['ARITH_SUB -]
                 ['ARITH_MUL *]
                 ['ARITH_DIV /])])
      (apply aop (for/list ([reg operands]) (hash-ref registers reg)))))

  (match op
    [(or 'ARITH_ADD 'ARITH_SUB 'ARITH_MUL 'ARITH_DIV)
     (match insts
       [(cons (list a b) rest)
        (let ([result (arith-op op (list a b))])
          (interp-arith `(ARITH_ASSIGN ,result) rest kont))]
       [_ (error "Eval Error: Invalid operands for arithmetic operation.")])]
    [`(ARITH_ASSIGN ,val)
     (match insts
       [(cons (list reg) rest)
        (hash-set! registers reg val)
        (kont rest)]
       [_ (error "Eval Error: Invalid result register for arithmetic operation.")])]))


(define (interp-assign op insts kont)
  (match op
    ['ASSIGN_REG
     (match insts
       [(cons (list reg) rest)
        (interp-assign `(ASSIGN_VAL ,reg) rest kont)]
       [else (error "Eval Error: Invalid register for assignment.")])]
    [`(ASSIGN_VAL ,reg)
     (match insts
       [(cons chord rest) #:when (integer? (decode-value chord))
        (hash-set! registers reg (decode-value chord))
        (kont rest)]
       [else (error "Eval Error: Invalid operands for assignment.")])]
    ))

(define (interp-print op insts kont)
  (match op
    ['PRINT_INT
     (match insts
       [(cons (list reg) rest)
        (printf "~a\n" (hash-ref registers reg))
        (kont rest)]
       [else (error "Eval Error: Invalid register for print operation.")])]
    ['PRINT_CHAR
     (match insts
       [(cons (list reg) rest)
        (printf "~a" (integer->char (hash-ref registers reg)))
        (kont rest)]
       [else (error "Eval Error: Invalid register for print operation.")])]))


;; eval-cps : Expression (Value -> Value) -> Value
(define (interp insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match (hash-ref chord2cmd inst #f)
       ['CMD_ADD (interp-arith 'ARITH_ADD rest interp)]
       ['CMD_SUB (interp-arith 'ARITH_SUB rest interp)]
       ['CMD_MUL (interp-arith 'ARITH_MUL rest interp)]
       ['CMD_DIV (interp-arith 'ARITH_DIV rest interp)]
       ['CMD_ASSIGN (interp-assign 'ASSIGN_REG rest interp)]
       ['CMD_PRINT_INT (interp-print 'PRINT_INT rest interp)]
       ['CMD_PRINT_CHAR (interp-print 'PRINT_CHAR rest interp)])]))


(provide interp)