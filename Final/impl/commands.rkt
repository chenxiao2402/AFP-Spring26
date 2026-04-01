#lang racket

(require "keys.rkt")



(define chord2cmd
  (make-hash
    '(((A1 A2 A3) . CMD_ADD)
      ((A1 A2 A4) . CMD_SUB)
      ((A1 A2 A5) . CMD_MUL)
      ((A1 A2 A6) . CMD_DIV)
      ((A1 A2 A7) . CMD_ASSIGN)

      ((A1 A2 A8) . CMD_PRINT_INT)
      ((A1 A2 A9) . CMD_PRINT_CHAR))))


(define (decode-id chord #:key-signature [key-sig #f])
  (for/list ([k chord]) (hash-ref key-values k)))


(define (decode-value chord #:key-signature [key-sig #f])
  (for/sum ([k chord]) (hash-ref key-values k)))


(provide chord2cmd decode-id decode-value)