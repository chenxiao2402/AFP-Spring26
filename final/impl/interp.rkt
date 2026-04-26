#lang racket
(require "keys.rkt"
         "commands.rkt"
         "tools.rkt")
(provide interp)

(define state 'NONE)
(define result 0)


;;;
; BASE INTERPRETER
;;;

(define called-function empty)

(define (set-state inst)
  (let ([temp (chord-to-command inst)])
    (when (eqv? temp 'FUNCTION_CALL)
        (set! called-function inst))
    (set! state temp)))

(define (interp insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['NONE
        (set-state inst)
        (interp rest)]
       [(or 'RESULT 'CMD_ESTABLISH 'CMD_RESET 'CMD_ASSIGN)
        (interp-set insts)]
       [(or 'CMD_ADD 'CMD_SUB 'CMD_MUL 'CMD_DIV)
        (interp-arith insts)]
       [(or 'CMD_START_FUNC_DEF 'FUNCTION_CALL)
        (interp-func insts 0)]
       [(or 'CMD_PRINT_INT 'CMD_PRINT_CHAR)
        (interp-print insts)]
       [(or 'CMD_IF)
        (interp-cond insts (Cond empty empty empty) 0)]
       [(or 'CMD_WHILE)
        (interp-while insts (While empty empty) 0)]

       
       [else
        (error state)])]))


;;;
; PRINTING
;;;

(define (interp-print insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_PRINT_INT
        (for/list ([reg inst]) (print (reg-ref reg)) (printf ""))
        (printf "\n")
        (set! state 'NONE)
        (interp rest)]
       ['CMD_PRINT_CHAR
        (println (list->string (for/list ([reg inst]) (integer->char (reg-ref reg)))))
        (set! state 'NONE)
        (interp rest)])]))


;;;
; VARIABLES
;;;

(define (var-set-regs inst val)
  (for/list ([reg inst]) (reg-set! reg val)))

(define (interp-set insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ; set var(s) to the value in `result`
       ['RESULT
        (var-set-regs inst result)
        (set! state 'NONE)
        (interp rest)]
       ; set var(s) to 1
       ['CMD_ESTABLISH
        (var-set-regs inst 1)
        (set! state 'NONE)
        (interp rest)]
       ; set var(s) to 0
       ['CMD_RESET
        (var-set-regs inst 0)
        (set! state 'NONE)
        (interp rest)]
       ; set result to var
       ['CMD_ASSIGN
        (set! result (reg-ref (car inst)))
        (set! state 'RESULT)
        (interp rest)])]))


;;;
; ARITHMETIC
;;;

(define (arith-set-result inst op)
  (set! result (apply op (for/list ([reg inst]) (reg-ref reg)))))

(define (interp-arith insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_ADD
        (arith-set-result inst +)
        (set! state 'RESULT)
        (interp rest)]
       ['CMD_SUB
        (arith-set-result inst -)
        (set! state 'RESULT)
        (interp rest)]
       ['CMD_MUL
        (arith-set-result inst *)
        (set! state 'RESULT)
        (interp rest)]
       ['CMD_DIV
        (arith-set-result inst /)
        (set! state 'RESULT)
        (interp rest)])]))


;;;
; FUNCTIONS
;;;

(struct Func (args insts ret) #:transparent #:mutable)

(define curr-func-name empty)
(define curr-func-args empty)
(define curr-func-insts empty)
(define curr-func-ret empty)

(define (create-function)
  (add-func curr-func-name (Func curr-func-args (reverse curr-func-insts) curr-func-ret))
  (set! curr-func-name empty)
  (set! curr-func-args empty)
  (set! curr-func-insts empty)
  (set! curr-func-ret empty))

(define handle-function-calls
  (lambda (inst)
    (define function (get-func called-function))
    (define function-instructions (Func-insts function))
    ; push current reg values and save relevant values for args
    (define saved-regs (for/list ([reg inst]) (reg-ref reg)))
    (reg-push)
    (push-func (cons called-function function))
    (for/list ([arg (Func-args function)] [reg saved-regs])
      (reg-set! arg reg))
    ; interp function body
    (set! state 'NONE)
    (when debug (println function-instructions))
    (interp function-instructions)
    ; get return value
    (define return-reg (Func-ret function))
    (set! result (reg-ref (car return-reg)))
    ; restore state
    (pop-func)
    (reg-pop)))

(define (interp-func insts index)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_START_FUNC_DEF
        (when debug (println "START FUNCTION DEF"))
        (set! curr-func-name inst)
        (set! state 'DEF_FUNC_ARGS)
        ; (set! func-index (add1 func-index))
        (interp-func rest index)]
       ['DEF_FUNC_ARGS
        (when debug (println "START FUNCTION ARGS DEF"))
        (set! curr-func-args inst)
        (set! state 'DEF_FUNC_BODY)
        (interp-func rest index)]
       ['DEF_FUNC_BODY
        (define current-index index)

        (when (eqv? (chord-to-command inst) 'CMD_START_FUNC_DEF) (set! index (add1 current-index)))
        (when (eqv? (chord-to-command inst) 'CMD_END_FUNC_DEF) (set! index (sub1 current-index)))
        
        (if (and (eqv? (chord-to-command inst) 'CMD_END_FUNC_DEF) (zero? current-index))
            (begin
              (set! state 'DEF_FUNC_RETURN)
              (interp-func rest index))
            (begin
              (set! curr-func-insts (cons inst curr-func-insts))
              (interp-func rest index)))]
       ['DEF_FUNC_RETURN
        (set! curr-func-ret inst)
        (create-function)
        (set! state 'NONE)
        (interp rest)]
       ['FUNCTION_CALL
        (handle-function-calls inst)
        (set! state 'RESULT)
        (interp rest)])]))


;;;
; CONDITIONALS
;;;

(struct Cond (cond then else) #:transparent #:mutable)

(define (cond-get-result cond)
  (let ([cond-set-result (lambda (inst op) (set! result (if (apply op (for/list ([reg inst]) (reg-ref reg))) 0 1)))]
        [cond-state (chord-to-cond (car (Cond-cond cond)))]
        [cond-inst (car (cdr (Cond-cond cond)))])
    (match cond-state
      ['COND_EQUAL
        (cond-set-result cond-inst =)]
       ['COND_LESS_THAN
        (cond-set-result cond-inst <)]
       ['COND_GREATER_THAN
        (cond-set-result cond-inst >)]
       ['COND_LESS_THAN_EQUAL
        (cond-set-result cond-inst <=)]
       ['COND_GREATER_THAN_EQUAL
        (cond-set-result cond-inst >=)])))

(define (interp-cond insts cond index)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_IF
        (set! state 'DEF_COND_TYPE)
        (interp-cond insts cond index)]
       ['DEF_COND_TYPE
        (define cond-cond (Cond-cond cond))
        (if (eqv? (chord-to-command inst) 'CMD_THEN)
            (begin
              (when debug (println "Switching to THEN!"))
              (set! state 'DEF_COND_THEN)
              (interp-cond rest cond index))
            (begin
              (set-Cond-cond! cond (append cond-cond (list inst)))
              (interp-cond rest cond index)))]
       ['DEF_COND_THEN
        (define cond-then (Cond-then cond))

        (define current-index index)

        (when (eqv? (chord-to-command inst) 'CMD_IF) (set! index (add1 current-index)))
        (when (eqv? (chord-to-command inst) 'CMD_END_IF) (set! index (sub1 current-index)))

        (if (and (eqv? (chord-to-command inst) 'CMD_ELSE) (zero? current-index))
            (begin
              (when debug (println "Switching to ELSE!"))
              (set! state 'DEF_COND_ELSE)
              (interp-cond rest cond index))
            (begin
              (set-Cond-then! cond (append cond-then (list inst)))
              (interp-cond rest cond index)))]
       ['DEF_COND_ELSE
        (define cond-else (Cond-else cond))

        (define current-index index)

        (when (eqv? (chord-to-command inst) 'CMD_IF) (set! index (add1 current-index)))
        (when (eqv? (chord-to-command inst) 'CMD_END_IF) (set! index (sub1 current-index)))

        (if (and (eqv? (chord-to-command inst) 'CMD_END_IF) (zero? current-index))
            (begin
              (when debug (println "Switching to END!"))
              (set! state 'EXECUTE_COND)
              (interp-cond insts cond index))
            (begin
              (set-Cond-else! cond (append cond-else (list inst)))
              (interp-cond rest cond index)))]
       ['EXECUTE_COND
        (when debug (println "heyo"))
        (when debug (println cond))
        (cond-get-result cond)
        (when debug (println result))
        (set! state 'NONE)
        (if (zero? result)
            (interp (Cond-then cond))
            (interp (Cond-else cond)))
        (interp rest)])]))


;;;
; WHILE LOOPS
;;;

(define whiles '())
(struct While (cond body) #:transparent #:mutable)

(define (while-get-result cond)
  (let ([while-set-result (lambda (inst op) (set! result (if (apply op (for/list ([reg inst]) (reg-ref reg))) 0 1)))]
        [cond-state (chord-to-cond (car (While-cond cond)))]
        [cond-inst (car (cdr (While-cond cond)))])
    (match cond-state
      ['COND_EQUAL
        (while-set-result cond-inst =)]
       ['COND_LESS_THAN
        (while-set-result cond-inst <)]
       ['COND_GREATER_THAN
        (while-set-result cond-inst >)]
       ['COND_LESS_THAN_EQUAL
        (while-set-result cond-inst <=)]
       ['COND_GREATER_THAN_EQUAL
        (while-set-result cond-inst >=)])))

(define (execute-while while)
  (while-get-result while)
  (if (zero? result)
      (begin
        (set! state 'NONE)
        (interp (While-body while))
        (execute-while while))
      (void)))

(define (interp-while insts while index)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_WHILE
        (set! state 'DEF_WHILE_COND)
        (interp-while insts while index)]
       ['DEF_WHILE_COND
        (define while-cond (While-cond while))
        (if (eqv? (chord-to-command inst) 'CMD_WHILE_BODY)
            (begin
              (when debug (println "Switching to BODY!"))
              (set! state 'DEF_WHILE_BODY)
              (interp-while rest while index))
            (begin
              (when debug (println "Defining while cond"))
              (set-While-cond! while (append while-cond (list inst)))
              (interp-while rest while index)))]
       ['DEF_WHILE_BODY
        (define while-body (While-body while))
        
        (define current-index index)
        (when (eqv? (chord-to-command inst) 'CMD_WHILE) (set! index (add1 current-index)))
        (when (eqv? (chord-to-command inst) 'CMD_END_WHILE) (set! index (sub1 current-index)))
            
        (if (and (eqv? (chord-to-command inst) 'CMD_END_WHILE) (zero? current-index))
            (begin
              (when debug (println "Executing WHILE!"))
              (set! state 'EXECUTE_WHILE)
              (interp-while insts while index))
            (begin
              (set-While-body! while (append while-body (list inst)))
              (interp-while rest while index)))]
       ['EXECUTE_WHILE
        (when debug (println while))
        (execute-while while)
        (interp rest)])]))

    