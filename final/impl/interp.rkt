#lang racket
(require "keys.rkt"
         "commands.rkt"
         "tools.rkt")
(provide interp)

(define state 'NONE)
(define result 0)
(define whiles '())

(define (extract-branch insts branch-count branch-name next-branch-name branch)
  (match insts
    ['() (values branch '())]
    [(cons inst rest)
       (printf "Inst: ~a, Cmd: ~a, branch-name: ~a, next-branch-name: ~a\n"
               inst (hash-ref chord-to-command inst #f) branch-name next-branch-name)
     (cond
       [(equal? (hash-ref chord-to-command inst #f) branch-name)
        (extract-branch rest (add1 branch-count) branch-name next-branch-name
                        (append branch (list inst)))]
       [(equal? (hash-ref chord-to-command inst #f) next-branch-name)
        (if (= branch-count 0)
            (values branch rest)
            (extract-branch rest (sub1 branch-count) branch-name next-branch-name
                            (append branch (list inst))))]
       [else
        (extract-branch rest branch-count branch-name next-branch-name
                        (append branch (list inst)))])]))

(define (interp-if-zero args)
  (match state
    ['CMD_IF_ZERO
     (define iszero (for/and ([a args]) (zero? (reg-ref a))))
     (set! state (if iszero 'CMD_THEN 'CMD_ELSE))]))

(define (extract-then-else-tail insts)

  (define-values (thn rest) (extract-branch (cdr insts) 0 'CMD_THEN 'CMD_ELSE '()))
  (define-values (els tail) (extract-branch rest 0 'CMD_ELSE 'CMD_END_IF_ZERO '()))
  ;;; (printf "Extracted THEN branch: ~a\n" thn)
  ;;; (printf "Extracted ELSE branch: ~a\n" els)
  ;;; (printf "Remaining tail: ~a\n" tail)
  (values thn els tail))

(define (interp-while args insts)

  (define iszero (for/and ([a args]) (zero? (reg-ref a))))
  (define (add-new-while)
    (set! whiles (cons (cons args (cdr insts)) whiles))
    (cdr insts))
  (define (skip-new-while)
    (define-values (_ rest) (extract-branch insts 0
                                            'CMD_WHILE
                                            'CMD_END_WHILE '()))
    rest)
  (define (loop-cur-while)
    (cdr (car whiles)))
  (define (exit-cur-while)
    (set! whiles (cdr whiles))
    insts)

  ;;; (printf "While condition args: ~a, iszero: ~a\n" args iszero)
  ;;; (printf "Current state: ~a\n" state)
  ;;; (printf "Insts : ~a\n" insts)
  (cond
    [(and (not iszero) (equal? state 'CMD_WHILE))

     (add-new-while)]
    [(and iszero (equal? state 'CMD_WHILE))
     (skip-new-while)]
    [(and (not iszero) (equal? state 'CMD_END_WHILE))
     (loop-cur-while)]
    [(and iszero (equal? state 'CMD_END_WHILE))
     (exit-cur-while)]

    ))









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
        (interp-func insts)]
       [(or 'CMD_PRINT_INT 'CMD_PRINT_CHAR)
        (interp-print insts)]
       [(or 'CMD_IF)
        (interp-cond insts)]

       
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

(struct Func (args insts ret) #:transparent)

(define curr-func-name empty)
(define curr-func-args empty)
(define curr-func-insts empty)
(define curr-func-ret empty)

(define func-index 0)

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
    (println function-instructions)
    (interp function-instructions)
    ; get return value
    (define return-reg (Func-ret function))
    (set! result (reg-ref (car return-reg)))
    ; restore state
    (pop-func)
    (reg-pop)))

(define (interp-func insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_START_FUNC_DEF
        (set! curr-func-name inst)
        (set! state 'DEF_FUNC_ARGS)
        ; (set! func-index (add1 func-index))
        (interp-func rest)]
       ['DEF_FUNC_ARGS
        (set! curr-func-args inst)
        (set! state 'DEF_FUNC_BODY)
        (interp-func rest)]
       ['DEF_FUNC_BODY
        (if (eqv? (chord-to-command inst) 'CMD_END_FUNC_DEF)
            (if (zero? func-index)
                (set! state 'DEF_FUNC_RETURN)
                (begin
                  (set! curr-func-insts (cons inst curr-func-insts))
                  (set! func-index (sub1 func-index))))
            (set! curr-func-insts (cons inst curr-func-insts)))
        (when (eqv? (chord-to-command inst) 'CMD_START_FUNC_DEF) (set! func-index (add1 func-index)))
        (interp-func rest)]
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

(define extract-then
  (lambda (insts index)
    (match insts
      ['() empty]
      [(cons inst rest)
       (match (chord-to-command inst)
         ['CMD_THEN
          (if (zero? index)
              (extract-then rest index)
              (cons inst (extract-then rest index)))]
         ['CMD_IF
          (cons inst (extract-then rest (add1 index)))]
         ['CMD_ELSE
          (if (zero? index)
              '()
              (cons inst (extract-then rest index)))]
         ['CMD_END_IF
          (if (zero? index)
              '()
              (cons inst (extract-then rest (sub1 index))))]
         [else
          (cons inst (extract-then rest index))])])))

(define extract-else
  (lambda (insts index)
    (match insts
      ['() empty]
      [(cons inst rest)
       (match (chord-to-command inst)
         ['CMD_IF
          (extract-else rest (add1 index))]
         ['CMD_ELSE
          (if (zero? index)
              (extract-then rest 0)
              (extract-else rest index))]
         ['CMD_END_IF
          (if (zero? index)
              '()
              (cons inst (extract-else rest (sub1 index))))]
         [else
          (extract-else rest index)])])))

(define extract-tail
  (lambda (insts index)
    (match insts
      ['() empty]
      [(cons inst rest)
       (match (chord-to-command inst)
         ['CMD_IF
          (extract-tail rest (add1 index))]
         ['CMD_END_IF
          (if (zero? index)
              rest
              (extract-tail rest (sub1 index)))]
         [else
          (extract-tail rest index)])])))

(define (cond-set-result inst op)
  (set! result (if (apply op (for/list ([reg inst]) (reg-ref reg))) 0 1)))

(define (interp-cond insts)
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       ['CMD_IF
        (set! state 'DEF_COND_TYPE)
        (interp-cond insts)]
       ['DEF_COND_TYPE
        (set! state (chord-to-cond inst))
        (interp-cond rest)]
       
       ['COND_EQUAL
        (cond-set-result inst =)
        (set! state 'COND_RESULT)
        (interp-cond rest)]
       ['COND_LESS_THAN
        (cond-set-result inst <)
        (set! state 'COND_RESULT)
        (interp-cond rest)]
       ['COND_GREATER_THAN
        (cond-set-result inst >)
        (set! state 'COND_RESULT)
        (interp-cond rest)]
       ['COND_LESS_THAN_EQUAL
        (cond-set-result inst <=)
        (set! state 'COND_RESULT)
        (interp-cond rest)]
       ['COND_GREATER_THAN_EQUAL
        (cond-set-result inst >=)
        (set! state 'COND_RESULT)
        (interp-cond rest)]
        
  
       ['COND_RESULT
        (set! state 'NONE)
        (if (zero? result)
            (interp (extract-then insts 0))
            (interp (extract-else insts 0)))
        (interp (extract-tail insts 0))])]))



(define (interp-OLD insts)
  (error "oopsie")
  (match insts
    ['() (void)]
    [(cons inst rest)
     (match state
       #;
       ['NONE
        (set! state (hash-ref chord-to-command inst))
        (interp (if (equal? state 'CMD_END_WHILE)
                    insts rest))]
       ; arithmetic

       ; output

       ['CMD_IF_ZERO
        (interp-if-zero inst)
        (let-values ([(thn els tail) (extract-then-else-tail rest)])
          (match state
            ['CMD_THEN
             (set! state 'NONE)
             (interp (append thn tail))]
            ['CMD_ELSE
             (set! state 'NONE)
             (interp (append els tail))]
            [_ (error "Interp error: Invalid state after CMD_IF_ZERO")]))]

       ['CMD_WHILE
        (define new-insts (interp-while inst rest))
        (set! state 'NONE)
        ;;; (printf "while New-insts: ~a\n" new-insts)
        ;;; (printf "Current whiles stack: ~a\n" whiles)
        (interp new-insts)]
       ['CMD_END_WHILE
        (define while-cnd-args (car (car whiles)))
        (define new-insts (interp-while while-cnd-args rest))
        (set! state 'NONE)
        ;;; (printf "Endwhile New-insts: ~a\n" new-insts)
        ;;; (printf "Current whiles stack: ~a\n" whiles)
        (interp new-insts)]
       )]))

    