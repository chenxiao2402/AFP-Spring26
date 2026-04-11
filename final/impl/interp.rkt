#lang racket
(require "keys.rkt"
         "commands.rkt")
(provide interp)


(define state 'NONE)
(define result 0)
(define functions (make-hash))
(define whiles (make-hash))

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




(define (interp-zero? args)
  (match state
    ['CMD_IF_ZERO
     (define iszero (for/and ([a args]) (zero? (reg-ref a))))
     (set! state (if iszero 'CMD_THEN 'CMD_ELSE))]))

(define (extract-then-else-tail insts)
  (define (extract-branch insts branch-count branch-name next-branch-name branch)
    (match insts
      ['() (values branch '())]
      [(cons inst rest)
       ;;;  (printf "Inst: ~a, Cmd: ~a, branch-name: ~a, next-branch-name: ~a\n"
       ;;;          inst (hash-ref chord2cmd inst #f) branch-name next-branch-name)
       (cond
         [(equal? (hash-ref chord2cmd inst #f) branch-name)
          (extract-branch rest (add1 branch-count) branch-name next-branch-name
                          (append branch (list inst)))]
         [(equal? (hash-ref chord2cmd inst #f) next-branch-name)
          (if (= branch-count 0)
              (values branch rest)
              (extract-branch rest (sub1 branch-count) branch-name next-branch-name
                              (append branch (list inst))))]
         [else
          (extract-branch rest branch-count branch-name next-branch-name
                          (append branch (list inst)))])]
      ))
  (define-values (thn rest) (extract-branch (cdr insts) 0 'CMD_THEN 'CMD_ELSE '()))
  (define-values (els tail) (extract-branch rest 0 'CMD_ELSE 'CMD_END_IF_ZERO '()))
  ;;; (printf "Extracted THEN branch: ~a\n" thn)
  ;;; (printf "Extracted ELSE branch: ~a\n" els)
  ;;; (printf "Remaining tail: ~a\n" tail)
  (values thn els tail)
  )





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
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['NONE
        (set! state (hash-ref chord2cmd inst))
        (interp rest)]
       ['RESULT
        (interp-result inst)
        (set! state 'NONE)
        (interp rest)]
       [(or 'CMD_ESTABLISH 'CMD_RESET)
        (interp-set inst)
        (set! state 'NONE)
        (interp rest)]
       [(or 'CMD_ADD 'CMD_SUB 'CMD_MUL 'CMD_DIV)
        (interp-arith inst)
        (set! state 'RESULT)
        (interp rest)]
       [(or 'CMD_ASSIGN)
        (interp-assign inst)
        (set! state 'RESULT)
        (interp rest)]
       [(or 'CMD_PRINT_INT 'CMD_PRINT_CHAR)
        (interp-print inst)
        (set! state 'NONE)
        (interp rest)]

       ['CMD_IF_ZERO
        (interp-zero? inst)
        (let-values ([(thn els tail) (extract-then-else-tail rest)])
          (match state
            ['CMD_THEN
             (set! state 'NONE)
             (interp (append thn tail))]
            ['CMD_ELSE
             (set! state 'NONE)
             (interp (append els tail))]
            [_ (error "Interp error: Invalid state after CMD_IF_ZERO")]))]

       ; function definitions
       ['CMD_START_FUNC_DEF ; set an entry in the functions hash-map with the instruction as a name
        (hash-set! functions inst empty)
        (set! state (cons 'DEF_FUNC_ARGS inst))
        ;(println functions)
        (interp rest)]
       [(cons 'DEF_FUNC_ARGS func-name)
        (hash-set! functions func-name (Function inst empty empty))
        (set! state (cons 'DEF_FUNC_BODY func-name))
        ;(println functions)
        (interp rest)]
       [(cons 'DEF_FUNC_BODY func-name)
        (if (eqv? (hash-ref chord2cmd inst #f) 'CMD_END_FUNC_DEF)
            (set! state (cons 'DEF_FUNC_RETURN func-name))
            (let ([ref (hash-ref functions func-name)])
              (let ([new-instructions (append (Function-instructions ref) (list inst))])
                (hash-set! functions func-name (Function (Function-args ref) new-instructions empty)))))
        ;(println functions)
        (interp rest)
        ]
       [(cons 'DEF_FUNC_RETURN func-name)
        (define ref (hash-ref functions func-name))
        (hash-set! functions func-name (Function (Function-args ref) (Function-instructions ref) inst))
        (hash-set! chord2cmd func-name (cons 'CUSTOM_FUNCTION func-name))
        (set! state 'NONE)
        ;(println functions)
        ;(println chord2cmd)
        (interp rest)
        ]
       ; function calling
       [(cons 'CUSTOM_FUNCTION func-name)
        ;(print func-name)
        ;(println " called !!")
        (handle-function-calls func-name inst)
        (set! state 'RESULT)
        (interp rest)]

       )]))

    