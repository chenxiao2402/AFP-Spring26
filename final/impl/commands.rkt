#lang racket
(require "tools.rkt")
(provide
 chord-to-command
 chord-to-cond
 add-func
 get-func
 push-func
 pop-func)
;                       0  1  2  3  4  5  6  7  8  9  10 11 12 13 14
(define key-signature '(C2 D2 E2 F2 G2 A3 B3 C3 D3 E3 F3 G3 A4 B4 C4))

(define basic-instruction-set
  (make-hash
    '(((0 1 2) . CMD_ADD)
      ((3 11 12) . CMD_SUB)
      ((0 2 3) . CMD_MUL)
      ((A1 A2 A6) . CMD_DIV)

      ((1 2 3) . CMD_ESTABLISH)
      ((1 4 7) . CMD_RESET)
      ((A1 A2 A7) . CMD_ASSIGN)

      ((2 3 4) . CMD_PRINT_INT)
      ((A1 A2 A9) . CMD_PRINT_CHAR)

      ((6 7 8) . CMD_START_FUNC_DEF)
      ((6 8 9) . CMD_END_FUNC_DEF)


      ((4 5 6) . CMD_WHILE)
      ((7 8 9) . CMD_WHILE_BODY)
      ((10 5 7) . CMD_END_WHILE)

      ((1 3 5) . CMD_IF)
      ((2 3 5) . CMD_THEN)
      ((3 2 5) . CMD_ELSE)
      ((4 6 7) . CMD_END_IF)

      ((C1 C2 E3) . CMD_IF_ZERO)
      ((C4 C5 E6) . CMD_END_IF_ZERO))))

(define function-stack (cons (make-hash) empty))

; pushing functions takes a "base" which is the called function
; this way functions can reference themselves ie recursion
(define (push-func base)
  (set! function-stack (cons (make-hash (list base)) function-stack)))

(define (pop-func)
  (set! function-stack (cdr function-stack)))

(define (add-func inst func)
  (when debug (println func))
  (hash-set! (car function-stack) inst func))

(define (get-func inst)
  (hash-ref (car function-stack) inst))

(define (chord-to-command inst)
  (define inst-to-num (for/list ([e inst]) (index-of key-signature e)))
  (when debug (println inst-to-num))
  (hash-ref
   basic-instruction-set
   inst-to-num
   (lambda () (check-for-custom inst))))

(define (chord-to-cond inst)
  (define inst-to-num (for/list ([e inst]) (index-of key-signature e)))
  (hash-ref
   (make-hash
    '(((1 3) . COND_LESS_THAN)
      ((2 4) . COND_GREATER_THAN)
      ((3 5) . COND_EQUAL)
      ((4 6) . COND_LESS_THAN_EQUAL)
      ((5 7) . COND_GREATER_THAN_EQUAL)))
   inst-to-num))
     

(define (check-for-custom inst)
  (when debug (println inst))
  (if (hash-ref (car function-stack) inst #f)
      'FUNCTION_CALL
      #f))
   

