;; a.rkt
#lang racket
(require (for-syntax syntax/parse racket/match ))
(provide (rename-out [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%module-begin))


(begin-for-syntax
  (define (subst bdy var rhs)
    (let loop ([stx bdy])
      (syntax-parse stx
        [x2:id #:when (free-identifier=? #'x2 var) rhs]
        [(f arg ...)
         (datum->syntax stx
           (for/list ([i (syntax->list stx)])
             (loop i))
           stx)]
        [_ stx])))
  
  (define (number-list? lst)
    (and (list? lst)
         (for/and ([x lst]) (number? x))))

  (define-syntax-class exp #:datum-literals (+ - * / let-values Whatever let lambda)
    ; Lab 5: Adding-zero Elimination
    (pattern (+ a 0)
      #:with code (if (number? (syntax->datum #'a)) #'a #'(+ a 0)))
    
    (pattern (+ 0 a)
      #:with code (if (number? (syntax->datum #'a)) #'a #'(+ 0 a)))
    
    ; Lab 5: Let-Values Elimination
    (pattern (let-values ([a] e) b)
      #:when (begin
               (when #f (println (syntax->datum #'a)) (println (syntax->datum #'b)))
               (eqv? (syntax->datum #'a) (syntax->datum #'b)))
      #:with code #'e)


    ; Assignment 5, Q1: Constant Propagation
    (pattern (let ([var:id rhs:number]) b)
      #:with code (syntax-parse (subst #'b #'var #'rhs)
                    [e:exp #'e.code]))

    ; Assignment 5, Q2: Redundant Variable Elimination
    (pattern (let ([var:id rhs:id]) b)
      #:with code (syntax-parse (subst #'b #'var #'rhs)
                    [e:exp #'e.code]))

    ; Assignment 5, Q3: Constant Folding
    (pattern (op a:exp ...)
      #:when (memv (syntax->datum #'op) '(+ - * /))
      #:with code (let ([args (map syntax->datum (syntax->list #'(a.code ...)))])
                    (cond
                      [(number-list? args)
                       (define rator (match (syntax->datum #'op)
                                       ['+ +]
                                       ['- -]
                                       ['* *]
                                       ['/ /]))
                       (datum->syntax #'here (apply rator args))]
                      [else #'(op a.code ...)])))
  
  

    ; Assignment 5, Q4: Lambda to Let
    (pattern ((lambda (var:id) body) arg)
      #:with code (syntax-parse #'(let ([var arg]) body)
                    [e:exp #'e.code]))


    (pattern Whatever #:with code #'(void))
    (pattern (cmd:exp arg:exp ...) #:with code #'(cmd.code arg.code ...))
    (pattern a #:with code #'a)))



(define-syntax (my-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     #'(#%plain-module-begin
        (handle-form form) ...
        (displayln ""))]))

(define-syntax (handle-form stx)
  (syntax-parse stx #:datum-literals (require provide)
    [(_ (require arg ...))
     #'(require arg ...)]
    [(_ (provide arg ...))
     #'(provide arg ...)]
    [(_ aa:exp)
      #'(begin
              (displayln "")
              (display "orignal expr: ")
              (displayln (syntax->datum (syntax aa)))
              (display "optimized expr: ")
              (displayln (syntax->datum (syntax aa.code)))
              (let ([result aa.code])
                (when (not (void? result))
                  (displayln result))))]
    [(_ other) #'other]))

