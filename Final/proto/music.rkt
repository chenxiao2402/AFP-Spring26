#lang racket

(provide flat registers state stave quarter-rest half-rest play chord sharp)

(define registers (make-hash))

(define setup
  (lambda ()
    (hash-set! registers "A4" 0)
    (hash-set! registers "B4" 0)
    (hash-set! registers "C4" 0)
    (hash-set! registers "D4" 0)
    (hash-set! registers "E4" 0)
    (hash-set! registers "F4" 0)
    (hash-set! registers "G4" 0)
    (hash-set! registers "A5" 0)
    (hash-set! registers "B5" 0)
    (hash-set! registers "C5" 0)
    (hash-set! registers "D5" 0)
    (hash-set! registers "E5" 0)
    (hash-set! registers "F5" 0)
    (hash-set! registers "G5" 0)
    (hash-set! registers "A6" 0)
    (hash-set! registers "B6" 0)
    (hash-set! registers "C6" 0)
    (hash-set! registers "D6" 0)
    (hash-set! registers "B6" 0)
    (hash-set! registers "F6" 0)
    (hash-set! registers "G6" 0)))

(define chord
  (lambda (x . rs)
    (append (list x) rs)))

(define stave
  (lambda (x . rs)
    (begin
      x
      rs
      (void))))

(define state "FIN")

(define quarter-rest "quarterrest")
(define half-rest "halfrest")

(define output-buffer "")

(define check-for-io
  (lambda (x)
    (if (eqv? x quarter-rest)
        (display output-buffer)
        #f)))

(define add-list
  (lambda (x)
    (define output 0)
    (for/list ([e x])
      (set! output (+ output (hash-ref registers e))))
    ; (println output)
    output))

(define sub-list
  (lambda (x)
    (define output (car x))
    (for/list ([e (cdr x)])
      (set! output (- output (hash-ref registers e))))
    ; (println output)
    output))

(define mul-list
  (lambda (x)
    (define output 1)
    (for/list ([e x])
      (set! output (* output (hash-ref registers e))))
    ; (println output)
    output))

(define sum-into-buffer
  (lambda (x)
    (for/list ([e x])
      (set! output-buffer (string-append output-buffer (string (integer->char (hash-ref registers e))))))
    (void)))

(define out-val 0)

(define play
  (lambda (x)
    (if (check-for-io x)
        (void)
        (if (eqv? state "FIN")
            (match x
              ['("A3" "B3")
               (set! state "ADD")]
              ['("A3" "C3")
               (set! state "SUB")]
              ['("A3" "D3")
               (set! state "MUL")]
              ['("A3" "E3")
               (set! state "PRINT")]
              [else
               (void)])
            (match state
              ["OUT"
               (hash-set! registers x out-val)
               (set! state "FIN")]
              ["ADD"
               (set! out-val (add-list x))
               (set! state "OUT")]
              ["MUL"
               (set! out-val (mul-list x))
               (set! state "OUT")]
              ["SUB"
               (set! out-val (sub-list x))
               (set! state "OUT")]
              ["PRINT"
               (sum-into-buffer x)
               (set! state "FIN")])))))

(define sharp
  (lambda (x)
    (hash-set! registers x (add1 (hash-ref registers x)))
    x))

(define flat
  (lambda (x)
    (hash-set! registers x (sub1 (hash-ref registers x)))
    x))

(setup)