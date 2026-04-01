#lang racket
(require "keys.rkt"
         "commands.rkt")
(provide interp)


(define state 'NONE)
(define result 0)
(define functions (make-hash))

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
     (for/list ([reg args]) (print (reg-ref reg)) (printf ""))
     (printf "\n")]
    ['CMD_PRINT_CHAR
     (println (list->string (for/list ([reg args]) (integer->char (reg-ref reg)))))]))

(define (interp-set args)
  (match state
    ['CMD_ESTABLISH
     (for/list ([a args]) (reg-set! a 1))]
    ['CMD_RESET
     (for/list ([a args]) (reg-set! a 0))]))


(struct Function (args instructions return) #:transparent)


(define handle-function-calls
  (lambda (func-name args)
    (define func (hash-ref functions func-name))
    (define instructions (Function-instructions func))

    ; offload current reg valus
    (define reg-list (for/list ([e args]) (reg-ref e)))
    (reg-swap-to-temp)

    ; set args to appropriate registers
    ; (println func)
    (for/list ([a1 (Function-args func)] [a2 reg-list])
      (reg-set! a1 a2))

    (set! state 'NONE)
    (interp instructions)

    (define ret (Function-return func))
    (set! result (reg-ref (car ret)))

    (reg-restore)))

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
       (set! state 'NONE)]
      ; function definitions
      ['CMD_START_FUNC_DEF ; set an entry in the functions hash-map with the instruction as a name
       (hash-set! functions inst empty)
       (set! state (cons 'DEF_FUNC_ARGS inst))
       ;(println functions)
       ]
      [(cons 'DEF_FUNC_ARGS func-name)
       (hash-set! functions func-name (Function inst empty empty))
       (set! state (cons 'DEF_FUNC_BODY func-name))
       ;(println functions)
       ]
      [(cons 'DEF_FUNC_BODY func-name)
       (if (eqv? (hash-ref chord2cmd inst #f) 'CMD_END_FUNC_DEF)
           (set! state (cons 'DEF_FUNC_RETURN func-name))
           (let ([ref (hash-ref functions func-name)])
             (let ([new-instructions (append (Function-instructions ref) (list inst))])
               (hash-set! functions func-name (Function (Function-args ref) new-instructions empty)))))
       ;(println functions)
       ]
      [(cons 'DEF_FUNC_RETURN func-name)
       (define ref (hash-ref functions func-name))
       (hash-set! functions func-name (Function (Function-args ref) (Function-instructions ref) inst))
       (hash-set! chord2cmd func-name (cons 'CUSTOM_FUNCTION func-name))
       (set! state 'NONE)
       ;(println functions)
       ;(println chord2cmd)
       ]
      ; function calling
      [(cons 'CUSTOM_FUNCTION func-name)
       ;(print func-name)
       ;(println " called !!")
       (handle-function-calls func-name inst)
       (set! state 'RESULT)]
       ))
  (void))

    