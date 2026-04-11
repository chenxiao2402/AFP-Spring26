#lang racket
(require "keys.rkt")
(provide chord2cmd decode-id decode-value)


(define chord2cmd
  (make-hash
    '(((A1 A2 A3) . CMD_ADD)
      ((A1 A2 A4) . CMD_SUB)
      ((A1 A2 A5) . CMD_MUL)
      ((A1 A2 A6) . CMD_DIV)
      ((A1 A2 A7) . CMD_ASSIGN)

      ((A3 A4 A5) . CMD_ESTABLISH)
      ((A5 A6 A7) . CMD_RESET)

      ((A1 A2 A8) . CMD_PRINT_INT)
      ((A1 A2 A9) . CMD_PRINT_CHAR)

      ((F1 F2 F3) . CMD_START_FUNC_DEF)
      ((F2 F3 F4) . CMD_END_FUNC_DEF)


      ((B1 B2 B3) . CMD_START_WHILE)
      ((B2 B3 B4) . CMD_END_WHILE)

      ((C1 C2 C3) . CMD_IF_ZERO)
      ((C2 C3 C4) . CMD_THEN)
      ((C3 C4 C5) . CMD_ELSE)
      ((C4 C5 C6) . CMD_END_IF_ZERO)

      )))

(define (decode-id chord #:key-signature [key-sig #f])
  (for/list ([k chord]) (reg-ref k)))

(define (decode-value chord #:key-signature [key-sig #f])
  (for/sum ([k chord]) (reg-ref k)))
