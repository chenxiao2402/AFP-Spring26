#lang racket
(require "tools.rkt")
(provide
 chord-to-command
 chord-to-cond
 add-func
 get-func
 push-func
 pop-func)

(define basic-instruction-set
  (make-hash
    '(((A1 A2 A3) . CMD_ADD)
      ((A1 A2 A4) . CMD_SUB)
      ((A1 A2 A5) . CMD_MUL)
      ((A1 A2 A6) . CMD_DIV)

      ((E3 E4 E5) . CMD_ESTABLISH)
      ((A5 A6 A7) . CMD_RESET)
      ((A1 A2 A7) . CMD_ASSIGN)

      ((A1 A2 A8) . CMD_PRINT_INT)
      ((A1 A2 A9) . CMD_PRINT_CHAR)

      ((F1 F2 F3) . CMD_START_FUNC_DEF)
      ((F2 F3 F4) . CMD_END_FUNC_DEF)


      ((B1 B2 B3) . CMD_WHILE)
      ((B2 B3 B4) . CMD_WHILE_BODY)
      ((B3 B4 B5) . CMD_END_WHILE)

      ((C1 C2 C3) . CMD_IF)
      ((C4 C5 C6) . CMD_END_IF)

      ((C1 C2 E3) . CMD_IF_ZERO)
      ((C2 C3 C4) . CMD_THEN)
      ((C3 C4 C5) . CMD_ELSE)
      ((C4 C5 E6) . CMD_END_IF_ZERO))))

(define function-stack (cons (make-hash) empty))

; pushing functions takes a "base" which is the called function
; this way functions can reference themselves ie recursion
(define (push-func base)
  (set! function-stack (cons (make-hash (list base)) function-stack)))

(define (pop-func)
  (set! function-stack (cdr function-stack)))

(define (add-func inst func)
  (println func)
  (hash-set! (car function-stack) inst func))

(define (get-func inst)
  (hash-ref (car function-stack) inst))

(define (chord-to-command inst)
  (hash-ref
   basic-instruction-set
   inst
   (lambda () (check-for-custom inst))))

(define (chord-to-cond inst)
  (hash-ref
   (make-hash
    '(((C1 C2) . COND_LESS_THAN)
      ((C2 C3) . COND_GREATER_THAN)
      ((C4 C5) . COND_EQUAL)
      ((C6 C7) . COND_LESS_THAN_EQUAL)
      ((C8 C1) . COND_GREATER_THAN_EQUAL)))
   inst))
     

(define (check-for-custom inst)
  (if (hash-ref (car function-stack) inst #f)
      'FUNCTION_CALL
      #f))
   

