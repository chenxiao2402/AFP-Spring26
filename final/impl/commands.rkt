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
    '(((0 1 2) . CMD_ADD) ; (chord C2 D2 E2) ; CMD_ADD
      ((0 2 3) . CMD_SUB) ; (chord C2 E2 F2) ; CMD_SUB
      ((0 3 4) . CMD_MUL) ; (chord C2 F2 G2) ; CMD_MUL
      ((0 4 5) . CMD_DIV) ; (chord C2 G2 A3) ; CMD_DIV
      
      ((0 5 6) . CMD_BITWISE_AND) ; (chord C2 A3 B3) ; CMD_BITWISE_AND

      ((1 2 3) . CMD_ESTABLISH) ; (chord D2 E2 F2) ; CMD_ESTABLISH
      ((1 3 4) . CMD_RESET) ; (chord D2 F2 G2) ; CMD_RESET
      ((1 4 5) . CMD_ASSIGN) ; (chord D2 G2 A3) ; CMD_ASSIGN

      ((2 3 4) . CMD_PRINT_INT) ; (chord E2 F2 G2) ; CMD_PRINT_INT
      ((2 4 5) . CMD_PRINT_CHAR) ; (chord E2 G2 A3) ; CMD_PRINT_CHAR

      ((6 7 8) . CMD_START_FUNC_DEF) ; (chord B3 C3 D3) ; CMD_START_FUNC_DEF
      ((6 8 9) . CMD_END_FUNC_DEF) ; (chord B3 D3 E3) ; CMD_END_FUNC_DEF

      ((5 6 7) . CMD_WHILE) ; (chord A3 B3 C3) ; CMD_WHILE
      ((5 7 8) . CMD_WHILE_BODY) ; (chord A3 C3 D3) ; CMD_WHILE_BODY
      ((5 8 9) . CMD_END_WHILE) ; (chord A3 D3 E3) ; CMD_END_WHILE

      ((4 5 6) . CMD_IF) ; (chord G2 A3 B3) ; CMD_IF
      ((4 6 7) . CMD_THEN) ; (chord G2 B3 C3) ; CMD_THEN
      ((4 7 8) . CMD_ELSE) ; (chord G2 C3 D3) ; CMD_ELSE
      ((4 8 9) . CMD_END_IF) ; (chord G2 D3 E3) ; CMD_END_IF

      ((C1 C2 E3) . CMD_IF_ZERO) ; (chord _)
      ((C4 C5 E6) . CMD_END_IF_ZERO)))) ; (chord _)

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
    '(((0 1) . COND_LESS_THAN) ; (chord C2 D2) ; COND_LESS_THAN
      ((0 2) . COND_GREATER_THAN) ; (chord C2 E2) ; COND_GREATER_THAN
      ((0 3) . COND_EQUAL) ; (chord C2 F2) ; COND_EQUAL
      ((0 4) . COND_LESS_THAN_EQUAL) ; (chord C2 G2)
      ((0 5) . COND_GREATER_THAN_EQUAL))) ; (chord C2 A3)
   inst-to-num))
     

(define (check-for-custom inst)
  (when debug (println inst))
  (if (hash-ref (car function-stack) inst #f)
      'FUNCTION_CALL
      #f))
   

