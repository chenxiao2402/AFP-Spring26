#lang racket
(require "keys.rkt"
         "commands.rkt")
(provide interp)


(define state 'NONE)
(define result 0)

(define (interp-arith args)
  (let ([op (match state
              ['CMD_ADD +]
              ['CMD_SUB -]
              ['CMD_MUL *]
              ['CMD_DIV /]
              [else (error "Interp error: Invalid command passed to (interp-arith)")])])
    (set! result (apply op (for/list ([e args]) (reg-ref e))))))

(define (interp-result args)
  (begin
    (for/list ([e args]) (reg-set! e result))
    (set! result 0)))

(define (interp-assign args)
  (set! result (reg-ref (car args))))

(define (interp-print args)
  (match state
    ['CMD_PRINT_INT
     (println (for/list ([reg args]) (reg-ref reg)))]
    ['CMD_PRINT_CHAR
     (println (list->string (for/list ([reg args]) (integer->char (reg-ref reg)))))]))

(define (interp-set args)
  (match state
    ['CMD_ESTABLISH
     (for/list ([a args]) (reg-set! a 1))]
    ['CMD_RESET
     (for/list ([a args]) (reg-set! a 0))]))

(define (interp insts)
  (for/list ([inst insts])
    (match state
      ['NONE
       (set! state (hash-ref chord2cmd inst))]
      ['RESULT
       (interp-result inst)
       (set! state 'NONE)]
      [(or 'CMD_ESTABLISH 'CMD_RESET)
       (interp-set inst)
       (set! state 'NONE)]
      [(or 'CMD_ADD 'CMD_SUB 'CMD_MUL 'CMD_DIV)
       (interp-arith inst)
       (set! state 'RESULT)]
      [(or 'CMD_ASSIGN)
       (interp-assign inst)
       (set! state 'RESULT)]
      [(or 'CMD_PRINT_INT 'CMD_PRINT_CHAR)
       (interp-print inst)
       (set! state 'NONE)]))
  (void))